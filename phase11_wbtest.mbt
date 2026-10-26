///|
/// Phase 11 white-box tests (accumulated per work item).

///|
fn phase11_copy_bytes(bytes : Array[Int32]) -> Array[Int32] {
  let out : Array[Int32] = []
  for i in 0..<bytes.length() {
    out.push(bytes[i])
  }
  out
}

///|
fn phase11_truncate_bytes(bytes : Array[Int32], keep : Int32) -> Array[Int32] {
  let out : Array[Int32] = []
  for i in 0..<keep {
    out.push(bytes[i])
  }
  out
}

///|
test "phase11: schema registry byte persistence roundtrips" {
  let registry = schema_registry_new()
  ignore(schema_registry_register_inductive(registry, nat_schema()))
  ignore(schema_registry_register_inductive(registry, list_schema()))
  ignore(schema_registry_register_inductive(registry, vec_schema()))
  ignore(schema_registry_register_hit(registry, circle_schema()))
  ignore(schema_registry_register_hit(registry, torus_schema()))
  assert_true(schema_registry_binary_roundtrip_ok(registry))
  let bytes = schema_registry_to_binary(registry)
  let report = schema_registry_snapshot_load_binary_report(bytes)
  assert_true(report.status == ModuleBinaryOk)
  // Corruption is detected precisely: flipping a payload byte is
  // caught by the checksum.
  let corrupted = phase11_copy_bytes(bytes)
  corrupted[bytes.length() - 1] = (corrupted[bytes.length() - 1] + 1) % 256
  assert_true(
    match schema_registry_snapshot_from_binary(corrupted) {
      Some(_) => false
      None => true
    },
  )
  // Truncation and bad magic are rejected as well.
  let truncated = phase11_truncate_bytes(bytes, bytes.length() - 3)
  assert_true(
    match schema_registry_snapshot_from_binary(truncated) {
      Some(_) => false
      None => true
    },
  )
  let bad_magic = phase11_copy_bytes(bytes)
  bad_magic[0] = 88
  assert_true(
    schema_registry_snapshot_load_binary_report(bad_magic).status ==
    ModuleBinaryBadMagic,
  )
  // The restored registry still validates fresh registrations.
  let restored_ok = match schema_registry_from_binary(bytes) {
    Some(restored) =>
      schema_registry_register_inductive(restored, nat_schema()).valid
    None => false
  }
  assert_true(restored_ok)
}

///|
test "phase11: DTerm interner shares equal subterms and preserves terms" {
  // A type with heavy repetition: nested copies of (Nat -> Nat).
  let arrow = DPi(DNatTy, DNatTy)
  let pair_ty = DSigma(arrow, arrow)
  let big = DSigma(pair_ty, DPi(pair_ty, pair_ty))
  let table = dterm_intern_table_new()
  let interned = dterm_intern(table, big)
  assert_true(interned == big)
  assert_true(dterm_cache_key(interned) == dterm_cache_key(big))
  let tree = dterm_tree_node_count(big)
  let distinct = dterm_intern_table_size(table)
  assert_true(distinct < tree)
  assert_true(distinct == dterm_distinct_subterm_count(big))
  // Interning a structurally equal but separately built term does
  // not grow the table and yields the same id.
  let arrow2 = DPi(DNatTy, DNatTy)
  let pair2 = DSigma(arrow2, arrow2)
  let big2 = DSigma(pair2, DPi(pair2, pair2))
  let (_, id1) = dterm_intern_id(table, big)
  let (_, id2) = dterm_intern_id(table, big2)
  assert_true(id1 == id2)
  assert_true(dterm_intern_table_size(table) == distinct)
  // Rebuild is the inverse of children on compound shapes,
  // including schema eliminators and partial elements.
  let partial = DPartial([
    { face: FEq1(DVar(0)), body: DNatZero, },
    { face: FTop, body: DNatZero, },
  ])
  assert_true(dterm_rebuild(partial, dterm_children(partial)) == partial)
  let elim = DInductiveElim(
    nat_schema(),
    DLam(DNatTy, DNatTy),
    [DNatZero, DLam(DNatTy, DLam(DNatTy, DTVar(0)))],
    [],
    [],
    DSucc(DNatZero),
  )
  assert_true(dterm_rebuild(elim, dterm_children(elim)) == elim)
  assert_true(dterm_intern(table, elim) == elim)
  // Interned terms elaborate identically: type-check and normalize
  // a closed term before and after interning.
  let term = DApp(DLam(DNatTy, DSucc(DTVar(0))), DSucc(DNatZero))
  let interned_term = dterm_intern(table, term)
  assert_true(dep_check_closed(term, DNatTy))
  assert_true(dep_check_closed(interned_term, DNatTy))
  assert_true(
    dep_nf_closed(interned_term, DNatTy) == dep_nf_closed(term, DNatTy),
  )
  assert_true(dep_nf_closed(term, DNatTy) == Some(DSucc(DSucc(DNatZero))))
}

///|
test "phase11: Face agreement region retains both endpoints" {
  // loop(i) vs base in the circle: agreement at i=0 and i=1, but
  // not at a free i.
  let a = circle_point(DVar(0))
  let b = DVCirclePoint(DZero)
  let agreement = face_agreement_face(0, 1, FTop, DVCircleTy, a, b)
  assert_true(agreement != FTop)
  assert_true(agreement != FBot)
  assert_true(face_holds(agreement, [false]))
  assert_true(face_holds(agreement, [true]))
  assert_true(bdd_of_face(agreement, 1) == BddOne)
  assert_true(
    face_agreement_face_sound(0, 1, FTop, agreement, DVCircleTy, a, b),
  )
  // The BDD-valued region necessarily drops the 1-endpoint.
  let region = face_agreement_region(0, 1, FTop, DVCircleTy, a, b)
  assert_true(region != BddOne)
  assert_true(region == BddNode(0, BddOne, BddZero))
  // Total agreement and total disagreement on Nat.
  assert_true(
    face_agreement_face(0, 1, FTop, DVNatTy, DVZeroNat, DVZeroNat) == FTop,
  )
  assert_true(
    face_agreement_face(0, 1, FTop, DVNatTy, DVZeroNat, dv_nat_lit(1)) == FBot,
  )
}

///|
test "phase11: exact repair keeps endpoint-disjunction faces" {
  let system = dsystem_of([tube_branch(FTop, _ => circle_point(DVar(0)))])
  let base = DVCirclePoint(DZero)
  let line = (_ : Dim) => DVCircleTy
  let exact = dsystem_repair_to_base_exact(0, 1, line, system, base)
  assert_true(exact.system.branches.length() == 1)
  let kept_face = exact.system.branches[0].face
  assert_true(kept_face != FTop)
  assert_true(face_holds(kept_face, [false]))
  assert_true(face_holds(kept_face, [true]))
  // Nothing was removed at the Boolean (vertex) level.
  assert_true(exact.base_removed_region == BddZero)
  // The BDD repair keeps only the 0-endpoint by comparison.
  let bdd_repair = dsystem_repair_to_base(0, 1, line, system, base)
  assert_true(bdd_repair.system.branches.length() == 1)
  let bdd_face = bdd_repair.system.branches[0].face
  assert_true(face_holds(bdd_face, [false]))
  assert_true(!face_holds(bdd_face, [true]))
}

///|
test "phase11: open-box filler assembles and verifies whole boundary" {
  // A square in the circle: left and right edges are the loop,
  // the bottom edge is constant at the base point.
  let loop_cube = dcube_of_path(d => circle_point(d))
  let const_base = dcube_of_path(_ => DVCirclePoint(DZero))
  let box = dcube_open_box(DVCircleTy, 2, 0, [
    dcube_box_face(0, false, loop_cube),
    dcube_box_face(0, true, loop_cube),
    dcube_box_face(1, false, const_base),
  ])
  let report = dcube_box_validate(box, 0)
  assert_true(report.complete)
  assert_true(report.overlaps_ok)
  match dcube_box_fill_verified(box, 0) {
    Some(filler) => {
      assert_true(dcube_filler_faces_ok(box, filler, 0))
      // The cap is a loop from base to base (endpoints compute).
      match dcube_box_cap(box) {
        Some(cap) => {
          assert_true(
            conv_at(
              0,
              0,
              DVCircleTy,
              dcube_at(cap, [DZero]),
              DVCirclePoint(DZero),
            ),
          )
          assert_true(
            conv_at(
              0,
              0,
              DVCircleTy,
              dcube_at(cap, [DOne]),
              DVCirclePoint(DZero),
            ),
          )
        }
        None => assert_true(false)
      }
    }
    None => assert_true(false)
  }
  // An incompatible square in Nat is rejected with witnesses.
  let one_path = dcube_of_path(_ => dv_nat_lit(1))
  let zero_path = dcube_of_path(_ => DVZeroNat)
  let bad_box = dcube_open_box(DVNatTy, 2, 0, [
    dcube_box_face(0, false, one_path),
    dcube_box_face(0, true, one_path),
    dcube_box_face(1, false, zero_path),
  ])
  let bad_report = dcube_box_validate(bad_box, 0)
  assert_true(bad_report.complete)
  assert_true(!bad_report.overlaps_ok)
  assert_true(bad_report.failed_overlaps >= 1)
  assert_true(
    match dcube_box_fill_verified(bad_box, 0) {
      Some(_) => false
      None => true
    },
  )
  // A degenerate 3-cube in Nat (all faces zero) fills and verifies.
  let zero_square = dcube_constant(2, DVZeroNat)
  let cube3 = dcube_open_box(DVNatTy, 3, 0, [
    dcube_box_face(0, false, zero_square),
    dcube_box_face(0, true, zero_square),
    dcube_box_face(1, false, zero_square),
    dcube_box_face(1, true, zero_square),
    dcube_box_face(2, false, zero_square),
  ])
  match dcube_box_fill_verified(cube3, 0) {
    Some(filler) =>
      assert_true(dv_is_nat(dcube_at(filler, [DZero, DZero, DZero]), 0))
    None => assert_true(false)
  }
  // An incomplete box (missing a side face) does not fill.
  let open_box = dcube_open_box(DVNatTy, 2, 0, [
    dcube_box_face(1, false, zero_path),
  ])
  assert_true(!dcube_box_complete(open_box))
  assert_true(
    match dcube_box_fill(open_box) {
      Some(_) => false
      None => true
    },
  )
}

///|
test "phase11: circle and torus point-valued composition computes" {
  let circle_line = (_ : Dim) => DVCircleTy
  let base_pt = DVCirclePoint(DZero)
  // Tube on (i = 1) with point path (j and i): the cap is the
  // loop point at i.  Previously this stayed a formal DNComp.
  let system = dsystem_of([
    tube_branch(FEq1(DVar(0)), (j : Dim) => {
      circle_point(dim_simplify(DAnd(j, DVar(0))))
    }),
  ])
  let cap = comp_value(circle_line, system, base_pt, 1)
  assert_true(
    match force_value(cap) {
      DVCirclePoint(_) => true
      _ => false
    },
  )
  assert_true(conv_at(0, 1, DVCircleTy, cap, circle_point(DVar(0))))
  // The filler itself is point-valued and restricts correctly:
  // at the fill parameter 0 it is the base.
  let filler = hfill_value(DVCircleTy, system, base_pt, 1)
  assert_true(conv_at(0, 1, DVCircleTy, filler(DZero), base_pt))
  assert_true(
    match force_value(filler(DVar(1))) {
      DVCirclePoint(_) => true
      _ => false
    },
  )
  // Torus: blend in the first coordinate only.
  let torus_line = (_ : Dim) => DVTorusTy
  let torus_system = dsystem_of([
    tube_branch(FEq1(DVar(0)), (j : Dim) => {
      torus_point(dim_simplify(DAnd(j, DVar(0))), DZero)
    }),
  ])
  let torus_cap = comp_value(
    torus_line,
    torus_system,
    DVTorusPoint(DZero, DZero),
    1,
  )
  assert_true(
    match force_value(torus_cap) {
      DVTorusPoint(_, _) => true
      _ => false
    },
  )
  assert_true(conv_at(0, 1, DVTorusTy, torus_cap, torus_point(DVar(0), DZero)))
  // Non-point-valued tubes remain formal.
  let stuck_system = dsystem_of([
    tube_branch(FEq1(DVar(0)), _ => DVNeutral(DNVar(0))),
  ])
  let stuck = comp_value(circle_line, stuck_system, base_pt, 1)
  assert_true(
    match force_value(stuck) {
      DVNeutral(DNComp(_, _, _)) => true
      _ => false
    },
  )
  // All-base boxes still reduce to the base point.
  let base_system = dsystem_of([tube_branch(FEq0(DVar(0)), _ => base_pt)])
  assert_true(
    conv_at(
      0,
      1,
      DVCircleTy,
      comp_value(circle_line, base_system, base_pt, 1),
      base_pt,
    ),
  )
  // dim_of_face has the right vertex semantics.
  assert_true(dim_eq_sem(dim_of_face(FEq0(DVar(0))), DNeg(DVar(0))))
  assert_true(
    dim_eq_sem(
      dim_of_face(FAnd(FEq1(DVar(0)), FEq0(DVar(1)))),
      DAnd(DVar(0), DNeg(DVar(1))),
    ),
  )
}

///|
test "phase11: exact optimal BDD order beats blocked order and matches semantics" {
  // f = (x0&x3) | (x1&x4) | (x2&x5): pairing variables matters.
  let pair = (a : Int32, b : Int32) => FAnd(FEq1(DVar(a)), FEq1(DVar(b)))
  let f = FOr(pair(0, 3), FOr(pair(1, 4), pair(2, 5)))
  let opt = bdd_dag_of_face_optimal(f, 6)
  assert_true(opt.exact)
  assert_true(opt.tried == 720)
  // The blocked order (all first components, then all seconds)
  // is strictly worse than optimal.
  let blocked_manager = bdd_manager_with_order([0, 1, 2, 3, 4, 5], 6)
  let blocked_root = bdd_dag_build_face(blocked_manager, f)
  let blocked_size = bdd_dag_reachable_count(blocked_manager, blocked_root)
  assert_true(opt.size < blocked_size)
  // Heuristic sifting cannot beat the exact optimum.
  let sifted = bdd_dag_of_face_optimized(f, 6)
  assert_true(sifted.reachable >= opt.size)
  // Semantics: evaluation agrees with face_holds everywhere.
  let mut ok = true
  for mask in 0..<64 {
    let env : Array[Bool] = []
    for i in 0..<6 {
      let bit = (mask >> i) & 1
      env.push(bit == 1)
    }
    if bdd_dag_eval(opt.built.manager, opt.built.root, env) !=
      face_holds(f, env) {
      ok = false
    }
  }
  assert_true(ok)
  // Above the exact threshold it honestly reports non-exactness.
  let big = bdd_dag_of_face_optimal(f, 6, exact_max_vars=4)
  assert_true(!big.exact)
}
