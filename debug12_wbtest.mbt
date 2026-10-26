///|
test "debug elim motive value check" {
  let base = code_interpretation_ir(false).base
  let motive = DLam(DInductive(base, []), DUniv(0))
  let ty = inductive_motive_type(base, [])
  let ok = match d_check(motive, ty, denv_empty(), denv_empty(), ddim_empty()) {
    Some(_) => true
    None => false
  }
  inspect(ok, content="true")
}

///|
test "debug elim scrut check" {
  let base = code_interpretation_ir(false).base
  let cnat_t = schema_intro_term(base, 0, [], [])
  let ok = match
    d_check(
      cnat_t,
      DVInductive(base, [], []),
      denv_empty(),
      denv_empty(),
      ddim_empty(),
    ) {
    Some(_) => true
    None => false
  }
  inspect(ok, content="true")
}

///|
test "debug elim infer direct" {
  let base = code_interpretation_ir(false).base
  let cnat_t = schema_intro_term(base, 0, [], [])
  let motive = DLam(DInductive(base, []), DUniv(0))
  let cases = [
    DNatTy,
    DBoolTy,
    DLam(
      DInductive(base, []),
      DLam(
        DUniv(0),
        DLam(DInductive(base, []), DLam(DUniv(0), DSigma(DTVar(2), DTVar(1)))),
      ),
    ),
    DLam(
      DInductive(base, []),
      DLam(
        DUniv(0),
        DLam(DInductive(base, []), DLam(DUniv(0), DPi(DTVar(2), DTVar(1)))),
      ),
    ),
  ]
  let ok = match
    infer_inductive_elim(
      base,
      motive,
      cases,
      [],
      [],
      cnat_t,
      denv_empty(),
      denv_empty(),
      ddim_empty(),
    ) {
    Some(_) => true
    None => false
  }
  inspect(ok, content="true")
}
