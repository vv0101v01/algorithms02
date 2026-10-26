///|
// High-level cubical algorithms over the dependent kernel.
//
// The kernel already provides the primitive Kan operations
// (`coe_value`, `comp_value`, `fill_value`, `hcomp_value`).  This
// component packages the operations that cubical developments use
// every day -- transport, dependent paths over a transport filler,
// path symmetry/congruence/transitivity by an explicit hcomp square,
// function extensionality, and substitution along a path -- as one
// coherent semantic API, together with closed-term builders for the
// same operations.  Nothing in the kernel depends back on this file:
// it is an upper layer in `architecture.json`.
//
// Semantic paths are `DVPathLam` values.  The transitivity square is
// the standard one: for `p : x = y` and `q : y = z`, the square
// `S(i,j)` fills, in direction `j`, the open box whose base at `j=0`
// is `p(i)`, whose `i=0` side is constant `x`, and whose `i=1` side
// is `q(j)`.  Then `i ↦ S(i,1)` is a path `x = z`.

// ---------------------------------------------------------------------------
// Transport and Kan boxes
// ---------------------------------------------------------------------------

///|
/// Transport (coe 0→1) along a semantic type line.
pub fn transport_value(
  line : (Dim) -> DValue,
  v : DValue,
  dlevel : Int32,
) -> DValue {
  coe_value(line, DZero, DOne, v, dlevel)
}

///|
/// Backwards transport (coe 1→0) along a semantic type line.
pub fn transport_back_value(
  line : (Dim) -> DValue,
  v : DValue,
  dlevel : Int32,
) -> DValue {
  coe_value(line, DOne, DZero, v, dlevel)
}

///|
/// Transport along a checked (substitutable) type line.
pub fn transport_checked_line_value(
  line : DCheckedTypeLine,
  v : DValue,
  dlevel : Int32,
) -> DValue {
  checked_coe_value(line, DZero, DOne, v, dlevel)
}

///|
/// The transport filler: a dependent path from `v` to its transport.
pub fn transport_filler_value(
  line : (Dim) -> DValue,
  v : DValue,
  dlevel : Int32,
) -> (Dim) -> DValue {
  fill_value(line, dsystem_empty(), v, dlevel)
}

///|
/// The transport filler as a `PathP` value over the line.
pub fn transport_pathp_value(
  line : (Dim) -> DValue,
  v : DValue,
  dlevel : Int32,
) -> DValue {
  DVPathLam(transport_filler_value(line, v, dlevel))
}

///|
/// An open Kan box: a type line, a tube system and a base cap.
pub struct KanBox {
  line : (Dim) -> DValue
  system : DSystem
  base : DValue
  dlevel : Int32
}

///|
pub fn kan_box(
  line : (Dim) -> DValue,
  system : DSystem,
  base : DValue,
  dlevel : Int32,
) -> KanBox {
  KanBox::{ line, system, base, dlevel, }
}

///|
/// The filler of an open box, as a function of the composition
/// direction: at 0 it is the base, at 1 the composition, and on each
/// tube face it agrees with that tube.
pub fn kan_box_fill(box : KanBox) -> (Dim) -> DValue {
  fill_value(box.line, box.system, box.base, box.dlevel)
}

///|
/// The composition (cap) of an open box.
pub fn kan_box_comp(box : KanBox) -> DValue {
  comp_value(box.line, box.system, box.base, box.dlevel)
}

///|
/// The filler of an open box as a `PathP` value over its line.
pub fn kan_box_pathp(box : KanBox) -> DValue {
  DVPathLam(kan_box_fill(box))
}

// ---------------------------------------------------------------------------
// Path algebra on semantic values
// ---------------------------------------------------------------------------

///|
/// The point of a semantic path at a dimension.
pub fn dpath_at_value(p : DValue, d : Dim) -> DValue {
  dapp_dim(p, d)
}

///|
/// Reflexivity: the constant path.
pub fn dpath_refl_value(v : DValue) -> DValue {
  DVPathLam(_ => v)
}

///|
/// Symmetry by dimension reversal.
pub fn dpath_sym_value(p : DValue) -> DValue {
  DVPathLam(d => dapp_dim(p, DNeg(d)))
}

///|
/// The suffix of a path starting at `r`: `j ↦ p(r ∨ j)`, a path from
/// `p(r)` to `p(1)`.
pub fn dpath_segment_value(p : DValue, r : Dim) -> DValue {
  DVPathLam(j => dapp_dim(p, DOr(r, j)))
}

///|
/// The prefix of a path ending at `r`: `j ↦ p(r ∧ j)`, a path from
/// `p(0)` to `p(r)`.
pub fn dpath_prefix_value(p : DValue, r : Dim) -> DValue {
  DVPathLam(j => dapp_dim(p, DAnd(r, j)))
}

///|
/// The transitivity square of `p : x = y` and `q : y = z`, as a
/// nested path value `S(i,j)`.
pub fn dpath_trans_square_value(
  ty : DValue,
  p : DValue,
  q : DValue,
  dlevel : Int32,
) -> DValue {
  DVPathLam(i => {
    DVPathLam(j => {
      let branches = dsystem_of([
        tube_branch(face_simplify(FEq0(i)), _ => dapp_dim(p, DZero)),
        tube_branch(face_simplify(FEq1(i)), k => dapp_dim(q, k)),
      ])
      fill_value(_ => ty, branches, dapp_dim(p, i), dlevel + 1)(j)
    })
  })
}

///|
/// Transitivity of paths: the top edge `i ↦ S(i,1)` of the
/// transitivity square.
pub fn dpath_trans_value(
  ty : DValue,
  p : DValue,
  q : DValue,
  dlevel : Int32,
) -> DValue {
  let square = dpath_trans_square_value(ty, p, q, dlevel)
  DVPathLam(i => dapp_dim(dapp_dim(square, i), DOne))
}

///|
/// Congruence (`ap`): apply a function pointwise to a path.
pub fn dpath_cong_value(f : DValue, dom : DValue, p : DValue) -> DValue {
  DVPathLam(d => dapp_typed(f, dapp_dim(p, d), dom))
}

///|
/// Function extensionality: from a pointwise path-valued function to
/// a path of functions.
pub fn dpath_funext_value(pointwise : DValue, dom : DValue) -> DValue {
  DVPathLam(d => DVLam(x => dapp_dim(dapp_typed(pointwise, x, dom), d)))
}

///|
/// Substitution/transport in a dependent family along a path in the
/// base type: `subst B p v = coe^{j.B(p j)} v`.
pub fn subst_value(
  fam : (DValue) -> DValue,
  p : DValue,
  v : DValue,
  dlevel : Int32,
) -> DValue {
  transport_value(j => fam(dapp_dim(p, j)), v, dlevel)
}

///|
/// The dependent path over `p` whose far endpoint is `subst B p v`.
pub fn subst_pathp_value(
  fam : (DValue) -> DValue,
  p : DValue,
  v : DValue,
  dlevel : Int32,
) -> DValue {
  transport_pathp_value(j => fam(dapp_dim(p, j)), v, dlevel)
}

// ---------------------------------------------------------------------------
// Closed-term builders
//
// These build DTerms.  The arguments must be closed with respect to
// ambient dimension variables (the builders place them under fresh
// dimension binders; term variables are in a separate space and are
// unaffected).
// ---------------------------------------------------------------------------

///|
/// `transport` of a closed term along a line body.
pub fn dtransport_term(line_body : DTerm, x : DTerm) -> DTerm {
  DCoe(line_body, DZero, DOne, x)
}

///|
/// Backwards `transport` of a closed term along a line body.
pub fn dtransport_back_term(line_body : DTerm, x : DTerm) -> DTerm {
  DCoe(line_body, DOne, DZero, x)
}

///|
pub fn dpath_refl_term(x : DTerm) -> DTerm {
  DLamDim(x)
}

///|
pub fn dpath_sym_term(p : DTerm) -> DTerm {
  DLamDim(DAppDim(p, DNeg(DVar(0))))
}

///|
pub fn dpath_cong_term(f : DTerm, p : DTerm) -> DTerm {
  DLamDim(DApp(f, DAppDim(p, DVar(0))))
}

///|
/// Function extensionality as a closed term: from
/// `pointwise : (x:A) -> Path B (f x) (g x)` build a path
/// `f = g` in `A -> B` (at the constant family `B`).
pub fn dfunext_term(dom : DTerm, pointwise : DTerm) -> DTerm {
  DLamDim(DLam(dom, DAppDim(DApp(pointwise, DTVar(0)), DVar(0))))
}

///|
/// Transitivity of closed paths by the hcomp square.  Under the
/// outer `<i>` binder, `DHComp` composes in a fresh direction `j`:
/// tube bodies therefore see `j` as `DVar(0)`.
pub fn dpath_trans_term(ty : DTerm, p : DTerm, q : DTerm) -> DTerm {
  DLamDim(
    DHComp(
      ty,
      [
        d_tube(FEq0(DVar(0)), DAppDim(p, DZero)),
        d_tube(FEq1(DVar(0)), DAppDim(q, DVar(0))),
      ],
      DAppDim(p, DVar(0)),
    ),
  )
}

// ---------------------------------------------------------------------------
// Behavioural laws
// ---------------------------------------------------------------------------

///|
// Shared test helper (also used by equiv_laws/univalence law checks).
fn cubical_bool_is(v : DValue, expected : Bool) -> Bool {
  conv_at(0, 0, DVBoolTy, v, DVBool(expected))
}

///|
fn check_transport_algorithms() -> Bool {
  let e = deval_dim(bool_not_equiv_term(), denv_empty(), ddim_empty())
  let line = ua_line_value(e, DVBoolTy, DVBoolTy, 0)
  let filler = transport_filler_value(line, DVBool(true), 0)
  let box = kan_box(line, dsystem_empty(), DVBool(true), 0)
  cubical_bool_is(transport_value(line, DVBool(true), 0), false) &&
  cubical_bool_is(transport_back_value(line, DVBool(true), 0), false) &&
  cubical_bool_is(filler(DZero), true) &&
  cubical_bool_is(filler(DOne), false) &&
  cubical_bool_is(kan_box_comp(box), false) &&
  cubical_bool_is(dapp_dim(kan_box_pathp(box), DOne), false) &&
  cubical_bool_is(
    subst_value(_ => DVBoolTy, dpath_refl_value(DVBool(true)), DVBool(true), 0),
    true,
  )
}

///|
fn check_path_algebra_algorithms() -> Bool {
  // The circle loop is a genuinely nonconstant path.
  let loop_path : DValue = DVPathLam(d => circle_point(d))
  let base = circle_point(DZero)
  let sym_ok = conv_at(
      0,
      0,
      DVCircleTy,
      dapp_dim(dpath_sym_value(loop_path), DZero),
      base,
    ) &&
    conv_at(0, 0, DVCircleTy, dapp_dim(dpath_sym_value(loop_path), DOne), base)
  let trans = dpath_trans_value(DVCircleTy, loop_path, loop_path, 0)
  let trans_ok = conv_at(0, 0, DVCircleTy, dapp_dim(trans, DZero), base) &&
    conv_at(0, 0, DVCircleTy, dapp_dim(trans, DOne), base)
  let cong = dpath_cong_value(DVLam(x => x), DVCircleTy, loop_path)
  let cong_ok = conv_at(
    0,
    1,
    DVCircleTy,
    dapp_dim(cong, DVar(0)),
    dapp_dim(loop_path, DVar(0)),
  )
  let pointwise : DValue = DVLam(x => dpath_refl_value(x))
  let funext_path = dpath_funext_value(pointwise, DVCircleTy)
  let funext_ok = conv_at(
    0,
    0,
    DVCircleTy,
    dapp_typed(dapp_dim(funext_path, DOne), base, DVCircleTy),
    base,
  )
  let segment_ok = conv_at(
      0,
      0,
      DVCircleTy,
      dapp_dim(dpath_segment_value(loop_path, DZero), DOne),
      base,
    ) &&
    conv_at(
      0,
      0,
      DVCircleTy,
      dapp_dim(dpath_prefix_value(loop_path, DOne), DOne),
      base,
    )
  sym_ok && trans_ok && cong_ok && funext_ok && segment_ok
}

///|
fn check_cubical_term_builders() -> Bool {
  let path_ty = DPath(DCircleTy, DCircleBase, DCircleBase)
  let trans = dpath_trans_term(DCircleTy, DCircleLoop, DCircleLoop)
  if !dep_check_closed(trans, path_ty) {
    return false
  }
  let sym = dpath_sym_term(DCircleLoop)
  if !dep_check_closed(sym, path_ty) {
    return false
  }
  let cong = dpath_cong_term(DLam(DCircleTy, DTVar(0)), DCircleLoop)
  if !dep_check_closed(cong, path_ty) {
    return false
  }
  let id_fun = DLam(DCircleTy, DTVar(0))
  let pointwise = DLam(DCircleTy, DLamDim(DTVar(0)))
  let fun_path_ty = DPath(DPi(DCircleTy, DCircleTy), id_fun, id_fun)
  if !dep_check_closed(dfunext_term(DCircleTy, pointwise), fun_path_ty) {
    return false
  }
  let ua_line = DAppDim(DUa(bool_not_equiv_term()), DVar(0))
  dep_nf_closed(dtransport_term(ua_line, DBoolLit(true)), DBoolTy) ==
  Some(DBoolLit(false)) &&
  dep_nf_closed(dtransport_back_term(ua_line, DBoolLit(true)), DBoolTy) ==
  Some(DBoolLit(false))
}

///|
pub fn check_cubical_algorithms() -> Bool {
  check_transport_algorithms() &&
  check_path_algebra_algorithms() &&
  check_cubical_term_builders()
}

///|
/// Left unit as a 3-cell: for `alpha : Path(space, r, r)`, a
/// path in `Path(space, r, r)` from `refl(r) ⬝ alpha` to
/// `alpha`.  The transitivity square `S` of `(refl, alpha)`
/// has top edge `refl ⬝ alpha`, right edge `alpha`, and left
/// and bottom edges constant at `r`; the 3-cell rotates the
/// top edge onto the right edge in two connection phases --
/// first `S(i, i ∨ ¬t)` (top edge to diagonal, start point
/// sliding down the constant left edge), then `S(i ∨ t, i)`
/// (diagonal to right edge, start point sliding along the
/// constant bottom edge) -- so both endpoints stay at `r`
/// throughout.
pub fn dpath_left_unit3_value(
  space_ty : DValue,
  r : DValue,
  alpha : DValue,
  dlevel : Int32,
) -> DValue {
  let square = dpath_trans_square_value(
    space_ty,
    dpath_refl_value(r),
    alpha,
    dlevel,
  )
  let phase1 : DValue = DVPathLam(t => {
    DVPathLam(i => dapp_dim(dapp_dim(square, i), dim_simplify(DOr(i, DNeg(t)))))
  })
  let phase2 : DValue = DVPathLam(t => {
    DVPathLam(i => dapp_dim(dapp_dim(square, dim_simplify(DOr(i, t))), i))
  })
  dpath_trans_value(DVPathTy(_ => space_ty, r, r), phase1, phase2, dlevel)
}

///|
/// Right unit as a 3-cell: a path from `alpha ⬝ refl(r)` to
/// `alpha`, by sliding vertically through the transitivity
/// square of `(alpha, refl)`, whose bottom edge is `alpha`
/// and whose left and right edges are constant at `r`.
pub fn dpath_right_unit3_value(
  space_ty : DValue,
  r : DValue,
  alpha : DValue,
  dlevel : Int32,
) -> DValue {
  let square = dpath_trans_square_value(
    space_ty,
    alpha,
    dpath_refl_value(r),
    dlevel,
  )
  DVPathLam(t => DVPathLam(i => dapp_dim(dapp_dim(square, i), DNeg(t))))
}
