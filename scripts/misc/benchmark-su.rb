#!/usr/bin/env ruby

require 'timeout'

################################################################################
# Collects performance data for the Flix implementation of the Strong Update   #
# analysis, as well as a pure Datalog implementation (running on DLV).         #
# Memory (reported in MB) is sampled by ps. Specifically, it is the resident   #
# set size (RES/RSS). Time is simply the execution time, reported by Flix or   #
# timed by this Ruby script. Benchmarks are killed if they exceed the timeout. #
#                                                                              #
# Usage: Edit the configuration below, then run the script. The script takes   #
# no arguments.                                                                #
################################################################################

MSEC_PER_SEC = 1000
SEC_PER_MIN = 60
KB_PER_MB = 1024

################################################################################
# CONFIGURATION BEGINS HERE ####################################################
################################################################################

TIMEOUT = 15 * SEC_PER_MIN
SAMPLE_FREQ = 1

DLV = "./dlv"
DLV_ARGS = "-silent -nofacts"
DLV_ANALYSIS = "../flix-subench/dlv/SUdatalog.dlv"
DLV_FACTS = "../flix-subench/dlv/%s.dlv"
DLV_OUT = "/dev/null"

FLIX = "java -Xmx8192M -jar ../flix/out/flix.jar"
#FLIX_ARGS = ""
FLIX_ARGS = "-c" # Generate bytecode
FLIX_ANALYSIS = "../flix/examples/analysis/SUopt.flix"
FLIX_FACTS = "../flix-subench/%s.flix"
FLIX_OUT = "flix.out"

DLV_BENCHMARKS = [
  "470.lbm",
  "181.mcf",
  "429.mcf",
  "256.bzip2",
  "462.libquantum",
  "164.gzip",
  "401.bzip2",
  "458.sjeng",
]
# Benchmarks that timeout on DLV but run on Flix
FLIX_BENCHMARKS = DLV_BENCHMARKS + [
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

def run_dlv(benchmark)
  print "#{benchmark} (DLV)"

  # Run the benchmark in a new process
  facts = DLV_FACTS % benchmark
  start = Time.now
  pid = Process.spawn("#{DLV} #{DLV_ARGS} #{DLV_ANALYSIS} #{facts}",
                      :out => DLV_OUT)
  Process.detach pid
  max_mem = 0
  time = 0

  begin
    # Set a timeout on the benchmark
    Timeout.timeout(TIMEOUT) do
      while true do
        # Sample memory (RSS/RES) using ps.
        # Keep track of the maximum memory.
        mem = `ps -o rss= -p #{pid}`
        break if mem.empty?
        max_mem = mem.to_i if mem.to_i > max_mem
        sleep SAMPLE_FREQ
      end
    end

    # Get the time
    time = Time.now - start
    time = "%.2f s" % time
  rescue Timeout::Error
    # Benchmark exceeded timeout, so kill process.
    Process.kill('TERM', pid)
    time = "-"
  end

  `rm #{DLV_OUT}` unless DLV_OUT == "/dev/null"

  puts "%20d MB%20s" % [max_mem / KB_PER_MB, time]
end

def run_flix(benchmark)
  print "#{benchmark} (Flix)"

  # Run the benchmark in a new process
  facts = FLIX_FACTS % benchmark
  pid = Process.spawn("#{FLIX} #{FLIX_ARGS} #{FLIX_ANALYSIS} #{facts}",
                      :out => FLIX_OUT)
  Process.detach pid
  max_mem = 0
  time = 0

  begin
    # Set a timeout on the benchmark
    Timeout.timeout(TIMEOUT) do
      while true do
        # Sample memory (RSS/RES) using ps.
        # Keep track of the maximum memory.
        mem = `ps -o rss= -p #{pid}`
        break if mem.empty?
        max_mem = mem.to_i if mem.to_i > max_mem
        sleep SAMPLE_FREQ
      end
    end

    # Flix prints out some information, including the line
    # "Successfully solved in XX msec."
    # Use grep and awk to extract XX, and then convert to seconds.
    # Note that the time includes a comma, which must be stripped out.
    time = `grep Success #{FLIX_OUT} | awk '{print $4}'`
      .gsub(',', '').to_f / MSEC_PER_SEC
    time = "%.1f s" % time
  rescue Timeout::Error
    # Benchmark exceeded timeout, so kill process.
    Process.kill('TERM', pid)
    time = "-"
  end

  `rm #{FLIX_OUT}`

  puts "%20d MB%20s" % [max_mem / KB_PER_MB, time]
end

def main
  #FLIX_BENCHMARKS.each {|b| run_flix b}
  ALL_BENCHMARKS.each {|b| run_flix b}
end

# Run the script
main
