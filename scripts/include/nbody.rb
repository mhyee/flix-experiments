require_relative "common"

module Nbody

################################################################################
# CONFIGURATION BEGINS HERE ####################################################
################################################################################

  NAME = "nbody"
  FILE_NAME = "../#{NAME}/#{NAME}"
  CXX_FILE = FILE_NAME + ".cpp"
  FLIX_FILE = FILE_NAME + ".flix"
  JAVA_FILE = FILE_NAME + ".java"
  RUBY_FILE = FILE_NAME + ".rb"
  SCALA_FILE = FILE_NAME + ".scala"

  BENCHMARKS = [
    16000,       # 2**04 * 1000
    32000,       # 2**05 * 1000
    64000,       # 2**06 * 1000
    128000,      # 2**07 * 1000
    # Stack overflow for Flix
    256000,      # 2**08 * 1000
    512000,      # 2**09 * 1000
    1024000,     # 2**10 * 1000
    2048000,     # 2**11 * 1000
    4096000,     # 2**12 * 1000
    8192000,     # 2**13 * 1000
    16384000,    # 2**14 * 1000
    32768000,    # 2**15 * 1000
  ]

################################################################################
# CONFIGURATION ENDS HERE ######################################################
################################################################################

  def Nbody.run
    (0..3).each {|i| BENCHMARKS.each {|b| break unless run_gcc(b, i) } }
    (0..3).each {|i| BENCHMARKS.each {|b| break unless run_clang(b, i) } }
    BENCHMARKS.each {|b| break unless run_flix_compiled b }
    BENCHMARKS.each {|b| break unless run_flix_interpreted b }
    BENCHMARKS.each {|b| break unless run_java b }
    BENCHMARKS.each {|b| break unless run_ruby b }
    BENCHMARKS.each {|b| break unless run_scala b }
  end

private

  def Nbody.run_gcc(size, opt)
    `perl -pi -e 's/int N = \\d+/int N = #{size}/' #{CXX_FILE}`
    `#{GCC} -O#{opt} #{CXX_FILE}`
    Common.run_benchmark("#{NAME} N=#{size}", "gcc -O#{opt}") do
      $pid = Process.spawn("./#{CC_OUT}", :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Nbody.run_clang(size, opt)
    `perl -pi -e 's/int N = \\d+/int N = #{size}/' #{CXX_FILE}`
    `#{CLANG} -O#{opt} #{CXX_FILE}`
    Common.run_benchmark("#{NAME} N=#{size}", "clang -O#{opt}") do
      $pid = Process.spawn("./#{CC_OUT}", :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Nbody.run_flix_compiled(size)
    `perl -pi -e 's/Int = \\d+/Int = #{size}/' #{FLIX_FILE}`
    Common.run_benchmark("#{NAME} N=#{size}", "Flix compiled") do
      $pid = Process.spawn("#{FLIX} #{FLIX_FILE}",
                           :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Nbody.run_flix_interpreted(size)
    `perl -pi -e 's/Int = \\d+/Int = #{size}/' #{FLIX_FILE}`
    Common.run_benchmark("#{NAME} N=#{size}", "Flix interpreted") do
      $pid = Process.spawn("#{FLIX} -Xinterpreter #{FLIX_FILE}",
                           :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Nbody.run_java(size)
    `perl -pi -e 's/int N = \\d+/int N = #{size}/' #{JAVA_FILE}`
    `#{JAVAC} #{JAVA_FILE}`
    Common.run_benchmark("#{NAME} N=#{size}", "Java") do
      $pid = Process.spawn("#{JAVA} #{NAME}", :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Nbody.run_ruby(size)
    `perl -pi -e 's/N = \\d+/N = #{size}/' #{RUBY_FILE}`
    Common.run_benchmark("#{NAME} N=#{size}", "Ruby") do
      $pid = Process.spawn("#{RUBY} #{RUBY_FILE}", :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Nbody.run_scala(size)
    `perl -pi -e 's/N: Int = \\d+/N: Int = #{size}/' #{SCALA_FILE}`
    Common.run_benchmark("#{NAME} N=#{size}", "Scala") do
      $pid = Process.spawn("#{SCALA} #{SCALA_FILE}",
                           :out => BENCHMARK_OUT)
      $pid
    end
  end

end

