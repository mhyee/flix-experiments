#!/usr/bin/env ruby

require_relative "include/common"
require_relative "include/fibonacci"
require_relative "include/matrixmult"
require_relative "include/nbody"
require_relative "include/pidigits"
require_relative "include/shortestpaths"
require_relative "include/strongupdate"

include Common

# Global pid so we can kill it if the script is terminated.
$pid = nil

def main
  puts "Benchmark, Language, Input, Time (s), Mem (MB)"
  Fibonacci.run
  Nbody.run
  Pidigits.run
  Matrixmult.run
  Shortestpaths.run
  Strongupdate.run
  cleanup
end

def shutdown
  puts
  $stderr.puts "Cleaning up... "
  Process.kill('TERM', $pid) if process_exists? $pid
  cleanup
  $stderr.puts "Exited."
end

def cleanup
  `rm -f #{BENCHMARK_OUT} #{CC_OUT} *.class`
  `rm -f #{Shortestpaths::SHORTESTPATHS} #{Matrixmult::MATRIXMULT}`
end

Signal.trap("SIGINT")  { shutdown; exit 130 }
Signal.trap("SIGTERM") { shutdown; exit 143 }

main

