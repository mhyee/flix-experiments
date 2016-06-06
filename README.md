flix-experiments
================

A collection of benchmarks for Flix.

Some benchmarks are implemented in other languages (C++, Java, Scala, Ruby) for
comparison. These implementations are written "naturally." They are written
clearly in a style that fits with the language, are not optimized, and do not
intentionally mimic the Flix code. Thus, they will use mutability and iteration
instead of immutability and recursion, but the overall data structures and
algorithms are the same. The Scala implementations are written in a functional
style, and are therefore more similar to Flix than Java.

The Flix-only benchmarks are ones that would not make sense for comparisons with
other languages, since they rely heavily on the solver and its datastore. (When
rewritten for other languages, these benchmarks would probably use arrays, which
are very efficient due to cache locality and fewer memory allocations.)

The Strong Update analysis is a real benchmark (that is, not a toy program or
contrived example), and was one of the benchmarks used for the PLDI 2016 Flix
paper. The inputs for the analysis are kept in a separate, private repository.

The `scripts` directory contains scripts for running these benchmarks.

Includes:

- fibonacci
- matrixmult (Flix only)
- nbody
- pidigits
- shortestpaths (Flix only)
- strongupdate (Flix only, see above)
