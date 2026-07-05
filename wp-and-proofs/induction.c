/*
  The half an automatic solver cannot do: reasoning by INDUCTION.

  `sum(n)` is defined recursively.  The closed form 2*sum(n) == n*(n+1) is true
  but its proof needs induction on n -- and SMT solvers do not do induction.
  WP emits the goal; Alt-Ergo/Z3 fail on it; Coq closes it in a few lines
  (see wsession/interactive/lemma_sum_closed.v).
*/

/*@ axiomatic Sum {
      logic integer sum(integer n);
      axiom sum_0: sum(0) == 0;
      axiom sum_n: \forall integer n; n >= 1 ==> sum(n) == n + sum(n-1);
    } */

/*@ lemma sum_closed: \forall integer n; n >= 0 ==> 2 * sum(n) == n * (n + 1); */
