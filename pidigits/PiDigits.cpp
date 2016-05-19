#include <cstdio>
#include <chrono>
#include <tuple>
#include <gmpxx.h>

// pidigits, from the Computer Language Benchmarks Game.
// http://benchmarksgame.alioth.debian.org/u64q/pidigits-description.html#pidigits

// This implementation is a loose translation of the Flix program, which was loosely based on:
// http://benchmarksgame.alioth.debian.org/u64q/program.php?test=pidigits&lang=yarv&id=3

const mpz_class N = 10000;

std::tuple<mpz_class, mpz_class> compTpl1(mpz_class a2, mpz_class n1, mpz_class d1, mpz_class t1, mpz_class u) {
    if (a2 >= n1) {
        return std::make_tuple(((n1 * 3) + a2) / d1, (((n1 * 3) + a2) % d1) + n1);
    } else {
        return std::make_tuple(t1, u);
    }
}

std::tuple<mpz_class, mpz_class, mpz_class> compTpl2(mpz_class a2, mpz_class n1, mpz_class d1, mpz_class u1, mpz_class i, mpz_class t2) {
    if (a2 >= n1 && d1 > u1) {
        return std::make_tuple(i - 1, (a2 - (d1 * t2)) * 10, n1 * 10);
    } else {
        return std::make_tuple(i, a2, n1);
    }
}

mpz_class pi(mpz_class i) {
    mpz_class j = i;
    mpz_class k = 0;
    mpz_class l = 1;
    mpz_class n = 1;
    mpz_class a = 0;
    mpz_class d = 1;
    mpz_class t = 0;
    mpz_class u = 0;
    while (j != 0) {
        k = k + 1;
        t = n << 1;
        n = n * k;
        a = a + t;
        l = l + 2;
        a = a * l;
        d = d * l;
        auto tpl1 = compTpl1(a, n, d, t, u);
        t = std::get<0>(tpl1);
        u = std::get<1>(tpl1);
        auto tpl2 = compTpl2(a, n, d, u, j, t);
        j = std::get<0>(tpl2);
        a = std::get<1>(tpl2);
        n = std::get<2>(tpl2);
    }
    return t;
}

int main(int argv, char **argc) {
    auto start = std::chrono::high_resolution_clock::now();
    auto result = pi(N);
    auto end = std::chrono::high_resolution_clock::now();
    auto elapsed = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count() / 1000000;

    printf("Time: %ld ms\n", elapsed);
    gmp_printf("Result: %Zd\n", result.get_mpz_t());
}

