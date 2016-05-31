require 'benchmark'

# pidigits, from the Computer Language Benchmarks Game.
# http://benchmarksgame.alioth.debian.org/u64q/pidigits-description.html#pidigits

# This implementation is a close translation of the Flix program, which was loosely based on:
# http://benchmarksgame.alioth.debian.org/u64q/program.php?test=pidigits&lang=yarv&id=3

N = 10000

def compTpl1(a2, n1, d1, t1, u)
  tmp = (n1 * 3) + a2
  if a2 >= n1 then [tmp / d1, (tmp % d1) + n1] else [t1, u] end
end

def compTpl2(a2, n1, d1, u1, i, t2)
  if a2 >= n1 && d1 > u1 then [i - 1, (a2 - (d1 * t2)) * 10, n1 * 10] else [i, a2, n1] end
end

def piHelper(i, k, l, n, a, d, t, u)
  if i == 0 then t
  else
    k1 = k + 1
    t1 = n << 1
    n1 = n * k1
    a1 = a + t1
    l1 = l + 2
    a2 = a1 * l1
    d1 = d * l1
    t2, u1 = compTpl1(a2, n1, d1, t1, u)
    i1, a3, n2 = compTpl2(a2, n1, d1, u1, i, t2)
    piHelper(i1, k1, l1, n2, a3, d1, t2, u1)
  end
end

def pi(i)
  piHelper(i, 0, 1, 1, 0, 1, 0, 0)
end

result = nil
time = Benchmark.realtime { result = pi(N) }

puts "Time: #{(time * 1000).round} ms"
puts "Result: #{result}"

