///|
// Complete factorization over Q by Yun squarefree decomposition
// followed by Kronecker interpolation.
//
// After all linear factors are removed, a degree-`m` integer factor
// is searched for in increasing `m`.  At any `m+1` distinct integer
// points `x_j` with `f(x_j) != 0`, its values must be signed divisors
// of the values `f(x_j)`.  Enumerating those divisor tuples and
// interpolating is therefore exhaustive.  This is a classical
// finite algorithm, not a heuristic: with an unlimited budget it
// either finds a factor or proves that none of degree `<= deg(f)/2`
// exists.  The budgeted entry point makes candidate exhaustion an
// explicit `None`, never a guessed factorization.

///|
pub struct QPolyCompleteFactorization {
  leading : Rat
  factors : Array[QPolyFactor]
}

///|
fn eval_big_poly(coeffs : Array[BigInt], x : BigInt) -> BigInt {
  let mut acc = 0N
  for i = coeffs.length() - 1; i >= 0; i = i - 1 {
    acc = acc * x + coeffs[i]
  }
  acc
}

///|
fn kronecker_points(
  coeffs : Array[BigInt],
  count : Int32,
) -> (Array[BigInt], Array[BigInt]) {
  // Choose a consecutive block minimizing the signed-divisor tuple
  // count.  Consecutive points additionally enable the finite-
  // difference divisibility pruning in the search below.
  let extent = count + 12
  let xs : Array[BigInt] = []
  let ys : Array[BigInt] = []
  let choice_counts : Array[Int32] = []
  for k in 0..<(2 * extent + 1) {
    let offset = k - extent
    let x = BigInt::from_int(offset)
    let y = eval_big_poly(coeffs, x)
    xs.push(x)
    ys.push(y)
    choice_counts.push(if y == 0N { 0 } else { bigint_divisors(y).length() })
  }
  let mut best_start = 0
  let mut best_score : BigInt? = None
  for start in 0..<(xs.length() - count + 1) {
    let mut score = 1N
    let mut valid = true
    for j in start..<(start + count) {
      if choice_counts[j] == 0 {
        valid = false
        break
      }
      score = score * BigInt::from_int(choice_counts[j])
    }
    if valid {
      let better = match best_score {
        Some(best) => score < best
        None => true
      }
      if better {
        best_start = start
        best_score = Some(score)
      }
    }
  }
  let px : Array[BigInt] = []
  let py : Array[BigInt] = []
  for i in best_start..<(best_start + count) {
    px.push(xs[i])
    py.push(ys[i])
  }
  (px, py)
}

///|
fn bigint_factorial(n : Int32) -> BigInt {
  let mut out = 1N
  for i in 2..<(n + 1) {
    out = out * BigInt::from_int(i)
  }
  out
}

///|
fn finite_difference(tuple : Array[BigInt], upto : Int32) -> BigInt {
  let values : Array[BigInt] = []
  for i in 0..<(upto + 1) {
    values.push(tuple[i])
  }
  for order in 1..<(upto + 1) {
    for i in 0..<(upto + 1 - order) {
      values[i] = values[i + 1] - values[i]
    }
  }
  values[0]
}

///|
fn interpolate_big(xs : Array[BigInt], ys : Array[BigInt]) -> QPoly {
  let mut result = qpoly_zero()
  for j in 0..<xs.length() {
    let mut basis = qpoly_one()
    let mut denom = rat_one()
    for k in 0..<xs.length() {
      if k != j {
        basis = qpoly_mul(
          basis,
          qpoly_normalize([rat_neg(rat_big_int(xs[k])), rat_one()]),
        )
        denom = rat_mul(denom, rat_big_int(xs[j] - xs[k]))
      }
    }
    result = qpoly_add(
      result,
      qpoly_scale(rat_div(rat_big_int(ys[j]), denom), basis),
    )
  }
  result
}

///|
fn qpoly_array_contains(xs : Array[QPoly], x : QPoly) -> Bool {
  for i in 0..<xs.length() {
    if qpoly_eq(xs[i], x) {
      return true
    }
  }
  false
}

///|
fn kronecker_search_degree(
  primitive : QPoly,
  coeffs : Array[BigInt],
  degree : Int32,
  state : Array[Int32],
) -> QPoly? {
  let (xs, ys) = kronecker_points(coeffs, degree + 1)
  let choices : Array[Array[BigInt]] = []
  for j in 0..<ys.length() {
    let divisors = bigint_divisors(ys[j])
    let signed : Array[BigInt] = []
    if j == 0 {
      // Only one member of each globally negated pair is needed.
      for i in 0..<divisors.length() {
        signed.push(divisors[i])
      }
    } else {
      for i in 0..<divisors.length() {
        signed.push(divisors[i])
        signed.push(-divisors[i])
      }
    }
    choices.push(signed)
  }
  let tuple : Array[BigInt] = []
  for _i in 0..<xs.length() {
    tuple.push(0N)
  }
  let seen : Array[QPoly] = []
  fn go(pos : Int32) -> QPoly? {
    if state[1] != 0 {
      return None
    }
    if pos >= xs.length() {
      if state[0] == 0 {
        state[1] = 1
        return None
      }
      if state[0] > 0 {
        state[0] = state[0] - 1
      }
      let candidate0 = interpolate_big(xs, tuple)
      if qpoly_degree(candidate0) != degree {
        return None
      }
      let candidate = qpoly_primitive_part(candidate0)
      if qpoly_degree(candidate) != degree ||
        qpoly_array_contains(seen, candidate) {
        return None
      }
      seen.push(candidate)
      let dm = qpoly_divmod(primitive, candidate)
      if qpoly_is_zero(dm.remainder) {
        return Some(qpoly_monic(candidate))
      }
      return None
    }
    for i in 0..<choices[pos].length() {
      tuple[pos] = choices[pos][i]
      if pos >= 2 {
        let difference = finite_difference(tuple, pos)
        if difference % bigint_factorial(pos) != 0N {
          continue
        }
        if pos == degree {
          let leading = difference / bigint_factorial(pos)
          let target = bigint_abs(coeffs[coeffs.length() - 1])
          if leading == 0N || target % bigint_abs(leading) != 0N {
            continue
          }
        }
      }
      match go(pos + 1) {
        Some(found) => return Some(found)
        None => ()
      }
      if state[1] != 0 {
        return None
      }
    }
    None
  }

  go(0)
}

///|
fn mod_norm(p : Int32, a : Array[Int32]) -> Array[Int32] {
  let out : Array[Int32] = []
  for i in 0..<a.length() {
    let mut v = a[i] % p
    if v < 0 {
      v = v + p
    }
    out.push(v)
  }
  let mut n = out.length()
  while n > 1 && out[n - 1] == 0 {
    n = n - 1
  }
  let trimmed : Array[Int32] = []
  for i in 0..<n {
    trimmed.push(out[i])
  }
  if trimmed.length() == 0 {
    [0]
  } else {
    trimmed
  }
}

///|
fn mod_degree(a : Array[Int32]) -> Int32 {
  if a.length() == 1 && a[0] == 0 {
    -1
  } else {
    a.length() - 1
  }
}

///|
fn mod_coeff(a : Array[Int32], i : Int32) -> Int32 {
  if i < 0 || i >= a.length() {
    0
  } else {
    a[i]
  }
}

///|
fn mod_sub(p : Int32, a : Array[Int32], b : Array[Int32]) -> Array[Int32] {
  let n = if a.length() > b.length() { a.length() } else { b.length() }
  let out : Array[Int32] = []
  for i in 0..<n {
    out.push(mod_coeff(a, i) - mod_coeff(b, i))
  }
  mod_norm(p, out)
}

///|
fn mod_mul(p : Int32, a : Array[Int32], b : Array[Int32]) -> Array[Int32] {
  if mod_degree(a) < 0 || mod_degree(b) < 0 {
    return [0]
  }
  let out : Array[Int32] = []
  for _i in 0..<(a.length() + b.length() - 1) {
    out.push(0)
  }
  for i in 0..<a.length() {
    for j in 0..<b.length() {
      out[i + j] = (out[i + j] + a[i] * b[j]) % p
    }
  }
  mod_norm(p, out)
}

///|
fn mod_inv(a0 : Int32, p : Int32) -> Int32 {
  let mut a = (a0 % p + p) % p
  let mut result = 1
  let mut exponent = p - 2
  if p == 2 {
    return 1
  }
  while exponent > 0 {
    if exponent % 2 == 1 {
      result = result * a % p
    }
    a = a * a % p
    exponent = exponent / 2
  }
  result
}

///|
fn mod_divmod(
  p : Int32,
  a0 : Array[Int32],
  b : Array[Int32],
) -> (Array[Int32], Array[Int32]) {
  let db = mod_degree(b)
  if db < 0 {
    return ([0], [0])
  }
  let q : Array[Int32] = []
  let qlen = if mod_degree(a0) >= db { mod_degree(a0) - db + 1 } else { 1 }
  for _i in 0..<qlen {
    q.push(0)
  }
  let mut rem = mod_norm(p, a0)
  let inv = mod_inv(b[b.length() - 1], p)
  while mod_degree(rem) >= db && mod_degree(rem) >= 0 {
    let shift = mod_degree(rem) - db
    let coeff = rem[rem.length() - 1] * inv % p
    q[shift] = coeff
    let sub : Array[Int32] = []
    for _i in 0..<shift {
      sub.push(0)
    }
    for i in 0..<b.length() {
      sub.push(coeff * b[i])
    }
    rem = mod_sub(p, rem, sub)
  }
  (mod_norm(p, q), rem)
}

///|
fn mod_gcd(p : Int32, a0 : Array[Int32], b0 : Array[Int32]) -> Array[Int32] {
  let mut a = mod_norm(p, a0)
  let mut b = mod_norm(p, b0)
  while mod_degree(b) >= 0 {
    let (_, r) = mod_divmod(p, a, b)
    a = b
    b = r
  }
  if mod_degree(a) >= 0 {
    let inv = mod_inv(a[a.length() - 1], p)
    let out : Array[Int32] = []
    for i in 0..<a.length() {
      out.push(a[i] * inv)
    }
    mod_norm(p, out)
  } else {
    a
  }
}

///|
fn mod_powmod(
  p : Int32,
  base0 : Array[Int32],
  exponent0 : Int32,
  modulus : Array[Int32],
) -> Array[Int32] {
  let mut exponent = exponent0
  let mut base = mod_divmod(p, base0, modulus).1
  let mut result = mod_divmod(p, [1], modulus).1
  while exponent > 0 {
    if exponent % 2 == 1 {
      result = mod_divmod(p, mod_mul(p, result, base), modulus).1
    }
    base = mod_divmod(p, mod_mul(p, base, base), modulus).1
    exponent = exponent / 2
  }
  result
}

///|
fn mod_distinct_degrees(coeffs : Array[BigInt], p : Int32) -> Array[Int32]? {
  let reduced : Array[Int32] = []
  for i in 0..<coeffs.length() {
    reduced.push((coeffs[i] % BigInt::from_int(p)).to_int())
  }
  let f = mod_norm(p, reduced)
  if mod_degree(f) != coeffs.length() - 1 {
    return None
  }
  let derivative : Array[Int32] = []
  for i in 1..<f.length() {
    derivative.push(f[i] * (i % p))
  }
  if mod_degree(mod_gcd(p, f, mod_norm(p, derivative))) > 0 {
    return None
  }
  let degrees : Array[Int32] = []
  let mut rem = f
  let xpoly : Array[Int32] = [0, 1]
  let mut h = xpoly
  let n = mod_degree(f)
  for d in 1..<(n + 1) {
    if mod_degree(rem) <= 0 {
      break
    }
    if 2 * d > mod_degree(rem) {
      degrees.push(mod_degree(rem))
      break
    }
    h = mod_powmod(p, h, p, rem)
    let g = mod_gcd(p, rem, mod_sub(p, h, xpoly))
    if mod_degree(g) > 0 {
      let count = mod_degree(g) / d
      for _i in 0..<count {
        degrees.push(d)
      }
      rem = mod_divmod(p, rem, g).0
      h = mod_divmod(p, h, rem).1
    }
  }
  Some(degrees)
}

///|
fn possible_factor_degrees(coeffs : Array[BigInt]) -> Array[Bool] {
  let n = coeffs.length() - 1
  let half = n / 2
  let allowed : Array[Bool] = []
  for _i in 0..<(half + 1) {
    allowed.push(true)
  }
  let primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
  for pi in 0..<primes.length() {
    match mod_distinct_degrees(coeffs, primes[pi]) {
      Some(degrees) => {
        let subset : Array[Bool] = []
        for _i in 0..<(half + 1) {
          subset.push(false)
        }
        subset[0] = true
        for i in 0..<degrees.length() {
          let d = degrees[i]
          for sum = half - d; sum >= 0; sum = sum - 1 {
            if subset[sum] {
              subset[sum + d] = true
            }
          }
        }
        for degree in 2..<(half + 1) {
          allowed[degree] = allowed[degree] && subset[degree]
        }
      }
      None => ()
    }
  }
  allowed
}

///|
fn factor_squarefree(f0 : QPoly, state : Array[Int32]) -> Array[QPoly] {
  let mut f = qpoly_monic(f0)
  let out : Array[QPoly] = []
  while qpoly_degree(f) > 0 {
    if state[1] != 0 {
      return out
    }
    if qpoly_degree(f) == 1 {
      out.push(f)
      break
    }
    let roots = qpoly_rational_roots(f)
    if roots.length() > 0 {
      let factor = qpoly_root_factor(roots[0])
      out.push(factor)
      f = qpoly_monic(qpoly_div_exact(f, factor))
      continue
    }
    let primitive = qpoly_primitive_part(f)
    let coeffs = qpoly_integer_coeffs_big(f)
    let mut found : QPoly? = None
    let allowed_degrees = possible_factor_degrees(coeffs)
    for degree in 2..<(qpoly_degree(f) / 2 + 1) {
      if degree < allowed_degrees.length() && !allowed_degrees[degree] {
        continue
      }
      match kronecker_search_degree(primitive, coeffs, degree, state) {
        Some(candidate) => {
          found = Some(candidate)
          break
        }
        None => ()
      }
      if state[1] != 0 {
        break
      }
    }
    match found {
      Some(candidate) => {
        out.push(candidate)
        f = qpoly_monic(qpoly_div_exact(f, candidate))
      }
      None => {
        if state[1] == 0 {
          out.push(f)
        }
        break
      }
    }
  }
  out
}

///|
fn add_factor(
  factors : Array[QPolyFactor],
  factor : QPoly,
  multiplicity : Int32,
) -> Unit {
  for i in 0..<factors.length() {
    if qpoly_eq(factors[i].factor, factor) {
      factors[i] = qpoly_factor(factor, factors[i].multiplicity + multiplicity)
      return
    }
  }
  factors.push(qpoly_factor(factor, multiplicity))
}

///|
/// Complete factorization with an explicit Kronecker tuple budget.
/// `budget < 0` means unlimited enumeration; `budget = 0` allows
/// no Kronecker tuples at all.  Factors are monic
/// irreducible polynomials and `leading` is the leading coefficient
/// of the input.  Budget exhaustion returns `None`.
pub fn qpoly_factor_complete_with_budget(
  p : QPoly,
  budget : Int32,
) -> QPolyCompleteFactorization? {
  if qpoly_is_zero(p) {
    return Some(QPolyCompleteFactorization::{
      leading: rat_zero(),
      factors: [],
    })
  }
  if qpoly_degree(p) <= 0 {
    return Some(QPolyCompleteFactorization::{
      leading: qpoly_coeff(p, 0),
      factors: [],
    })
  }
  let state = [budget, 0]
  let factors : Array[QPolyFactor] = []
  let groups = qpoly_squarefree_factorization(p)
  for i in 0..<groups.length() {
    let irreducible = factor_squarefree(groups[i].factor, state)
    if state[1] != 0 {
      return None
    }
    for j in 0..<irreducible.length() {
      add_factor(factors, irreducible[j], groups[i].multiplicity)
    }
  }
  Some(QPolyCompleteFactorization::{ leading: qpoly_leading(p), factors, })
}

///|
/// Complete factorization over Q into monic irreducibles.  The
/// underlying Kronecker enumeration is finite but can be extremely
/// expensive for adversarial coefficient sizes; use the budgeted
/// version where an explicit undecided result is preferable.
pub fn qpoly_factor_complete(p : QPoly) -> QPolyCompleteFactorization {
  match qpoly_factor_complete_with_budget(p, -1) {
    Some(f) => f
    None =>
      QPolyCompleteFactorization::{ leading: qpoly_leading(p), factors: [], }
  }
}

///|
pub fn qpoly_complete_factorization_expand(
  f : QPolyCompleteFactorization,
) -> QPoly {
  let mut acc = qpoly_const(f.leading)
  for i in 0..<f.factors.length() {
    acc = qpoly_mul(
      acc,
      qpoly_pow(f.factors[i].factor, f.factors[i].multiplicity),
    )
  }
  if f.factors.length() == 0 && rat_is_zero(f.leading) {
    qpoly_zero()
  } else {
    acc
  }
}

///|
/// Irreducibility over Q, decided by the complete factorization.
pub fn qpoly_is_irreducible(p : QPoly) -> Bool {
  if qpoly_degree(p) <= 0 {
    return false
  }
  let f = qpoly_factor_complete(p)
  f.factors.length() == 1 &&
  f.factors[0].multiplicity == 1 &&
  qpoly_eq(f.factors[0].factor, qpoly_monic(p))
}

///|
pub fn check_qpoly_factor_complete() -> Bool {
  let x = qpoly_x()
  let quad = qpoly_add(qpoly_mul(x, x), qpoly_int(1))
  let quartic = qpoly_mul(
    quad,
    qpoly_add(qpoly_mul(x, x), qpoly_add(x, qpoly_int(1))),
  )
  let mixed = qpoly_mul(
    qpoly_pow(qpoly_sub(x, qpoly_int(2)), 2),
    qpoly_mul(quartic, qpoly_pow(quad, 3)),
  )
  let cyclotomic6 = qpoly_add(qpoly_sub(qpoly_mul(x, x), x), qpoly_int(1))
  let f1 = qpoly_factor_complete(quartic)
  let f2 = qpoly_factor_complete(mixed)
  let bounded = match qpoly_factor_complete_with_budget(quartic, 0) {
    Some(_) => false
    None => true
  }
  let huge = qpoly_mul(
    qpoly_sub(x, qpoly_const(rat_big_int(BigInt::from_string("1000000000000")))),
    qpoly_add(x, qpoly_const(rat_big_int(BigInt::from_string("999999937")))),
  )
  f1.factors.length() == 2 &&
  qpoly_eq(qpoly_complete_factorization_expand(f1), quartic) &&
  qpoly_eq(qpoly_complete_factorization_expand(f2), mixed) &&
  f2.factors.length() == 3 &&
  qpoly_is_irreducible(quad) &&
  qpoly_is_irreducible(cyclotomic6) &&
  !qpoly_is_irreducible(quartic) &&
  qpoly_factor_complete(huge).factors.length() == 2 &&
  bounded
}
