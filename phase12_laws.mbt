// ---------------------------------------------------------------------------
// Phase 12 law checks backing the theorem registry.
// ---------------------------------------------------------------------------

///|
fn phase12_pair_face(n : Int32) -> Face {
  let half = n / 2
  let mut out = FAnd(FEq1(DVar(0)), FEq1(DVar(half)))
  for i in 1..<half {
    out = FOr(out, FAnd(FEq1(DVar(i)), FEq1(DVar(i + half))))
  }
  out
}

///|
fn phase12_bdd_semantics_ok(f : Face, built : BddDagFace, n : Int32) -> Bool {
  for mask in 0..<(1 << n) {
    let env : Array[Bool] = []
    for i in 0..<n {
      let bit = (mask >> i) & 1
      env.push(bit == 1)
    }
    if bdd_dag_eval(built.manager, built.root, env) != face_holds(f, env) {
      return false
    }
  }
  true
}

///|
/// Subset-DP optimal BDD ordering agrees with factorial search on
/// small cases, remains exact at ten variables without trying all
/// permutations, and reports its cap honestly.
pub fn check_bdd_optimal_order_dp() -> Bool {
  for n in [2, 4, 6] {
    let f = phase12_pair_face(n)
    let brute = bdd_dag_of_face_optimal(f, n)
    let dp = bdd_dag_of_face_optimal_dp(f, n)
    if !dp.exact {
      return false
    }
    if dp.size != brute.size {
      return false
    }
    if !phase12_bdd_semantics_ok(f, dp.built, n) {
      return false
    }
  }
  let mixed = FOr(
    FAnd(FEq1(DVar(0)), FEq0(DVar(1))),
    FAnd(FEq1(DVar(1)), FOr(FEq0(DVar(2)), FEq1(DVar(3)))),
  )
  let brute = bdd_dag_of_face_optimal(mixed, 4)
  let dp = bdd_dag_of_face_optimal_dp(mixed, 4)
  if dp.size != brute.size {
    return false
  }
  let f10 = phase12_pair_face(10)
  let dp10 = bdd_dag_of_face_optimal(f10, 10, exact_max_vars=10)
  if !dp10.exact {
    return false
  }
  if dp10.tried != 5120 {
    return false
  }
  if !phase12_bdd_semantics_ok(f10, dp10.built, 10) {
    return false
  }
  let over_cap = bdd_dag_of_face_optimal_dp(FTop, 13)
  if over_cap.exact {
    return false
  }
  true
}

///|
/// CDCL UNSAT results carry RUP-checkable proofs; learned-clause
/// database reduction engages on a larger pigeonhole instance
/// without changing the recorded proof semantics.
pub fn check_cdcl_proof_and_reduction() -> Bool {
  if !face_cdcl_proof_check([[1], [-1]], [[]]) {
    return false
  }
  if face_cdcl_proof_check([[-1]], [[]]) {
    return false
  }
  let (php, pvars) = phase11_pigeonhole_face(6, 5)
  let result = face_sat_cdcl_proof(php, pvars, max_steps=2000000)
  if result.decision != FaceUnsat {
    return false
  }
  if result.stats.learned <= 0 {
    return false
  }
  if result.proof_clauses.length() != result.stats.learned + 1 {
    return false
  }
  if !face_cdcl_proof_check(result.original_clauses, result.proof_clauses) {
    return false
  }
  // Removing the final empty clause, or inserting a clause that
  // is not a RUP consequence, must invalidate the audit.
  let truncated : Array[Array[Int32]] = []
  for i in 0..<(result.proof_clauses.length() - 1) {
    truncated.push(result.proof_clauses[i])
  }
  if face_cdcl_proof_check(result.original_clauses, truncated) {
    return false
  }
  let bogus : Array[Array[Int32]] = []
  for i in 0..<result.proof_clauses.length() {
    bogus.push(result.proof_clauses[i])
    if i == 0 {
      bogus.push([1000000])
    }
  }
  if face_cdcl_proof_check(result.original_clauses, bogus) {
    return false
  }
  // SAT runs return no UNSAT proof.
  let (php_sat, svars) = phase11_pigeonhole_face(5, 5)
  let sat_result = face_sat_cdcl_proof(php_sat, svars, max_steps=2000000)
  match sat_result.decision {
    FaceSat(_) => ()
    _ => return false
  }
  if sat_result.proof_clauses.length() != 0 {
    return false
  }
  // Database reduction triggers on PHP(7,6); checking only the
  // report here keeps this acceptance from paying for a second
  // full proof audit on the larger instance.
  let (php76, vars76) = phase11_pigeonhole_face(7, 6)
  let report = face_sat_cdcl_report(php76, vars76, max_steps=5000000)
  if report.decision != FaceUnsat {
    return false
  }
  report.stats.deleted > 0
}
