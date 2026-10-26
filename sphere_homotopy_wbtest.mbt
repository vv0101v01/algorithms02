///|
test "spherical homotopy representatives" {
  inspect(check_sphere_homotopy_representatives(), content="true")
}

///|
test "classical Hopf map numerical invariants" {
  inspect(check_hopf_numeric(), content="true")
}
