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
