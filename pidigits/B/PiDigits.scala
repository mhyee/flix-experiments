object PiDigits {

  // pidigits, from the Computer Language Benchmarks Game.
  // http://benchmarksgame.alioth.debian.org/u64q/pidigits-description.html#pidigits

  // This implementation is a loose translation of the Flix program, which was loosely based on:
  // http://benchmarksgame.alioth.debian.org/u64q/program.php?test=pidigits&lang=yarv&id=3

  val N: BigInt = 10000

  def pi(i: BigInt): BigInt = {
    var (j, k, l, n, a, d, t, u): (BigInt, BigInt, BigInt, BigInt, BigInt, BigInt, BigInt, BigInt) = (i, 0, 1, 1, 0, 1, 0, 0)
    while (j != 0) {
      k = k + 1
      t = n << 1
      n = n * k
      a = a + t
      l = l + 2
      a = a * l
      d = d * l
      if (a >= n) {
        val tmp = (n * 3) + a
        t = tmp / d
        u = (tmp % d) + n
        if (d > u) {
          //print(t)
          j = j - 1
          a = (a - (d * t)) * 10
          n = n * 10
        }
      }
    }
    t
  }

  def main(args: Array[String]): Unit = {
    val start = System.nanoTime()
    val result = pi(N)
    val end = System.nanoTime()
    val elapsed = (end - start) / 1000000

    println(s"Time: $elapsed ms")
    println(s"Result: $result")
  }

}

