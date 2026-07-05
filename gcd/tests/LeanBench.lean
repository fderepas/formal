def myGcd (a b : Nat) : Nat :=
  if h : b = 0 then a else myGcd b (a % b)
termination_by b
decreasing_by exact Nat.mod_lt a (Nat.pos_of_ne_zero h)
def bench (n : Nat) : Nat := Id.run do
  let mut s := 0
  for i in [0:n] do s := s + myGcd (i + 1000000000) 998244353
  return s
def main : IO Unit := IO.println (bench 10000000)
