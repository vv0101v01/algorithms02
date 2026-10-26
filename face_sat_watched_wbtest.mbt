///|
test "watched DPLL agrees with brute force on generated faces" {
  let n = 7
  for seed in 1..<80 {
    let f = phase11_random_face(seed * 7919, n)
    let mut brute_sat = false
    for mask in 0..<pow2(n) {
      if face_holds(f, assignment_of_mask(mask, n)) {
        brute_sat = true
      }
    }
    match face_sat_watched_dpll(f, n, max_steps=100000) {
      FaceSat(env) => assert_true(brute_sat && face_holds(f, env))
      FaceUnsat => assert_false(brute_sat)
      FaceSearchBudgetExceeded => assert_false(true)
    }
    let g = phase11_random_face(seed * 104729 + 17, n)
    let mut brute_eq = true
    for mask in 0..<pow2(n) {
      let env = assignment_of_mask(mask, n)
      if face_holds(f, env) != face_holds(g, env) {
        brute_eq = false
      }
    }
    match face_eq_watched_dpll(f, g, n, max_steps=100000) {
      FaceDecided(eq) => assert_true(eq == brute_eq)
      FaceBudgetExceeded => assert_false(true)
    }
  }
}

///|
test "BDD and SAT cost optimizations" {
  assert_true(check_bdd_cost_optimizations())
}

///|
test "CDCL agrees with brute force and learns on pigeonhole" {
  assert_true(check_cdcl_clause_learning())
}
