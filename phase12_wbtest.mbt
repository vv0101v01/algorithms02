///|
/// Phase 12 white-box tests; bodies live in `phase12_laws.mbt`.

///|
test "phase12: subset DP gives exact optimal BDD order beyond factorial range" {
  inspect(check_bdd_optimal_order_dp(), content="true")
}

///|
test "phase12: CDCL proofs are RUP-checkable and clause DB reduction engages" {
  inspect(check_cdcl_proof_and_reduction(), content="true")
}
