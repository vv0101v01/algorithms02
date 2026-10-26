///|
test "adjoint equivalence and contractible fibers" {
  inspect(check_adjoint_equivalence_and_fibers(), content="true")
}

///|
test "GlueEquiv quote preserves syntax" {
  inspect(check_glue_equiv_quote_preserves_syntax(), content="true")
}
