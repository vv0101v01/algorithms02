///|
test "BDD DAG scalability and certified numeric shadows" {
  inspect(check_bdd_and_certified_numeric(), content="true")
}

///|
test "certified algebraic numeric over cube root of two" {
  inspect(check_certified_algebraic_numeric(), content="true")
}

///|
test "BDD DAG native operations and total decisions" {
  inspect(check_bdd_dag_native_operations(), content="true")
}
