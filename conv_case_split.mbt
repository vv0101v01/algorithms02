// ==================================================================
// Case-split conversion on discrete (Bool) context variables.
//
// The kernel's semantic conversion compares neutral forms at
// discrete types structurally: `if x then 0 else 0` and `0`
// are not convertible for a neutral Bool variable `x`, even
// though they agree under both substitutions.  Bool is a
// discrete cubical type -- its elements over any cube are
// constants -- so conversion may legitimately case-split on
// Bool *variables*: two terms in a telescope context are
// convertible if they are convertible after substituting
// `true` and after substituting `false` for some Bool
// variable they mention.  This file implements that
// strengthening at the term level (`conv_terms_case_split`):
// it first tries ordinary conversion in the fresh-neutral
// interpretation of the context, then recursively splits on
// mentioned Bool variables (dependent types and later context
// entries are substituted along).  Variables of other types
// are never split (Nat would need infinitely many cases), and
// the search is bounded by the number of Bool variables in
// the context, each split removing one.
// ==================================================================

///|
fn cs_mentions_var(t : DTerm, index : Int32) -> Bool {
  let mut found = false
  ignore(
    dterm_map_vars_at(t, 0, (v, depth) => {
      if v - depth == index {
        found = true
      }
      DTVar(v)
    }),
  )
  found
}

///|
fn cs_eval_ctx(ctx : Array[DTerm]) -> (DEnv, Array[DValue]) {
  let values : Array[DValue] = []
  let types : Array[DValue] = []
  for i in 0..<ctx.length() {
    types.push(
      force_value(
        deval_dim(ctx[i], denv_extend(values, denv_empty()), ddim_empty()),
      ),
    )
    values.push(DVNeutral(DNVar(i)))
  }
  (denv_extend(values, denv_empty()), types)
}

///|
fn cs_conv_go(ctx : Array[DTerm], ty : DTerm, a : DTerm, b : DTerm) -> Bool {
  let (env, types) = cs_eval_ctx(ctx)
  let ty_value = deval_dim(ty, env, ddim_empty())
  if conv_at(
      ctx.length(),
      0,
      ty_value,
      deval_dim(a, env, ddim_empty()),
      deval_dim(b, env, ddim_empty()),
    ) {
    return true
  }
  // Find a Bool variable (in declaration order) mentioned by
  // the type or either term, and split on it.
  for i in 0..<ctx.length() {
    let is_bool = match types[i] {
      DVBoolTy => true
      _ => false
    }
    if !is_bool {
      continue
    }
    let index = ctx.length() - 1 - i
    if !cs_mentions_var(a, index) &&
      !cs_mentions_var(b, index) &&
      !cs_mentions_var(ty, index) {
      continue
    }
    for branch in 0..<2 {
      let lit = DBoolLit(branch == 0)
      let new_ctx : Array[DTerm] = []
      for j in 0..<ctx.length() {
        if j < i {
          new_ctx.push(ctx[j])
        } else if j > i {
          // In entry j's scope the split variable has index
          // j - 1 - i.
          new_ctx.push(dterm_substitute(ctx[j], j - 1 - i, lit))
        }
      }
      if !cs_conv_go(
          new_ctx,
          dterm_substitute(ty, index, lit),
          dterm_substitute(a, index, lit),
          dterm_substitute(b, index, lit),
        ) {
        return false
      }
    }
    return true
  }
  false
}

///|
/// Conversion of two terms at a (possibly dependent) type in a
/// telescope context, strengthened by case splits on Bool
/// variables.  `ctx` lists the context entry types in
/// declaration order; `ty`, `a`, and `b` are in the full
/// context's scope.  Ordinary conversion is tried first.
pub fn conv_terms_case_split(
  ctx : Array[DTerm],
  ty : DTerm,
  a : DTerm,
  b : DTerm,
) -> Bool {
  cs_conv_go(ctx, ty, a, b)
}

///|
/// Ordinary (unsplit) conversion in the fresh-neutral
/// interpretation of the same context, for comparison.
pub fn conv_terms_plain(
  ctx : Array[DTerm],
  ty : DTerm,
  a : DTerm,
  b : DTerm,
) -> Bool {
  let (env, _) = cs_eval_ctx(ctx)
  conv_at(
    ctx.length(),
    0,
    deval_dim(ty, env, ddim_empty()),
    deval_dim(a, env, ddim_empty()),
    deval_dim(b, env, ddim_empty()),
  )
}
