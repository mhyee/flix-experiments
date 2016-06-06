require 'timeout'
require 'thread'

module Common

  MSEC_PER_SEC = 1000
  SEC_PER_MIN = 60
  KB_PER_MB = 1024

################################################################################
# CONFIGURATION BEGINS HERE ####################################################
################################################################################

  NUM_TRIALS = 5
  TIMEOUT_MIN = 15 * SEC_PER_MIN
  SAMPLE_INTERVAL_SEC = 0.1

  FLIX = "java -Xmx8192M -Xss32M -jar ../../flix/out/flix.jar"
  BENCHMARK_OUT = "benchmark.out"

  CC_OUT = "a.out"
  CC_OPTS = "-std=c++14 -pedantic -Wall -Wextra -o #{CC_OUT}"
  GCC = "g++ #{CC_OPTS}"
  CLANG = "clang++ #{CC_OPTS}"

  JAVAC = "javac -d ."
  JAVA = "java -Xmx8192M -Xss32M"

  RUBY = "ruby"

  SCALA = "scala -J-Xmx8192M -J-Xss32M"

################################################################################
# CONFIGURATION ENDS HERE ######################################################
################################################################################

  # Run the benchmark NUM_TRIALS times. If one of the trials fails, don't run
  # the subsequent trials.
  #   Parameters:
  #     benchmark - the name of the benchmark to run
  #     impl      - the name of the implementation
  #     block     - a block wrapping a Process.spawn (which runs the actual
  #                 benchmark), returning the pid
  #  Returns: true if the trials succeeded, false otherwise (so we can skip
  #           subsequent benchmarks).
  def Common.run_benchmark(benchmark, impl, &block)
    print "#{benchmark} (#{impl}), "

    result = nil
    total_time = 0.0
    total_max_mem = 0.0

    NUM_TRIALS.times do
      result, time, max_mem = run_trial(block)
      break unless result == :success
      total_time += time
      total_max_mem += max_mem
    end

    avg_time, avg_max_mem = case result
      when :success then
        ["%.1f" % (total_time / NUM_TRIALS),
         "%.0f" % (total_max_mem / NUM_TRIALS)]
      when :timeout then ["timeout", "-"]
      else ["err", "err"]
      end

    puts "#{avg_time}, #{avg_max_mem}"

    result == :success
  end

  # Run one trial of a benchmark, timing out after TIMEOUT_MIN minutes. Collects
  # the time and memory usage of running the benchmark. Tries to handle errors
  # (timeout, benchmark process dying) and returns something sensible.
  #   Parameters:
  #     block - a block wrapping a Process.spawn (which runs the actual
  #             benchmark), returning the pid
  #   Returns: the triple [result, time, max_mem]
  def Common.run_trial(block)
    in_queue = Queue.new
    out_queue = Queue.new

    # Run the benchmark by calling the block.
    pid = block.call

    begin
      # Start the sampler in a separate thread.
      # Once the benchmark process finishes, tell the sampler thread to stop.
      Thread.fork { sample_mem(pid, in_queue, out_queue) }
      Timeout.timeout(TIMEOUT_MIN) { Process.wait pid }
      raise RuntimeError unless $?.exitstatus == 0
      in_queue << :stop
      [:success, get_time, out_queue.pop.to_f / KB_PER_MB]
    rescue Timeout::Error
      # Benchmark exceeded timeout, so kill process and thread.
      Process.kill('TERM', pid)
      in_queue << :stop
      [:timeout, nil, nil]
    rescue RuntimeError
      # Some other error, so kill process and thread.
      # Benchmark exceeded timeout, so kill process and thread.
      in_queue << :stop
      [:error, nil, nil]
    end
  end

private

  # Sample memory usage (RSS/RES) using `ps`, every SAMPLE_INTERVAL_SEC seconds.
  #   Parameters:
  #     pid       - ID of process to monitor
  #     in_queue  - sample until message is received on in_queue
  #     out_queue - return the result (max memory usage) on out_queue
  #   Returns: max memory usage in KB
  def Common.sample_mem(pid, in_queue, out_queue)
    max_mem = 0
    while in_queue.empty? do
      mem = `ps -o rss= -p #{pid}`
      max_mem = mem.to_i if mem.to_i > max_mem
      sleep SAMPLE_INTERVAL_SEC
    end
    out_queue << max_mem
    max_mem
  end

  # Extracts the time taken to run the benchmark.
  # Delete the temp benchmark output file when done.
  def Common.get_time
    raw = 0.0

    if `grep Success #{BENCHMARK_OUT}`.empty? then
      # Other output format is "Time: XX ms"
      # Use grep and awk to extract XX, and then convert to seconds.
      raw = `grep Time #{BENCHMARK_OUT} | awk '{print $2}'`
    else
      # Flix output format is "Successfully solved in XX msec."
      # Use grep and awk to extract XX, and then convert to seconds.
      # Note that the time includes a comma, which must be stripped out.
      raw = `grep Success #{BENCHMARK_OUT} | awk '{print $4}' | sed 's/,//g'`
    end

    raw.to_f / MSEC_PER_SEC
  end

end

