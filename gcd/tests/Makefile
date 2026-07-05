# Comparison harness: build the three GCD runners (Lean-C, Rocq-unary, Rocq-int)
# and run correctness / performance comparisons.  See RESULTS.md.
LEAN     ?= lean
LEANC    ?= leanc
OCAMLOPT ?= ocamlopt

# Extracted Rocq OCaml is produced in ../rocq; we build/copy it here.
RGEN = rocq_gcd.ml rocq_gcd.mli rocq_gcd_int.ml rocq_gcd_int.mli

.PHONY: all test bench clean distclean

all: lean_gcd rocq_gcd_unary rocq_gcd_int vectors_small.txt vectors_big.txt

# Pull the extracted OCaml from ../rocq (grouped target: recipe runs once).
$(RGEN) &: ../rocq/Gcd.v ../rocq/Gcd_int.v
	$(MAKE) -C ../rocq all
	cp -f $(addprefix ../rocq/,$(RGEN)) .

# Deterministic test vectors + reference gcd.
vectors_small.txt vectors_big.txt &: gen_vectors.py
	python3 gen_vectors.py

# Runner 1: proven myGcd compiled Lean -> C -> native.
lean_gcd: LeanBatch.lean
	$(LEAN) -c LeanBatch.c LeanBatch.lean
	$(LEANC) LeanBatch.c -o lean_gcd

# Runner 2: Rocq extraction with unary Peano nat.
rocq_gcd_unary: rocq_gcd.mli rocq_gcd.ml rocq_batch.ml
	$(OCAMLOPT) rocq_gcd.mli rocq_gcd.ml rocq_batch.ml -o rocq_gcd_unary

# Runner 3: Rocq extraction with native OCaml int (+ native mod).
rocq_gcd_int: rocq_gcd_int.mli rocq_gcd_int.ml rocq_batch_int.ml
	$(OCAMLOPT) rocq_gcd_int.mli rocq_gcd_int.ml rocq_batch_int.ml -o rocq_gcd_int

# (Re)run the correctness comparison.
test: all
	@sh run_tests.sh

# Compute-bound benchmark (isolates the generated gcd from I/O).
bench: rocq_gcd_int
	$(LEAN) -c LeanBench.c LeanBench.lean && $(LEANC) LeanBench.c -o lean_bench
	$(OCAMLOPT) rocq_gcd_int.mli rocq_gcd_int.ml rocq_bench_int.ml -o rocq_bench_int
	@echo "Compute-bound: 10,000,000 gcd calls, one line out"
	@printf "  Lean(C):  "; { /usr/bin/time -f '%es' ./lean_bench >/dev/null; } 2>&1
	@printf "  Rocq-int: "; { /usr/bin/time -f '%es' ./rocq_bench_int >/dev/null; } 2>&1

# Junk + regenerable copies/binaries (keeps sources, vectors, RESULTS.md).
clean:
	rm -f *~ *.c *.cmi *.cmo *.cmx *.o *.olean *.out
	rm -f lean_gcd rocq_gcd_unary rocq_gcd_int lean_bench rocq_bench_int
	rm -f small_in.txt small_expected.txt big_in.txt big_expected.txt
	rm -f $(RGEN)

# Also drop the regenerable test vectors.
distclean: clean
	rm -f vectors_small.txt vectors_big.txt
