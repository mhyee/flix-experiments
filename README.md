flix-experiments
================

A collection of benchmarks for Flix.

Some benchmarks are implemented in other languages (C++, Java, Scala, Ruby) for
comparison. Furthermore, there are two implementations for each language: an
"apples-to-apples" (A) version which is as close to Flix as possible, and an
"apples-to-oranges" (B) version which is written more naturally.

The Flix-only benchmarks are ones that would not make sense for comparisons with
other languages, since they rely heavily on the solver and its datastore. (When
rewritten for other languages, these benchmarks would probably use arrays, which
are very efficient due to cache locality and fewer memory allocations.)

The Strong Update analysis is a real benchmark (that is, not a toy program or
contrived example), and was one of the benchmarks used for the PLDI 2016 Flix
paper. The inputs for the analysis are kept in a separate, private repository.

The `scripts` directory contains scripts for running these benchmarks.

Includes:

- Fibonacci
- matrixmult (Flix only)
- n-body
- pidigits
- shortestpaths (Flix only)
- strongupdate (Flix only, see above)
