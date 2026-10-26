///|
fn random_face_for_sat_test(seed0 : Int32, n : Int32) -> Face {
  let mut seed = seed0
  let next = () => {
    seed = (seed * 1103515245 + 12345) & 2147483647
    seed
  }
  let literal = () => {
    let v = next() % n
    if next() % 2 == 0 {
      FEq1(DVar(v))
    } else {
      FEq0(DVar(v))
    }
  }
  let mut out = literal()
  for _i in 0..<18 {
    let clause = FOr(literal(), FOr(literal(), literal()))
    out = if next() % 5 == 0 { FOr(out, clause) } else { FAnd(out, clause) }
  }
  out
}

///|
test "watched DPLL agrees with brute force on generated faces" {
  let n = 7
  for seed in 1..<80 {
    let f = random_face_for_sat_test(seed * 7919, n)
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
    let g = random_face_for_sat_test(seed * 104729 + 17, n)
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
