require_relative "common"

module Matrixmult

################################################################################
# CONFIGURATION BEGINS HERE ####################################################
################################################################################

  NAME = "matrixmult"
  GENERATOR = "../#{NAME}/generate.scala"
  GENERATOR_SEED = "0"

  MATRIXMULT = NAME + ".flix"

  BENCHMARKS = [
    8,        # 2**03
    16,       # 2**04
    32,       # 2**05
    64,       # 2**06
    128,      # 2**07
    256,      # 2**08
    # Benchmarks that timeout
    512,      # 2**09
    # Benchmarks that OOM
    1024,     # 2**10
    2048,     # 2**11
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

  def Matrixmult.run
    BENCHMARKS.each {|b| break unless run_flix_compiled b }
    BENCHMARKS.each {|b| break unless run_flix_interpreted b }
  end

private

  def Matrixmult.run_flix_compiled(size)
    `#{SCALA} #{GENERATOR} #{size} #{GENERATOR_SEED} > #{MATRIXMULT}`
    Common.run_benchmark("#{NAME} N=#{size}", "Flix compiled") do
      $pid = Process.spawn("#{FLIX} #{MATRIXMULT}",
                           :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Matrixmult.run_flix_interpreted(size)
    `#{SCALA} #{GENERATOR} #{size} #{GENERATOR_SEED} > #{MATRIXMULT}`
    Common.run_benchmark("#{NAME} N=#{size}", "Flix interpreted") do
      $pid = Process.spawn("#{FLIX} -Xinterpreter #{MATRIXMULT}",
                           :out => BENCHMARK_OUT)
      $pid
    end
  end

end

