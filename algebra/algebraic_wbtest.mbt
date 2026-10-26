///|
test "algebraic extensions generalized eigenspaces and Jordan form" {
  inspect(check_algebraic_extensions_and_Jordan(), content="true")
}

///|
test "complete rational polynomial factorization" {
  inspect(check_qpoly_factor_complete(), content="true")
}

///|
test "exact real and complex root isolation" {
  inspect(check_root_isolation(), content="true")
}

///|
test "splitting fields and factorization over number fields" {
  inspect(check_splitting_field(), content="true")
}

///|
test "radical denesting beyond quadratic square roots" {
  inspect(check_radical_denesting(), content="true")
}

///|
test "Karatsuba integer polynomial multiplication agrees with schoolbook" {
  let a : Array[BigInt] = []
  let b : Array[BigInt] = []
  for i in 0..<97 {
    a.push(BigInt::from_int(i * 37 % 101 - 50))
    b.push(BigInt::from_int(i * 53 % 89 - 44))
  }
  assert_true(int_poly_mul_fast(a, b) == int_poly_mul_school(a, b))
  let x = qpoly_x()
  let p = qpoly_pow(qpoly_add(x, qpoly_int(1)), 37)
  assert_true(qpoly_degree(p) == 37)
  assert_true(rat_eq(qpoly_coeff(p, 0), rat_int(1)))
  assert_true(rat_eq(qpoly_coeff(p, 37), rat_int(1)))
}
