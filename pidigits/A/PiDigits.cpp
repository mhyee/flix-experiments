#include <cstdio>
#include <chrono>
#include <tuple>
#include <gmpxx.h>

// pidigits, from the Computer Language Benchmarks Game.
// http://benchmarksgame.alioth.debian.org/u64q/pidigits-description.html#pidigits

// This implementation is a close translation of the Flix program, which was loosely based on:
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

mpz_class piHelper(mpz_class i, mpz_class k, mpz_class l, mpz_class n, mpz_class a, mpz_class d, mpz_class t, mpz_class u) {
    if (i == 0) {
        return t;
    } else {
        const auto k1 = k + 1;
        const auto t1 = n << 1;
        const auto n1 = n * k1;
        const auto a1 = a + t1;
        const auto l1 = l + 2;
        const auto a2 = a1 * l1;
        const auto d1 = d * l1;
        const auto tpl1 = compTpl1(a2, n1, d1, t1, u);
        const auto t2 = std::get<0>(tpl1);
        const auto u1 = std::get<1>(tpl1);
        const auto tpl2 = compTpl2(a2, n1, d1, u1, i, t2);
        const auto i1 = std::get<0>(tpl2);
        const auto a3 = std::get<1>(tpl2);
        const auto n2 = std::get<2>(tpl2);
        return piHelper(i1, k1, l1, n2, a3, d1, t2, u1);
    }
}

mpz_class pi(mpz_class i) {
    return piHelper(i, 0, 1, 1, 0, 1, 0, 0);
}

int main(int, char**) {
    auto start = std::chrono::high_resolution_clock::now();
    auto result = pi(N);
    auto end = std::chrono::high_resolution_clock::now();
    auto elapsed = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count() / 1000000;

    printf("Time: %ld ms\n", elapsed);
    gmp_printf("Result: %Zd\n", result.get_mpz_t());
}

