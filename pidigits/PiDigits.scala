object PiDigits {

  // pidigits, from the Computer Language Benchmarks Game.
  // http://benchmarksgame.alioth.debian.org/u64q/pidigits-description.html#pidigits

  // This implementation is a loose translation of the Flix program, which was loosely based on:
  // http://benchmarksgame.alioth.debian.org/u64q/program.php?test=pidigits&lang=yarv&id=3

  val N: BigInt = 10000

  def compTpl1(a2: BigInt, n1: BigInt, d1: BigInt, t1: BigInt, u: BigInt): (BigInt, BigInt) =
    if (a2 >= n1) (((n1 * 3) + a2) / d1, (((n1 * 3) + a2) % d1) + n1) else (t1, u)
  def compTpl2(a2: BigInt, n1: BigInt, d1: BigInt, u1: BigInt, i: BigInt, t2: BigInt): (BigInt, BigInt, BigInt) =
    if ((a2 >= n1) && (d1 > u1)) (i - 1, (a2 - (d1 * t2)) * 10, n1 * 10) else (i, a2, n1)

  def pi(i: BigInt): BigInt = {
    var (j,k,l,n,a,d,t,u): (BigInt,BigInt,BigInt,BigInt,BigInt,BigInt,BigInt,BigInt) = (i,0,1,1,0,1,0,0)
    while (j != 0) {
      k = k + 1
      t = n << 1
      n = n * k
      a = a + t
      l = l + 2
      a = a * l
      d = d * l
      var tpl1 = compTpl1(a, n, d, t, u)
      t = tpl1._1
      u = tpl1._2
      var tpl2 = compTpl2(a, n, d, u, j, t)
      j = tpl2._1
      a = tpl2._2
      n = tpl2._3
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

