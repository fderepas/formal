/*
  The half an automatic verifier does well.

  `align_up_pow2` rounds `v` up to a multiple of the alignment `a` (a power of
  two).  Frama-C's WP generates the proof obligations -- run-time safety (no
  overflow, valid pointer) AND the functional lower bound `*r >= v`, whose
  correctness rests on the bitwise fact `x & (a-1) <= a-1` -- and the SMT solvers
  (Alt-Ergo, Z3) discharge ALL of them automatically.  No human proof needed.
  (The function is extracted verbatim from peimage's PE-image loader.)
*/

#include <stdint.h>
#include <stdbool.h>

#ifdef __FRAMAC__
#include <__fc_gcc_builtins.h>   /* WP's ACSL specs for __builtin_add_overflow */
#endif

/*@ requires \valid(r);
    requires a >= 1;                 // an alignment is a positive power of two
    assigns *r;
    ensures \result ==> *r >= v;     // rounding up never lands below the input
*/
bool align_up_pow2(uint64_t v, uint64_t a, uint64_t *r)
{
  uint64_t t;
  if (__builtin_add_overflow(v, a - 1, &t))     // t = v + (a-1), or bail on wrap
    return false;
  uint64_t low = t & (a - 1);
  *r = t - low;                                 // == t & ~(a-1) for power-of-two a
  return true;
}
