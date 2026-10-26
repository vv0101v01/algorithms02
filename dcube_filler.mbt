///|
/// Phase 11: n-dimensional open boxes, assembled fillers, and
/// whole-boundary verification.
///
/// A cube is represented extensionally as a function from one
/// dimension expression per axis to a value.  An open box of arity
/// `n` in a constant type supplies every face except the cap
/// `(axis n-1) = 1`.  The filler is assembled by a single
/// homogeneous composition along the last axis: the side faces
/// become the branches of a `DSystem` (branch face `x_k = e`,
/// branch path the side cube with the composition parameter
/// inserted on the last axis) and the `(n-1) = 0` face is the
/// base.  `dcube_box_validate` checks completeness and all
/// pairwise overlap compatibilities; `dcube_filler_faces_ok`
/// verifies, at generic interior dimensions, that the assembled
/// filler restricts to *every* supplied face -- the whole
/// boundary, not just vertices or a single segment.

///|
pub struct DCubeFunction {
  arity : Int32
  at : (Array[Dim]) -> DValue
}

///|
pub fn dcube_function(
  arity : Int32,
  at : (Array[Dim]) -> DValue,
) -> DCubeFunction {
  { arity, at, }
}

///|
/// Evaluate a cube.  A dimension list of the wrong length yields
/// the defensive value `DVUnit`.
pub fn dcube_at(cube : DCubeFunction, dims : Array[Dim]) -> DValue {
  if dims.length() != cube.arity {
    DVUnit
  } else {
    (cube.at)(dims)
  }
}

///|
pub fn dcube_constant(arity : Int32, value : DValue) -> DCubeFunction {
  { arity, at: _ => value, }
}

///|
pub fn dcube_of_path(path : (Dim) -> DValue) -> DCubeFunction {
  { arity: 1, at: dims => path(dims[0]), }
}

///|
pub fn dcube_of_point(value : DValue) -> DCubeFunction {
  { arity: 0, at: _ => value, }
}

///|
fn dcube_without_axis(dims : Array[Dim], axis : Int32) -> Array[Dim] {
  let out : Array[Dim] = []
  for i in 0..<dims.length() {
    if i != axis {
      out.push(dims[i])
    }
  }
  out
}

///|
fn dcube_with_axis(dims : Array[Dim], axis : Int32, value : Dim) -> Array[Dim] {
  let out : Array[Dim] = []
  for i in 0..<dims.length() {
    out.push(if i == axis { value } else { dims[i] })
  }
  out
}

///|
/// Restrict `axis` to the endpoint dimension (`DZero` or `DOne`).
pub fn dcube_face(
  cube : DCubeFunction,
  axis : Int32,
  endpoint : Dim,
) -> DCubeFunction {
  {
    arity: cube.arity - 1,
    at: dims => {
      let full : Array[Dim] = []
      for i in 0..<cube.arity {
        if i == axis {
          full.push(endpoint)
        } else if i < axis {
          full.push(dims[i])
        } else {
          full.push(dims[i - 1])
        }
      }
      dcube_at(cube, full)
    },
  }
}

///|
/// Insert a degenerate (unused) axis at position `axis`.
pub fn dcube_degenerate(cube : DCubeFunction, axis : Int32) -> DCubeFunction {
  {
    arity: cube.arity + 1,
    at: dims => dcube_at(cube, dcube_without_axis(dims, axis)),
  }
}

///|
pub struct DCubeBoxFace {
  axis : Int32
  hi : Bool
  cube : DCubeFunction
}

///|
pub fn dcube_box_face(
  axis : Int32,
  hi : Bool,
  cube : DCubeFunction,
) -> DCubeBoxFace {
  { axis, hi, cube, }
}

///|
/// An open box of arity `arity` in the constant type `ty`, in an
/// ambient context of `ambient_dlevel` dimensions.  The missing
/// face is `(axis arity-1) = 1` (the cap).
pub struct DCubeOpenBox {
  ty : DValue
  arity : Int32
  ambient_dlevel : Int32
  faces : Array[DCubeBoxFace]
}

///|
pub fn dcube_open_box(
  ty : DValue,
  arity : Int32,
  ambient_dlevel : Int32,
  faces : Array[DCubeBoxFace],
) -> DCubeOpenBox {
  { ty, arity, ambient_dlevel, faces, }
}

///|
pub fn dcube_box_face_of(
  box : DCubeOpenBox,
  axis : Int32,
  hi : Bool,
) -> DCubeFunction? {
  for i in 0..<box.faces.length() {
    let f = box.faces[i]
    if f.axis == axis && f.hi == hi {
      return Some(f.cube)
    }
  }
  None
}

///|
/// Every required face present, with the right arity: all side
/// faces on axes `< arity-1` and the base face `(arity-1) = 0`.
pub fn dcube_box_complete(box : DCubeOpenBox) -> Bool {
  if box.arity < 1 {
    return false
  }
  let last_axis = box.arity - 1
  for axis in 0..<last_axis {
    for hi in [false, true] {
      match dcube_box_face_of(box, axis, hi) {
        Some(cube) => if cube.arity != box.arity - 1 { return false }
        None => return false
      }
    }
  }
  match dcube_box_face_of(box, box.arity - 1, false) {
    Some(cube) => cube.arity == box.arity - 1
    None => false
  }
}

///|
/// Fresh generic dimensions for `n` axes above an ambient context.
pub fn dcube_generic_dims(ambient_dlevel : Int32, n : Int32) -> Array[Dim] {
  let out : Array[Dim] = []
  for i in 0..<n {
    out.push(DVar(ambient_dlevel + i))
  }
  out
}

///|
/// Convertibility of two `n`-cubes at generic interior dimensions.
pub fn dcube_cubes_conv(
  level : Int32,
  ambient_dlevel : Int32,
  ty : DValue,
  f : DCubeFunction,
  g : DCubeFunction,
) -> Bool {
  if f.arity != g.arity {
    return false
  }
  let gd = dcube_generic_dims(ambient_dlevel, f.arity)
  conv_at(level, ambient_dlevel + f.arity, ty, dcube_at(f, gd), dcube_at(g, gd))
}

///|
fn dcube_overlap_axis(axis : Int32, removed : Int32) -> Int32 {
  if axis < removed {
    axis
  } else {
    axis - 1
  }
}

///|
pub struct DCubeBoxReport {
  complete : Bool
  overlaps_ok : Bool
  failed_overlaps : Int32
}

///|
/// Validate an open box: completeness, plus compatibility of
/// every pair of faces on distinct axes along their common edge
/// (checked at generic dimensions of the remaining axes).
pub fn dcube_box_validate(box : DCubeOpenBox, level : Int32) -> DCubeBoxReport {
  let complete = dcube_box_complete(box)
  let mut failed = 0
  if complete && box.arity >= 2 {
    for i in 0..<box.faces.length() {
      for j in (i + 1)..<box.faces.length() {
        let a = box.faces[i]
        let b = box.faces[j]
        if a.axis == b.axis {
          continue
        }
        let a_edge = dcube_face(
          a.cube,
          dcube_overlap_axis(b.axis, a.axis),
          if b.hi {
            DOne
          } else {
            DZero
          },
        )
        let b_edge = dcube_face(
          b.cube,
          dcube_overlap_axis(a.axis, b.axis),
          if a.hi {
            DOne
          } else {
            DZero
          },
        )
        if !dcube_cubes_conv(level, box.ambient_dlevel, box.ty, a_edge, b_edge) {
          failed = failed + 1
        }
      }
    }
  }
  { complete, overlaps_ok: complete && failed == 0, failed_overlaps: failed, }
}

///|
/// Assemble the filler of a complete open box by composing along
/// the last axis.  Returns `None` for an incomplete box.  (Overlap
/// compatibility is the caller's concern -- see
/// `dcube_box_validate`; composition of an incompatible system is
/// still defined by first-match semantics but will not pass
/// `dcube_filler_faces_ok`.)
pub fn dcube_box_fill(box : DCubeOpenBox) -> DCubeFunction? {
  if !dcube_box_complete(box) {
    return None
  }
  let n = box.arity
  let base_cube = match dcube_box_face_of(box, n - 1, false) {
    Some(cube) => cube
    None => return None
  }
  let side_faces : Array[DCubeBoxFace] = []
  for i in 0..<box.faces.length() {
    let f = box.faces[i]
    if f.axis < n - 1 {
      side_faces.push(f)
    }
  }
  let ty = box.ty
  let fill_dlevel = box.ambient_dlevel + n
  Some({
    arity: n,
    at: dims => {
      if dims.length() != n {
        return DVUnit
      }
      let others = dcube_without_axis(dims, n - 1)
      let last = dims[n - 1]
      let branches : Array[DTubeBranch] = []
      for i in 0..<side_faces.length() {
        let sf = side_faces[i]
        let axis = sf.axis
        let side_cube = sf.cube
        let branch_face = face_simplify(
          if sf.hi {
            FEq1(dims[axis])
          } else {
            FEq0(dims[axis])
          },
        )
        branches.push(
          tube_branch(branch_face, (j : Dim) => {
            let full = dcube_with_axis(dims, n - 1, j)
            dcube_at(side_cube, dcube_without_axis(full, axis))
          }),
        )
      }
      let base = dcube_at(base_cube, others)
      hfill_value(ty, dsystem_of(branches), base, fill_dlevel)(last)
    },
  })
}

///|
/// The cap: the assembled filler's missing face `(arity-1) = 1`.
pub fn dcube_box_cap(box : DCubeOpenBox) -> DCubeFunction? {
  match dcube_box_fill(box) {
    Some(filler) => Some(dcube_face(filler, box.arity - 1, DOne))
    None => None
  }
}

///|
/// Whole-boundary verification: the filler restricts to every
/// supplied face, checked at generic interior dimensions.
pub fn dcube_filler_faces_ok(
  box : DCubeOpenBox,
  filler : DCubeFunction,
  level : Int32,
) -> Bool {
  if filler.arity != box.arity {
    return false
  }
  for i in 0..<box.faces.length() {
    let f = box.faces[i]
    let restricted = dcube_face(filler, f.axis, if f.hi { DOne } else { DZero })
    if !dcube_cubes_conv(level, box.ambient_dlevel, box.ty, restricted, f.cube) {
      return false
    }
  }
  true
}

///|
/// Fill and verify in one step: validate the box, assemble the
/// filler, and check the whole boundary.
pub fn dcube_box_fill_verified(
  box : DCubeOpenBox,
  level : Int32,
) -> DCubeFunction? {
  let report = dcube_box_validate(box, level)
  if !report.overlaps_ok {
    return None
  }
  match dcube_box_fill(box) {
    Some(filler) =>
      if dcube_filler_faces_ok(box, filler, level) {
        Some(filler)
      } else {
        None
      }
    None => None
  }
}

// ---------------------------------------------------------------------------
// Phase 12: stratified extensionality for host cube functions.
//
// `dcube_cubes_conv` probes one generic interior point, but a
// host cube is an arbitrary function on dimension expressions:
// it can branch on an axis being an endpoint, on two axes
// coinciding, or on connection structure (`i ∧ j`, `i ∨ j`,
// `¬i`), none of which a single generic probe sees.  The
// stratified checker evaluates both cubes on three tiers of
// dimension assignments:
//
//   A. every axis in {0, 1, fresh var} -- all faces' interiors;
//   B. every axis in {0, 1, s, t} for two shared dimensions
//      `s` (an ambient variable when one exists) and `t` --
//      diagonals and ambient collisions;
//   C. every axis in {s, ¬s, s ∧ t, s ∨ t} -- connection
//      strata.
//
// This is still a finite probe set (a host function could in
// principle hide behaviour on expressions outside it), but it
// covers every stratum of the cube's face lattice and the
// standard connection/diagonal degenerations.  Tiers whose
// probe count exceeds 4096 are skipped and reported through
// `complete = false`.
// ---------------------------------------------------------------------------

///|
pub struct DCubeStratifiedReport {
  equal : Bool
  probes : Int32
  failed : Int32
  complete : Bool
}

///|
fn dcube_stratified_tier(
  level : Int32,
  dlevel : Int32,
  ty : DValue,
  f : DCubeFunction,
  g : DCubeFunction,
  pools : Array[Array[Dim]],
  stats : Array[Int32],
) -> Bool {
  let n = pools.length()
  let indices : Array[Int32] = []
  for _i in 0..<n {
    indices.push(0)
  }
  while true {
    let dims : Array[Dim] = []
    for i in 0..<n {
      dims.push(pools[i][indices[i]])
    }
    stats[0] = stats[0] + 1
    if !conv_at(level, dlevel, ty, dcube_at(f, dims), dcube_at(g, dims)) {
      stats[1] = stats[1] + 1
      return false
    }
    let mut pos = n - 1
    while pos >= 0 {
      indices[pos] = indices[pos] + 1
      if indices[pos] < pools[pos].length() {
        break
      }
      indices[pos] = 0
      pos = pos - 1
    }
    if pos < 0 {
      break
    }
  }
  true
}

///|
pub fn dcube_cubes_conv_stratified_report(
  level : Int32,
  ambient_dlevel : Int32,
  ty : DValue,
  f : DCubeFunction,
  g : DCubeFunction,
) -> DCubeStratifiedReport {
  if f.arity != g.arity {
    return { equal: false, probes: 0, failed: 0, complete: false, }
  }
  let n = f.arity
  if n == 0 {
    let eq = conv_at(
      level,
      ambient_dlevel,
      ty,
      dcube_at(f, []),
      dcube_at(g, []),
    )
    return {
      equal: eq,
      probes: 1,
      failed: if eq {
        0
      } else {
        1
      },
      complete: true,
    }
  }
  let dlevel = ambient_dlevel + n + 2
  let shared_s = DVar(0)
  let shared_t = DVar(ambient_dlevel + n)
  let tiers : Array[Array[Array[Dim]]] = []
  let tier_a : Array[Array[Dim]] = []
  for i in 0..<n {
    tier_a.push([DZero, DOne, DVar(ambient_dlevel + i)])
  }
  tiers.push(tier_a)
  let tier_b : Array[Array[Dim]] = []
  for _i in 0..<n {
    tier_b.push([DZero, DOne, shared_s, shared_t])
  }
  tiers.push(tier_b)
  let tier_c : Array[Array[Dim]] = []
  for _i in 0..<n {
    tier_c.push([
      shared_s,
      DNeg(shared_s),
      DAnd(shared_s, shared_t),
      DOr(shared_s, shared_t),
    ])
  }
  tiers.push(tier_c)
  let stats = [0, 0]
  let mut complete = true
  for t in 0..<tiers.length() {
    let pools = tiers[t]
    let mut count = 1
    for i in 0..<pools.length() {
      count = count * pools[i].length()
    }
    if count > 4096 {
      complete = false
      continue
    }
    if !dcube_stratified_tier(level, dlevel, ty, f, g, pools, stats) {
      return { equal: false, probes: stats[0], failed: stats[1], complete, }
    }
  }
  { equal: true, probes: stats[0], failed: 0, complete, }
}

///|
pub fn dcube_cubes_conv_stratified(
  level : Int32,
  ambient_dlevel : Int32,
  ty : DValue,
  f : DCubeFunction,
  g : DCubeFunction,
) -> Bool {
  dcube_cubes_conv_stratified_report(level, ambient_dlevel, ty, f, g).equal
}

///|
/// Stratified box validation: pairwise face overlaps are
/// compared on all strata of the shared edge, not only at its
/// generic interior.
pub fn dcube_box_validate_stratified(
  box : DCubeOpenBox,
  level : Int32,
) -> DCubeBoxReport {
  let complete = dcube_box_complete(box)
  let mut failed = 0
  if complete && box.arity >= 2 {
    for i in 0..<box.faces.length() {
      for j in (i + 1)..<box.faces.length() {
        let a = box.faces[i]
        let b = box.faces[j]
        if a.axis == b.axis {
          continue
        }
        let a_edge = dcube_face(
          a.cube,
          dcube_overlap_axis(b.axis, a.axis),
          if b.hi {
            DOne
          } else {
            DZero
          },
        )
        let b_edge = dcube_face(
          b.cube,
          dcube_overlap_axis(a.axis, b.axis),
          if a.hi {
            DOne
          } else {
            DZero
          },
        )
        if !dcube_cubes_conv_stratified(
            level,
            box.ambient_dlevel,
            box.ty,
            a_edge,
            b_edge,
          ) {
          failed = failed + 1
        }
      }
    }
  }
  { complete, overlaps_ok: complete && failed == 0, failed_overlaps: failed, }
}

///|
pub fn dcube_filler_faces_ok_stratified(
  box : DCubeOpenBox,
  filler : DCubeFunction,
  level : Int32,
) -> Bool {
  if filler.arity != box.arity {
    return false
  }
  for i in 0..<box.faces.length() {
    let f = box.faces[i]
    let restricted = dcube_face(filler, f.axis, if f.hi { DOne } else { DZero })
    if !dcube_cubes_conv_stratified(
        level,
        box.ambient_dlevel,
        box.ty,
        restricted,
        f.cube,
      ) {
      return false
    }
  }
  true
}

///|
/// Fill and verify with stratified extensionality throughout.
pub fn dcube_box_fill_verified_stratified(
  box : DCubeOpenBox,
  level : Int32,
) -> DCubeFunction? {
  let report = dcube_box_validate_stratified(box, level)
  if !report.overlaps_ok {
    return None
  }
  match dcube_box_fill(box) {
    Some(filler) =>
      if dcube_filler_faces_ok_stratified(box, filler, level) {
        Some(filler)
      } else {
        None
      }
    None => None
  }
}
