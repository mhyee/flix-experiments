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

# Run one trial of a benchmark.
# Returns a triple [success, time, max_mem].
def run_trial(benchmark, interpret)
  # Run the benchmark in a new process
  facts = FLIX_FACTS % benchmark
  args = FLIX_ARGS +
    if interpret then "-Xinterpreter"
    else "" end
  pid = Process.spawn("#{FLIX} #{args} #{FLIX_ANALYSIS} #{facts}",
                      :out => FLIX_OUT)
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
        sleep SEC_PER_SAMPLE
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

  `rm #{FLIX_OUT}`

  [success, time, max_mem]
end

# Run the given benchmark. Runs NUM_TRIALS trials and prints the averages.
def run_benchmark(benchmark, interpret = false)
  type =
    if interpret then "interpreted"
    else "compiled" end

  print "#{benchmark} (#{type}), "

  all_success = true
  total_time = 0.0
  total_max_mem = 0.0

  NUM_TRIALS.times do
    success, time, max_mem = run_trial(benchmark, interpret)
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
  puts "Benchmark, Time (s), Mem (MB)"
  benchmarks = FLIX_BENCHMARKS
  benchmarks.each {|b| run_benchmark(b, false) }
  benchmarks.each {|b| run_benchmark(b, true) }
end

trap "SIGINT" do
  puts
  print "Cleaning up... "
  `rm #{FLIX_OUT}`
  puts "Exited."
  exit 130
end

# Run the script
main
