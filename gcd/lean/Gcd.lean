/-
  A formally verified Euclidean GCD in Lean 4, compiled to C.

  Two things are proved (both checked by the Lean kernel, no `sorry`):
    1. TERMINATION  — Lean is total; the recursion on `b` is shown well-founded
                      via `Nat.mod_lt`, so the function is guaranteed to halt.
    2. CORRECTNESS  — `myGcd a b` is a common divisor of `a` and `b`, and it is
                      the *greatest* one (any common divisor divides it). Together
                      these are exactly the mathematical definition of gcd.

  Lean then compiles this to C (see `lean -c Gcd.c Gcd.lean`); the proofs are
  erased at compile time, leaving only the executable algorithm.
-/

namespace GcdLean

/-- Euclidean gcd: `(a, b) → (b, a % b)` until `b = 0`. The `termination_by`
    + `decreasing_by` clauses discharge the halting obligation. -/
@[export lean_myGcd]
def myGcd (a b : Nat) : Nat :=
  if h : b = 0 then
    a
  else
    myGcd b (a % b)
termination_by b
decreasing_by
  -- goal: a % b < b, given h : ¬ b = 0
  exact Nat.mod_lt a (Nat.pos_of_ne_zero h)

/-- Both correctness facts at once (so a single induction hypothesis suffices):
    `myGcd a b` divides both `a` and `b`. -/
theorem myGcd_dvd (a b : Nat) : myGcd a b ∣ a ∧ myGcd a b ∣ b := by
  induction a, b using myGcd.induct with
  | case1 a =>
    -- base: b = 0, so `myGcd a 0 = a`; need `a ∣ a ∧ a ∣ 0`
    unfold myGcd
    exact ⟨Nat.dvd_refl a, Nat.dvd_zero a⟩
  | case2 a b h ih =>
    -- step: b ≠ 0, so `myGcd a b = myGcd b (a % b)`; ih : (d ∣ b) ∧ (d ∣ a % b)
    rw [myGcd, dif_neg h]
    exact ⟨(Nat.dvd_mod_iff ih.1).mp ih.2, ih.1⟩

/-- `myGcd a b` divides `a`. -/
theorem myGcd_dvd_left (a b : Nat) : myGcd a b ∣ a := (myGcd_dvd a b).1

/-- `myGcd a b` divides `b`. -/
theorem myGcd_dvd_right (a b : Nat) : myGcd a b ∣ b := (myGcd_dvd a b).2

/-- Greatest: every common divisor of `a` and `b` divides `myGcd a b`.
    Quantifying `c` inside the motive makes the induction hypothesis usable. -/
theorem myGcd_greatest (a b : Nat) : ∀ c, c ∣ a → c ∣ b → c ∣ myGcd a b := by
  induction a, b using myGcd.induct with
  | case1 a =>
    -- base: myGcd a 0 = a, and we already have c ∣ a
    intro c ha _hb
    unfold myGcd
    exact ha
  | case2 a b h ih =>
    -- step: reduce to (b, a % b); c ∣ b given, c ∣ a % b from c ∣ a ∧ c ∣ b
    intro c ha hb
    rw [myGcd, dif_neg h]
    exact ih c hb ((Nat.dvd_mod_iff hb).mpr ha)

-- Executable sanity checks (evaluated by the Lean kernel/compiler, not proofs):
#eval myGcd 252 105   -- 21
#eval myGcd 1071 462  -- 21
#eval myGcd 17 5      -- 1

end GcdLean

/-- A `main` so the compiled C is a runnable program. -/
def main : IO Unit := do
  IO.println s!"gcd(252, 105)  = {GcdLean.myGcd 252 105}"
  IO.println s!"gcd(1071, 462) = {GcdLean.myGcd 1071 462}"

