#!/usr/bin/env ruby

require 'timeout'
require 'thread'

MSEC_PER_SEC = 1000
SEC_PER_MIN = 60
KB_PER_MB = 1024

################################################################################
# CONFIGURATION BEGINS HERE ####################################################
################################################################################

NUM_TRIALS = 5
TIMEOUT = 15 * SEC_PER_MIN
SEC_PER_SAMPLE = 0.1

FLIX = "java -Xmx8192M -jar ../../flix/out/flix.jar"
FLIX_ARGS = ""
FLIX_ANALYSIS = "../strong-update/StrongUpdate.flix"
FLIX_FACTS = "../../flix-subench/%s.flix"
FLIX_OUT = "flix.out"

FLIX_BENCHMARKS = [
  "470.lbm",
  "181.mcf",
  "429.mcf",
  "256.bzip2",
  "462.libquantum",
  "164.gzip",
  "401.bzip2",
  "458.sjeng",
  "433.milc",
  "175.vpr",
  "186.crafty",
  "197.parser",
  "482.sphinx3",
  "300.twolf",
]
# Benchmarks that timeout on Flix
ALL_BENCHMARKS = FLIX_BENCHMARKS + [
  "456.hmmer",
  "464.h264ref",
  "255.vortex",
  "254.gap",
  "253.perlbmk",
  "445.gobmk",
  "400.perlbench",
  "176.gcc",
  "403.gcc",
]

################################################################################
# CONFIGURATION ENDS HERE ######################################################
################################################################################

# Queues for thread communication
RESULT_QUEUE = Queue.new
SIGNAL_QUEUE = Queue.new

# Global pid so we can kill it if the script is terminated.
$pid = nil

# Sample memory (RSS/RES) using ps, until we get a signal to stop.
# Keep track of the maximum memory, and return it on the queue.
def sample_mem(pid)
  max_mem = 0
  while SIGNAL_QUEUE.empty? do
    mem = `ps -o rss= -p #{pid}`
    max_mem = mem.to_i if mem.to_i > max_mem
    sleep SEC_PER_SAMPLE
  end
  RESULT_QUEUE << max_mem
end

# Run one trial of a benchmark.
# Returns a triple [result, time, max_mem].
def run_trial(benchmark, interpret)
  # Initialize values, clear the queues.
  time = 0
  max_mem = 0
  result = nil
  RESULT_QUEUE.clear
  SIGNAL_QUEUE.clear

  # Run the benchmark in a new process
  facts = FLIX_FACTS % benchmark
  args = FLIX_ARGS +
    if interpret then "-Xinterpreter"
    else "" end
  $pid = Process.spawn("#{FLIX} #{args} #{FLIX_ANALYSIS} #{facts}",
                       :out => FLIX_OUT)

  begin
    # Start the sampler in a separate thread.
    # Once the benchmark process finishes, tell the sampler thread to stop.
    thread = Thread.fork { sample_mem $pid }
    Timeout.timeout(TIMEOUT) { Process.wait $pid }
    raise RuntimeError unless $?.exitstatus == 0
    SIGNAL_QUEUE << :stop

    # Flix prints out some information, including the line
    # "Successfully solved in XX msec."
    # Use grep and awk to extract XX, and then convert to seconds.
    # Note that the time includes a comma, which must be stripped out.
    time = `grep Success #{FLIX_OUT} | awk '{print $4}'`
      .gsub(',', '').to_f / MSEC_PER_SEC
    max_mem = RESULT_QUEUE.pop.to_f / KB_PER_MB
    result = :success
  rescue Timeout::Error
    # Benchmark exceeded timeout, so kill process and thread.
    Process.kill('TERM', $pid)
    SIGNAL_QUEUE << :stop
    time = nil
    max_mem = nil
    result = :timeout
  rescue RuntimeError
    # Some other error, so kill process and thread.
    # Benchmark exceeded timeout, so kill process and thread.
    SIGNAL_QUEUE << :stop
    time = nil
    max_mem = nil
    result = :error
  end

  `rm -f #{FLIX_OUT}`

  [result, time, max_mem]
end

# Run the given benchmark. Runs NUM_TRIALS trials and prints the averages.
# Returns false if there were any errors (so later benchmarks can be skipped).
def run_benchmark(benchmark, interpret = false)
  type =
    if interpret then "interpreted"
    else "compiled" end

  print "#{benchmark} (Flix #{type}), "

  result = nil
  total_time = 0.0
  total_max_mem = 0.0

  NUM_TRIALS.times do
    result, time, max_mem = run_trial(benchmark, interpret)
    break unless result == :success
    total_time += time
    total_max_mem += max_mem
  end

  avg_time, avg_max_mem = case result
    when :success then
      ["%.1f" % (total_time / NUM_TRIALS),
       "%.0f" % (total_max_mem / NUM_TRIALS)]
    when :timeout then ["timeout", "-"]
    else ["err", "err"]
    end

  puts "#{avg_time}, #{avg_max_mem}"

  result == :success
end

def main
  puts "Benchmark, Time (s), Mem (MB)"
  benchmarks = FLIX_BENCHMARKS
  benchmarks.each {|b| break unless run_benchmark(b, false) }
  benchmarks.each {|b| break unless run_benchmark(b, true) }
end

def shutdown
  puts
  $stderr.puts "Cleaning up... "
  Process.kill('TERM', $pid) unless $pid.nil?
  `rm -f #{FLIX_OUT}`
  $stderr.puts "Exited."
end

trap "SIGINT" do
  shutdown
  exit 130
end

trap "SIGTERM" do
  shutdown
  exit 143
end

# Run the script
main

