# formal/gcd — a verified Euclidean GCD in Lean 4 and Rocq, compared

The same small program — Euclid's `gcd(a, b) = gcd(b, a mod b)` — is **proved
correct twice**, once in **Lean 4** and once in **Rocq** (Coq 8.20), then turned
into executable code by each system's own pipeline. A test harness compares the
**generated code** for correctness and performance.

The point isn't the algorithm; it's to see, on one honest example, how two proof
assistants take you from a theorem to a running binary — and where they differ.

## Layout

| Dir | What it holds |
|---|---|
| [`lean/`](lean/README.md) | `Gcd.lean` — verified `myGcd` (termination + correctness); Lean lowers it to **C** natively (`Gcd.c`). |
| [`rocq/`](rocq/README.md) | `Gcd.v` — verified `rocq_gcd`; Rocq **extracts** it to **OCaml** (`rocq_gcd.ml`). `Gcd_int.v` is the fast native-`int` extraction. |
| [`tests/`](tests/RESULTS.md) | the comparison harness: shared test vectors, three runners, and [`RESULTS.md`](tests/RESULTS.md) with the measurements. |

## Quick start

```sh
make            # check both proofs, generate the code, build the runners
make test       # run the correctness comparison (Lean vs both Rocq extractions)
make bench      # compute-bound performance benchmark
make clean      # remove build junk (objects, *.vo/.glob, binaries, backups)
make distclean  # clean + remove generated code (Gcd.c, extracted .ml, vectors)
```

Every file under here is **reproducible from source** — nothing is meant to be
committed; `make` regenerates the generated code, `make distclean` removes it.

## What is proved (both sides, kernel-checked, no `sorry`/`admit`)

1. **Termination.** The recursion decreases on `b` — not structurally — so each
   system discharges an explicit obligation `a mod b < b` (Lean `termination_by`
   / Rocq `Function {measure b}`). A total, always-halting function.
2. **Functional correctness** — the full definition of gcd: the result **divides
   both** `a` and `b`, and is the **greatest** such (every common divisor divides
   it). Proved by induction that follows the algorithm's own control flow
   (`myGcd.induct` / `rocq_gcd_ind`). Core libraries only, no Mathlib.

## What the comparison shows (details in [`tests/RESULTS.md`](tests/RESULTS.md))

- **Correctness carries through codegen.** All implementations agree with a
  reference `gcd` and with each other, byte-for-byte, on every input they can run
  (416 small + 204 large pairs). The proof survives extraction/compilation.
- **Native target differs.** Lean emits **C** out of the box; Rocq's built-in
  `Extraction` emits **OCaml/Haskell** — true Rocq → C needs **CertiCoq** (not
  installed here; `rocq/README.md` has the recipe).
- **Representation dominates performance, and it's orthogonal to the proof.**
  Rocq's *default* extraction uses **unary Peano `nat`** — O(*value*), unusable
  past a few million (2×10⁷ → ~5 s; 10⁹ would need GBs of RAM). Switching to
  native `int` (`ExtrOcamlNatInt` **plus** remapping `mod`) makes it fast — at the
  cost of 63-bit bounds and trusted extraction axioms.
- **Beware benchmarking the harness.** A first "50× " gap turned out to be I/O and
  string-parsing in a naive Lean driver, not the gcd. Isolated compute is
  **~3.2×** (Lean's unbounded-`Nat` object model vs OCaml's unboxed native `int`)
  — a modest, well-understood gap. See the ⚠️ note in `RESULTS.md`.

## Toolchain

Lean 4.31.0 · Rocq / Coq 8.20.1 · OCaml 4.14.2 (`ocamlopt`) · GNU Make 4.4.
Lean and `leanc` come with the Lean toolchain; `coqc` + the extraction plugin
come with Coq. No Mathlib, no CertiCoq required for what runs here.

## Two routes to a machine-checked guarantee

This directory is the **correct-by-construction** route: build the algorithm
inside a proof assistant that refuses non-total or unproven code, then
extract/compile it. Its counterpart is the **verify-after-the-fact** route
(e.g. Frama-C/WP): take *existing* C and prove ACSL contracts — run-time-error
freedom, functional properties — about it. Same goal, approached from opposite
ends: here the proof produces the code; there the code precedes the proof.
