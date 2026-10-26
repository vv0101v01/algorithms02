///|
test "stable binary compiled-module format" {
  assert_true(check_module_binary_format())
}

///|
test "phase11 binary versions, migration and byte store" {
  assert_true(check_module_binary_versions_and_store())
}
