open Rocq_gcd_int
let () =
  let s = ref 0 in
  for i = 0 to 10000000 - 1 do s := !s + rocq_gcd (i + 1000000000) 998244353 done;
  Printf.printf "%d\n" !s
