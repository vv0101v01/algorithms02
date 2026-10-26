///|
test "certified Hermitian Jacobi interval iteration" {
  inspect(check_Jacobi_interval(), content="true")
}

///|
test "arbitrary precision Jacobi endpoints" {
  inspect(check_Jacobi_arbitrary_precision(), content="true")
}
