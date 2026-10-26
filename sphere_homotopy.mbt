///|
// Homotopy representatives for the iterated-suspension spheres.
//
// This file deliberately separates three kinds of data:
//
//   * kernel-level representatives: loop-space and based-map types,
//     integer degree maps obtained by iterating the suspension functor,
//     and the usual point-to-loop unit for a suspension;
//   * an explicit equivalence datum between `S^3` and the same sphere
//     presented with its two poles interchanged;
//   * the classical Hopf map on the unit sphere in `C^2`, including a
//     numerical linking-number computation for two Hopf fibers.
//
// These are concrete representatives and invariants.  Phase 10 adds
// an internal integer type, quotient presentations of `pi_3`, and a
// canonical spherical-loop representative calculus in
// `sphere_classification.mbt`.  Even together, those constructions
// do not constitute internal encode/decode proofs of the
// classifications `pi_3(S^3) ~= Z` or `pi_3(S^2) ~= Z`; those remain
// synthetic-homotopy theorems beyond this component.

// ---------------------------------------------------------------------------
// Closed-term loop spaces and based maps
// ---------------------------------------------------------------------------

///|
/// The canonical point of an iterated loop space: reflexivity iterated
/// `n` times.  For `n <= 0` this is just `base`.
pub fn iterated_refl_term(base : DTerm, n : Int32) -> DTerm {
  if n <= 0 {
    base
  } else {
    DLamDim(iterated_refl_term(base, n - 1))
  }
}

///|
/// The closed term for the `n`-fold loop space `Omega^n(a, base)`.
/// `Omega^0` is `a`, and
/// `Omega^(n+1)(a,base) =
///   Path(Omega^n(a,base), refl^n(base), refl^n(base))`.
pub fn loop_space_type_term(a : DTerm, base : DTerm, n : Int32) -> DTerm {
  if n <= 0 {
    a
  } else {
    let previous = loop_space_type_term(a, base, n - 1)
    let point = iterated_refl_term(base, n - 1)
    DPath(previous, point, point)
  }
}

///|
/// The type of based maps, represented as a dependent pair of a function
/// and a path identifying the image of the source base point with the
/// target base point.  All four type/point terms are expected to be
/// closed.
pub fn based_map_type_term(
  source : DTerm,
  target : DTerm,
  source_base : DTerm,
  target_base : DTerm,
) -> DTerm {
  DSigma(
    DPi(source, target),
    DPath(target, DApp(DTVar(0), source_base), target_base),
  )
}

// ---------------------------------------------------------------------------
// Circle powers and spherical degree maps
// ---------------------------------------------------------------------------

///|
/// The base point of the schema circle.
pub fn circle_hit_base_value() -> DValue {
  DVHitCell(circle_schema(), 0, [], [], [])
}

///|
/// The generating loop of the schema circle, as a semantic path.
pub fn circle_hit_loop_path_value() -> DValue {
  let circle = circle_schema()
  DVPathLam(d => hit_cell_value(circle, 1, [], [], [d]))
}

///|
/// The `n`-fold composite of the circle loop.  Positive powers compose
/// the loop with itself by path transitivity; negative powers reverse
/// the corresponding positive power.
pub fn circle_hit_loop_power_value(n : Int32) -> DValue {
  let circle_ty : DValue = DVHitType(circle_schema(), [], [])
  if n == 0 {
    dpath_refl_value(circle_hit_base_value())
  } else if n < 0 {
    dpath_sym_value(circle_hit_loop_power_value(0 - n))
  } else {
    let mut power = circle_hit_loop_path_value()
    let mut k = 1
    while k < n {
      power = dpath_trans_value(
        circle_ty,
        power,
        circle_hit_loop_path_value(),
        0,
      )
      k = k + 1
    }
    power
  }
}

///|
/// The degree-`n` endomap of the schema circle, applied to a point.  It
/// fixes the base point and sends the generating loop to its `n`-th
/// power.
pub fn circle_degree_value(n : Int32, point : DValue, dlevel : Int32) -> DValue {
  let circle = circle_schema()
  let circle_ty : DValue = DVHitType(circle, [], [])
  eval_hit_elim(
    circle,
    (_, _) => circle_ty,
    [circle_hit_base_value(), circle_hit_loop_power_value(n)],
    [],
    [],
    point,
    dlevel,
  )
}

///|
/// Apply a map on suspension bases to a point of a suspension sphere.
/// North goes to north, south to south, and a meridian over `x` goes to
/// the meridian over `base_map(x)`.
pub fn suspension_map_value(
  source : DHitSpec,
  target : DHitSpec,
  base_map : (DValue) -> DValue,
  point : DValue,
  dlevel : Int32,
) -> DValue {
  let target_ty : DValue = DVHitType(target, [], [])
  eval_hit_elim(
    source,
    (_, _) => target_ty,
    [
      DVHitCell(target, 0, [], [], []),
      DVHitCell(target, 1, [], [], []),
      DVLam(x => {
        DVPathLam(d => hit_cell_value(target, 2, [], [base_map(x)], [d]))
      }),
    ],
    [],
    [],
    point,
    dlevel,
  )
}

///|
/// The degree-`n` map on the `dimension`-sphere, applied to a point.
/// It is the circle degree map iterated through the suspension functor.
pub fn sphere_degree_value(
  dimension : Int32,
  n : Int32,
  point : DValue,
  dlevel : Int32,
) -> DValue {
  if dimension <= 1 {
    circle_degree_value(n, point, dlevel)
  } else {
    let spec = sphere_schema(dimension)
    suspension_map_value(
      spec,
      spec,
      x => sphere_degree_value(dimension - 1, n, x, dlevel),
      point,
      dlevel,
    )
  }
}

///|
/// The degree-`n` spherical endomap as a semantic function value.
pub fn sphere_degree_function_value(dimension : Int32, n : Int32) -> DValue {
  DVLam(point => sphere_degree_value(dimension, n, point, dimension + 2))
}

// ---------------------------------------------------------------------------
// The suspension-to-loop unit
// ---------------------------------------------------------------------------

///|
/// A meridian of a suspension sphere, as a semantic path.
pub fn suspension_meridian_path_value(
  spec : DHitSpec,
  point : DValue,
) -> DValue {
  DVPathLam(d => hit_cell_value(spec, 2, [], [point], [d]))
}

///|
/// The loop at the north pole associated with a point `point` of the
/// suspension base:
///
/// `meridian(point) . sym(meridian(base_point))`.
///
/// This is the pointwise representative of the unit
/// `X -> Omega(Susp X)` for the based suspension/loop-space adjunction.
pub fn suspension_unit_loop_value(
  spec : DHitSpec,
  base_point : DValue,
  point : DValue,
  dlevel : Int32,
) -> DValue {
  dpath_trans_value(
    DVHitType(spec, [], []),
    suspension_meridian_path_value(spec, point),
    dpath_sym_value(suspension_meridian_path_value(spec, base_point)),
    dlevel,
  )
}

// ---------------------------------------------------------------------------
// `S^3` with its poles interchanged
// ---------------------------------------------------------------------------

///|
/// Another presentation of `S^3`: the zeroth cell is the south pole, the
/// first cell is the north pole, and the meridian still runs from north
/// to south.  The underlying suspension base is the usual `S^2`.
pub fn sphere3_swapped_schema() -> DHitSpec {
  let base = sphere2_schema()
  dhit_spec("Sphere3SwappedS", base.level, base.params, [], [
    dhit_cell_spec("south", 0, [], []),
    dhit_cell_spec("north", 0, [], []),
    dhit_cell_spec(
      "meridian",
      1,
      [
        darg_external(
          "point",
          DHitType(base, suspension_parameter_terms(base.params.length())),
        ),
      ],
      [dhit_face(1, [], []), dhit_face(0, [], [])],
    ),
  ])
}

///|
/// The pole-swapped `S^3` type.
pub fn sphere3_swapped_type_term() -> DTerm {
  DHitType(sphere3_swapped_schema(), [])
}

///|
/// The north pole (cell 1) of the swapped presentation.
pub fn sphere3_swapped_north_value() -> DValue {
  DVHitCell(sphere3_swapped_schema(), 1, [], [], [])
}

///|
/// The south pole (cell 0) of the swapped presentation.
pub fn sphere3_swapped_south_value() -> DValue {
  DVHitCell(sphere3_swapped_schema(), 0, [], [], [])
}

///|
/// A meridian point in the swapped presentation.
pub fn sphere3_swapped_meridian_value(point : DValue, dim : Dim) -> DValue {
  hit_cell_value(sphere3_swapped_schema(), 2, [], [point], [dim])
}

///|
/// The canonical map from the usual `S^3` to the swapped presentation,
/// applied to a point.
pub fn sphere3_to_swapped_value(point : DValue, dlevel : Int32) -> DValue {
  let swapped = sphere3_swapped_schema()
  let target_ty : DValue = DVHitType(swapped, [], [])
  eval_hit_elim(
    sphere3_schema(),
    (_, _) => target_ty,
    [
      sphere3_swapped_north_value(),
      sphere3_swapped_south_value(),
      DVLam(x => DVPathLam(d => hit_cell_value(swapped, 2, [], [x], [d]))),
    ],
    [],
    [],
    point,
    dlevel,
  )
}

///|
/// The canonical map back from the swapped presentation, applied to a
/// point.
pub fn sphere3_from_swapped_value(point : DValue, dlevel : Int32) -> DValue {
  let sphere3 = sphere3_schema()
  let target_ty : DValue = DVHitType(sphere3, [], [])
  eval_hit_elim(
    sphere3_swapped_schema(),
    (_, _) => target_ty,
    [
      sphere3_south_value(),
      sphere3_north_value(),
      DVLam(x => DVPathLam(d => hit_cell_value(sphere3, 2, [], [x], [d]))),
    ],
    [],
    [],
    point,
    dlevel,
  )
}

///|
/// Retraction data for the pole-swapped equivalence: for a point of the
/// usual presentation, a path from its round trip back to itself.  The
/// path is defined by dependent HIT elimination; on meridians the
/// two-dimensional case is constant in the path direction because the
/// round trip computes to the same meridian point.
pub fn sphere3_swapped_retr_value(point : DValue, dlevel : Int32) -> DValue {
  let spec = sphere3_schema()
  let ty : DValue = DVHitType(spec, [], [])
  eval_hit_elim(
    spec,
    (_, point) => {
      DVPathTy(
        _ => ty,
        sphere3_from_swapped_value(
          sphere3_to_swapped_value(point, dlevel),
          dlevel,
        ),
        point,
      )
    },
    [
      dpath_refl_value(sphere3_north_value()),
      dpath_refl_value(sphere3_south_value()),
      DVLam(x => DVPathLam(i => DVPathLam(_ => sphere3_meridian_value(x, i)))),
    ],
    [],
    [],
    point,
    dlevel,
  )
}

///|
/// Section data for the pole-swapped equivalence: for a point of the
/// swapped presentation, a path from its round trip back to itself.
pub fn sphere3_swapped_sect_value(point : DValue, dlevel : Int32) -> DValue {
  let spec = sphere3_swapped_schema()
  let ty : DValue = DVHitType(spec, [], [])
  eval_hit_elim(
    spec,
    (_, point) => {
      DVPathTy(
        _ => ty,
        sphere3_to_swapped_value(
          sphere3_from_swapped_value(point, dlevel),
          dlevel,
        ),
        point,
      )
    },
    [
      dpath_refl_value(sphere3_swapped_south_value()),
      dpath_refl_value(sphere3_swapped_north_value()),
      DVLam(x => {
        DVPathLam(i => DVPathLam(_ => sphere3_swapped_meridian_value(x, i)))
      }),
    ],
    [],
    [],
    point,
    dlevel,
  )
}

///|
/// The assembled semantic equivalence datum between the two `S^3`
/// presentations.  Its section and retraction fields are the dependent
/// eliminations above.
pub fn sphere3_swapped_equiv_value() -> DValue {
  DVEquiv(
    DVHitType(sphere3_schema(), [], []),
    DVHitType(sphere3_swapped_schema(), [], []),
    DVLam(point => sphere3_to_swapped_value(point, 4)),
    DVLam(point => sphere3_from_swapped_value(point, 4)),
    DVLam(point => sphere3_swapped_sect_value(point, 4)),
    DVLam(point => sphere3_swapped_retr_value(point, 4)),
  )
}

// ---------------------------------------------------------------------------
// The classical Hopf map and its numerical linking invariant
// ---------------------------------------------------------------------------

///|
/// The Hopf map `S^3 -> S^2` in complex coordinates.  A point is stored
/// as `[Re z, Im z, Re w, Im w]`, and the map is
///
/// `(z,w) |-> (2 Re(z conj(w)), 2 Im(z conj(w)), |z|^2 - |w|^2)`.
pub fn hopf_map_s3_to_s2(q : Array[Double]) -> Array[Double] {
  if q.length() != 4 {
    return [0.0, 0.0, 0.0]
  }
  let x1 = q[0]
  let x2 = q[1]
  let x3 = q[2]
  let x4 = q[3]
  [
    2.0 * (x1 * x3 + x2 * x4),
    2.0 * (x2 * x3 - x1 * x4),
    x1 * x1 + x2 * x2 - x3 * x3 - x4 * x4,
  ]
}

///|
/// Simultaneously multiply both complex coordinates by `e^(i theta)`.
/// This moves along the Hopf fiber through `q`.
pub fn hopf_phase_rotate(q : Array[Double], theta : Double) -> Array[Double] {
  if q.length() != 4 {
    return [0.0, 0.0, 0.0, 0.0]
  }
  let c = @math.cos(theta)
  let s = @math.sin(theta)
  [
    c * q[0] - s * q[1],
    s * q[0] + c * q[1],
    c * q[2] - s * q[3],
    s * q[2] + c * q[3],
  ]
}

///|
/// The Hopf fiber over the north pole, parameterized by its phase.
pub fn hopf_north_fiber(theta : Double) -> Array[Double] {
  [@math.cos(theta), @math.sin(theta), 0.0, 0.0]
}

///|
/// The Hopf fiber over the south pole, parameterized by its phase.
pub fn hopf_south_fiber(theta : Double) -> Array[Double] {
  [0.0, 0.0, @math.cos(theta), @math.sin(theta)]
}

///|
fn hopf_dot4(a : Array[Double], b : Array[Double]) -> Double {
  a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3]
}

///|
/// Stereographic projection from the pole
/// `(1/sqrt(2), 0, 1/sqrt(2), 0)`, together with the derivative of the
/// projected curve.  The chosen pole does not meet either canonical
/// Hopf fiber.
fn hopf_stereographic_with_derivative(
  x : Array[Double],
  dx : Array[Double],
) -> (Array[Double], Array[Double]) {
  let s = 0.7071067811865476
  let pole = [s, 0.0, s, 0.0]
  let basis = [
    [0.0, 1.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 1.0],
    [s, 0.0, 0.0 - s, 0.0],
  ]
  let a = hopf_dot4(x, pole)
  let da = hopf_dot4(dx, pole)
  let denom = 1.0 - a
  let y : Array[Double] = []
  let dy : Array[Double] = []
  for i in 0..<3 {
    let numerator = hopf_dot4(x, basis[i])
    let dnumerator = hopf_dot4(dx, basis[i])
    y.push(numerator / denom)
    dy.push(dnumerator / denom + numerator * da / (denom * denom))
  }
  (y, dy)
}

///|
/// A numerical Gauss linking integral for the north and south Hopf
/// fibers, after stereographic projection to `R^3`.  The parameter is
/// the number of midpoint samples on each circle.  With the conventions
/// above the value is plus or minus one up to quadrature error; its
/// absolute value is the Hopf invariant of the classical Hopf map.
pub fn hopf_linking_number_numeric(samples : Int32) -> Double {
  if samples <= 0 {
    return 0.0
  }
  let pi = 3.141592653589793
  let step = 2.0 * pi / samples.to_double()
  let first_points : Array[Array[Double]] = []
  let first_derivatives : Array[Array[Double]] = []
  let second_points : Array[Array[Double]] = []
  let second_derivatives : Array[Array[Double]] = []
  for i in 0..<samples {
    let t = (i.to_double() + 0.5) * step
    let (p1, v1) = hopf_stereographic_with_derivative(hopf_north_fiber(t), [
      0.0 - @math.sin(t),
      @math.cos(t),
      0.0,
      0.0,
    ])
    let (p2, v2) = hopf_stereographic_with_derivative(hopf_south_fiber(t), [
      0.0,
      0.0,
      0.0 - @math.sin(t),
      @math.cos(t),
    ])
    first_points.push(p1)
    first_derivatives.push(v1)
    second_points.push(p2)
    second_derivatives.push(v2)
  }
  let mut total = 0.0
  for i in 0..<samples {
    for j in 0..<samples {
      let r = [
        first_points[i][0] - second_points[j][0],
        first_points[i][1] - second_points[j][1],
        first_points[i][2] - second_points[j][2],
      ]
      let a = first_derivatives[i]
      let b = second_derivatives[j]
      let cross = [
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
      ]
      let triple = r[0] * cross[0] + r[1] * cross[1] + r[2] * cross[2]
      let dist2 = r[0] * r[0] + r[1] * r[1] + r[2] * r[2]
      if dist2 > 0.0 {
        total = total + triple / (dist2 * dist2.sqrt())
      }
    }
  }
  total * step * step / (4.0 * pi)
}

// ---------------------------------------------------------------------------
// Representative checks
// ---------------------------------------------------------------------------

///|
fn hopf_vector_close(
  a : Array[Double],
  b : Array[Double],
  tolerance : Double,
) -> Bool {
  if a.length() != b.length() {
    return false
  }
  for i in 0..<a.length() {
    let difference = a[i] - b[i]
    if difference * difference > tolerance * tolerance {
      return false
    }
  }
  true
}

///|
/// Checks for the classical Hopf representatives: unit-sphere values,
/// phase/fiber invariance, constant canonical fibers and numerical
/// linking number one.
pub fn check_hopf_numeric() -> Bool {
  let samples = [
    [1.0, 0.0, 0.0, 0.0],
    [0.5, 0.5, 0.5, 0.5],
    [0.6, 0.0, 0.8, 0.0],
    [0.0, 0.6, 0.0, 0.8],
  ]
  for i in 0..<samples.length() {
    let image = hopf_map_s3_to_s2(samples[i])
    let norm2 = image[0] * image[0] + image[1] * image[1] + image[2] * image[2]
    let err = norm2 - 1.0
    if err * err > 0.000000001 {
      return false
    }
    let rotated_image = hopf_map_s3_to_s2(hopf_phase_rotate(samples[i], 0.7))
    if !hopf_vector_close(image, rotated_image, 0.000001) {
      return false
    }
  }
  let north_image = hopf_map_s3_to_s2(hopf_north_fiber(1.3))
  let south_image = hopf_map_s3_to_s2(hopf_south_fiber(2.1))
  if !hopf_vector_close(north_image, [0.0, 0.0, 1.0], 0.000001) {
    return false
  }
  if !hopf_vector_close(south_image, [0.0, 0.0, -1.0], 0.000001) {
    return false
  }
  let linking = hopf_linking_number_numeric(48)
  let magnitude_error = linking.abs() - 1.0
  magnitude_error * magnitude_error < 0.0064
}

///|
/// Aggregated checks for the spherical homotopy representatives in this
/// file: formations of iterated loop spaces, identity/zero degree maps
/// on generating meridian points, suspension-unit endpoints and the
/// pole-swapped round trips.
pub fn check_sphere_homotopy_representatives() -> Bool {
  // Closed formations: Omega^3(S^3) at the north pole and the type of
  // based endomaps of S^3.
  let s3_ty = sphere3_type_term()
  let north = sphere3_north_term()
  if !dep_check_closed(loop_space_type_term(s3_ty, north, 3), DUniv(0)) {
    return false
  }
  if !dep_check_closed(
      based_map_type_term(s3_ty, s3_ty, north, north),
      DUniv(0),
    ) {
    return false
  }

  let circle = circle_schema()
  let s2 = sphere2_schema()
  let s3 = sphere3_schema()
  let circle_ty : DValue = DVHitType(circle, [], [])
  let s2_ty : DValue = DVHitType(s2, [], [])
  let s3_value_ty : DValue = DVHitType(s3, [], [])
  let swapped_ty : DValue = DVHitType(sphere3_swapped_schema(), [], [])

  // Generating points with genuinely free dimensions at every stage.
  let circle_point : DValue = DVHitCell(circle, 1, [], [], [DVar(0)])
  let s2_point : DValue = DVHitCell(s2, 2, [], [circle_point], [DVar(1)])
  let s3_point : DValue = DVHitCell(s3, 2, [], [s2_point], [DVar(2)])

  // Degree one is the identity on these generators; degree zero sends
  // the base point at every stage to the chosen base point.
  if !conv_at(
      0,
      1,
      circle_ty,
      circle_degree_value(1, circle_point, 2),
      circle_point,
    ) {
    return false
  }
  if !conv_at(
      0,
      1,
      circle_ty,
      circle_degree_value(0, circle_point, 2),
      circle_hit_base_value(),
    ) {
    return false
  }
  if !conv_at(0, 2, s2_ty, sphere_degree_value(2, 1, s2_point, 3), s2_point) {
    return false
  }
  let s2_degree0_point : DValue = DVHitCell(
    s2,
    2,
    [],
    [circle_hit_base_value()],
    [DVar(1)],
  )
  if !conv_at(
      0,
      2,
      s2_ty,
      sphere_degree_value(2, 0, s2_point, 3),
      s2_degree0_point,
    ) {
    return false
  }
  if !conv_at(
      0,
      3,
      s3_value_ty,
      sphere_degree_value(3, 1, s3_point, 4),
      s3_point,
    ) {
    return false
  }
  let s3_degree0_point : DValue = DVHitCell(s3, 2, [], [s2_degree0_point], [
    DVar(2),
  ])
  if !conv_at(
      0,
      3,
      s3_value_ty,
      sphere_degree_value(3, 0, s3_point, 4),
      s3_degree0_point,
    ) {
    return false
  }

  // Degree maps are based at both suspension poles.
  if !conv_at(
      0,
      0,
      s3_value_ty,
      sphere_degree_value(3, -2, sphere3_north_value(), 2),
      sphere3_north_value(),
    ) {
    return false
  }
  if !conv_at(
      0,
      0,
      s3_value_ty,
      sphere_degree_value(3, 5, sphere3_south_value(), 2),
      sphere3_south_value(),
    ) {
    return false
  }

  // The suspension unit at the generic circle point is a loop at the
  // north pole of S^2.
  let unit_loop = suspension_unit_loop_value(
    s2,
    circle_hit_base_value(),
    circle_point,
    2,
  )
  if !conv_at(
      0,
      1,
      s2_ty,
      dapp_dim(unit_loop, DZero),
      DVHitCell(s2, 0, [], [], []),
    ) {
    return false
  }
  if !conv_at(
      0,
      1,
      s2_ty,
      dapp_dim(unit_loop, DOne),
      DVHitCell(s2, 0, [], [], []),
    ) {
    return false
  }

  // Pole-swapped round trips and the endpoints of their dependent
  // retraction/section paths on a fully generic meridian point.
  let round_trip = sphere3_from_swapped_value(
    sphere3_to_swapped_value(s3_point, 4),
    4,
  )
  if !conv_at(0, 3, s3_value_ty, round_trip, s3_point) {
    return false
  }
  let retr = sphere3_swapped_retr_value(s3_point, 4)
  if !conv_at(0, 3, s3_value_ty, dapp_dim(retr, DZero), round_trip) {
    return false
  }
  if !conv_at(0, 3, s3_value_ty, dapp_dim(retr, DOne), s3_point) {
    return false
  }
  let swapped_point = sphere3_swapped_meridian_value(s2_point, DVar(2))
  let swapped_round_trip = sphere3_to_swapped_value(
    sphere3_from_swapped_value(swapped_point, 4),
    4,
  )
  if !conv_at(0, 3, swapped_ty, swapped_round_trip, swapped_point) {
    return false
  }
  let sect = sphere3_swapped_sect_value(swapped_point, 4)
  if !conv_at(0, 3, swapped_ty, dapp_dim(sect, DZero), swapped_round_trip) {
    return false
  }
  if !conv_at(0, 3, swapped_ty, dapp_dim(sect, DOne), swapped_point) {
    return false
  }

  // The assembled equivalence datum has the expected source and target.
  match sphere3_swapped_equiv_value() {
    DVEquiv(source, target, _, _, _, _) =>
      conv_ty(0, 0, source, s3_value_ty) && conv_ty(0, 0, target, swapped_ty)
    _ => false
  }
}
