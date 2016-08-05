require_relative "common"

module Shortestpaths

################################################################################
# CONFIGURATION BEGINS HERE ####################################################
################################################################################

  NAME = "shortestpaths"
  GENERATOR = "../#{NAME}/generate.scala"
  GENERATOR_SEED = "0"

  SHORTESTPATHS = NAME + ".flix"

  BENCHMARKS = [
    8,        # 2**03
    16,       # 2**04
    32,       # 2**05
    64,       # 2**06
    128,      # 2**07
    256,      # 2**08
    512,      # 2**09
    1024,     # 2**10
    2048,     # 2**11
    # Benchmarks that timeout
    4096,     # 2**12
    8192,     # 2**13
    16384,    # 2**14
    32768,    # 2**15
    65536,    # 2**16
    131072,   # 2**17
    262144,   # 2**18
    524288,   # 2**19
    1048576,  # 2**20
  ]

################################################################################
# CONFIGURATION ENDS HERE ######################################################
################################################################################

  def Shortestpaths.run
    BENCHMARKS.each {|b| break unless run_flix_interpreted b }
    BENCHMARKS.each {|b| break unless run_flix_compiled b }
  end

private

  def Shortestpaths.run_flix_compiled(size)
    `#{SCALA} #{GENERATOR} #{size} #{GENERATOR_SEED} > #{SHORTESTPATHS}`
    Common.run_benchmark("#{NAME}", "Flix (compiled)", "#{size}") do
      $pid = Process.spawn("#{FLIX} #{SHORTESTPATHS}",
                           :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Shortestpaths.run_flix_interpreted(size)
    `#{SCALA} #{GENERATOR} #{size} #{GENERATOR_SEED} > #{SHORTESTPATHS}`
    Common.run_benchmark("#{NAME}", "Flix (interpreted)", "#{size}") do
      $pid = Process.spawn("#{FLIX} -Xinterpreter #{SHORTESTPATHS}",
                           :out => BENCHMARK_OUT)
      $pid
    end
  end

end

