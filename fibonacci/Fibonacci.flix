namespace Fibonacci {

  def n(dummy: Int): Int64 = 35i64

  rel Fib(n: Int64, value: Int64);

  index Fib({n}, {n, value});

  def filter(x: Int64): Bool = x < n(0)
  def inc(x: Int64): Int64 = x + 1i64

  def fib(n: Int64): Int64 =
    if (n == 0i64) 0i64
    else if (n == 1i64) 1i64
    else fib(n - 1i64) + fib(n - 2i64)

  Fib(0i64, fib(n(0))).

}

