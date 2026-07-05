# formal — small, honest experiments in machine-checked software

Hands-on examples of getting **machine-checked guarantees** about real code, using
proof assistants (Lean 4, Rocq/Coq) and an automatic program verifier
(Frama-C/WP). Each example is small enough to read in full, runs from a
`Makefile`, and is written to be *honest about what it does and does not show* —
including where a first impression turned out to be wrong.

## What's here

| Directory | Question it explores |
|---|---|
| [`gcd/`](gcd/README.md) | Prove one algorithm (Euclid's GCD) correct in **Lean 4** *and* **Rocq**, turn each proof into running code, and **compare the generated code** for correctness and performance. |
| [`wp-and-proofs/`](wp-and-proofs/README.md) | Where does **automatic** proving (Frama-C/WP + SMT) end and an **interactive** theorem prover (Coq) begin? A toy that shows both halves on one page. |

## The through-line

All of it is about the same goal — a guarantee a machine has checked, not a
human has eyeballed — approached along two axes:

- **Proof → code, vs code → proof.** In [`gcd/`](gcd/README.md) the proof comes
  *first*: you build the algorithm inside a system that refuses non-total or
  unproven code, then extract/compile it (**correct by construction**).
  [`wp-and-proofs/`](wp-and-proofs/README.md) also touches the opposite direction —
  take *existing* C and prove contracts about it after the fact (Frama-C/WP), the
  style used at scale elsewhere.

- **Automatic, vs interactive.** SMT solvers close most obligations with no human
  help; some obligations (notably **induction over a recursive definition**) lie
  categorically outside them and need an interactive prover. `wp-and-proofs/`
  isolates exactly that boundary; `gcd/` leans on each system's automation to make
  the proofs short.

Two properties recur in every example, because together they are what "correct"
means for a function: **termination** (the program always halts — non-trivial when
the recursion isn't structural) and **functional correctness** (the output meets
its mathematical spec).

## Two lessons the examples actually taught

- **Benchmark the code, not the harness.** In `gcd/` a first "50× " speed gap
  between the Lean- and Rocq-generated code turned out to be I/O and string
  parsing in a naive driver; isolated computation is a modest ~3.2×, for
  well-understood reasons (unbounded `Nat` object model vs unboxed native `int`).
  See [`gcd/tests/RESULTS.md`](gcd/tests/RESULTS.md).

- **Re-check the tool's limit before blaming it.** The `wp-and-proofs/` toy was
  meant to lift a "needs a theorem prover" case out of a Frama-C/WP proof — but on
  re-running, SMT discharged it fine; the earlier obstacle was a *missing
  precondition*, not a solver limit. The honest gap (induction) is a different,
  categorical one. See [`wp-and-proofs/README.md`](wp-and-proofs/README.md).

Both are the same discipline: trust the machine-checked verdict, and don't
over-claim from a misread of it.

## Running things

Each directory is self-contained with a `Makefile`:

```sh
make -C gcd            # check both proofs, generate code, build the runners
make -C gcd test       # correctness comparison (Lean vs Rocq extractions)
make -C gcd bench      # compute-bound performance benchmark
make -C wp-and-proofs  # the WP-vs-Coq complementarity demonstration
make -C <dir> clean    # remove build artefacts
```

Every generated file is reproducible from source; nothing here needs to be
committed.

## Toolchain

Lean 4.31.0 · Rocq / Coq 8.20.1 · OCaml 4.14.2 · Frama-C 32.1 (WP) ·
Alt-Ergo 2.6.2 · Z3 4.13.3 · GNU Make 4.4. No Mathlib, no CertiCoq required for
what runs here. Per-directory READMEs note anything else and any honest caveats.
