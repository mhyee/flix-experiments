require_relative "common"

module Strongupdate

################################################################################
# CONFIGURATION BEGINS HERE ####################################################
################################################################################

  NAME = "strongupdate"
  ANALYSIS = "../#{NAME}/#{NAME}.flix"
  FACTS = "../../flix-subench/%s.flix"

  BENCHMARKS = [
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
    # Benchmarks that timeout
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

  def Strongupdate.run
    BENCHMARKS.each {|b| break unless run_flix_interpreted b }
    BENCHMARKS.each {|b| break unless run_flix_compiled b }
  end

private

  def Strongupdate.run_flix_compiled(benchmark)
    facts = FACTS % benchmark
    Common.run_benchmark("#{NAME}", "Flix (compiled)", "#{benchmark}") do
      $pid = Process.spawn("#{FLIX} #{ANALYSIS} #{facts}",
                           :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Strongupdate.run_flix_interpreted(benchmark)
    facts = FACTS % benchmark
    Common.run_benchmark("#{NAME}", "Flix (interpreted)", "#{benchmark}") do
      $pid = Process.spawn("#{FLIX} -Xinterpreter #{ANALYSIS} #{facts}",
                            :out => BENCHMARK_OUT)
      $pid
    end
  end

end

