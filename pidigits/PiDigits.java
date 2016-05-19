import java.math.BigInteger;

class PiDigits {

    // pidigits, from the Computer Language Benchmarks Game.
    // http://benchmarksgame.alioth.debian.org/u64q/pidigits-description.html#pidigits

    // This implementation is a loose translation of the Flix program, which was loosely based on:
    // http://benchmarksgame.alioth.debian.org/u64q/program.php?test=pidigits&lang=yarv&id=3

    public static final BigInteger N = BigInteger.valueOf(10000);

    public static BigInteger[] compTpl1(BigInteger a2, BigInteger n1, BigInteger d1, BigInteger t1, BigInteger u) {
        BigInteger[] ret = new BigInteger[2];
        if (a2.compareTo(n1) >= 0) {
            ret[0] = ((n1.multiply(BigInteger.valueOf(3))).add(a2)).divide(d1);
            ret[1] = (((n1.multiply(BigInteger.valueOf(3))).add(a2)).mod(d1)).add(n1);
        } else {
            ret[0] = t1;
            ret[1] = u;
        }
        return ret;
    }

    public static BigInteger[] compTpl2(BigInteger a2, BigInteger n1, BigInteger d1, BigInteger u1, BigInteger i, BigInteger t2) {
        BigInteger[] ret = new BigInteger[3];
        if ((a2.compareTo(n1) >= 0) && (d1.compareTo(u1) > 0)) {
            ret[0] = i.subtract(BigInteger.ONE);
            ret[1] = (a2.subtract(d1.multiply(t2))).multiply(BigInteger.TEN);
            ret[2] = n1.multiply(BigInteger.TEN);
        } else {
            ret[0] = i;
            ret[1] = a2;
            ret[2] = n1;
        }
        return ret;
    }

    public static BigInteger pi(BigInteger i) {
        BigInteger j = i;
        BigInteger k = BigInteger.ZERO;
        BigInteger l = BigInteger.ONE;
        BigInteger n = BigInteger.ONE;
        BigInteger a = BigInteger.ZERO;
        BigInteger d = BigInteger.ONE;
        BigInteger t = BigInteger.ZERO;
        BigInteger u = BigInteger.ZERO;
        while (!j.equals(BigInteger.ZERO)) {
            k = k.add(BigInteger.ONE);
            t = n.shiftLeft(1);
            n = n.multiply(k);
            a = a.add(t);
            l = l.add(BigInteger.valueOf(2));
            a = a.multiply(l);
            d = d.multiply(l);
            BigInteger[] tpl1 = compTpl1(a, n, d, t, u);
            t = tpl1[0];
            u = tpl1[1];
            BigInteger[] tpl2 = compTpl2(a, n, d, u, j, t);
            j = tpl2[0];
            a = tpl2[1];
            n = tpl2[2];
        }
        return t;
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

