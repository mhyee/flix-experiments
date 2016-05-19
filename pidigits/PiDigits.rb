require 'benchmark'

# pidigits, from the Computer Language Benchmarks Game.
# http://benchmarksgame.alioth.debian.org/u64q/pidigits-description.html#pidigits

# This implementation is a loose translation of the Flix program, which was loosely based on:
# http://benchmarksgame.alioth.debian.org/u64q/program.php?test=pidigits&lang=yarv&id=3

N = 10000

def compTpl1(a2, n1, d1, t1, u)
  if a2 >= n1 then [((n1 * 3) + a2) / d1, (((n1 * 3) + a2) % d1) + n1] else [t1, u] end
end

def compTpl2(a2, n1, d1, u1, i, t2)
  if a2 >= n1 && d1 > u1 then [i - 1, (a2 - (d1 * t2)) * 10, n1 * 10] else [i, a2, n1] end
end

def pi(i)
  j,k,l,n,a,d,t,u = [i,0,1,1,0,1,0,0]
  while j != 0 do
    k = k + 1
    t = n << 1
    n = n * k
    a = a + t
    l = l + 2
    a = a * l
    d = d * l
    t,u = compTpl1(a, n, d, t, u)
    j,a,n = compTpl2(a, n, d, u, j, t)
  end
  t
end

result = nil
time = Benchmark.realtime { result = pi(N) }

puts "Time: #{(time * 1000).round} ms"
puts "Result: #{result}"

