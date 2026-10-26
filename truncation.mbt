///|
// Propositional truncation as a generated HIT, enabled by argument
// faces (`dhit_arg_face`): the squash constructor takes two
// arbitrary elements of the truncation and its endpoints are those
// arguments themselves.
//
//   ‖A‖ ::= point (a : A) | squash (x y : ‖A‖) : x ⇝ y
//
// The eliminator is the generated HIT eliminator; mapping out of
// ‖A‖ into a family requires a squash case, which for a
// proposition-valued (or constant-unit) motive is supplied by
// reflexivity/unit paths.  The universal property at the level of
// points is definitional: every two elements are joined by the
// squash path constructor.

///|
pub fn prop_trunc_schema_at(level : Int32) -> DHitSpec {
  dhit_spec("PropTruncS", level, [dtelescope_entry("A", DUniv(level))], [], [
    dhit_cell_spec("point", 0, [darg_external("value", DTVar(0))], []),
    dhit_cell_spec("squash", 1, [darg_recursive("x"), darg_recursive("y")], [
      dhit_arg_face(DTVar(1)),
      dhit_arg_face(DTVar(0)),
    ]),
  ])
}

///|
pub fn prop_trunc_schema() -> DHitSpec {
  prop_trunc_schema_at(0)
}

///|
pub fn trunc_type_term(a : DTerm) -> DTerm {
  DHitType(prop_trunc_schema(), [a])
}

///|
pub fn trunc_point_term(a : DTerm, value : DTerm) -> DTerm {
  hit_intro_term(prop_trunc_schema(), 0, [a], [value], [])
}

///|
/// The squash path constructor at a dimension.
pub fn trunc_squash_term(a : DTerm, x : DTerm, y : DTerm, dim : Dim) -> DTerm {
  hit_intro_term(prop_trunc_schema(), 1, [a], [x, y], [dim])
}

///|
/// The squash as a path term `x = y` in `‖A‖`.
pub fn trunc_squash_path_term(a : DTerm, x : DTerm, y : DTerm) -> DTerm {
  DLamDim(trunc_squash_term(a, x, y, DVar(0)))
}

///|
/// Recursion into Unit: every truncated type maps to the unit type,
/// with the squash case given by the constant unit path.  This is
/// the simplest instance of the universal property whose squash
/// case type-checks definitionally.
pub fn trunc_rec_unit_term(scrut : DTerm) -> DTerm {
  let spec = prop_trunc_schema()
  DHitElim(
    spec,
    DLam(DHitType(spec, [DBoolTy]), DUnitTy),
    [
      DLam(DBoolTy, DUnitLit),
      DLam(
        DHitType(spec, [DBoolTy]),
        DLam(
          DHitType(spec, [DBoolTy]),
          DLam(DUnitTy, DLam(DUnitTy, DLamDim(DUnitLit))),
        ),
      ),
    ],
    [DBoolTy],
    [],
    scrut,
  )
}

///|
pub fn check_propositional_truncation() -> Bool {
  let spec = prop_trunc_schema()
  if !hit_schema_validate(spec) {
    return false
  }
  let trunc_bool = trunc_type_term(DBoolTy)
  let t = trunc_point_term(DBoolTy, DBoolLit(true))
  let f = trunc_point_term(DBoolTy, DBoolLit(false))
  // Points inhabit the truncation.
  if !dep_check_closed(t, trunc_bool) || !dep_check_closed(f, trunc_bool) {
    return false
  }
  // Squash joins arbitrary points: the path type-checks and its
  // normal form has the advertised endpoints.
  let path_ty = DPath(trunc_bool, t, f)
  let squash_path = trunc_squash_path_term(DBoolTy, t, f)
  if !dep_check_closed(squash_path, path_ty) {
    return false
  }
  // Semantic endpoint computation through argument faces.
  let ty_value = DVHitType(spec, [DVBoolTy], [])
  let t_val = hit_cell_value(spec, 0, [DVBoolTy], [DVBool(true)], [])
  let f_val = hit_cell_value(spec, 0, [DVBoolTy], [DVBool(false)], [])
  let at0 = hit_cell_value(spec, 1, [DVBoolTy], [t_val, f_val], [DZero])
  let at1 = hit_cell_value(spec, 1, [DVBoolTy], [t_val, f_val], [DOne])
  if !conv_at(0, 0, ty_value, at0, t_val) ||
    !conv_at(0, 0, ty_value, at1, f_val) {
    return false
  }
  // Squash also joins non-point elements (its arguments are
  // arbitrary truncation elements): squash between a squash point
  // at a generic dimension and a point type-checks.
  let mid = trunc_squash_term(DBoolTy, t, f, DVar(0))
  let denv = ddim_from_array([DVar(0)])
  let joined = match d_check(mid, ty_value, denv_empty(), denv_empty(), denv) {
    Some(v) =>
      conv_at(
        0,
        1,
        ty_value,
        hit_cell_value(spec, 1, [DVBoolTy], [v, t_val], [DZero]),
        v,
      )
    None => false
  }
  joined &&
  // Recursion into Unit on a point computes.
  dep_nf_closed(trunc_rec_unit_term(t), DUnitTy) == Some(DUnitLit)
}
