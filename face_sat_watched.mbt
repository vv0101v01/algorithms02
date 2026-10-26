///|\
// Watched-literal DPLL for faces.
//
// A face and the dimension expressions inside its atoms form one
// Boolean formula over the dimension variables.  This file compiles
// that formula to CNF by Tseitin extension variables, then searches
// with watched literals, saved phases, and conflict-driven variable
// activity.  It complements the ROBDD decision procedure: the BDD
// is canonical but can be exponentially large for a bad order or a
// hard function, whereas this solver trades canonicity for search
// and returns the existing budget-exceeded status rather than
// guessing when its step budget is exhausted.

///|
pub struct FaceCnfStats {
  variables : Int32
  auxiliary_variables : Int32
  clauses : Int32
  literals : Int32
} derive(Debug, Eq)

///|
pub extend FaceCnfStats with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend FaceCnfStats with Eq::{not_equal, equal}

///|
enum FaceBoolExpr {
  FBEConst(Bool)
  FBEVar(Int32)
  FBENot(FaceBoolExpr)
  FBEAnd(FaceBoolExpr, FaceBoolExpr)
  FBEOr(FaceBoolExpr, FaceBoolExpr)
} derive(Debug, Eq)

///|
pub extend FaceBoolExpr with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend FaceBoolExpr with Eq::{not_equal, equal}

///|
fn fbe_not(a : FaceBoolExpr) -> FaceBoolExpr {
  match a {
    FBEConst(b) => FBEConst(!b)
    FBENot(x) => x
    _ => FBENot(a)
  }
}

///|
fn fbe_and(a : FaceBoolExpr, b : FaceBoolExpr) -> FaceBoolExpr {
  match (a, b) {
    (FBEConst(false), _) | (_, FBEConst(false)) => FBEConst(false)
    (FBEConst(true), x) => x
    (x, FBEConst(true)) => x
    _ => if a == b { a } else { FBEAnd(a, b) }
  }
}

///|
fn fbe_or(a : FaceBoolExpr, b : FaceBoolExpr) -> FaceBoolExpr {
  match (a, b) {
    (FBEConst(true), _) | (_, FBEConst(true)) => FBEConst(true)
    (FBEConst(false), x) => x
    (x, FBEConst(false)) => x
    _ => if a == b { a } else { FBEOr(a, b) }
  }
}

///|
fn fbe_of_dim(r : Dim, n : Int32) -> FaceBoolExpr {
  match r {
    DZero => FBEConst(false)
    DOne => FBEConst(true)
    DVar(i) => if i >= 0 && i < n { FBEVar(i) } else { FBEConst(false) }
    DNeg(a) => fbe_not(fbe_of_dim(a, n))
    DAnd(a, b) => fbe_and(fbe_of_dim(a, n), fbe_of_dim(b, n))
    DOr(a, b) => fbe_or(fbe_of_dim(a, n), fbe_of_dim(b, n))
  }
}

///|
fn fbe_of_face(f : Face, n : Int32) -> FaceBoolExpr {
  match f {
    FTop => FBEConst(true)
    FBot => FBEConst(false)
    FEq0(r) => fbe_not(fbe_of_dim(r, n))
    FEq1(r) => fbe_of_dim(r, n)
    FAnd(a, b) => fbe_and(fbe_of_face(a, n), fbe_of_face(b, n))
    FOr(a, b) => fbe_or(fbe_of_face(a, n), fbe_of_face(b, n))
  }
}

///|
priv struct FaceCnfBuilder {
  clauses : Array[Array[Int32]]
  mut next_variable : Int32
}

///|
fn face_cnf_add_clause(builder : FaceCnfBuilder, input : Array[Int32]) -> Unit {
  let clause : Array[Int32] = []
  for i in 0..<input.length() {
    let lit = input[i]
    let mut duplicate = false
    let mut tautology = false
    for j in 0..<clause.length() {
      if clause[j] == lit {
        duplicate = true
      }
      if clause[j] == 0 - lit {
        tautology = true
      }
    }
    if tautology {
      return
    }
    if !duplicate {
      clause.push(lit)
    }
  }
  builder.clauses.push(clause)
}

///|
fn face_cnf_tseitin(builder : FaceCnfBuilder, expr : FaceBoolExpr) -> Int32 {
  match expr {
    FBEConst(true) => {
      let variable = builder.next_variable
      builder.next_variable = builder.next_variable + 1
      face_cnf_add_clause(builder, [variable])
      variable
    }
    FBEConst(false) => {
      let variable = builder.next_variable
      builder.next_variable = builder.next_variable + 1
      face_cnf_add_clause(builder, [0 - variable])
      variable
    }
    FBEVar(i) => i + 1
    FBENot(a) => 0 - face_cnf_tseitin(builder, a)
    FBEAnd(a, b) => {
      let la = face_cnf_tseitin(builder, a)
      let lb = face_cnf_tseitin(builder, b)
      let x = builder.next_variable
      builder.next_variable = builder.next_variable + 1
      face_cnf_add_clause(builder, [0 - x, la])
      face_cnf_add_clause(builder, [0 - x, lb])
      face_cnf_add_clause(builder, [x, 0 - la, 0 - lb])
      x
    }
    FBEOr(a, b) => {
      let la = face_cnf_tseitin(builder, a)
      let lb = face_cnf_tseitin(builder, b)
      let x = builder.next_variable
      builder.next_variable = builder.next_variable + 1
      face_cnf_add_clause(builder, [x, 0 - la])
      face_cnf_add_clause(builder, [x, 0 - lb])
      face_cnf_add_clause(builder, [0 - x, la, lb])
      x
    }
  }
}

///|
fn face_cnf_build(f : Face, n : Int32) -> FaceCnfBuilder {
  let builder = FaceCnfBuilder::{ clauses: [], next_variable: n + 1, }
  let root = face_cnf_tseitin(builder, fbe_of_face(face_bound(f, n), n))
  face_cnf_add_clause(builder, [root])
  builder
}

///|
/// Size of the Tseitin CNF used by the watched-literal solver.
pub fn face_cnf_stats(f : Face, n : Int32) -> FaceCnfStats {
  let builder = face_cnf_build(f, n)
  let mut literals = 0
  for i in 0..<builder.clauses.length() {
    literals = literals + builder.clauses[i].length()
  }
  FaceCnfStats::{
    variables: builder.next_variable - 1,
    auxiliary_variables: builder.next_variable - 1 - n,
    clauses: builder.clauses.length(),
    literals,
  }
}

///|
priv struct FaceSatSolver {
  clauses : Array[Array[Int32]]
  watches : Array[Array[Int32]]
  assignment : Array[Int32] // -1 unassigned, 0 false, 1 true; 1-based vars
  phase : Array[Bool]
  activity : Array[Double]
  trail : Array[Int32]
  mut qhead : Int32
  variables : Int32
  mut steps : Int32
  max_steps : Int32
  mut budget_exceeded : Bool
}

///|
fn face_sat_lit_index(lit : Int32) -> Int32 {
  let variable = if lit < 0 { 0 - lit } else { lit }
  2 * variable + (if lit < 0 { 1 } else { 0 })
}

///|
fn face_sat_lit_value(solver : FaceSatSolver, lit : Int32) -> Int32 {
  let variable = if lit < 0 { 0 - lit } else { lit }
  let value = solver.assignment[variable]
  if value < 0 {
    -1
  } else if lit > 0 {
    value
  } else {
    1 - value
  }
}

///|
fn face_sat_enqueue(solver : FaceSatSolver, lit : Int32) -> Bool {
  let variable = if lit < 0 { 0 - lit } else { lit }
  let wanted = if lit > 0 { 1 } else { 0 }
  let current = solver.assignment[variable]
  if current >= 0 {
    return current == wanted
  }
  solver.assignment[variable] = wanted
  solver.phase[variable] = wanted == 1
  solver.trail.push(lit)
  true
}

///|
fn face_sat_undo_to(solver : FaceSatSolver, length : Int32) -> Unit {
  while solver.trail.length() > length {
    match solver.trail.pop() {
      Some(lit) => {
        let variable = if lit < 0 { 0 - lit } else { lit }
        solver.assignment[variable] = -1
      }
      None => ()
    }
  }
  if solver.qhead > length {
    solver.qhead = length
  }
}

///|
fn face_sat_bump_clause(solver : FaceSatSolver, clause : Array[Int32]) -> Unit {
  for i in 0..<clause.length() {
    let variable = if clause[i] < 0 { 0 - clause[i] } else { clause[i] }
    solver.activity[variable] = solver.activity[variable] + 1.0
  }
}

///|
/// Propagate with watched literals.  Returns a conflicting clause
/// index, `-1` for no conflict, or `-2` on budget exhaustion.
fn face_sat_propagate(solver : FaceSatSolver) -> Int32 {
  while solver.qhead < solver.trail.length() {
    solver.steps = solver.steps + 1
    if solver.max_steps > 0 && solver.steps > solver.max_steps {
      solver.budget_exceeded = true
      return -2
    }
    let true_lit = solver.trail[solver.qhead]
    solver.qhead = solver.qhead + 1
    let false_lit = 0 - true_lit
    let watchers = solver.watches[face_sat_lit_index(false_lit)]
    let mut read = 0
    let mut write = 0
    let mut conflict = -1
    while read < watchers.length() {
      let clause_index = watchers[read]
      read = read + 1
      solver.steps = solver.steps + 1
      if solver.max_steps > 0 && solver.steps > solver.max_steps {
        solver.budget_exceeded = true
        conflict = -2
        // Preserve the unprocessed watchers before returning.
        watchers[write] = clause_index
        write = write + 1
        while read < watchers.length() {
          watchers[write] = watchers[read]
          write = write + 1
          read = read + 1
        }
        break
      }
      let clause = solver.clauses[clause_index]
      if clause.length() < 2 {
        watchers[write] = clause_index
        write = write + 1
        continue
      }
      if clause[0] == false_lit {
        clause[0] = clause[1]
        clause[1] = false_lit
      }
      if clause[1] != false_lit {
        watchers[write] = clause_index
        write = write + 1
        continue
      }
      let other = clause[0]
      if face_sat_lit_value(solver, other) == 1 {
        watchers[write] = clause_index
        write = write + 1
        continue
      }
      let mut replacement = -1
      for k in 2..<clause.length() {
        if face_sat_lit_value(solver, clause[k]) != 0 {
          replacement = k
          break
        }
      }
      if replacement >= 0 {
        let moved = clause[replacement]
        clause[replacement] = clause[1]
        clause[1] = moved
        solver.watches[face_sat_lit_index(moved)].push(clause_index)
        continue
      }
      watchers[write] = clause_index
      write = write + 1
      if face_sat_lit_value(solver, other) == 0 {
        conflict = clause_index
        while read < watchers.length() {
          watchers[write] = watchers[read]
          write = write + 1
          read = read + 1
        }
        break
      }
      if !face_sat_enqueue(solver, other) {
        conflict = clause_index
        while read < watchers.length() {
          watchers[write] = watchers[read]
          write = write + 1
          read = read + 1
        }
        break
      }
    }
    while watchers.length() > write {
      ignore(watchers.pop())
    }
    if conflict >= 0 {
      face_sat_bump_clause(solver, solver.clauses[conflict])
      return conflict
    }
    if conflict == -2 {
      return -2
    }
  }
  -1
}

///|
fn face_sat_pick_variable(solver : FaceSatSolver) -> Int32 {
  let mut best = -1
  let mut best_activity = -1.0
  for variable in 1..<(solver.variables + 1) {
    if solver.assignment[variable] < 0 &&
      solver.activity[variable] > best_activity {
      best = variable
      best_activity = solver.activity[variable]
    }
  }
  best
}

///|
fn face_sat_search(solver : FaceSatSolver) -> Int32 {
  let conflict = face_sat_propagate(solver)
  if conflict >= 0 {
    return 0
  }
  if conflict == -2 || solver.budget_exceeded {
    return -1
  }
  let variable = face_sat_pick_variable(solver)
  if variable < 0 {
    return 1
  }
  solver.steps = solver.steps + 1
  if solver.max_steps > 0 && solver.steps > solver.max_steps {
    solver.budget_exceeded = true
    return -1
  }
  let checkpoint = solver.trail.length()
  let first_phase = solver.phase[variable]
  for attempt in 0..<2 {
    face_sat_undo_to(solver, checkpoint)
    let phase = if attempt == 0 { first_phase } else { !first_phase }
    let lit = if phase { variable } else { 0 - variable }
    if !face_sat_enqueue(solver, lit) {
      continue
    }
    let result = face_sat_search(solver)
    if result != 0 {
      return result
    }
  }
  face_sat_undo_to(solver, checkpoint)
  0
}

///|
/// Satisfiability by CNF conversion and watched-literal search.
/// `max_steps <= 0` means an unbounded search.
pub fn face_sat_watched_dpll(
  f : Face,
  n : Int32,
  max_steps~ : Int32 = 100000,
) -> FaceSatDecision {
  let builder = face_cnf_build(f, n)
  let variables = builder.next_variable - 1
  let watches : Array[Array[Int32]] = []
  for _i in 0..<(2 * (variables + 2)) {
    watches.push([])
  }
  let assignment : Array[Int32] = []
  let phase : Array[Bool] = []
  let activity : Array[Double] = []
  for _i in 0..<(variables + 1) {
    assignment.push(-1)
    phase.push(true)
    activity.push(0.0)
  }
  let solver = FaceSatSolver::{
    clauses: builder.clauses,
    watches,
    assignment,
    phase,
    activity,
    trail: [],
    qhead: 0,
    variables,
    steps: 0,
    max_steps,
    budget_exceeded: false,
  }
  for ci in 0..<solver.clauses.length() {
    let clause = solver.clauses[ci]
    if clause.length() == 0 {
      return FaceUnsat
    }
    for i in 0..<clause.length() {
      let variable = if clause[i] < 0 { 0 - clause[i] } else { clause[i] }
      solver.activity[variable] = solver.activity[variable] + 1.0
    }
    if clause.length() == 1 {
      if !face_sat_enqueue(solver, clause[0]) {
        return FaceUnsat
      }
    } else {
      solver.watches[face_sat_lit_index(clause[0])].push(ci)
      solver.watches[face_sat_lit_index(clause[1])].push(ci)
    }
  }
  match face_sat_search(solver) {
    1 => {
      let env : Array[Bool] = []
      for i in 0..<n {
        env.push(solver.assignment[i + 1] == 1)
      }
      // The witness is checked before it leaves the solver.
      if face_holds(face_bound(f, n), env) {
        FaceSat(env)
      } else {
        FaceSearchBudgetExceeded
      }
    }
    0 => FaceUnsat
    _ => FaceSearchBudgetExceeded
  }
}

///|
/// Face equality through the watched-literal solver applied to the
/// symmetric difference.
pub fn face_eq_watched_dpll(
  f : Face,
  g : Face,
  n : Int32,
  max_steps~ : Int32 = 100000,
) -> FaceDecision {
  let difference = FOr(FAnd(f, face_not(g)), FAnd(g, face_not(f)))
  match face_sat_watched_dpll(difference, n, max_steps~) {
    FaceSat(_) => FaceDecided(false)
    FaceUnsat => FaceDecided(true)
    FaceSearchBudgetExceeded => FaceBudgetExceeded
  }
}

// ---------------------------------------------------------------------------
// Phase 11: CDCL (conflict-driven clause learning) over the same CNF.
//
// The watched DPLL above backtracks chronologically.  This solver
// keeps the same CNF builder and two-watched-literal propagation,
// but records a reason clause for every propagated literal, and on
// conflict performs first-UIP analysis: the conflicting clause is
// resolved with reason clauses along the trail until a single
// literal of the current decision level remains.  The resolvent is
// learned (it is a resolution consequence of the original CNF, so
// learning is sound), the search back*jumps* to the second-highest
// level in the learned clause, and the learned clause immediately
// propagates there.  Variable selection is VSIDS with phase
// saving; restarts follow the Luby sequence.  At each restart a
// clause-database reduction deletes long, high-LBD learned
// clauses that are not reasons for the level-0 trail, while a
// separate proof log retains every learned clause for auditing.
// ---------------------------------------------------------------------------

///|
pub struct FaceCdclStats {
  decisions : Int32
  conflicts : Int32
  propagations : Int32
  learned : Int32
  deleted : Int32
  restarts : Int32
} derive(Debug, Eq)

///|
pub extend FaceCdclStats with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend FaceCdclStats with Eq::{not_equal, equal}

///|
pub struct FaceCdclResult {
  decision : FaceSatDecision
  stats : FaceCdclStats
}

///|
/// A completed CDCL run together with the clause-level data
/// needed to audit an UNSAT answer independently.  Clauses use
/// the solver's signed-literal encoding (variables are positive
/// integers; negation is arithmetic negation).  For UNSAT,
/// `proof_clauses` is the sequence of learned clauses in the
/// order they were derived, followed by the empty clause; every
/// entry is checkable by reverse unit propagation
/// (`face_cdcl_proof_check`).  Solver-side clause deletion never
/// removes entries from this recorded proof.
pub struct FaceCdclProofResult {
  decision : FaceSatDecision
  stats : FaceCdclStats
  original_clauses : Array[Array[Int32]]
  proof_clauses : Array[Array[Int32]]
}

///|
priv struct FaceCdclSolver {
  clauses : Array[Array[Int32]]
  clause_lbd : Array[Int32]
  clause_is_learned : Array[Bool]
  proof_clauses : Array[Array[Int32]]
  watches : Array[Array[Int32]]
  assignment : Array[Int32]
  level_of : Array[Int32]
  reason_of : Array[Int32]
  phase : Array[Bool]
  activity : Array[Double]
  mut var_inc : Double
  trail : Array[Int32]
  trail_lim : Array[Int32]
  mut qhead : Int32
  variables : Int32
  mut steps : Int32
  max_steps : Int32
  mut budget_exceeded : Bool
  seen : Array[Bool]
  mut decisions : Int32
  mut conflicts : Int32
  mut propagations : Int32
  mut learned_count : Int32
  mut deleted_count : Int32
  mut restarts : Int32
}

///|
fn cdcl_var_of(lit : Int32) -> Int32 {
  if lit < 0 {
    0 - lit
  } else {
    lit
  }
}

///|
fn cdcl_decision_level(solver : FaceCdclSolver) -> Int32 {
  solver.trail_lim.length()
}

///|
fn cdcl_enqueue(solver : FaceCdclSolver, lit : Int32, reason : Int32) -> Bool {
  let variable = cdcl_var_of(lit)
  let wanted = if lit > 0 { 1 } else { 0 }
  let current = solver.assignment[variable]
  if current >= 0 {
    return current == wanted
  }
  solver.assignment[variable] = wanted
  solver.phase[variable] = wanted == 1
  solver.level_of[variable] = cdcl_decision_level(solver)
  solver.reason_of[variable] = reason
  solver.trail.push(lit)
  true
}

///|
fn cdcl_cancel_to(solver : FaceCdclSolver, level : Int32) -> Unit {
  if cdcl_decision_level(solver) <= level {
    return
  }
  let target = solver.trail_lim[level]
  while solver.trail.length() > target {
    match solver.trail.pop() {
      Some(lit) => {
        let variable = cdcl_var_of(lit)
        solver.assignment[variable] = -1
        solver.reason_of[variable] = -1
      }
      None => ()
    }
  }
  while solver.trail_lim.length() > level {
    ignore(solver.trail_lim.pop())
  }
  solver.qhead = solver.trail.length()
}

///|
fn cdcl_lit_value(solver : FaceCdclSolver, lit : Int32) -> Int32 {
  let value = solver.assignment[cdcl_var_of(lit)]
  if value < 0 {
    -1
  } else if lit > 0 {
    value
  } else {
    1 - value
  }
}

///|
/// Watched propagation recording reasons.  Returns a conflicting
/// clause index, `-1` for no conflict, `-2` on budget exhaustion.
fn cdcl_propagate(solver : FaceCdclSolver) -> Int32 {
  while solver.qhead < solver.trail.length() {
    solver.steps = solver.steps + 1
    solver.propagations = solver.propagations + 1
    if solver.max_steps > 0 && solver.steps > solver.max_steps {
      solver.budget_exceeded = true
      return -2
    }
    let true_lit = solver.trail[solver.qhead]
    solver.qhead = solver.qhead + 1
    let false_lit = 0 - true_lit
    let watchers = solver.watches[face_sat_lit_index(false_lit)]
    let mut read = 0
    let mut write = 0
    let mut conflict = -1
    while read < watchers.length() {
      let clause_index = watchers[read]
      read = read + 1
      solver.steps = solver.steps + 1
      if solver.max_steps > 0 && solver.steps > solver.max_steps {
        solver.budget_exceeded = true
        conflict = -2
        watchers[write] = clause_index
        write = write + 1
        while read < watchers.length() {
          watchers[write] = watchers[read]
          write = write + 1
          read = read + 1
        }
        break
      }
      let clause = solver.clauses[clause_index]
      if clause.length() < 2 {
        watchers[write] = clause_index
        write = write + 1
        continue
      }
      if clause[0] == false_lit {
        clause[0] = clause[1]
        clause[1] = false_lit
      }
      if clause[1] != false_lit {
        watchers[write] = clause_index
        write = write + 1
        continue
      }
      let other = clause[0]
      if cdcl_lit_value(solver, other) == 1 {
        watchers[write] = clause_index
        write = write + 1
        continue
      }
      let mut replacement = -1
      for k in 2..<clause.length() {
        if cdcl_lit_value(solver, clause[k]) != 0 {
          replacement = k
          break
        }
      }
      if replacement >= 0 {
        let moved = clause[replacement]
        clause[replacement] = clause[1]
        clause[1] = moved
        solver.watches[face_sat_lit_index(moved)].push(clause_index)
        continue
      }
      watchers[write] = clause_index
      write = write + 1
      if cdcl_lit_value(solver, other) == 0 {
        conflict = clause_index
        while read < watchers.length() {
          watchers[write] = watchers[read]
          write = write + 1
          read = read + 1
        }
        break
      }
      if !cdcl_enqueue(solver, other, clause_index) {
        conflict = clause_index
        while read < watchers.length() {
          watchers[write] = watchers[read]
          write = write + 1
          read = read + 1
        }
        break
      }
    }
    while watchers.length() > write {
      ignore(watchers.pop())
    }
    if conflict >= 0 || conflict == -2 {
      return conflict
    }
  }
  -1
}

///|
fn cdcl_bump(solver : FaceCdclSolver, variable : Int32) -> Unit {
  solver.activity[variable] = solver.activity[variable] + solver.var_inc
  if solver.activity[variable] > 1.0e100 {
    for v in 1..<(solver.variables + 1) {
      solver.activity[v] = solver.activity[v] * 1.0e-100
    }
    solver.var_inc = solver.var_inc * 1.0e-100
  }
}

///|
/// First-UIP conflict analysis.  Returns the learned clause
/// (asserting literal first, highest-level other literal second)
/// and the backjump level.
fn cdcl_analyze(
  solver : FaceCdclSolver,
  conflict_index : Int32,
) -> (Array[Int32], Int32, Int32) {
  let learned : Array[Int32] = [0]
  let touched : Array[Int32] = []
  let current_level = cdcl_decision_level(solver)
  let mut path_count = 0
  let mut p = 0
  let mut index = solver.trail.length() - 1
  let mut clause_index = conflict_index
  while true {
    let clause = solver.clauses[clause_index]
    for qi in 0..<clause.length() {
      let q = clause[qi]
      if q == p && p != 0 {
        continue
      }
      let v = cdcl_var_of(q)
      if !solver.seen[v] && solver.level_of[v] > 0 {
        solver.seen[v] = true
        touched.push(v)
        cdcl_bump(solver, v)
        if solver.level_of[v] >= current_level {
          path_count = path_count + 1
        } else {
          learned.push(q)
        }
      }
    }
    while index >= 0 && !solver.seen[cdcl_var_of(solver.trail[index])] {
      index = index - 1
    }
    if index < 0 {
      break
    }
    p = solver.trail[index]
    index = index - 1
    solver.seen[cdcl_var_of(p)] = false
    path_count = path_count - 1
    if path_count <= 0 {
      break
    }
    clause_index = solver.reason_of[cdcl_var_of(p)]
    if clause_index < 0 {
      break
    }
  }
  learned[0] = 0 - p
  // Literal block distance: the number of distinct decision
  // levels represented in the learned clause.  Low-LBD clauses
  // are the ones retained by database reduction.
  let levels : Array[Int32] = []
  for i in 0..<learned.length() {
    let lv = solver.level_of[cdcl_var_of(learned[i])]
    let mut present = false
    for j in 0..<levels.length() {
      if levels[j] == lv {
        present = true
      }
    }
    if !present {
      levels.push(lv)
    }
  }
  let lbd = levels.length()
  for i in 0..<touched.length() {
    solver.seen[touched[i]] = false
  }
  // Backjump level: maximum level among the non-asserting
  // literals; move such a literal to the second watch position.
  let mut backtrack = 0
  let mut max_pos = -1
  for i in 1..<learned.length() {
    let lv = solver.level_of[cdcl_var_of(learned[i])]
    if lv > backtrack {
      backtrack = lv
      max_pos = i
    }
  }
  if max_pos > 1 {
    let tmp = learned[1]
    learned[1] = learned[max_pos]
    learned[max_pos] = tmp
  }
  (learned, backtrack, lbd)
}

///|
fn cdcl_pick_variable(solver : FaceCdclSolver) -> Int32 {
  let mut best = -1
  let mut best_activity = -1.0
  for variable in 1..<(solver.variables + 1) {
    if solver.assignment[variable] < 0 &&
      solver.activity[variable] > best_activity {
      best = variable
      best_activity = solver.activity[variable]
    }
  }
  best
}

///|
fn cdcl_Luby(x0 : Int32) -> Int32 {
  // The Luby sequence 1,1,2,1,1,2,4,... (0-based restart index),
  // by the standard iterative characterization.
  let mut size = 1
  let mut seq = 0
  while size < x0 + 1 {
    seq = seq + 1
    size = 2 * size + 1
  }
  let mut x = x0
  let mut sz = size
  while sz - 1 != x {
    sz = (sz - 1) / 2
    seq = seq - 1
    x = x % sz
  }
  1 << seq
}

///|
fn cdcl_clone_clause(clause : Array[Int32]) -> Array[Int32] {
  let out : Array[Int32] = []
  for i in 0..<clause.length() {
    out.push(clause[i])
  }
  out
}

///|
/// Learned-clause database reduction, run only at decision level
/// 0 (immediately after a restart).  Original clauses, unit
/// learned clauses and clauses that are reasons for literals
/// still on the trail are always kept.  Among the rest, clauses
/// that are both long and of high literal block distance are
/// deleted; deleting a learned clause is sound because it is a
/// consequence of the original CNF, and the recorded proof copy
/// is not touched.  Clause arrays are compacted in place and all
/// reason indices and watch lists are rebuilt.
fn cdcl_reduce_db(solver : FaceCdclSolver) -> Unit {
  let total = solver.clauses.length()
  let keep_clause : Array[Bool] = []
  for _i in 0..<total {
    keep_clause.push(false)
  }
  for variable in 1..<(solver.variables + 1) {
    let reason = solver.reason_of[variable]
    if reason >= 0 && reason < total {
      keep_clause[reason] = true
    }
  }
  let remap : Array[Int32] = []
  for _i in 0..<total {
    remap.push(-1)
  }
  let mut write = 0
  for read in 0..<total {
    let clause = solver.clauses[read]
    let deletable = solver.clause_is_learned[read] &&
      !keep_clause[read] &&
      clause.length() > 1 &&
      clause.length() > 8 &&
      solver.clause_lbd[read] > 6
    if !deletable {
      remap[read] = write
      solver.clauses[write] = clause
      solver.clause_lbd[write] = solver.clause_lbd[read]
      solver.clause_is_learned[write] = solver.clause_is_learned[read]
      write = write + 1
    }
  }
  let removed = total - write
  if removed <= 0 {
    return
  }
  solver.deleted_count = solver.deleted_count + removed
  while solver.clauses.length() > write {
    ignore(solver.clauses.pop())
    ignore(solver.clause_lbd.pop())
    ignore(solver.clause_is_learned.pop())
  }
  for variable in 1..<(solver.variables + 1) {
    let reason = solver.reason_of[variable]
    if reason >= 0 && reason < total {
      solver.reason_of[variable] = remap[reason]
    }
  }
  for w in 0..<solver.watches.length() {
    while solver.watches[w].length() > 0 {
      ignore(solver.watches[w].pop())
    }
  }
  for ci in 0..<solver.clauses.length() {
    let clause = solver.clauses[ci]
    if clause.length() > 1 {
      solver.watches[face_sat_lit_index(clause[0])].push(ci)
      solver.watches[face_sat_lit_index(clause[1])].push(ci)
    }
  }
}

///|
/// CDCL main loop: 1 = SAT, 0 = UNSAT, -1 = budget exceeded.
fn cdcl_search(solver : FaceCdclSolver) -> Int32 {
  let mut restart_count = 0
  let mut conflicts_since_restart = 0
  while true {
    let conflict = cdcl_propagate(solver)
    if conflict == -2 || solver.budget_exceeded {
      return -1
    }
    if conflict >= 0 {
      solver.conflicts = solver.conflicts + 1
      conflicts_since_restart = conflicts_since_restart + 1
      if cdcl_decision_level(solver) == 0 {
        return 0
      }
      let (learned, backtrack, lbd) = cdcl_analyze(solver, conflict)
      cdcl_cancel_to(solver, backtrack)
      let clause_index = solver.clauses.length()
      solver.proof_clauses.push(cdcl_clone_clause(learned))
      solver.clauses.push(learned)
      solver.clause_lbd.push(lbd)
      solver.clause_is_learned.push(true)
      solver.learned_count = solver.learned_count + 1
      if learned.length() > 1 {
        solver.watches[face_sat_lit_index(learned[0])].push(clause_index)
        solver.watches[face_sat_lit_index(learned[1])].push(clause_index)
      }
      if !cdcl_enqueue(solver, learned[0], clause_index) {
        return 0
      }
      solver.var_inc = solver.var_inc * (1.0 / 0.95)
      if conflicts_since_restart >= cdcl_Luby(restart_count) * 100 {
        cdcl_cancel_to(solver, 0)
        cdcl_reduce_db(solver)
        solver.restarts = solver.restarts + 1
        restart_count = restart_count + 1
        conflicts_since_restart = 0
      }
    } else {
      let variable = cdcl_pick_variable(solver)
      if variable < 0 {
        return 1
      }
      solver.steps = solver.steps + 1
      if solver.max_steps > 0 && solver.steps > solver.max_steps {
        solver.budget_exceeded = true
        return -1
      }
      solver.trail_lim.push(solver.trail.length())
      solver.decisions = solver.decisions + 1
      let lit = if solver.phase[variable] { variable } else { 0 - variable }
      ignore(cdcl_enqueue(solver, lit, -1))
    }
  }
  -1
}

///|
fn cdcl_stats_of(solver : FaceCdclSolver) -> FaceCdclStats {
  FaceCdclStats::{
    decisions: solver.decisions,
    conflicts: solver.conflicts,
    propagations: solver.propagations,
    learned: solver.learned_count,
    deleted: solver.deleted_count,
    restarts: solver.restarts,
  }
}

///|
fn cdcl_decision_of(
  code : Int32,
  solver : FaceCdclSolver,
  f : Face,
  n : Int32,
) -> FaceSatDecision {
  match code {
    1 => {
      let env : Array[Bool] = []
      for i in 0..<n {
        env.push(solver.assignment[i + 1] == 1)
      }
      if face_holds(face_bound(f, n), env) {
        FaceSat(env)
      } else {
        FaceSearchBudgetExceeded
      }
    }
    0 => FaceUnsat
    _ => FaceSearchBudgetExceeded
  }
}

///|
/// Build and run a CDCL solver, returning its search code
/// (1 = SAT, 0 = UNSAT, -1 = budget exceeded), the solver, and a
/// pristine copy of the original CNF (the solver permutes watched
/// literals inside its own clause arrays).
fn cdcl_run_solver(
  f : Face,
  n : Int32,
  max_steps : Int32,
) -> (Int32, FaceCdclSolver, Array[Array[Int32]]) {
  let builder = face_cnf_build(f, n)
  let original_clauses : Array[Array[Int32]] = []
  for ci in 0..<builder.clauses.length() {
    original_clauses.push(cdcl_clone_clause(builder.clauses[ci]))
  }
  let variables = builder.next_variable - 1
  let watches : Array[Array[Int32]] = []
  for _i in 0..<(2 * (variables + 2)) {
    watches.push([])
  }
  let assignment : Array[Int32] = []
  let level_of : Array[Int32] = []
  let reason_of : Array[Int32] = []
  let phase : Array[Bool] = []
  let seen : Array[Bool] = []
  let activity : Array[Double] = []
  for _i in 0..<(variables + 1) {
    assignment.push(-1)
    level_of.push(0)
    reason_of.push(-1)
    phase.push(true)
    seen.push(false)
    activity.push(0.0)
  }
  let clause_lbd : Array[Int32] = []
  let clause_is_learned : Array[Bool] = []
  for _i in 0..<builder.clauses.length() {
    clause_lbd.push(0)
    clause_is_learned.push(false)
  }
  let solver = FaceCdclSolver::{
    clauses: builder.clauses,
    clause_lbd,
    clause_is_learned,
    proof_clauses: [],
    watches,
    assignment,
    level_of,
    reason_of,
    phase,
    activity,
    var_inc: 1.0,
    trail: [],
    trail_lim: [],
    qhead: 0,
    variables,
    steps: 0,
    max_steps,
    budget_exceeded: false,
    seen,
    decisions: 0,
    conflicts: 0,
    propagations: 0,
    learned_count: 0,
    deleted_count: 0,
    restarts: 0,
  }
  for ci in 0..<solver.clauses.length() {
    let clause = solver.clauses[ci]
    if clause.length() == 0 {
      return (0, solver, original_clauses)
    }
    for i in 0..<clause.length() {
      let variable = cdcl_var_of(clause[i])
      solver.activity[variable] = solver.activity[variable] + 1.0
    }
    if clause.length() == 1 {
      if !cdcl_enqueue(solver, clause[0], ci) {
        return (0, solver, original_clauses)
      }
    } else {
      solver.watches[face_sat_lit_index(clause[0])].push(ci)
      solver.watches[face_sat_lit_index(clause[1])].push(ci)
    }
  }
  let code = cdcl_search(solver)
  (code, solver, original_clauses)
}

///|
/// Satisfiability by CDCL with clause learning.  `max_steps <= 0`
/// means an unbounded search.
pub fn face_sat_cdcl_report(
  f : Face,
  n : Int32,
  max_steps~ : Int32 = 100000,
) -> FaceCdclResult {
  let (code, solver, _) = cdcl_run_solver(f, n, max_steps)
  {
    decision: cdcl_decision_of(code, solver, f, n),
    stats: cdcl_stats_of(solver),
  }
}

///|
/// CDCL with an independently checkable UNSAT proof.  On SAT or
/// budget exhaustion `proof_clauses` is empty; on UNSAT it is the
/// learned clauses in derivation order followed by the empty
/// clause.  Audit it with `face_cdcl_proof_check` against
/// `original_clauses` from the same result.
pub fn face_sat_cdcl_proof(
  f : Face,
  n : Int32,
  max_steps~ : Int32 = 100000,
) -> FaceCdclProofResult {
  let (code, solver, original_clauses) = cdcl_run_solver(f, n, max_steps)
  let proof_clauses : Array[Array[Int32]] = []
  if code == 0 {
    for i in 0..<solver.proof_clauses.length() {
      proof_clauses.push(cdcl_clone_clause(solver.proof_clauses[i]))
    }
    proof_clauses.push([])
  }
  {
    decision: cdcl_decision_of(code, solver, f, n),
    stats: cdcl_stats_of(solver),
    original_clauses,
    proof_clauses,
  }
}

///|
fn cdcl_proof_max_var(
  original_clauses : Array[Array[Int32]],
  proof_clauses : Array[Array[Int32]],
) -> Int32 {
  let mut best = 0
  for ci in 0..<original_clauses.length() {
    let clause = original_clauses[ci]
    for i in 0..<clause.length() {
      let v = cdcl_var_of(clause[i])
      if v > best {
        best = v
      }
    }
  }
  for ci in 0..<proof_clauses.length() {
    let clause = proof_clauses[ci]
    for i in 0..<clause.length() {
      let v = cdcl_var_of(clause[i])
      if v > best {
        best = v
      }
    }
  }
  best
}

///|
fn cdcl_proof_lit_value(assignment : Array[Int32], lit : Int32) -> Int32 {
  let value = assignment[cdcl_var_of(lit)]
  if value < 0 {
    -1
  } else if lit > 0 {
    value
  } else {
    1 - value
  }
}

///|
/// Whether assuming every literal of `assumptions` true makes
/// `clauses` conflict under unit propagation.
fn cdcl_proof_up_conflict(
  clauses : Array[Array[Int32]],
  assumptions : Array[Int32],
  max_var : Int32,
) -> Bool {
  let assignment : Array[Int32] = []
  for _i in 0..<(max_var + 1) {
    assignment.push(-1)
  }
  for i in 0..<assumptions.length() {
    let lit = assumptions[i]
    if lit == 0 {
      return false
    }
    let variable = cdcl_var_of(lit)
    let wanted = if lit > 0 { 1 } else { 0 }
    if assignment[variable] >= 0 && assignment[variable] != wanted {
      return true
    }
    assignment[variable] = wanted
  }
  while true {
    let mut changed = false
    for ci in 0..<clauses.length() {
      let clause = clauses[ci]
      let mut satisfied = false
      let mut open_count = 0
      let mut open_lit = 0
      for i in 0..<clause.length() {
        let lit = clause[i]
        if lit == 0 || cdcl_var_of(lit) > max_var {
          return false
        }
        let value = cdcl_proof_lit_value(assignment, lit)
        if value == 1 {
          satisfied = true
        } else if value < 0 {
          open_count = open_count + 1
          open_lit = lit
        }
      }
      if satisfied {
        continue
      }
      if open_count == 0 {
        return true
      }
      if open_count == 1 {
        let variable = cdcl_var_of(open_lit)
        let wanted = if open_lit > 0 { 1 } else { 0 }
        if assignment[variable] < 0 {
          assignment[variable] = wanted
          changed = true
        } else if assignment[variable] != wanted {
          return true
        }
      }
    }
    if !changed {
      return false
    }
  }
  false
}

///|
/// Check a CDCL UNSAT proof by reverse unit propagation: each
/// proof clause must become conflicting when all of its literals
/// are assumed false, using only the original clauses and the
/// proof clauses before it; the final proof clause must be
/// empty.  This is the standard RUP audit and is independent of
/// the solver's watch lists, activities and deletion policy.
pub fn face_cdcl_proof_check(
  original_clauses : Array[Array[Int32]],
  proof_clauses : Array[Array[Int32]],
) -> Bool {
  if proof_clauses.length() == 0 {
    return false
  }
  if proof_clauses[proof_clauses.length() - 1].length() != 0 {
    return false
  }
  let max_var = cdcl_proof_max_var(original_clauses, proof_clauses)
  let db : Array[Array[Int32]] = []
  for ci in 0..<original_clauses.length() {
    db.push(original_clauses[ci])
  }
  for pi in 0..<proof_clauses.length() {
    let clause = proof_clauses[pi]
    let assumptions : Array[Int32] = []
    for i in 0..<clause.length() {
      if clause[i] == 0 {
        return false
      }
      assumptions.push(0 - clause[i])
    }
    if !cdcl_proof_up_conflict(db, assumptions, max_var) {
      return false
    }
    db.push(clause)
  }
  true
}

///|
pub fn face_sat_cdcl(
  f : Face,
  n : Int32,
  max_steps~ : Int32 = 100000,
) -> FaceSatDecision {
  face_sat_cdcl_report(f, n, max_steps~).decision
}

///|
/// Face equality through the CDCL solver applied to the symmetric
/// difference.
pub fn face_eq_cdcl(
  f : Face,
  g : Face,
  n : Int32,
  max_steps~ : Int32 = 100000,
) -> FaceDecision {
  let difference = FOr(FAnd(f, face_not(g)), FAnd(g, face_not(f)))
  match face_sat_cdcl(difference, n, max_steps~) {
    FaceSat(_) => FaceDecided(false)
    FaceUnsat => FaceDecided(true)
    FaceSearchBudgetExceeded => FaceBudgetExceeded
  }
}
