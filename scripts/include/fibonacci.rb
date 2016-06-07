require_relative "common"

module Fibonacci

################################################################################
# CONFIGURATION BEGINS HERE ####################################################
################################################################################

  NAME = "fibonacci"
  FILE_NAME = "../#{NAME}/#{NAME}"
  CXX_FILE = FILE_NAME + ".cpp"
  FLIX_FILE = FILE_NAME + ".flix"
  JAVA_FILE = FILE_NAME + ".java"
  RUBY_FILE = FILE_NAME + ".rb"
  SCALA_FILE = FILE_NAME + ".scala"

  BENCHMARKS = [
    35,
    40,
    45,
    50,
    55,
    # Benchmarks that timeout
    60,
    65,
    70,
    75,
    80,
    85,
    90,
    # long type overflows at n > 92
  ]

################################################################################
# CONFIGURATION ENDS HERE ######################################################
################################################################################

  def Fibonacci.run
    (0..3).each {|i| BENCHMARKS.each {|b| break unless run_gcc(b, i) } }
    (0..3).each {|i| BENCHMARKS.each {|b| break unless run_clang(b, i) } }
    BENCHMARKS.each {|b| break unless run_flix_compiled b }
    BENCHMARKS.each {|b| break unless run_flix_interpreted b }
    BENCHMARKS.each {|b| break unless run_java b }
    BENCHMARKS.each {|b| break unless run_ruby b }
    BENCHMARKS.each {|b| break unless run_scala b }
  end

private

  def Fibonacci.run_gcc(size, opt)
    `perl -pi -e 's/long N = \\d+/long N = #{size}/' #{CXX_FILE}`
    `#{GCC} -O#{opt} #{CXX_FILE}`
    Common.run_benchmark("#{NAME} N=#{size}", "gcc -O#{opt}") do
      $pid = Process.spawn("./#{CC_OUT}", :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Fibonacci.run_clang(size, opt)
    `perl -pi -e 's/long N = \\d+/long N = #{size}/' #{CXX_FILE}`
    `#{CLANG} -O#{opt} #{CXX_FILE}`
    Common.run_benchmark("#{NAME} N=#{size}", "clang -O#{opt}") do
      $pid = Process.spawn("./#{CC_OUT}", :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Fibonacci.run_flix_compiled(size)
    `perl -pi -e 's/Int64 = \\d+i64/Int64 = #{size}i64/' #{FLIX_FILE}`
    Common.run_benchmark("#{NAME} N=#{size}", "Flix compiled") do
      $pid = Process.spawn("#{FLIX} #{FLIX_FILE}",
                           :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Fibonacci.run_flix_interpreted(size)
    `perl -pi -e 's/Int64 = \\d+i64/Int64 = #{size}i64/' #{FLIX_FILE}`
    Common.run_benchmark("#{NAME} N=#{size}", "Flix interpreted") do
      $pid = Process.spawn("#{FLIX} -Xinterpreter #{FLIX_FILE}",
                           :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Fibonacci.run_java(size)
    `perl -pi -e 's/long N = \\d+/long N = #{size}/' #{JAVA_FILE}`
    `#{JAVAC} #{JAVA_FILE}`
    Common.run_benchmark("#{NAME} N=#{size}", "Java") do
      $pid = Process.spawn("#{JAVA} #{NAME}", :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Fibonacci.run_ruby(size)
    `perl -pi -e 's/N = \\d+/N = #{size}/' #{RUBY_FILE}`
    Common.run_benchmark("#{NAME} N=#{size}", "Ruby") do
      $pid = Process.spawn("#{RUBY} #{RUBY_FILE}", :out => BENCHMARK_OUT)
      $pid
    end
  end

  def Fibonacci.run_scala(size)
    `perl -pi -e 's/N: Long = \\d+/N: Long = #{size}/' #{SCALA_FILE}`
    Common.run_benchmark("#{NAME} N=#{size}", "Scala") do
      $pid = Process.spawn("#{SCALA} #{SCALA_FILE}",
                           :out => BENCHMARK_OUT)
      $pid
    end
  end

end

