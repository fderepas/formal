-- The proven myGcd (def + termination; compiled code identical to the verified
-- module), driven over stdin pairs.  Nat = Lean's arbitrary-precision bignum.
def myGcd (a b : Nat) : Nat :=
  if h : b = 0 then a else myGcd b (a % b)
termination_by b
decreasing_by exact Nat.mod_lt a (Nat.pos_of_ne_zero h)

partial def loop : List Nat → IO Unit
  | a :: b :: rest => do IO.println (myGcd a b); loop rest
  | _ => pure ()

def main : IO Unit := do
  let input ← (← IO.getStdin).readToEnd
  let cleaned := ((input.replace "\n" " ").replace "\t" " ").replace "\r" " "
  let nums := (cleaned.splitOn " ").filterMap (·.toNat?)
  loop nums
