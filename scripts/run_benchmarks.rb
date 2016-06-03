#!/usr/bin/env ruby

require_relative "include/common"
require_relative "include/strongupdate"

include Common

# Global pid so we can kill it if the script is terminated.
$pid = nil

def main
  puts "Benchmark, N (size), Time (s), Mem (MB)"
  Strongupdate.run
end

def shutdown
  puts
  $stderr.puts "Cleaning up... "
  Process.kill('TERM', $pid) unless $pid.nil?
  `rm -f #{BENCHMARK_OUT}`
  $stderr.puts "Exited."
end

Signal.trap("SIGINT")  { shutdown; exit 130 }
Signal.trap("SIGTERM") { shutdown; exit 143 }

main

