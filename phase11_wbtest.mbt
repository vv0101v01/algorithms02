///|
/// Phase 11 white-box tests; the assertion bodies live in
/// `phase11_laws.mbt` so the theorem registry can run them too.

///|
test "phase11: schema registry byte persistence roundtrips" {
  inspect(check_schema_registry_byte_persistence(), content="true")
}

///|
test "phase11: DTerm interner shares equal subterms and preserves terms" {
  inspect(check_dterm_hash_consing(), content="true")
}

///|
test "phase11: Face agreement region retains both endpoints" {
  inspect(check_face_agreement_and_exact_repair(), content="true")
}

///|
test "phase11: open-box filler assembles and verifies whole boundary" {
  inspect(check_dcube_open_box_filler(), content="true")
}

///|
test "phase11: circle and torus point-valued composition computes" {
  inspect(check_circle_torus_point_comp(), content="true")
}

///|
test "phase11: exact optimal BDD order beats blocked order and matches semantics" {
  inspect(check_bdd_optimal_order_exact(), content="true")
}

///|
test "phase11: family functor persistence and v1 refusal" {
  inspect(check_family_functor_persistence(), content="true")
}

///|
test "circle encode decode" {
  inspect(check_circle_encode_decode(), content="true")
}
