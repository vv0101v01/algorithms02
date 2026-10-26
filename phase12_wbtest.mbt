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

///|
test "phase12: self-family Bush recursion, gather shapes and dependent Self parameters" {
  inspect(check_self_family_and_gather_shapes(), content="true")
}

///|
test "phase12: HOU pattern MGU, flex-flex intersection, pruning and residuals" {
  inspect(check_hou_pattern_mgu_and_residuals(), content="true")
}

///|
test "phase12: structural agreement regions and candidate-supplemented repair" {
  inspect(
    check_dsystem_structural_agreement_and_supplementation(),
    content="true",
  )
}

///|
test "phase12: artifact repository, DAG codec, version negotiation" {
  inspect(check_artifact_repository_and_dag_codec(), content="true")
}

///|
test "phase12: positivity declarations for opaque operators" {
  inspect(check_positivity_declarations(), content="true")
}

///|
test "phase12: simultaneous IR eliminator compilation for interdependent blocks" {
  inspect(check_simultaneous_ir_eliminator_compilation(), content="true")
}

///|
test "phase12: case-split conversion and path-valued circle/torus comp" {
  inspect(check_case_split_conversion_and_path_comp(), content="true")
}

///|
test "phase12: stratified extensionality for host cube functions" {
  inspect(check_dcube_stratified_extensionality(), content="true")
}

///|
test "phase12: loop unit 3-cells on sphere reps and exact rational Hopf" {
  inspect(check_loop_unit_3cells_and_hopf_exact(), content="true")
}
