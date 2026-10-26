///|
test "first-class level polymorphic declarations" {
  inspect(check_level_polymorphic_declarations(), content="true")
}

///|
test "transparent type operator positivity extraction" {
  inspect(check_type_operator_positivity_extraction(), content="true")
}

///|
test "iterated non-uniform nested datatype Bush" {
  inspect(check_nested_iter_datatype(), content="true")
}

///|
test "primitive mutual declaration joint positivity" {
  inspect(check_mutual_declaration_positivity(), content="true")
}

///|
test "simultaneous induction recursion" {
  inspect(check_simultaneous_induction_recursion(), content="true")
}

///|
test "HIT moving dimension cell lift" {
  inspect(check_hit_moving_dimension_lift(), content="true")
}

///|
test "phase11 simultaneous IR compiled to decode" {
  inspect(check_simultaneous_ir_compiled_decode(), content="true")
}
