///|
test "parameterized modules, imports, opens and namespaces" {
  inspect(check_module_system(), content="true")
}

///|
test "phase11 interleaved module items" {
  assert_true(check_module_interleaved_items())
}
