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
