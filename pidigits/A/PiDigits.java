import java.math.BigInteger;

class PiDigits {

    // pidigits, from the Computer Language Benchmarks Game.
    // http://benchmarksgame.alioth.debian.org/u64q/pidigits-description.html#pidigits

    // This implementation is a close translation of the Flix program, which was loosely based on:
    // http://benchmarksgame.alioth.debian.org/u64q/program.php?test=pidigits&lang=yarv&id=3

    public static final BigInteger N = BigInteger.valueOf(10000);

    public static BigInteger[] compTpl1(BigInteger a2, BigInteger n1, BigInteger d1, BigInteger t1, BigInteger u) {
        final BigInteger tmp = ((n1.multiply(BigInteger.valueOf(3))).add(a2));
        if (a2.compareTo(n1) >= 0) {
            return new BigInteger[] {tmp.divide(d1), (tmp.mod(d1)).add(n1)};
        } else {
            return new BigInteger[] {t1, u};
        }
    }

    public static BigInteger[] compTpl2(BigInteger a2, BigInteger n1, BigInteger d1, BigInteger u1, BigInteger i, BigInteger t2) {
        if ((a2.compareTo(n1) >= 0) && (d1.compareTo(u1) > 0)) {
            return new BigInteger[] {i.subtract(BigInteger.ONE),
                                     (a2.subtract(d1.multiply(t2))).multiply(BigInteger.TEN),
                                     n1.multiply(BigInteger.TEN)};
        } else {
            return new BigInteger[] {i, a2, n1};
        }
    }

    public static BigInteger piHelper(BigInteger i, BigInteger k, BigInteger l, BigInteger n, BigInteger a, BigInteger d, BigInteger t, BigInteger u) {
        if (i.compareTo(BigInteger.ZERO) == 0) {
            return t;
        } else {
            final BigInteger k1 = k.add(BigInteger.ONE);
            final BigInteger t1 = n.shiftLeft(1);
            final BigInteger n1 = n.multiply(k1);
            final BigInteger a1 = a.add(t1);
            final BigInteger l1 = l.add(BigInteger.valueOf(2));
            final BigInteger a2 = a1.multiply(l1);
            final BigInteger d1 = d.multiply(l1);
            final BigInteger[] tpl1 = compTpl1(a2, n1, d1, t1, u);
            final BigInteger t2 = tpl1[0];
            final BigInteger u1 = tpl1[1];
            final BigInteger[] tpl2 = compTpl2(a2, n1, d1, u1, i, t2);
            final BigInteger i1 = tpl2[0];
            final BigInteger a3 = tpl2[1];
            final BigInteger n2 = tpl2[2];
            return piHelper(i1, k1, l1, n2, a3, d1, t2, u1);
        }
    }

    public static BigInteger pi(BigInteger i) {
        return piHelper(i, BigInteger.ZERO, BigInteger.ONE, BigInteger.ONE, BigInteger.ZERO, BigInteger.ONE, BigInteger.ZERO, BigInteger.ZERO);
    }

    public static void main(String[] args) {
        long start = System.nanoTime();
        BigInteger result = pi(N);
        long end = System.nanoTime();
        long elapsed = (end - start) / 1000000;

        System.out.println("Time: " + elapsed + " ms");
        System.out.println("Result: " + result);
    }

}

