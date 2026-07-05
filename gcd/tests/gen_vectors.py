#!/usr/bin/env python3
# Deterministic GCD test vectors + reference (math.gcd). Emits "a b expected".
import math, random, sys
random.seed(20260704)

def emit(f, pairs):
    for a, b in pairs:
        f.write(f"{a} {b} {math.gcd(a,b)}\n")

# --- small vectors: values <= 1000 (safe for Rocq's unary nat) ---
small = []
# edge cases
small += [(0,0),(0,5),(5,0),(1,1),(7,7),(1,999),(999,1),(12,12)]
# one divides the other
small += [(6,18),(100,25),(81,27),(1000,10)]
# coprime
small += [(17,5),(101,100),(99,98),(35,64)]
# random
for _ in range(400):
    small.append((random.randint(0,1000), random.randint(0,1000)))
with open("tests/vectors_small.txt","w") as f: emit(f, small)

# --- big vectors: large values (Lean bignum). Rocq unary cannot do these. ---
big = []
big += [(1000000007, 998244353), (123456789, 987654321), (2**40, 3**25)]
# Fibonacci pair = worst case for Euclid (max iterations)
a,b = 1,1
for _ in range(88): a,b = b,a+b        # up to ~fib(90) ~ 2.8e18
big += [(b,a)]
for _ in range(200):
    big.append((random.randint(10**6,10**9), random.randint(10**6,10**9)))
with open("tests/vectors_big.txt","w") as f: emit(f, big)

print(f"small: {len(small)} pairs (<=1000), big: {len(big)} pairs (up to ~2.8e18)")
