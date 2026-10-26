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

///|
/// The certified Miller-pattern unifier returns principal
/// substitutions (including flex-flex intersection and same-head
/// pruning), explicit residuals under a principal partial
/// substitution for non-pattern spines, and transactional
/// no-unifier verdicts.
pub fn check_hou_pattern_mgu_and_residuals() -> Bool {
  let u = unifier_new()
  let f = hou_fresh_meta(u, 2)
  let rhs = UPair(UVar(0), UConst("c"))
  let report = hou_unify_mgu(f, rhs, 2, u)
  if report.status != HouMguPrincipal || report.substitution.length() != 1 {
    return false
  }
  if hou_semantic_optimize(f, u) != rhs {
    return false
  }
  // Flex-flex intersection over the shared spine variable.
  let u2 = unifier_new()
  ignore(hou_fresh_meta(u2, 0))
  ignore(hou_fresh_meta(u2, 0))
  let flex = hou_unify_mgu(
    UMeta(0, [UVar(2), UVar(1)]),
    UMeta(1, [UVar(1), UVar(0)]),
    3,
    u2,
  )
  if flex.status != HouMguPrincipal {
    return false
  }
  if hou_semantic_optimize(UMeta(0, [UVar(2), UVar(1)]), u2) !=
    hou_semantic_optimize(UMeta(1, [UVar(1), UVar(0)]), u2) {
    return false
  }
  // Same-head pruning: swapped spines share no fixed position.
  let u3 = unifier_new()
  ignore(hou_fresh_meta(u3, 0))
  let same = hou_unify_mgu(
    UMeta(0, [UVar(1), UVar(0)]),
    UMeta(0, [UVar(0), UVar(1)]),
    2,
    u3,
  )
  if same.status != HouMguPrincipal {
    return false
  }
  if hou_semantic_optimize(UMeta(0, [UVar(1), UVar(0)]), u3) !=
    hou_semantic_optimize(UMeta(0, [UVar(0), UVar(1)]), u3) {
    return false
  }
  // A repeated-variable spine has no single MGU; the pattern
  // component still solves principally and the repeated
  // component comes back as the residual, whose subsequent
  // (specific) solution completes the original problem.
  let u4 = unifier_new()
  ignore(hou_fresh_meta(u4, 0))
  ignore(hou_fresh_meta(u4, 0))
  let original_lhs = UPair(UMeta(0, [UVar(0)]), UMeta(1, [UVar(0), UVar(0)]))
  let original_rhs = UPair(UConst("c"), UPair(UVar(0), UConst("c")))
  let partial = hou_unify_mgu(original_lhs, original_rhs, 1, u4)
  if partial.status != HouMguResidual ||
    partial.residual.length() != 1 ||
    partial.substitution.length() != 1 {
    return false
  }
  let residual = partial.residual[0]
  if !hou_unify(residual.lhs, residual.rhs, residual.depth, u4) {
    return false
  }
  if hou_semantic_optimize(original_lhs, u4) !=
    hou_semantic_optimize(original_rhs, u4) {
    return false
  }
  // Definitive failures restore the unifier.
  let u5 = unifier_new()
  ignore(hou_fresh_meta(u5, 0))
  let scope = hou_unify_mgu(UMeta(0, [UVar(1)]), UVar(0), 2, u5)
  if scope.status != HouMguNoUnifier || u5.solved_count != 0 {
    return false
  }
  let clash = hou_unify_mgu(
    UPair(UConst("a"), UConst("b")),
    USucc(UNatZero),
    0,
    u5,
  )
  clash.status == HouMguNoUnifier
}

///|
/// Agreement walks split only on dimensions occurring in the
/// quoted terms, and repair can supplement a system from a
/// candidate pool under the full compatibility audit.
pub fn check_dsystem_structural_agreement_and_supplementation() -> Bool {
  if dterm_dim_vars(DAppDim(DCircleLoop, DAnd(DVar(3), DNeg(DVar(1))))) !=
    [1, 3] {
    return false
  }
  let var_bdd = bdd_of_face(FAnd(FEq1(DVar(0)), FEq0(DVar(1))), 2)
  if bdd_tree_cofactor(var_bdd, 0, true) != BddNode(1, BddOne, BddZero) {
    return false
  }
  if bdd_tree_cofactor(var_bdd, 0, false) != BddZero {
    return false
  }
  // The same endpoint agreement as the Phase 11 law, now in a
  // twelve-dimensional ambient context whose extra dimensions
  // occur nowhere in the values: the walk splits only on the
  // one relevant dimension.
  let a = circle_point(DVar(0))
  let b = DVCirclePoint(DZero)
  let agreement = face_agreement_face(0, 12, FTop, DVCircleTy, a, b)
  if agreement == FTop || agreement == FBot {
    return false
  }
  if !face_holds(agreement, [false]) || !face_holds(agreement, [true]) {
    return false
  }
  let region = face_agreement_region(0, 12, FTop, DVCircleTy, a, b)
  if region != BddNode(0, BddOne, BddZero) {
    return false
  }
  // Supplementation: one original branch is dropped, one is
  // kept, one candidate fills the other endpoint face, and two
  // candidates are rejected (base disagreement and pairwise
  // incompatibility respectively).
  let line = (_ : Dim) => DVNatTy
  let zero_path = (_ : Dim) => DVZeroNat
  let system = dsystem_of([
    tube_branch(FTop, _ => dv_nat_lit(1)),
    tube_branch(FEq0(DVar(0)), zero_path),
  ])
  let candidates : Array[DTubeBranch] = [
    tube_branch(FEq1(DVar(0)), zero_path),
    tube_branch(FTop, _ => dv_nat_lit(1)),
    tube_branch(FEq1(DVar(0)), j => {
      if dim_is_zero(j) {
        DVZeroNat
      } else {
        dv_nat_lit(1)
      }
    }),
  ]
  let repaired = dsystem_repair_with_candidates(
    0,
    1,
    line,
    system,
    DVZeroNat,
    candidates,
  )
  if !repaired.compatible {
    return false
  }
  if repaired.system.branches.length() != 2 {
    return false
  }
  if repaired.added_branches != 1 || repaired.rejected_candidates != 2 {
    return false
  }
  if repaired.repaired_branches < 1 {
    return false
  }
  dsystem_compatible_with_base(0, 1, line, repaired.system, DVZeroNat)
}

///|
/// Phase 12: shared DAG term codec, version negotiation, and
/// the durable artifact repository.  A registry snapshot whose
/// constructors repeat one large external type is strictly
/// smaller under the v3-codec registry layout than under the
/// v2-codec layout, and both parse back exactly.  A module with
/// a tag-8 family functor negotiates to v2 for a v1+v2 peer, is
/// refused for a v1-only peer, and uses v3 for a v3 peer.  The
/// repository round-trips a compiled module and a registry
/// snapshot, refuses a corrupted blob, repairs it on re-put,
/// and rebuilds a destroyed index from commit manifests.
pub fn check_artifact_repository_and_dag_codec() -> Bool {
  if compiled_module_binary_version_policy() !=
    BinaryVersionPolicy::{
      current: 3,
      supported: [1, 2, 3],
      oldest_writable: 1,
    } ||
    schema_registry_binary_version_policy() !=
    BinaryVersionPolicy::{ current: 2, supported: [1, 2], oldest_writable: 1, } ||
    compiled_module_binary_negotiate_version([1, 2]) != 2 ||
    compiled_module_binary_negotiate_version([9]) != -1 {
    return false
  }
  // DAG codec: one large type repeated across constructors.
  let big = DPi(DNatTy, DPi(DNatTy, DPi(DNatTy, DNatTy)))
  let ctors : Array[DConstructorSpec] = []
  for i in 0..<8 {
    ctors.push(
      dconstructor_spec("c" + i.to_string(), [darg_external("f", big)]),
    )
  }
  let dag_spec = dinductive_spec("DagShareS", 0, [], [], ctors)
  let dag_registry = schema_registry_new()
  ignore(schema_registry_register_inductive(dag_registry, dag_spec))
  let dag_snapshot = schema_registry_snapshot(dag_registry)
  let plain = match
    schema_registry_snapshot_to_binary_version(dag_snapshot, 1) {
    Some(v) => v
    None => return false
  }
  let shared = match
    schema_registry_snapshot_to_binary_version(dag_snapshot, 2) {
    Some(v) => v
    None => return false
  }
  if shared.length() >= plain.length() ||
    schema_registry_binary_version_of(shared) != 2 ||
    schema_registry_binary_version_of(plain) != 1 {
    return false
  }
  match schema_registry_snapshot_from_binary(shared) {
    Some(back) =>
      if back.inductive_specs != dag_snapshot.inductive_specs {
        return false
      }
    None => return false
  }
  // Negotiation against a tag-8 family module.
  let rose = dinductive_spec(
    "NegRoseS",
    0,
    [dtelescope_entry("A", DUniv(0))],
    [],
    [
      dconstructor_spec("leaf", [darg_external("label", DTVar(0))]),
      dconstructor_spec("node", [
        darg_nested(
          "children",
          dfunctor_family(list_schema(), params=[dfunctor_param_self()]),
        ),
      ]),
    ],
  )
  let rose_module = module_def("Demo.NegRose", decls=[
    module_decl("RoseBool", DUniv(0), DInductive(rose, [DBoolTy])),
  ])
  let rose_compiled = match module_compile(module_env_new(), rose_module, []) {
    Some(v) => v
    None => return false
  }
  if compiled_module_to_binary_for_peer(rose_compiled, [1]) != None {
    return false
  }
  match compiled_module_to_binary_for_peer(rose_compiled, [1, 2]) {
    Some(bytes) =>
      if compiled_module_binary_version_of(bytes) != 2 {
        return false
      }
    None => return false
  }
  match compiled_module_to_binary_for_peer(rose_compiled, [2, 3]) {
    Some(bytes) =>
      if compiled_module_binary_version_of(bytes) != 3 {
        return false
      }
    None => return false
  }
  // Repository behaviour over the in-memory byte store.
  let compiled = match module_compile(module_env_new(), bool_ops_module(), []) {
    Some(v) => v
    None => return false
  }
  let store = artifact_memory_byte_store_new()
  let repo = artifact_repository_new(store)
  let module_record = match
    artifact_repository_put_compiled_module(repo, compiled) {
    Some(v) => v
    None => return false
  }
  if module_record.format_version != 3 {
    return false
  }
  match artifact_repository_get_compiled_module(repo, compiled.module_path) {
    Some(back) => if back != compiled { return false }
    None => return false
  }
  match artifact_repository_put_registry_snapshot(repo, "dag", dag_snapshot) {
    Some(_) => ()
    None => return false
  }
  match artifact_repository_get_registry_snapshot(repo, "dag") {
    Some(back) =>
      if back.inductive_specs != dag_snapshot.inductive_specs {
        return false
      }
    None => return false
  }
  if artifact_repository_stats(repo).records != 2 ||
    !artifact_repository_verify_all(repo) {
    return false
  }
  // A corrupted blob is refused, then repaired by re-putting.
  let blob = match (store.read)(module_record.blob_key) {
    Some(v) => v
    None => return false
  }
  blob[blob.length() - 1] = (blob[blob.length() - 1] + 1) & 255
  ignore((store.write)(module_record.blob_key, blob))
  if artifact_repository_get_compiled_module(repo, compiled.module_path) != None {
    return false
  }
  match artifact_repository_put_compiled_module(repo, compiled) {
    Some(_) => ()
    None => return false
  }
  match artifact_repository_get_compiled_module(repo, compiled.module_path) {
    Some(back) => if back != compiled { return false }
    None => return false
  }
  // A destroyed index is rebuilt from the commit manifests.
  ignore((store.write)("artifacts/index.bin", [1, 2, 3]))
  if artifact_repository_get_compiled_module(repo, compiled.module_path) != None ||
    artifact_repository_recover(repo) != 2 {
    return false
  }
  match artifact_repository_get_compiled_module(repo, compiled.module_path) {
    Some(back) => if back != compiled { return false }
    None => return false
  }
  if !artifact_repository_remove(repo, artifact_kind_schema_registry(), "dag") ||
    artifact_repository_stats(repo).records != 1 {
    return false
  }
  match artifact_repository_get_registry_snapshot(repo, "dag") {
    Some(_) => return false
    None => ()
  }
  artifact_repository_verify_all(repo)
}
