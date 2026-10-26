///|
test "certified Hermitian Jacobi interval iteration" {
  inspect(check_Jacobi_interval(), content="true")
}

///|
test "arbitrary precision Jacobi endpoints" {
  inspect(check_Jacobi_arbitrary_precision(), content="true")
}

///|
test "Jacobi eigenvalue cluster separation by exact isolation" {
  inspect(check_jacobi_cluster_separation(), content="true")
}

///|
test "phase12: cluster-aware Jacobi iteration separates inside the loop" {
  inspect(check_jacobi_cluster_aware_iteration(), content="true")
}
