import scala.util.Random

object GenerateShortestPaths {

  def main(args: Array[String]): Unit = {

    val N = if (args.length < 1) 100 else args(0).toInt
    val seed = if (args.length < 2) 0 else args(1).toInt

    val P = 1.0 / N.toDouble
    val r = new Random(seed)

    println(
      s"""namespace ShortestPaths_N$N {
         |
         |    // N    = $N
         |    // seed = $seed
         |    // P    = $P
         |
         |    // If N*P = 1, then a graph in G(N, P) will almost surely have a largest component whose size is of order N^(2/3).
         |    // See: https://en.wikipedia.org/wiki/Erd%C5%91s%E2%80%93R%C3%A9nyi_model
         |
         |    // Floyd-Warshall algorithm for all-pairs shortest paths.
         |    // Strictly speaking, this program returns the shortest distance between two vertices, and not the path.
         |
         |    def leq(x: Int, y: Int): Bool = x >= y
         |    def lub(x: Int, y: Int): Int = if (x < y) x else y  // min
         |    def glb(x: Int, y: Int): Int = if (x > y) x else y  // max
         |
         |    def sum(x: Int, y: Int): Int = x + y
         |
         |    let Int<> = (2147483647, 0, leq, lub, glb);
         |
         |    rel Edge(x: Int, y: Int, cost: Int);
         |    lat Dist(x: Int, y: Int, cost: Int);
         |
         |    index Edge({x,y}, {x}, {y});
         |    index Dist({x,y});
         |
         |    // Initialize: Distance from a vertex v to itself is 0.
         |    Dist(v, v, 0) :- Edge(v, _, _).
         |    Dist(v, v, 0) :- Edge(_, v, _).
         |
         |    // Base case: Distance between two adjacent vertices is the cost of its edge.
         |    Dist(i, j, c) :- Edge(i, j, c).
         |
         |    // Recursive case: Distance between vertices i, j is either the current known distance,
         |    // or the distance from i to k and then k to j, whichever is smaller.
         |    Dist(i, j, sum(c1, c2)) :- Dist(i, k, c1), Dist(k, j, c2).
         |
         |    ////////// Encode the input graph (edges) here. //////////""".stripMargin)
    println()

    for (i <- 0 until N) {
      for (j <- 0 until N) {
        if (r.nextInt(Int.MaxValue).toDouble < (P * Int.MaxValue.toDouble) && i != j) {
          val cost = r.nextInt(101)
          println(s"    Edge($i, $j, $cost).")
        }
      }
    }
    println()

    println("}")
    println()

  }

}

