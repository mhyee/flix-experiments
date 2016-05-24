import scala.util.Random

object RandomMatrix {

  def main(args: Array[String]): Unit = {

    val N = if (args.length < 1) 100 else args(0).toInt
    val seed = if (args.length < 2) 0 else args(1).toInt

    val r = new Random(seed)

    println(
      s"""namespace Matrix_N$N {
         |
         |    // Matrix multiplication of a $N x $N matrix.
         |    // Matrix generated with seed = $seed
         |
         |    // Note that this does not satisfy the lattice properties, but we abuse
         |    // the `lub` operator and a `mult` transfer function to do the job.
         |
         |    def leq(x: Int, y: Int): Bool = false
         |    def lub(x: Int, y: Int): Int = x + y
         |    def glb(x: Int, y: Int): Int = 0
         |
         |    def mult(x: Int, y: Int): Int = x * y
         |
         |    let Int<> = (0, 0, leq, lub, glb);
         |
         |    rel A(row: Int, col: Int, value: Int);
         |    rel B(row: Int, col: Int, value: Int);
         |    lat S(row: Int, col: Int, value: Int);
         |
         |    index A({row, col});
         |    index B({row, col}, {row});
         |    index S({row, col});
         |
         |    S(i, j, mult(v1, v2)) :- A(i, k, v1), B(k, j, v2).
         |
         |    ////////// Encode the input matrices here. //////////""".stripMargin)
    println()

    for (i <- 0 until N) {
      for (j <- 0 until N) {
        val x = r.nextInt(101)
        println(s"    A($i, $j, $x).")
      }
    }
    println()

    for (i <- 0 until N) {
      for (j <- 0 until N) {
        val x = r.nextInt(101)
        println(s"    B($i, $j, $x).")
      }
    }
    println()

    println("}")
    println()

  }

}
