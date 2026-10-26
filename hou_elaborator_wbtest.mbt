///|
test "pattern HOU drives bidirectional elaboration" {
  inspect(check_hou_elaborator(), content="true")
}

///|
test "phase 9 HOU fragments beyond Miller patterns" {
  inspect(check_hou_phase9_extensions(), content="true")
}

///|
test "bounded Huet search extensions" {
  assert_true(check_hou_bounded_search())
}

///|
test "phase11 HOU search extensions" {
  assert_true(check_hou_search_extensions())
}
