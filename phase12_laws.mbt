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

///|
fn phase12_shape_host(name : String, inner : DInductiveSpec) -> DInductiveSpec {
  dinductive_spec(name, 0, [], [], [
    dconstructor_spec("base", []),
    dconstructor_spec("node", [
      darg_nested(
        "stored",
        dfunctor_family(inner, params=[dfunctor_param_self()]),
      ),
    ]),
  ])
}

///|
/// Same-spec self-family recursion (Bush), parameter shapes
/// traversable by the IH gatherer (lists and dependent pairs of
/// stored elements), and precise validation of parameter terms
/// depending on a `Self` parameter.
pub fn check_self_family_and_gather_shapes() -> Bool {
  // --- Bush: `Bush A` storing a `Bush (Bush A)` tail.
  let bush = dinductive_spec(
    "BushS",
    0,
    [dtelescope_entry("A", DUniv(0))],
    [],
    [
      dconstructor_spec("nil", []),
      dconstructor_spec("cons", [
        darg_external("head", DTVar(0)),
        darg_nested(
          "tail",
          dfunctor_self_family(params=[dfunctor_param_self()]),
        ),
      ]),
    ],
  )
  if !inductive_schema_validate(bush) {
    return false
  }
  let registry = schema_registry_new()
  ignore(schema_registry_register_inductive(registry, bush))
  if !schema_registry_binary_roundtrip_ok(registry) {
    return false
  }
  let b0 : DValue = DVInductive(bush, [DVBoolTy], [])
  let b1 : DValue = DVInductive(bush, [b0], [])
  if !conv_ty(
      0,
      0,
      inductive_arg_type(bush, bush.constructors[1].args[1], [DVBoolTy], [
        DVBool(true),
      ]),
      b1,
    ) {
    return false
  }
  let nil1 : DValue = DVIntro(bush, 0, [b0], [])
  let nil2 : DValue = DVIntro(bush, 0, [b1], [])
  let headbush : DValue = DVIntro(bush, 1, [DVBoolTy], [DVBool(false), nil1])
  let tail : DValue = DVIntro(bush, 1, [b0], [headbush, nil2])
  let tree : DValue = DVIntro(bush, 1, [DVBoolTy], [DVBool(true), tail])
  let leaf_count = eval_inductive_elim(
    bush,
    (_, _) => DVNatTy,
    [
      dv_nat_lit(0),
      DVLam(_ => {
        DVLam(_ => {
          DVLam(bundle => {
            dv_nat_plus(dv_nat_lit(1), dv_sum_bundle_leaves(bundle))
          })
        })
      }),
    ],
    [DVBoolTy],
    [],
    tree,
    0,
  )
  if !dv_is_nat(leaf_count, 2) {
    return false
  }
  // A parameter used in a function domain cannot be the target
  // of a `Self` self-family argument.
  let bad_self = dinductive_spec(
    "BadSelfBushS",
    0,
    [dtelescope_entry("A", DUniv(0))],
    [],
    [
      dconstructor_spec("mk", [
        darg_nested("fnarg", dfunctor_pi(DTVar(0), dfunctor_identity([]))),
        darg_nested(
          "tail",
          dfunctor_self_family(params=[dfunctor_param_self()]),
        ),
      ]),
    ],
  )
  if inductive_schema_validate(bad_self) {
    return false
  }
  // --- Gather through List and Sigma parameter shapes.
  let many = dinductive_spec(
    "ManyStoreS",
    0,
    [dtelescope_entry("A", DUniv(0))],
    [],
    [dconstructor_spec("wrap", [darg_external("items", DListTy(DTVar(0)))])],
  )
  let many_host = phase12_shape_host("ManyHostS", many)
  if !inductive_schema_validate(many_host) {
    return false
  }
  let count_cases : Array[DValue] = [
    dv_nat_lit(1),
    DVLam(_ => {
      DVLam(bundle => dv_nat_plus(dv_nat_lit(1), dv_sum_bundle_leaves(bundle)))
    }),
  ]
  let many_ty : DValue = DVInductive(many_host, [], [])
  let many_base : DValue = DVIntro(many_host, 0, [], [])
  let many_node : DValue = DVIntro(many_host, 1, [], [
    DVIntro(many, 0, [many_ty], [DVCons(many_base, DVCons(many_base, DVNil))]),
  ])
  if !dv_is_nat(
      eval_inductive_elim(
        many_host,
        (_, _) => DVNatTy,
        count_cases,
        [],
        [],
        many_node,
        0,
      ),
      3,
    ) {
    return false
  }
  let pair_inner = dinductive_spec(
    "PairStoreS",
    0,
    [dtelescope_entry("A", DUniv(0))],
    [],
    [
      dconstructor_spec("wrap", [
        darg_external("pair", DSigma(DTVar(0), DTVar(1))),
      ]),
    ],
  )
  let pair_host = phase12_shape_host("PairHostS", pair_inner)
  if !inductive_schema_validate(pair_host) {
    return false
  }
  let pair_ty : DValue = DVInductive(pair_host, [], [])
  let pair_base : DValue = DVIntro(pair_host, 0, [], [])
  let pair_node : DValue = DVIntro(pair_host, 1, [], [
    DVIntro(pair_inner, 0, [pair_ty], [DVPair(pair_base, pair_base)]),
  ])
  if !dv_is_nat(
      eval_inductive_elim(
        pair_host,
        (_, _) => DVNatTy,
        count_cases,
        [],
        [],
        pair_node,
        0,
      ),
      3,
    ) {
    return false
  }
  // --- A later family parameter whose type is an earlier
  // `Self` parameter is checked at the real host type.
  let dep_inner = dinductive_spec(
    "DepStoreS",
    0,
    [dtelescope_entry("A", DUniv(0)), dtelescope_entry("x", DTVar(0))],
    [],
    [
      dconstructor_spec("empty", []),
      dconstructor_spec("stored", [darg_external("elt", DTVar(1))]),
    ],
  )
  let dep_host = dinductive_spec("DepHostS", 0, [], [], [
    dconstructor_spec("base", []),
    dconstructor_spec("node", [
      darg_recursive("seed"),
      darg_nested(
        "stored",
        dfunctor_family(dep_inner, params=[
          dfunctor_param_self(),
          dfunctor_param_term(DTVar(0)),
        ]),
      ),
    ]),
  ])
  if !inductive_schema_validate(dep_host) {
    return false
  }
  let dep_host_wrong = dinductive_spec("DepHostWrongS", 0, [], [], [
    dconstructor_spec("base", []),
    dconstructor_spec("node", [
      darg_recursive("seed"),
      darg_nested(
        "stored",
        dfunctor_family(dep_inner, params=[
          dfunctor_param_self(),
          dfunctor_param_term(DUnitLit),
        ]),
      ),
    ]),
  ])
  if inductive_schema_validate(dep_host_wrong) {
    return false
  }
  let dep_ty : DValue = DVInductive(dep_host, [], [])
  let dep_base : DValue = DVIntro(dep_host, 0, [], [])
  let dep_node : DValue = DVIntro(dep_host, 1, [], [
    dep_base,
    DVIntro(dep_inner, 1, [dep_ty, dep_base], [dep_base]),
  ])
  let dep_count = eval_inductive_elim(
    dep_host,
    (_, _) => DVNatTy,
    [
      dv_nat_lit(1),
      DVLam(_ => {
        DVLam(seed_ih => {
          DVLam(_ => {
            DVLam(bundle => {
              dv_nat_plus(
                dv_nat_lit(1),
                dv_nat_plus(seed_ih, dv_sum_bundle_leaves(bundle)),
              )
            })
          })
        })
      }),
    ],
    [],
    [],
    dep_node,
    0,
  )
  dv_is_nat(dep_count, 3)
}
