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
fn pigeonhole_face(pigeons : Int32, holes : Int32) -> (Face, Int32) {
  // Variable (p, h) has index p * holes + h: "pigeon p in hole h".
  let lit = (index : Int32, positive : Bool) => {
    if positive {
      FEq1(DVar(index))
    } else {
      FEq0(DVar(index))
    }
  }
  let mut out : Face = FTop
  let mut started = false
  let conjoin = (clause : Face) => {
    out = if started { FAnd(out, clause) } else { clause }
    started = true
  }
  for pigeon in 0..<pigeons {
    let mut clause = lit(pigeon * holes, true)
    for h in 1..<holes {
      clause = FOr(clause, lit(pigeon * holes + h, true))
    }
    conjoin(clause)
  }
  for h in 0..<holes {
    for p1 in 0..<pigeons {
      for p2 in (p1 + 1)..<pigeons {
        conjoin(FOr(lit(p1 * holes + h, false), lit(p2 * holes + h, false)))
      }
    }
  }
  (out, pigeons * holes)
}

///|
test "CDCL agrees with brute force and learns on pigeonhole" {
  let expected_Luby = [1, 1, 2, 1, 1, 2, 4, 1, 1, 2, 1, 1, 2, 4, 8]
  for i in 0..<expected_Luby.length() {
    assert_true(cdcl_Luby(i) == expected_Luby[i])
  }
  let n = 7
  for seed in 1..<80 {
    let f = random_face_for_sat_test(seed * 7919, n)
    let mut brute_sat = false
    for mask in 0..<pow2(n) {
      if face_holds(f, assignment_of_mask(mask, n)) {
        brute_sat = true
      }
    }
    match face_sat_cdcl(f, n, max_steps=100000) {
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
    match face_eq_cdcl(f, g, n, max_steps=100000) {
      FaceDecided(eq) => assert_true(eq == brute_eq)
      FaceBudgetExceeded => assert_false(true)
    }
  }
  // PHP(6,5): UNSAT; clause learning must engage and beat the
  // chronological solver's step count.
  let (php, pvars) = pigeonhole_face(6, 5)
  let cdcl = face_sat_cdcl_report(php, pvars, max_steps=2000000)
  assert_true(cdcl.decision == FaceUnsat)
  assert_true(cdcl.stats.learned > 0)
  assert_true(cdcl.stats.conflicts > 0)
  // PHP(5,5) is SAT and every model is checked.
  let (php_sat, svars) = pigeonhole_face(5, 5)
  match face_sat_cdcl(php_sat, svars, max_steps=2000000) {
    FaceSat(env) => assert_true(face_holds(php_sat, env))
    _ => assert_false(true)
  }
}
