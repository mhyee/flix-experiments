namespace PiDigits {

    // pidigits, from the Computer Language Benchmarks Game.
    // http://benchmarksgame.alioth.debian.org/u64q/pidigits-description.html#pidigits

    // This implementation is loosely based on:
    // http://benchmarksgame.alioth.debian.org/u64q/program.php?test=pidigits&lang=yarv&id=3

    def ndigits(dummy: Int): BigInt = 10000ii

    rel Pi(digit: BigInt, value: BigInt);

    index Pi({digit}, {digit, value});

    def fst(t: (BigInt, BigInt)): BigInt = match t with { case (x, _) => x }
    def snd(t: (BigInt, BigInt)): BigInt = match t with { case (_, x) => x }
    def fstOf3(t: (BigInt, BigInt, BigInt)): BigInt = match t with { case (x, _, _) => x }
    def sndOf3(t: (BigInt, BigInt, BigInt)): BigInt = match t with { case (_, x, _) => x }
    def trdOf3(t: (BigInt, BigInt, BigInt)): BigInt = match t with { case (_, _, x) => x }

    def pi(i: BigInt): BigInt = piHelper(i, 0ii, 1ii, 1ii, 0ii, 1ii, 0ii, 0ii)

    def compTpl1(a2: BigInt, n1: BigInt, d1: BigInt, t1: BigInt, u: BigInt): (BigInt, BigInt) =
      if (a2 >= n1) (((n1 * 3ii) + a2) / d1, (((n1 * 3ii) + a2) % d1) + n1) else (t1, u)

    def compTpl2(a2: BigInt, n1: BigInt, d1: BigInt, u1: BigInt, i: BigInt, t2: BigInt): (BigInt, BigInt, BigInt) =
      if ((a2 >= n1) && (d1 > u1)) (i - 1ii, (a2 - (d1 * t2)) * 10ii, n1 * 10ii) else (i, a2, n1)

    def piHelper(i: BigInt, k: BigInt, l: BigInt, n: BigInt, a: BigInt, d: BigInt, t: BigInt, u: BigInt): BigInt =
      if (i == 0ii) t
      else let k1 = k + 1ii in
           let t1 = n << 1 in
           let n1 = n * k1 in
           let a1 = a + t1 in
           let l1 = l + 2ii in
           let a2 = a1 * l1 in
           let d1 = d * l1 in
           let tpl1 = compTpl1(a2, n1, d1, t1, u) in
           let t2 = fst(tpl1) in
           let u1 = snd(tpl1) in
           let tpl2 = compTpl2(a2, n1, d1, u1, i, t2) in
           let i1 = fstOf3(tpl2) in
           let a3 = sndOf3(tpl2) in
           let n2 = trdOf3(tpl2) in
             piHelper(i1, k1, l1, n2, a3, d1, t2, u1)

    Pi(0ii, pi(ndigits(0))).

}

