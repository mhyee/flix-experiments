#!/usr/bin/env ruby

require 'timeout'

MSEC_PER_SEC = 1000
SEC_PER_MIN = 60
KB_PER_MB = 1024

################################################################################
# CONFIGURATION BEGINS HERE ####################################################
################################################################################

NUM_TRIALS = 5
TIMEOUT = 15 * SEC_PER_MIN
SAMPLE_PER_SEC = 0.1

SCALA = "scala"
GENERATOR = "../shortest-paths/GenerateShortestPaths.scala"
GENERATOR_SEED = "0"

GRAPH_NAME = "ShortestPaths.flix"

FLIX = "java -Xmx8192M -jar ../../flix/out/flix.jar"
FLIX_ARGS = ""
FLIX_OUT = "flix.out"

SIZES = [
  8,
  16,
  32,
  64,
  128,
  256,
  512,
  1024,
  2048,
  4096,
]
# Benchmarks that timeout on Flix
ALL_SIZES = SIZES + [
  8192,
  16384,
  32768,
  65536,
  131072,
  262144,
  524288,
  1048576,
]

################################################################################
# CONFIGURATION ENDS HERE ######################################################
################################################################################

# Run one trial of a benchmark.
# Returns a triple [success, time, max_mem].
def run_trial(size, interpret)
  # First, generate the matrix
  `#{SCALA} #{GENERATOR} #{size} #{GENERATOR_SEED} > #{GRAPH_NAME}`

  # Run the benchmark in a new process
  args = FLIX_ARGS +
    if interpret then "-Xinterpreter"
    else "" end
  pid = Process.spawn("#{FLIX} #{args} #{GRAPH_NAME}", :out => FLIX_OUT)
  Process.detach pid
  success = false
  time = 0
  max_mem = 0

  begin
    # Set a timeout on the benchmark
    Timeout.timeout(TIMEOUT) do
      while true do
        # Sample memory (RSS/RES) using ps.
        # Keep track of the maximum memory.
        mem = `ps -o rss= -p #{pid}`
        break if mem.empty?
        max_mem = mem.to_i if mem.to_i > max_mem
        sleep SAMPLE_PER_SEC
      end
    end

    # Flix prints out some information, including the line
    # "Successfully solved in XX msec."
    # Use grep and awk to extract XX, and then convert to seconds.
    # Note that the time includes a comma, which must be stripped out.
    success = true
    time = `grep Success #{FLIX_OUT} | awk '{print $4}'`
      .gsub(',', '').to_f / MSEC_PER_SEC
    max_mem = max_mem.to_f / KB_PER_MB
  rescue Timeout::Error
    # Benchmark exceeded timeout, so kill process.
    Process.kill('TERM', pid)
    time = nil
    max_mem = nil
  end

  `rm #{FLIX_OUT} #{GRAPH_NAME}`

  [success, time, max_mem]
end

# Run the given benchmark. Runs NUM_TRIALS trials and prints the averages.
def run_benchmark(size, interpret = false)
  type =
    if interpret then "interpreted"
    else "compiled" end

  print "ShortestPaths (Flix #{type}), #{size}, "

  all_success = true
  total_time = 0.0
  total_max_mem = 0.0

  NUM_TRIALS.times do
    success, time, max_mem = run_trial(size, interpret)
    all_success &&= success
    break unless success
    total_time += time
    total_max_mem += max_mem
  end

  avg_time, avg_max_mem =
    if all_success then
      ["%.1f" % (total_time / NUM_TRIALS),
       "%.0f" % (total_max_mem / NUM_TRIALS)]
    else
      ["timeout", "-"]
    end

  puts "#{avg_time}, #{avg_max_mem}"
end

def main
  puts "Benchmark, N (size), Time (s), Mem (MB)"
  benchmarks = SIZES
  benchmarks.each {|b| run_benchmark(b, false) }
  benchmarks.each {|b| run_benchmark(b, true) }
end

trap "SIGINT" do
  puts
  $stderr.print "Cleaning up... "
  `rm #{FLIX_OUT} #{GRAPH_NAME}`
  $stderr.puts "Exited."
  exit 130
end

# Run the script
main

