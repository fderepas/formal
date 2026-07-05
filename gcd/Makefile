# formal/gcd — proven GCD in Lean & Rocq, plus a comparison test harness.
#
#   make            build everything (check proofs, generate code, build runners)
#   make test       (re)run the correctness comparison
#   make bench      run the compute-bound performance benchmark
#   make clean      remove build junk (objects, *.vo/.glob, binaries, backups)
#   make distclean  clean + remove generated code (Gcd.c, extracted .ml, vectors)
#
# Nothing here is meant to be committed: every generated file is reproducible.

SUBDIRS = rocq lean tests

.PHONY: all test bench clean distclean

all:
	@for d in $(SUBDIRS); do $(MAKE) -C $$d all || exit $$?; done

test:
	@$(MAKE) -C tests test

bench:
	@$(MAKE) -C tests bench

clean:
	@for d in $(SUBDIRS); do $(MAKE) -C $$d clean; done

distclean:
	@for d in $(SUBDIRS); do $(MAKE) -C $$d distclean; done
