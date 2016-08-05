require_relative "common"

module Pidigits

################################################################################
# CONFIGURATION BEGINS HERE ####################################################
################################################################################

  NAME = "pidigits"
  FILE_NAME = "../#{NAME}/#{NAME}"
  CXX_FILE = FILE_NAME + ".cpp"
  FLIX_FILE = FILE_NAME + ".flix"
  JAVA_FILE = FILE_NAME + ".java"
  RUBY_FILE = FILE_NAME + ".rb"
  SCALA_FILE = FILE_NAME + ".scala"

  GMP_OPTS = "-lgmp -lgmpxx"

  BENCHMARKS = [
    4000,        # 2**02 * 1000
    8000,        # 2**03 * 1000
    16000,       # 2**04 * 1000
    32000,       # 2**05 * 1000
    # Stack overflow for Flix
    64000,       # 2**06 * 1000
    128000,      # 2**07 * 1000
    256000,      # 2**08 * 1000
    512000,      # 2**09 * 1000
    1024000,     # 2**10 * 1000
  ]

################################################################################
# CONFIGURATION ENDS HERE ######################################################
################################################################################

  def Pidigits.run
    BENCHMARKS.each {|b| break unless run_ruby b }
    BENCHMARKS.each {|b| break unless run_flix_interpreted b }
    BENCHMARKS.each {|b| break unless run_flix_compiled b }
    BENCHMARKS.each {|b| break unless run_scala b }
    BENCHMARKS.each {|b| break unless run_java b }
    BENCHMARKS.each {|b| break unless run_gcc(b, 3) }
#    (0..3).each {|i| BENCHMARKS.each {|b| break unless run_gcc(b, i) } }
#    (0..3).each {|i| BENCHMARKS.each {|b| break unless run_clang(b, i) } }
  end

private

  def Pidigits.run_gcc(size, opt)
    `perl -pi -e 's/mpz_class N = \\d+/mpz_class N = #{size}/' #{CXX_FILE}`
    `#{GCC} #{GMP_OPTS} -O#{opt} #{CXX_FILE}`
    Common.run_benchmark("#{NAME}", "gcc -O#{opt}", "#{size}") do
      $pid = Process.spawn("./#{CC_OUT}", :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Pidigits.run_clang(size, opt)
    `perl -pi -e 's/mpz_class N = \\d+/mpz_class N = #{size}/' #{CXX_FILE}`
    `#{CLANG} #{GMP_OPTS} -O#{opt} #{CXX_FILE}`
    Common.run_benchmark("#{NAME}", "clang -O#{opt}", "#{size}") do
      $pid = Process.spawn("./#{CC_OUT}", :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Pidigits.run_flix_compiled(size)
    `perl -pi -e 's/BigInt = \\d+ii/BigInt = #{size}ii/' #{FLIX_FILE}`
    Common.run_benchmark("#{NAME}", "Flix (compiled)", "#{size}") do
      $pid = Process.spawn("#{FLIX} #{FLIX_FILE}",
                           :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Pidigits.run_flix_interpreted(size)
    `perl -pi -e 's/BigInt = \\d+ii/BigInt = #{size}ii/' #{FLIX_FILE}`
    Common.run_benchmark("#{NAME}", "Flix (interpreted)", "#{size}") do
      $pid = Process.spawn("#{FLIX} -Xinterpreter #{FLIX_FILE}",
                           :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Pidigits.run_java(size)
    `perl -pi -e 's/N = BigInteger\\.valueOf\\(\\d+\\)/N = BigInteger\\.valueOf\\(#{size}\\)/' #{JAVA_FILE}`
    `#{JAVAC} #{JAVA_FILE}`
    Common.run_benchmark("#{NAME}", "Java", "#{size}") do
      $pid = Process.spawn("#{JAVA} #{NAME}", :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Pidigits.run_ruby(size)
    `perl -pi -e 's/N = \\d+/N = #{size}/' #{RUBY_FILE}`
    Common.run_benchmark("#{NAME}", "Ruby", "#{size}") do
      $pid = Process.spawn("#{RUBY} #{RUBY_FILE}", :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Pidigits.run_scala(size)
    `perl -pi -e 's/N: BigInt = \\d+/N: BigInt = #{size}/' #{SCALA_FILE}`
    Common.run_benchmark("#{NAME}", "Scala", "#{size}") do
      $pid = Process.spawn("#{SCALA} #{SCALA_FILE}",
                           :out => BENCHMARK_OUT)
      $pid
    end
  end

end

