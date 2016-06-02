#!/usr/bin/env ruby

################################################################################
# Compares the Flix implementation of the Strong Update analysis with a pure   #
# Datalog implementation (running on DLV).                                     #
#                                                                              #
# The comparison simply checks that the sizes of the output sets match         #
# (VarPointsTo/Pt, HeapPointsTo/PtH). It does not check the set contents.      #
#                                                                              #
# Usage: Edit the configuration below, then run the script. The script takes   #
# no arguments.                                                                #
################################################################################

################################################################################
# CONFIGURATION BEGINS HERE ####################################################
################################################################################

DLV = "./dlv"
DLV_ARGS = "-silent -nofacts"
DLV_ANALYSIS = "../flix-subench/dlv/SUdatalog.dlv"
DLV_FACTS = "../flix-subench/dlv/%s.dlv"
DLV_OUT = "dlv.out"

FLIX = "java -Xmx8192M -jar ../flix/out/flix.jar"
#FLIX_ARGS = "-p Pt PtH"
FLIX_ARGS = "-c -p Pt PtH" # Generate bytecode
FLIX_ANALYSIS = "../flix/examples/analysis/SUopt.flix"
FLIX_FACTS = "../flix-subench/%s.flix"
FLIX_OUT = "flix.out"

# Comment out the benchmarks to run
BENCHMARKS = [
  "470.lbm",
  "181.mcf",
  "429.mcf",
  "256.bzip2",
  "462.libquantum",
  "164.gzip",
  "401.bzip2",
  "458.sjeng",
# Benchmarks that timeout on DLV but run on Flix
  # "433.milc",
  # "175.vpr",
  # "186.crafty",
  # "197.parser",
  # "482.sphinx3",
  # "300.twolf",
# Benchmarks that timeout on Flix
  # "456.hmmer",
  # "464.h264ref",
  # "255.vortex",
  # "254.gap",
  # "253.perlbmk",
  # "445.gobmk",
  # "400.perlbench",
  # "176.gcc",
  # "403.gcc",
]

################################################################################
# CONFIGURATION ENDS HERE ######################################################
################################################################################

# Colours from: http://stackoverflow.com/a/16363159
class String
def red;            "\e[31m#{self}\e[0m" end
def green;          "\e[32m#{self}\e[0m" end
def gray;           "\e[37m#{self}\e[0m" end

def bold;           "\e[1m#{self}\e[22m" end
end

def run_dlv(benchmark)
  # Run the benchmark
  facts = DLV_FACTS % benchmark
  `#{DLV} #{DLV_ARGS} #{DLV_ANALYSIS} #{facts} > #{DLV_OUT}`

  # Clean up the output (DLV puts everything on a single line)
  `perl -pi -e 's/\\), /\\),\n/g' #{DLV_OUT}`

  # Count the output sets
  var_count = `grep varpointsto #{DLV_OUT} | wc -l`.to_i
  heap_count = `grep heappointsto #{DLV_OUT} | wc -l`.to_i

  `rm #{DLV_OUT}`

  # Return the counts
  [var_count, heap_count]
end

def run_flix(benchmark)
  # Run the benchmark
  facts = FLIX_FACTS % benchmark
  `#{FLIX} #{FLIX_ARGS} #{FLIX_ANALYSIS} #{facts} > #{FLIX_OUT}`

  # Flix prints out the sets, followed by
  # "Query matched XX row(s) out of YY total row(s)."
  # So we use grep to extract these lines, awk to extract XX, and then convert
  # the result (a single string) to an array of ints.
  result = `grep Query #{FLIX_OUT} | awk '{print $3}'`.lines.map(&:to_i)

  `rm #{FLIX_OUT}`

  result
end

def compare(benchmark)
  # First run and collect the counts
  print "#{benchmark.gray.bold}: "

  dlv_counts = run_dlv benchmark
  flix_counts = run_flix benchmark

  # Is the overal result a pass or fail?
  result = if dlv_counts == flix_counts then
    "[PASS]".green.bold
  else
    "[FAIL]".red.bold
  end
  puts "%20s" % result

  # Where is the exact failure?
  vars = if dlv_counts[0] == flix_counts[0] then
            "VarPointsTo/Pt(#{dlv_counts[0]})"
          else
            "VarPointsTo/Pt" + "(#{dlv_counts[0]}|#{flix_counts[0]})".red
          end
  heaps = if dlv_counts[1] == flix_counts[1] then
            "HeapPointsTo/PtH(#{dlv_counts[1]})"
          else
            "HeapPointsTo/PtH" + "(#{dlv_counts[1]}|#{flix_counts[1]})".red
          end

  # Print the result
  puts "\t#{vars}\n\t#{heaps}"
end

def main
  BENCHMARKS.each {|b| compare b}
end

# Run the script
main
