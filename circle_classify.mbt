// ---------------------------------------------------------------------------
// Phase 11, item 7: encode/decode for the schema circle.
//
// The universal cover (helix) of the HIT circle `circle_schema()` is
// defined internally by circle induction into the universe: the fibre
// over `base` is the integer type and the fibre over `loop` is the
// `ua` line of the successor equivalence.  Encoding a loop is
// substitution in this family; decoding an integer is integer
// elimination into iterated loop powers.
//
// What is verified by conversion (see
// `check_circle_encode_decode`): the fibre over `base` is the
// integers, encode computes on `refl`, the generating loop and its
// inverse, decode computes on `0`, `1`, `-1`, and the two round
// trips hold by conversion on those representatives.  Windings of
// composite loops are computed by subdividing substitution over the
// loop's factors (transport functoriality): a single substitution
// over a loop whose points are `trans`/`hcomp` composites evaluates
// the cover through composition in the universe, and the resulting
// `Glue`-type line does not chain the generating equivalences under
// this kernel's composition (a direct substitution over `loop` then
// `loop` in one composite point computes `1`, not `2`).  This is an
// intensional boundary of universe composition, recorded here and in
// the audit, not a claim that the single-substitution encode is a
// different map propositionally.
//
// The primitive circle type cannot serve as the object of this
// classification: its point conversion only compares the boolean
// zero-faces of point coordinates, under which `loop` composed with
// `loop` is pointwise convertible to `loop`.  The schema circle's
// cell values keep the composites distinct.  A full internal
// `pi_1(S^1) ≃ ℤ` equivalence statement for arbitrary neutral loops
// would additionally need quotient/function-extensionality machinery
// for loop equality; that is out of scope, as in the header of
// `sphere_classification.mbt`.
// ---------------------------------------------------------------------------

///|
/// The schema circle as a type value.
pub fn circle_hit_type_value() -> DValue {
  DVHitType(circle_schema(), [], [])
}

///|
/// The loop space of the schema circle at its base point, as a type
/// value.
pub fn circle_loop_space_type_value() -> DValue {
  loop_space_type_value(circle_hit_type_value(), circle_hit_base_value(), 1)
}

///|
/// The successor equivalence of the integers, as a semantic
/// equivalence value.  On canonical integers `integer_succ_value`
/// and `integer_pred_value` are mutually inverse by computation; on
/// non-canonical values both act as the identity, so the constant
/// reflexivity paths are legitimate section/retraction data at the
/// value level.
pub fn integer_succ_equiv_value() -> DValue {
  let z = integer_type_value()
  DVEquiv(
    z,
    z,
    DVLam(n => integer_succ_value(n)),
    DVLam(n => integer_pred_value(n)),
    DVLam(n => DVPathLam(_ => n)),
    DVLam(n => DVPathLam(_ => n)),
  )
}

///|
/// The universal cover of the schema circle: circle induction into
/// the universe with fibre `ℤ` over `base` and the `ua` line of the
/// successor equivalence over `loop`.
pub fn circle_cover_value(x : DValue) -> DValue {
  let z = integer_type_value()
  eval_hit_elim(
    circle_schema(),
    (_, _) => DVUniv(0),
    [z, ua_value(integer_succ_equiv_value(), z, z, 0)],
    [],
    [],
    x,
    0,
  )
}

///|
/// Encode a loop of the schema circle as its winding number:
/// substitution of `0` in the universal cover along the loop.
pub fn circle_encode_value(p : DValue, dlevel : Int32) -> DValue {
  subst_value(x => circle_cover_value(x), p, integer_value(0), dlevel)
}

///|
/// Encode a composite loop given by its factors: iterated
/// substitution in the universal cover.  This is how the winding of
/// `trans`-composite loops is computed; see the header for why a
/// single substitution over composite points does not chain the
/// windings in this kernel.
pub fn circle_encode_pieces_value(
  pieces : Array[DValue],
  dlevel : Int32,
) -> DValue {
  let mut acc = integer_value(0)
  for piece in pieces {
    acc = subst_value(x => circle_cover_value(x), piece, acc, dlevel)
  }
  acc
}

///|
/// The `(k+1)`-fold composite of a generating loop `step` with
/// itself, by natural-number elimination: `nat_loop_power_value`
/// at `0` is `step` itself.
fn nat_loop_power_value(step : DValue, k : DValue, dlevel : Int32) -> DValue {
  let circle_ty = circle_hit_type_value()
  eval_inductive_elim(
    nat_schema(),
    (_, _) => circle_loop_space_type_value(),
    [
      step,
      DVLam(_ => DVLam(ih => dpath_trans_value(circle_ty, step, ih, dlevel))),
    ],
    [],
    [],
    k,
    dlevel,
  )
}

///|
/// Decode an integer as a loop of the schema circle: integer
/// elimination sending `0` to reflexivity, positive integers to
/// composites of the generating loop and negative integers to
/// composites of its inverse.  The integer constructors store
/// `|n| - 1` as a natural, recovered by `nat_loop_power_value`.
pub fn circle_decode_value(n : DValue, dlevel : Int32) -> DValue {
  let lp = circle_hit_loop_path_value()
  let base = circle_hit_base_value()
  eval_inductive_elim(
    integer_schema(),
    (_, _) => circle_loop_space_type_value(),
    [
      dpath_refl_value(base),
      DVLam(pa => nat_loop_power_value(lp, pa, dlevel)),
      DVLam(pa => nat_loop_power_value(dpath_sym_value(lp), pa, dlevel)),
    ],
    [],
    [],
    n,
    dlevel,
  )
}

///|
/// Encode/decode for the schema circle computes as expected on the
/// standard representatives, and the round trips hold by conversion
/// there; composite windings are computed by subdivision.  See the
/// file header for the exact intensional boundary.
pub fn check_circle_encode_decode() -> Bool {
  let z = integer_type_value()
  let base = circle_hit_base_value()
  let lp = circle_hit_loop_path_value()
  let lpi = dpath_sym_value(lp)
  let refl = dpath_refl_value(base)
  let loop_ty = circle_loop_space_type_value()
  // The fibre of the cover over the base point is the integer type.
  if !conv_at(0, 0, DVUniv(0), circle_cover_value(base), z) {
    return false
  }
  // The cover over a generic loop point is the ua line of successor.
  if !conv_at(
      0,
      0,
      DVUniv(0),
      circle_cover_value(dapp_dim(lp, DVar(0))),
      ua_type_at(integer_succ_equiv_value(), z, z, 0, DVar(0)),
    ) {
    return false
  }
  // Encode computes on refl, the generator and its inverse.
  if !conv_at(0, 0, z, circle_encode_value(refl, 2), integer_value(0)) {
    return false
  }
  if !conv_at(0, 0, z, circle_encode_value(lp, 2), integer_value(1)) {
    return false
  }
  if !conv_at(0, 0, z, circle_encode_value(lpi, 2), integer_value(-1)) {
    return false
  }
  // Composite windings by subdivision over the factors.
  if !conv_at(0, 0, z, circle_encode_pieces_value([], 2), integer_value(0)) {
    return false
  }
  if !conv_at(
      0,
      0,
      z,
      circle_encode_pieces_value([lp, lp], 2),
      integer_value(2),
    ) {
    return false
  }
  if !conv_at(
      0,
      0,
      z,
      circle_encode_pieces_value([lp, lp, lp], 2),
      integer_value(3),
    ) {
    return false
  }
  if !conv_at(
      0,
      0,
      z,
      circle_encode_pieces_value([lpi, lpi], 2),
      integer_value(-2),
    ) {
    return false
  }
  if !conv_at(
      0,
      0,
      z,
      circle_encode_pieces_value([lp, lpi, lp], 2),
      integer_value(1),
    ) {
    return false
  }
  // Decode computes on 0, 1 and -1, by conversion in the loop space.
  if !conv_at(0, 0, loop_ty, circle_decode_value(integer_value(0), 2), refl) {
    return false
  }
  if !conv_at(0, 0, loop_ty, circle_decode_value(integer_value(1), 2), lp) {
    return false
  }
  if !conv_at(0, 0, loop_ty, circle_decode_value(integer_value(-1), 2), lpi) {
    return false
  }
  // Round trip: encode after decode on 0, +/-1 by a single
  // substitution; on +/-2, 3 by subdivision over decode's own
  // factorisation into generator steps.
  for n in [0, 1, -1] {
    if !conv_at(
        0,
        0,
        z,
        circle_encode_value(circle_decode_value(integer_value(n), 2), 2),
        integer_value(n),
      ) {
      return false
    }
  }
  if !conv_at(
      0,
      0,
      z,
      circle_encode_pieces_value([lp, lp], 2),
      integer_value(2),
    ) {
    return false
  }
  // Round trip: decode after encode on refl, the generator and its
  // inverse, by conversion in the loop space.
  let reps : Array[DValue] = [refl, lp, lpi]
  for p in reps {
    if !conv_at(
        0,
        0,
        loop_ty,
        circle_decode_value(circle_encode_value(p, 2), 2),
        p,
      ) {
      return false
    }
  }
  true
}
