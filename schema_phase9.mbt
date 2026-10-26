///|
// Phase-9 schema declarations.
//
// This file makes universe polymorphism part of the declaration
// syntax instead of only a host function returning a schema.  A
// level-polymorphic declaration stores ordinary DTerm templates in
// which universes may be `DUnivLevel(expr)`; applying the
// declaration substitutes every such node (including nodes inside
// embedded schema descriptors) and then runs the ordinary checked
// schema/term validators on the resulting closed declaration.
//
// It also contains a mutual-declaration record with a joint
// positivity report, a positivity extraction pass from transparent
// type-operator bodies to the schema's positive-functor IR, and a
// compiler for iterated non-uniform nested datatypes (Bush-shaped
// recursion) through a depth-indexed auxiliary family.

// ---------------------------------------------------------------------------
// Level substitution in terms and schema descriptors
// ---------------------------------------------------------------------------

///|
pub fn dlevel_expr_in_scope(expr : DLevelExpr, arity : Int32) -> Bool {
  match expr {
    DLevelConst(n) => n >= 0
    DLevelVar(i) => i >= 0 && i < arity
    DLevelSucc(e) => dlevel_expr_in_scope(e, arity)
    DLevelMax(a, b) =>
      dlevel_expr_in_scope(a, arity) && dlevel_expr_in_scope(b, arity)
  }
}

///|
fn telescope_instantiate_levels(
  entries : Array[DTelescopeEntry],
  levels : Array[Int32],
  ok : Array[Bool],
) -> Array[DTelescopeEntry] {
  let out : Array[DTelescopeEntry] = []
  for i in 0..<entries.length() {
    out.push(
      dtelescope_entry(
        entries[i].name,
        dterm_instantiate_levels_go(entries[i].ty, levels, ok),
      ),
    )
  }
  out
}

///|
fn functor_instantiate_levels(
  functor : DPositiveFunctor,
  levels : Array[Int32],
  ok : Array[Bool],
) -> DPositiveFunctor {
  match functor {
    DFunctorIdentity(index) =>
      DFunctorIdentity(dterm_instantiate_levels_list(index, levels, ok))
    DFunctorConst(ty) =>
      DFunctorConst(dterm_instantiate_levels_go(ty, levels, ok))
    DFunctorProduct(a, b) =>
      DFunctorProduct(
        functor_instantiate_levels(a, levels, ok),
        functor_instantiate_levels(b, levels, ok),
      )
    DFunctorSum(a, b) =>
      DFunctorSum(
        functor_instantiate_levels(a, levels, ok),
        functor_instantiate_levels(b, levels, ok),
      )
    DFunctorList(inner) =>
      DFunctorList(functor_instantiate_levels(inner, levels, ok))
    DFunctorPi(dom, inner) =>
      DFunctorPi(
        dterm_instantiate_levels_go(dom, levels, ok),
        functor_instantiate_levels(inner, levels, ok),
      )
    DFunctorContainer(shape, positions, index) =>
      DFunctorContainer(
        dterm_instantiate_levels_go(shape, levels, ok),
        dterm_instantiate_levels_go(positions, levels, ok),
        dterm_instantiate_levels_list(index, levels, ok),
      )
    DFunctorSigma(a, b) =>
      DFunctorSigma(
        functor_instantiate_levels(a, levels, ok),
        functor_instantiate_levels(b, levels, ok),
      )
    DFunctorFamily(spec, pargs, index) => {
      let out : Array[DFunctorParamArg] = []
      for i in 0..<pargs.length() {
        out.push(
          match pargs[i] {
            DFunctorParamTerm(t) =>
              DFunctorParamTerm(dterm_instantiate_levels_go(t, levels, ok))
            DFunctorParamSelf(js) =>
              DFunctorParamSelf(dterm_instantiate_levels_list(js, levels, ok))
          },
        )
      }
      DFunctorFamily(
        inductive_spec_instantiate_levels_raw(spec, levels, ok),
        out,
        dterm_instantiate_levels_list(index, levels, ok),
      )
    }
    DFunctorSelfFamily(pargs, index) => {
      let out : Array[DFunctorParamArg] = []
      for i in 0..<pargs.length() {
        out.push(
          match pargs[i] {
            DFunctorParamTerm(t) =>
              DFunctorParamTerm(dterm_instantiate_levels_go(t, levels, ok))
            DFunctorParamSelf(js) =>
              DFunctorParamSelf(dterm_instantiate_levels_list(js, levels, ok))
          },
        )
      }
      DFunctorSelfFamily(out, dterm_instantiate_levels_list(index, levels, ok))
    }
  }
}

///|
fn arg_instantiate_levels(
  arg : DConstructorArg,
  levels : Array[Int32],
  ok : Array[Bool],
) -> DConstructorArg {
  DConstructorArg::{
    name: arg.name,
    kind: arg.kind,
    ty: dterm_instantiate_levels_go(arg.ty, levels, ok),
    index: dterm_instantiate_levels_list(arg.index, levels, ok),
    nested: functor_instantiate_levels(arg.nested, levels, ok),
    target: arg.target,
  }
}

///|
fn constraint_instantiate_levels(
  c : DConstructorConstraint,
  levels : Array[Int32],
  ok : Array[Bool],
) -> DConstructorConstraint {
  dconstructor_constraint(
    dterm_instantiate_levels_go(c.ty, levels, ok),
    dterm_instantiate_levels_go(c.lhs, levels, ok),
    dterm_instantiate_levels_go(c.rhs, levels, ok),
  )
}

///|
fn constraints_instantiate_levels(
  cs : Array[DConstructorConstraint],
  levels : Array[Int32],
  ok : Array[Bool],
) -> Array[DConstructorConstraint] {
  let out : Array[DConstructorConstraint] = []
  for i in 0..<cs.length() {
    out.push(constraint_instantiate_levels(cs[i], levels, ok))
  }
  out
}

///|
fn args_instantiate_levels(
  args : Array[DConstructorArg],
  levels : Array[Int32],
  ok : Array[Bool],
) -> Array[DConstructorArg] {
  let out : Array[DConstructorArg] = []
  for i in 0..<args.length() {
    out.push(arg_instantiate_levels(args[i], levels, ok))
  }
  out
}

///|
fn inductive_spec_instantiate_levels_with(
  spec : DInductiveSpec,
  levels : Array[Int32],
  ok : Array[Bool],
  result_level : Int32,
  decode_level : Int32,
) -> DInductiveSpec {
  let constructors : Array[DConstructorSpec] = []
  for i in 0..<spec.constructors.length() {
    let c = spec.constructors[i]
    constructors.push(
      dconstructor_spec(
        c.name,
        args_instantiate_levels(c.args, levels, ok),
        result_index=dterm_instantiate_levels_list(c.result_index, levels, ok),
        constraints=constraints_instantiate_levels(c.constraints, levels, ok),
      ),
    )
  }
  if spec.decode_cases.length() == 0 {
    dinductive_spec(
      spec.name,
      result_level,
      telescope_instantiate_levels(spec.params, levels, ok),
      telescope_instantiate_levels(spec.indices, levels, ok),
      constructors,
    )
  } else {
    dinductive_recursive_spec(
      spec.name,
      result_level,
      telescope_instantiate_levels(spec.params, levels, ok),
      telescope_instantiate_levels(spec.indices, levels, ok),
      constructors,
      dterm_instantiate_levels_list(spec.decode_cases, levels, ok),
      decode_level~,
    )
  }
}

///|
fn inductive_spec_instantiate_levels_raw(
  spec : DInductiveSpec,
  levels : Array[Int32],
  ok : Array[Bool],
) -> DInductiveSpec {
  if spec.level < 0 || spec.decode_level < 0 {
    ok[0] = false
  }
  inductive_spec_instantiate_levels_with(
    spec,
    levels,
    ok,
    spec.level,
    spec.decode_level,
  )
}

///|
fn hit_spec_instantiate_levels_with(
  spec : DHitSpec,
  levels : Array[Int32],
  ok : Array[Bool],
  result_level : Int32,
) -> DHitSpec {
  let cells : Array[DHitCellSpec] = []
  for i in 0..<spec.cells.length() {
    let c = spec.cells[i]
    let faces : Array[DHitFaceExpr] = []
    for j in 0..<c.faces.length() {
      faces.push(
        dhit_face(
          c.faces[j].cell,
          dterm_instantiate_levels_list(c.faces[j].args, levels, ok),
          c.faces[j].dims,
        ),
      )
    }
    cells.push(
      dhit_cell_spec(
        c.name,
        c.dim_count,
        args_instantiate_levels(c.args, levels, ok),
        faces,
        result_index=dterm_instantiate_levels_list(c.result_index, levels, ok),
        constraints=constraints_instantiate_levels(c.constraints, levels, ok),
      ),
    )
  }
  dhit_spec(
    spec.name,
    result_level,
    telescope_instantiate_levels(spec.params, levels, ok),
    telescope_instantiate_levels(spec.indices, levels, ok),
    cells,
  )
}

///|
fn hit_spec_instantiate_levels_raw(
  spec : DHitSpec,
  levels : Array[Int32],
  ok : Array[Bool],
) -> DHitSpec {
  if spec.level < 0 {
    ok[0] = false
  }
  hit_spec_instantiate_levels_with(spec, levels, ok, spec.level)
}

///|
fn dterm_instantiate_levels_list(
  terms : Array[DTerm],
  levels : Array[Int32],
  ok : Array[Bool],
) -> Array[DTerm] {
  let out : Array[DTerm] = []
  for i in 0..<terms.length() {
    out.push(dterm_instantiate_levels_go(terms[i], levels, ok))
  }
  out
}

///|
fn dterm_instantiate_levels_tubes(
  tubes : Array[DTubeTerm],
  levels : Array[Int32],
  ok : Array[Bool],
) -> Array[DTubeTerm] {
  let out : Array[DTubeTerm] = []
  for i in 0..<tubes.length() {
    out.push(
      d_tube(
        tubes[i].face,
        dterm_instantiate_levels_go(tubes[i].body, levels, ok),
      ),
    )
  }
  out
}

///|
fn dterm_instantiate_levels_go(
  t : DTerm,
  levels : Array[Int32],
  ok : Array[Bool],
) -> DTerm {
  match t {
    DTVar(i) => DTVar(i)
    DPi(a, b) =>
      DPi(
        dterm_instantiate_levels_go(a, levels, ok),
        dterm_instantiate_levels_go(b, levels, ok),
      )
    DSigma(a, b) =>
      DSigma(
        dterm_instantiate_levels_go(a, levels, ok),
        dterm_instantiate_levels_go(b, levels, ok),
      )
    DLam(a, b) =>
      DLam(
        dterm_instantiate_levels_go(a, levels, ok),
        dterm_instantiate_levels_go(b, levels, ok),
      )
    DApp(x, y) =>
      DApp(
        dterm_instantiate_levels_go(x, levels, ok),
        dterm_instantiate_levels_go(y, levels, ok),
      )
    DPair(x, y) =>
      DPair(
        dterm_instantiate_levels_go(x, levels, ok),
        dterm_instantiate_levels_go(y, levels, ok),
      )
    DFst(x) => DFst(dterm_instantiate_levels_go(x, levels, ok))
    DSnd(x) => DSnd(dterm_instantiate_levels_go(x, levels, ok))
    DBoolElim(m, x, y, z) =>
      DBoolElim(
        dterm_instantiate_levels_go(m, levels, ok),
        dterm_instantiate_levels_go(x, levels, ok),
        dterm_instantiate_levels_go(y, levels, ok),
        dterm_instantiate_levels_go(z, levels, ok),
      )
    DAnn(x, y) =>
      DAnn(
        dterm_instantiate_levels_go(x, levels, ok),
        dterm_instantiate_levels_go(y, levels, ok),
      )
    DPartial(branches) => {
      let out : Array[DFaceTerm] = []
      for i in 0..<branches.length() {
        out.push(
          d_face_term(
            branches[i].face,
            dterm_instantiate_levels_go(branches[i].body, levels, ok),
          ),
        )
      }
      DPartial(out)
    }
    DPathP(line, l, r) =>
      DPathP(
        dterm_instantiate_levels_go(line, levels, ok),
        dterm_instantiate_levels_go(l, levels, ok),
        dterm_instantiate_levels_go(r, levels, ok),
      )
    DPath(a, l, r) =>
      DPath(
        dterm_instantiate_levels_go(a, levels, ok),
        dterm_instantiate_levels_go(l, levels, ok),
        dterm_instantiate_levels_go(r, levels, ok),
      )
    DLamDim(body) => DLamDim(dterm_instantiate_levels_go(body, levels, ok))
    DAppDim(x, r) => DAppDim(dterm_instantiate_levels_go(x, levels, ok), r)
    DCoe(line, r, s, v) =>
      DCoe(
        dterm_instantiate_levels_go(line, levels, ok),
        r,
        s,
        dterm_instantiate_levels_go(v, levels, ok),
      )
    DComp(line, tubes, base) =>
      DComp(
        dterm_instantiate_levels_go(line, levels, ok),
        dterm_instantiate_levels_tubes(tubes, levels, ok),
        dterm_instantiate_levels_go(base, levels, ok),
      )
    DHComp(a, tubes, base) =>
      DHComp(
        dterm_instantiate_levels_go(a, levels, ok),
        dterm_instantiate_levels_tubes(tubes, levels, ok),
        dterm_instantiate_levels_go(base, levels, ok),
      )
    DHFill(a, tubes, base, r) =>
      DHFill(
        dterm_instantiate_levels_go(a, levels, ok),
        dterm_instantiate_levels_tubes(tubes, levels, ok),
        dterm_instantiate_levels_go(base, levels, ok),
        r,
      )
    DSucc(x) => DSucc(dterm_instantiate_levels_go(x, levels, ok))
    DNatElim(m, x, y, z) =>
      DNatElim(
        dterm_instantiate_levels_go(m, levels, ok),
        dterm_instantiate_levels_go(x, levels, ok),
        dterm_instantiate_levels_go(y, levels, ok),
        dterm_instantiate_levels_go(z, levels, ok),
      )
    DListTy(a) => DListTy(dterm_instantiate_levels_go(a, levels, ok))
    DCons(x, y) =>
      DCons(
        dterm_instantiate_levels_go(x, levels, ok),
        dterm_instantiate_levels_go(y, levels, ok),
      )
    DListElim(m, x, y, z) =>
      DListElim(
        dterm_instantiate_levels_go(m, levels, ok),
        dterm_instantiate_levels_go(x, levels, ok),
        dterm_instantiate_levels_go(y, levels, ok),
        dterm_instantiate_levels_go(z, levels, ok),
      )
    DCircleElim(m, x, y, z) =>
      DCircleElim(
        dterm_instantiate_levels_go(m, levels, ok),
        dterm_instantiate_levels_go(x, levels, ok),
        dterm_instantiate_levels_go(y, levels, ok),
        dterm_instantiate_levels_go(z, levels, ok),
      )
    DTorusElim(m, x, z) =>
      DTorusElim(
        dterm_instantiate_levels_go(m, levels, ok),
        dterm_instantiate_levels_go(x, levels, ok),
        dterm_instantiate_levels_go(z, levels, ok),
      )
    DInductive(spec, args) =>
      DInductive(
        inductive_spec_instantiate_levels_raw(spec, levels, ok),
        dterm_instantiate_levels_list(args, levels, ok),
      )
    DIntro(spec, ctor, params, args) =>
      DIntro(
        inductive_spec_instantiate_levels_raw(spec, levels, ok),
        ctor,
        dterm_instantiate_levels_list(params, levels, ok),
        dterm_instantiate_levels_list(args, levels, ok),
      )
    DInductiveElim(spec, m, cases, params, indices, scrut) =>
      DInductiveElim(
        inductive_spec_instantiate_levels_raw(spec, levels, ok),
        dterm_instantiate_levels_go(m, levels, ok),
        dterm_instantiate_levels_list(cases, levels, ok),
        dterm_instantiate_levels_list(params, levels, ok),
        dterm_instantiate_levels_list(indices, levels, ok),
        dterm_instantiate_levels_go(scrut, levels, ok),
      )
    DHitType(spec, args) =>
      DHitType(
        hit_spec_instantiate_levels_raw(spec, levels, ok),
        dterm_instantiate_levels_list(args, levels, ok),
      )
    DHitIntro(spec, cell, params, args, dims) =>
      DHitIntro(
        hit_spec_instantiate_levels_raw(spec, levels, ok),
        cell,
        dterm_instantiate_levels_list(params, levels, ok),
        dterm_instantiate_levels_list(args, levels, ok),
        dims,
      )
    DHitElim(spec, m, cases, params, indices, scrut) =>
      DHitElim(
        hit_spec_instantiate_levels_raw(spec, levels, ok),
        dterm_instantiate_levels_go(m, levels, ok),
        dterm_instantiate_levels_list(cases, levels, ok),
        dterm_instantiate_levels_list(params, levels, ok),
        dterm_instantiate_levels_list(indices, levels, ok),
        dterm_instantiate_levels_go(scrut, levels, ok),
      )
    DDecode(spec, params, indices, code) =>
      DDecode(
        inductive_spec_instantiate_levels_raw(spec, levels, ok),
        dterm_instantiate_levels_list(params, levels, ok),
        dterm_instantiate_levels_list(indices, levels, ok),
        dterm_instantiate_levels_go(code, levels, ok),
      )
    DEquivTy(a, b) =>
      DEquivTy(
        dterm_instantiate_levels_go(a, levels, ok),
        dterm_instantiate_levels_go(b, levels, ok),
      )
    DMkEquiv(a, b, fwd, bwd, sect, retr) =>
      DMkEquiv(
        dterm_instantiate_levels_go(a, levels, ok),
        dterm_instantiate_levels_go(b, levels, ok),
        dterm_instantiate_levels_go(fwd, levels, ok),
        dterm_instantiate_levels_go(bwd, levels, ok),
        dterm_instantiate_levels_go(sect, levels, ok),
        dterm_instantiate_levels_go(retr, levels, ok),
      )
    DEquivFwd(e) => DEquivFwd(dterm_instantiate_levels_go(e, levels, ok))
    DEquivBwd(e) => DEquivBwd(dterm_instantiate_levels_go(e, levels, ok))
    DEquivSect(e) => DEquivSect(dterm_instantiate_levels_go(e, levels, ok))
    DEquivRetr(e) => DEquivRetr(dterm_instantiate_levels_go(e, levels, ok))
    DGlueEquiv(base, branches) => {
      let out : Array[DEquivBranch] = []
      for i in 0..<branches.length() {
        out.push(
          d_equiv_branch(
            branches[i].face,
            dterm_instantiate_levels_go(branches[i].ty, levels, ok),
            dterm_instantiate_levels_go(branches[i].equiv, levels, ok),
          ),
        )
      }
      DGlueEquiv(dterm_instantiate_levels_go(base, levels, ok), out)
    }
    DUa(e) => DUa(dterm_instantiate_levels_go(e, levels, ok))
    DUnivLevel(expr) =>
      match dlevel_eval(expr, levels) {
        Some(level) => DUniv(level)
        None => {
          ok[0] = false
          DUniv(0)
        }
      }
    other => other
  }
}

///|
/// Substitute concrete universe levels for every `DUnivLevel` node
/// in a term, including schema descriptors embedded in it.
pub fn dterm_instantiate_levels(t : DTerm, levels : Array[Int32]) -> DTerm? {
  let ok = [true]
  let out = dterm_instantiate_levels_go(t, levels, ok)
  if ok[0] {
    Some(out)
  } else {
    None
  }
}

///|
fn dterm_list_levels_in_scope(terms : Array[DTerm], arity : Int32) -> Bool {
  for i in 0..<terms.length() {
    if !dterm_levels_in_scope(terms[i], arity) {
      return false
    }
  }
  true
}

///|
fn functor_levels_in_scope(f : DPositiveFunctor, arity : Int32) -> Bool {
  match f {
    DFunctorIdentity(index) => dterm_list_levels_in_scope(index, arity)
    DFunctorConst(ty) => dterm_levels_in_scope(ty, arity)
    DFunctorProduct(a, b) | DFunctorSum(a, b) =>
      functor_levels_in_scope(a, arity) && functor_levels_in_scope(b, arity)
    DFunctorList(inner) => functor_levels_in_scope(inner, arity)
    DFunctorPi(dom, inner) =>
      dterm_levels_in_scope(dom, arity) && functor_levels_in_scope(inner, arity)
    DFunctorContainer(shape, positions, index) =>
      dterm_levels_in_scope(shape, arity) &&
      dterm_levels_in_scope(positions, arity) &&
      dterm_list_levels_in_scope(index, arity)
    DFunctorSigma(a, b) =>
      functor_levels_in_scope(a, arity) && functor_levels_in_scope(b, arity)
    DFunctorFamily(spec, pargs, index) => {
      if !inductive_spec_levels_in_scope(spec, arity) ||
        !dterm_list_levels_in_scope(index, arity) {
        return false
      }
      for i in 0..<pargs.length() {
        match pargs[i] {
          DFunctorParamTerm(t) =>
            if !dterm_levels_in_scope(t, arity) {
              return false
            }
          DFunctorParamSelf(js) =>
            if !dterm_list_levels_in_scope(js, arity) {
              return false
            }
        }
      }
      true
    }
    DFunctorSelfFamily(pargs, index) => {
      if !dterm_list_levels_in_scope(index, arity) {
        return false
      }
      for i in 0..<pargs.length() {
        match pargs[i] {
          DFunctorParamTerm(t) =>
            if !dterm_levels_in_scope(t, arity) {
              return false
            }
          DFunctorParamSelf(js) =>
            if !dterm_list_levels_in_scope(js, arity) {
              return false
            }
        }
      }
      true
    }
  }
}

///|
fn telescope_levels_in_scope(
  entries : Array[DTelescopeEntry],
  arity : Int32,
) -> Bool {
  for i in 0..<entries.length() {
    if !dterm_levels_in_scope(entries[i].ty, arity) {
      return false
    }
  }
  true
}

///|
fn arg_levels_in_scope(arg : DConstructorArg, arity : Int32) -> Bool {
  dterm_levels_in_scope(arg.ty, arity) &&
  dterm_list_levels_in_scope(arg.index, arity) &&
  functor_levels_in_scope(arg.nested, arity)
}

///|
fn constraint_levels_in_scope(
  c : DConstructorConstraint,
  arity : Int32,
) -> Bool {
  dterm_levels_in_scope(c.ty, arity) &&
  dterm_levels_in_scope(c.lhs, arity) &&
  dterm_levels_in_scope(c.rhs, arity)
}

///|
fn inductive_spec_levels_in_scope(spec : DInductiveSpec, arity : Int32) -> Bool {
  if !telescope_levels_in_scope(spec.params, arity) ||
    !telescope_levels_in_scope(spec.indices, arity) ||
    !dterm_list_levels_in_scope(spec.decode_cases, arity) {
    return false
  }
  for i in 0..<spec.constructors.length() {
    let c = spec.constructors[i]
    for j in 0..<c.args.length() {
      if !arg_levels_in_scope(c.args[j], arity) {
        return false
      }
    }
    if !dterm_list_levels_in_scope(c.result_index, arity) {
      return false
    }
    for j in 0..<c.constraints.length() {
      if !constraint_levels_in_scope(c.constraints[j], arity) {
        return false
      }
    }
  }
  true
}

///|
fn hit_spec_levels_in_scope(spec : DHitSpec, arity : Int32) -> Bool {
  if !telescope_levels_in_scope(spec.params, arity) ||
    !telescope_levels_in_scope(spec.indices, arity) {
    return false
  }
  for i in 0..<spec.cells.length() {
    let c = spec.cells[i]
    for j in 0..<c.args.length() {
      if !arg_levels_in_scope(c.args[j], arity) {
        return false
      }
    }
    if !dterm_list_levels_in_scope(c.result_index, arity) {
      return false
    }
    for j in 0..<c.constraints.length() {
      if !constraint_levels_in_scope(c.constraints[j], arity) {
        return false
      }
    }
    for j in 0..<c.faces.length() {
      if !dterm_list_levels_in_scope(c.faces[j].args, arity) {
        return false
      }
    }
  }
  true
}

///|
/// Whether every level variable in a term (including embedded
/// schemas) is among the first `arity` level binders.
pub fn dterm_levels_in_scope(t : DTerm, arity : Int32) -> Bool {
  match t {
    DUnivLevel(expr) => dlevel_expr_in_scope(expr, arity)
    DInductive(spec, args) =>
      inductive_spec_levels_in_scope(spec, arity) &&
      dterm_list_levels_in_scope(args, arity)
    DIntro(spec, _, params, args) =>
      inductive_spec_levels_in_scope(spec, arity) &&
      dterm_list_levels_in_scope(params, arity) &&
      dterm_list_levels_in_scope(args, arity)
    DInductiveElim(spec, motive, cases, params, indices, scrut) =>
      inductive_spec_levels_in_scope(spec, arity) &&
      dterm_levels_in_scope(motive, arity) &&
      dterm_list_levels_in_scope(cases, arity) &&
      dterm_list_levels_in_scope(params, arity) &&
      dterm_list_levels_in_scope(indices, arity) &&
      dterm_levels_in_scope(scrut, arity)
    DHitType(spec, args) =>
      hit_spec_levels_in_scope(spec, arity) &&
      dterm_list_levels_in_scope(args, arity)
    DHitIntro(spec, _, params, args, _) =>
      hit_spec_levels_in_scope(spec, arity) &&
      dterm_list_levels_in_scope(params, arity) &&
      dterm_list_levels_in_scope(args, arity)
    DHitElim(spec, motive, cases, params, indices, scrut) =>
      hit_spec_levels_in_scope(spec, arity) &&
      dterm_levels_in_scope(motive, arity) &&
      dterm_list_levels_in_scope(cases, arity) &&
      dterm_list_levels_in_scope(params, arity) &&
      dterm_list_levels_in_scope(indices, arity) &&
      dterm_levels_in_scope(scrut, arity)
    DDecode(spec, params, indices, code) =>
      inductive_spec_levels_in_scope(spec, arity) &&
      dterm_list_levels_in_scope(params, arity) &&
      dterm_list_levels_in_scope(indices, arity) &&
      dterm_levels_in_scope(code, arity)
    _ => dterm_list_levels_in_scope(dterm_children(t), arity)
  }
}

// ---------------------------------------------------------------------------
// First-class level-polymorphic declarations
// ---------------------------------------------------------------------------

///|
pub struct DLevelInductiveDecl {
  binders : Array[String]
  result_level : DLevelExpr
  decode_level : DLevelExpr
  template : DInductiveSpec
}

///|
pub struct DLevelHitDecl {
  binders : Array[String]
  result_level : DLevelExpr
  template : DHitSpec
}

///|
pub struct DLevelTermDecl {
  name : String
  binders : Array[String]
  ty : DTerm
  body : DTerm
}

///|
pub enum DLevelDecl {
  DLevelInductive(DLevelInductiveDecl)
  DLevelHit(DLevelHitDecl)
  DLevelTerm(DLevelTermDecl)
}

///|
pub struct DLevelTermInstance {
  ty : DTerm
  body : DTerm
}

///|
pub fn dlevel_inductive_decl(
  binders : Array[String],
  result_level : DLevelExpr,
  template : DInductiveSpec,
  decode_level~ : DLevelExpr = DLevelConst(0),
) -> DLevelInductiveDecl {
  DLevelInductiveDecl::{ binders, result_level, decode_level, template, }
}

///|
pub fn dlevel_hit_decl(
  binders : Array[String],
  result_level : DLevelExpr,
  template : DHitSpec,
) -> DLevelHitDecl {
  DLevelHitDecl::{ binders, result_level, template, }
}

///|
pub fn dlevel_term_decl(
  name : String,
  binders : Array[String],
  ty : DTerm,
  body : DTerm,
) -> DLevelTermDecl {
  DLevelTermDecl::{ name, binders, ty, body, }
}

///|
pub fn level_inductive_decl_validate(decl : DLevelInductiveDecl) -> Bool {
  schema_names_unique(decl.binders) &&
  dlevel_expr_in_scope(decl.result_level, decl.binders.length()) &&
  dlevel_expr_in_scope(decl.decode_level, decl.binders.length()) &&
  inductive_spec_levels_in_scope(decl.template, decl.binders.length())
}

///|
pub fn level_hit_decl_validate(decl : DLevelHitDecl) -> Bool {
  schema_names_unique(decl.binders) &&
  dlevel_expr_in_scope(decl.result_level, decl.binders.length()) &&
  hit_spec_levels_in_scope(decl.template, decl.binders.length())
}

///|
pub fn level_term_decl_validate(decl : DLevelTermDecl) -> Bool {
  decl.name.length() > 0 &&
  schema_names_unique(decl.binders) &&
  dterm_levels_in_scope(decl.ty, decl.binders.length()) &&
  dterm_levels_in_scope(decl.body, decl.binders.length())
}

///|
pub fn instantiate_level_inductive_decl(
  decl : DLevelInductiveDecl,
  levels : Array[Int32],
) -> DInductiveSpec? {
  if levels.length() != decl.binders.length() ||
    !level_inductive_decl_validate(decl) {
    return None
  }
  match
    (
      dlevel_eval(decl.result_level, levels),
      dlevel_eval(decl.decode_level, levels),
    ) {
    (Some(result_level), Some(decode_level)) => {
      let ok = [true]
      let spec = inductive_spec_instantiate_levels_with(
        decl.template,
        levels,
        ok,
        result_level,
        decode_level,
      )
      if ok[0] && inductive_schema_validate(spec) {
        Some(spec)
      } else {
        None
      }
    }
    _ => None
  }
}

///|
pub fn instantiate_level_hit_decl(
  decl : DLevelHitDecl,
  levels : Array[Int32],
) -> DHitSpec? {
  if levels.length() != decl.binders.length() || !level_hit_decl_validate(decl) {
    return None
  }
  match dlevel_eval(decl.result_level, levels) {
    Some(result_level) => {
      let ok = [true]
      let spec = hit_spec_instantiate_levels_with(
        decl.template,
        levels,
        ok,
        result_level,
      )
      if ok[0] && hit_schema_validate(spec) {
        Some(spec)
      } else {
        None
      }
    }
    None => None
  }
}

///|
pub fn instantiate_level_term_decl(
  decl : DLevelTermDecl,
  levels : Array[Int32],
) -> DLevelTermInstance? {
  if levels.length() != decl.binders.length() || !level_term_decl_validate(decl) {
    return None
  }
  match
    (
      dterm_instantiate_levels(decl.ty, levels),
      dterm_instantiate_levels(decl.body, levels),
    ) {
    (Some(ty), Some(body)) =>
      if dep_check_closed(body, ty) {
        Some(DLevelTermInstance::{ ty, body, })
      } else {
        None
      }
    _ => None
  }
}

///|
pub fn list_level_decl() -> DLevelInductiveDecl {
  dlevel_inductive_decl(
    ["l"],
    DLevelVar(0),
    dinductive_spec(
      "ListU",
      0,
      [dtelescope_entry("A", DUnivLevel(DLevelVar(0)))],
      [],
      [
        dconstructor_spec("nil", []),
        dconstructor_spec("cons", [
          darg_external("head", DTVar(0)),
          darg_recursive("tail"),
        ]),
      ],
    ),
  )
}

///|
pub fn circle_level_decl() -> DLevelHitDecl {
  dlevel_hit_decl(
    ["l"],
    DLevelVar(0),
    dhit_spec("CircleU", 0, [], [], [
      dhit_cell_spec("base", 0, [], []),
      dhit_cell_spec("loop", 1, [], [dhit_face(0, [], []), dhit_face(0, [], [])]),
    ]),
  )
}

///|
pub fn level_identity_decl() -> DLevelTermDecl {
  dlevel_term_decl(
    "id",
    ["l"],
    DPi(DUnivLevel(DLevelVar(0)), DPi(DTVar(0), DTVar(1))),
    DLam(DUnivLevel(DLevelVar(0)), DLam(DTVar(0), DTVar(0))),
  )
}

///|
pub fn check_level_polymorphic_declarations() -> Bool {
  let list_ok = match instantiate_level_inductive_decl(list_level_decl(), [2]) {
    Some(spec) => spec.level == 2 && spec.params[0].ty == DUniv(2)
    None => false
  }
  let circle_ok = match instantiate_level_hit_decl(circle_level_decl(), [1]) {
    Some(spec) => spec.level == 1 && hit_schema_validate(spec)
    None => false
  }
  let identity_ok = match
    instantiate_level_term_decl(level_identity_decl(), [3]) {
    Some(instance) => dep_check_closed(instance.body, instance.ty)
    None => false
  }
  list_ok &&
  circle_ok &&
  identity_ok &&
  instantiate_level_inductive_decl(list_level_decl(), []) == None &&
  !dterm_levels_in_scope(DUnivLevel(DLevelVar(1)), 1)
}

///|
pub fn level_decl_inductive(decl : DLevelInductiveDecl) -> DLevelDecl {
  DLevelDecl::DLevelInductive(decl)
}

///|
pub fn level_decl_hit(decl : DLevelHitDecl) -> DLevelDecl {
  DLevelDecl::DLevelHit(decl)
}

///|
pub fn level_decl_term(decl : DLevelTermDecl) -> DLevelDecl {
  DLevelDecl::DLevelTerm(decl)
}

///|
pub fn level_decl_validate(decl : DLevelDecl) -> Bool {
  match decl {
    DLevelInductive(d) => level_inductive_decl_validate(d)
    DLevelHit(d) => level_hit_decl_validate(d)
    DLevelTerm(d) => level_term_decl_validate(d)
  }
}

// ---------------------------------------------------------------------------
// Type-operator positivity extraction
// ---------------------------------------------------------------------------

///|
/// A transparent one-argument type operator declaration.  `head` is
/// the term denoting the operator in the ambient context (often a
/// variable or a previously defined constant); `body` is its
/// defining lambda.  Extraction unfolds the head and beta-reduces,
/// so an operator is accepted only through this transparent body,
/// not through an unexamined positivity assertion.
pub struct DTypeOperatorDecl {
  name : String
  head : DTerm
  body : DTerm
}

///|
pub fn dtype_operator_decl(
  name : String,
  head : DTerm,
  body : DTerm,
) -> DTypeOperatorDecl {
  DTypeOperatorDecl::{ name, head, body, }
}

///|
fn shifted_terms(terms : Array[DTerm]) -> Array[DTerm] {
  let out : Array[DTerm] = []
  for i in 0..<terms.length() {
    out.push(dterm_shift(terms[i], 0, 1))
  }
  out
}

///|
fn shifted_operators(
  operators : Array[DTypeOperatorDecl],
) -> Array[DTypeOperatorDecl] {
  let out : Array[DTypeOperatorDecl] = []
  for i in 0..<operators.length() {
    out.push(
      dtype_operator_decl(
        operators[i].name,
        dterm_shift(operators[i].head, 0, 1),
        dterm_shift(operators[i].body, 0, 1),
      ),
    )
  }
  out
}

///|
fn find_type_operator(
  operators : Array[DTypeOperatorDecl],
  head : DTerm,
) -> DTypeOperatorDecl? {
  for i in 0..<operators.length() {
    if operators[i].head == head {
      return Some(operators[i])
    }
  }
  None
}

///|
fn extract_positive_functor_go(
  body : DTerm,
  self_name : String,
  expected_params : Array[DTerm],
  operators : Array[DTypeOperatorDecl],
  fuel : Int32,
) -> DPositiveFunctor? {
  if fuel <= 0 {
    return None
  }
  match body {
    DInductive(spec, args) =>
      if spec.name == self_name {
        let (params, indices) = positivity_split_terms(
          args,
          spec.params.length(),
        )
        if params.length() != expected_params.length() {
          return None
        }
        for i in 0..<params.length() {
          if params[i] != expected_params[i] {
            return None
          }
        }
        Some(DFunctorIdentity(indices))
      } else if dterm_family_occurs(body, self_name) {
        // Indirect recursion through another inductive family may
        // have a strictly positive polarity report, but this
        // extraction returns a traversal only when it can synthesize
        // one in the functor IR.
        None
      } else {
        Some(DFunctorConst(body))
      }
    DHitType(spec, args) =>
      if spec.name == self_name {
        let (params, indices) = positivity_split_terms(
          args,
          spec.params.length(),
        )
        if params.length() != expected_params.length() {
          return None
        }
        for i in 0..<params.length() {
          if params[i] != expected_params[i] {
            return None
          }
        }
        Some(DFunctorIdentity(indices))
      } else if dterm_family_occurs(body, self_name) {
        None
      } else {
        Some(DFunctorConst(body))
      }
    DApp(DLam(_, inner), arg) =>
      extract_positive_functor_go(
        dterm_substitute(inner, 0, arg),
        self_name,
        expected_params,
        operators,
        fuel - 1,
      )
    DApp(head, arg) =>
      match find_type_operator(operators, head) {
        Some(decl) =>
          extract_positive_functor_go(
            DApp(decl.body, arg),
            self_name,
            expected_params,
            operators,
            fuel - 1,
          )
        None =>
          if dterm_family_occurs(body, self_name) {
            None
          } else {
            Some(DFunctorConst(body))
          }
      }
    DPi(dom, cod) =>
      if dterm_family_occurs(dom, self_name) {
        None
      } else {
        match
          extract_positive_functor_go(
            cod,
            self_name,
            shifted_terms(expected_params),
            shifted_operators(operators),
            fuel - 1,
          ) {
          Some(inner) => Some(DFunctorPi(dom, inner))
          None => None
        }
      }
    DSigma(first, second) =>
      match
        (
          extract_positive_functor_go(
            first,
            self_name,
            expected_params,
            operators,
            fuel - 1,
          ),
          extract_positive_functor_go(
            second,
            self_name,
            shifted_terms(expected_params),
            shifted_operators(operators),
            fuel - 1,
          ),
        ) {
        (Some(a), Some(b)) => Some(DFunctorSigma(a, b))
        _ => None
      }
    DListTy(inner) =>
      match
        extract_positive_functor_go(
          inner,
          self_name,
          expected_params,
          operators,
          fuel - 1,
        ) {
        Some(f) => Some(DFunctorList(f))
        None => None
      }
    DAnn(inner, _) =>
      extract_positive_functor_go(
        inner,
        self_name,
        expected_params,
        operators,
        fuel - 1,
      )
    _ =>
      if dterm_family_occurs(body, self_name) {
        None
      } else {
        Some(DFunctorConst(body))
      }
  }
}

///|
/// Extract a positive-functor traversal from a transparent type
/// body.  Recursive leaves are applications of the named family at
/// exactly `expected_params` (in the ambient de Bruijn context) and
/// arbitrary index terms.  Pi domains must not mention the family;
/// dependent Sigma, Pi codomains, lists, beta-redexes, and declared
/// transparent type operators are compiled to the functor IR.
pub fn extract_positive_functor(
  body : DTerm,
  self_name : String,
  expected_params : Array[DTerm],
  operators~ : Array[DTypeOperatorDecl] = [],
) -> DPositiveFunctor? {
  extract_positive_functor_go(body, self_name, expected_params, operators, 128)
}

///|
/// The current parameter variables in a schema constructor context
/// consisting of the parameters followed by `prior_arg_count`
/// earlier constructor arguments.
pub fn schema_expected_param_terms(
  param_count : Int32,
  prior_arg_count : Int32,
) -> Array[DTerm] {
  let out : Array[DTerm] = []
  for j in 0..<param_count {
    out.push(DTVar(prior_arg_count + param_count - 1 - j))
  }
  out
}

///|
/// Build a nested constructor argument by extracting a traversal
/// from its displayed type-operator body.
pub fn darg_nested_from_type(
  name : String,
  body : DTerm,
  self_name : String,
  param_count : Int32,
  prior_arg_count : Int32,
  operators~ : Array[DTypeOperatorDecl] = [],
) -> DConstructorArg? {
  match
    extract_positive_functor(
      body,
      self_name,
      schema_expected_param_terms(param_count, prior_arg_count),
      operators~,
    ) {
    Some(functor) => Some(darg_nested(name, functor))
    None => None
  }
}

///|
/// Positivity of a transparent type operator in its bound type
/// argument, by the same probe-family method as generated-family
/// parameter certification.
pub fn type_operator_positivity(decl : DTypeOperatorDecl) -> DPositivityReport {
  match decl.body {
    DLam(_, result) =>
      dterm_family_positivity(
        dterm_substitute(result, 0, positivity_probe_term()),
        positivity_probe_name(),
      )
    _ => positivity_unknown()
  }
}

///|
pub fn type_operator_is_strictly_positive(decl : DTypeOperatorDecl) -> Bool {
  let r = type_operator_positivity(decl)
  !r.occurs || (r.strictly_positive && !r.unknown && !r.negative_polarity)
}

///|
pub fn check_type_operator_positivity_extraction() -> Bool {
  let params = [dtelescope_entry("A", DUniv(0))]
  let dummy = dinductive_spec("OpTree", 0, params, [], [])
  let operator = dtype_operator_decl(
    "ListPair",
    DTVar(1),
    DLam(DUniv(0), DListTy(DSigma(DTVar(0), DBoolTy))),
  )
  let applied = DApp(DTVar(1), DInductive(dummy, [DTVar(0)]))
  let extracted = extract_positive_functor(applied, "OpTree", [DTVar(0)], operators=[
    operator,
  ])
  let operator_ok = match extracted {
    Some(
      DFunctorList(DFunctorSigma(DFunctorIdentity([]), DFunctorConst(DBoolTy)))
    ) => true
    _ => false
  }
  // A dependent-Sigma nested argument in an actual schema:
  // node : (label:A) -> Sigma (n:Nat), OpTree A -> OpTree A, where
  // in the nested argument context A is DTVar(1), hence DTVar(2)
  // under the Sigma binder.
  let nested_body = DSigma(DNatTy, DInductive(dummy, [DTVar(2)]))
  let nested_arg = match
    darg_nested_from_type("child", nested_body, "OpTree", 1, 1) {
    Some(arg) => arg
    None => darg_external("bad", DUnitTy)
  }
  let spec = dinductive_spec("OpTree", 0, params, [], [
    dconstructor_spec("leaf", []),
    dconstructor_spec("node", [darg_external("label", DTVar(0)), nested_arg]),
  ])
  operator_ok &&
  type_operator_is_strictly_positive(operator) &&
  inductive_schema_validate(spec) &&
  extract_positive_functor(
    DPi(DInductive(dummy, [DTVar(0)]), DBoolTy),
    "OpTree",
    [DTVar(0)],
  ) ==
  None
}

// ---------------------------------------------------------------------------
// Iterated non-uniform nested datatypes
// ---------------------------------------------------------------------------

///|
/// One argument of an iterated nested datatype.  External types are
/// read in the context of the current varying type parameter
/// followed by earlier arguments.  A recursive argument advances
/// the parameter transformation by the given positive number of
/// steps (one step is Bush's `A |-> A x A`).
pub enum DNestedArg {
  DNestedExternal(String, DTerm)
  DNestedRecursive(String, Int32)
}

///|
pub struct DNestedConstructor {
  name : String
  args : Array[DNestedArg]
  constraints : Array[DConstructorConstraint]
}

///|
/// A nested datatype with one varying type parameter.  `transform`
/// is a type term under one binder for the current parameter.  The
/// compiler below builds the depth-indexed auxiliary family
/// `Aux A k`, where the element parameter at depth `k` is the
/// k-fold iteration of `transform`; the nested type itself is
/// `Aux A 0`.  This is the standard depth encoding of iterated
/// non-uniform recursion and gives the correct dependent eliminator
/// over the depth index.
pub struct DNestedIterDecl {
  name : String
  level : Int32
  param_name : String
  param_level : Int32
  transform : DTerm
  constructors : Array[DNestedConstructor]
}

///|
pub struct DNestedIterFamily {
  decl : DNestedIterDecl
  auxiliary : DInductiveSpec
}

///|
pub fn dnested_external(name : String, ty : DTerm) -> DNestedArg {
  DNestedArg::DNestedExternal(name, ty)
}

///|
pub fn dnested_recursive(name : String, advance~ : Int32 = 1) -> DNestedArg {
  DNestedArg::DNestedRecursive(name, advance)
}

///|
pub fn dnested_constructor(
  name : String,
  args : Array[DNestedArg],
  constraints~ : Array[DConstructorConstraint] = [],
) -> DNestedConstructor {
  DNestedConstructor::{ name, args, constraints, }
}

///|
pub fn dnested_iter_decl(
  name : String,
  level : Int32,
  param_name : String,
  param_level : Int32,
  transform : DTerm,
  constructors : Array[DNestedConstructor],
) -> DNestedIterDecl {
  DNestedIterDecl::{
    name,
    level,
    param_name,
    param_level,
    transform,
    constructors,
  }
}

///|
fn nested_iter_type_at(decl : DNestedIterDecl, depth_index : Int32) -> DTerm {
  // In the context where this is inserted, DTVar(depth_index) is
  // the depth and DTVar(depth_index+1) is the base parameter.
  DNatElim(
    DUniv(decl.param_level),
    DTVar(depth_index + 1),
    DLam(DNatTy, DLam(DUniv(decl.param_level), decl.transform)),
    DTVar(depth_index),
  )
}

///|
fn nested_map_abstract_type(
  decl : DNestedIterDecl,
  t : DTerm,
  prior_args : Int32,
) -> DTerm {
  dterm_map_vars_at(t, 0, (i, depth) => {
    if i < prior_args + depth {
      DTVar(i)
    } else if i == prior_args + depth {
      nested_iter_type_at(decl, prior_args + depth)
    } else {
      // No further outer variables exist in the abstract
      // constructor context; keep any ill-scoped variable shifted
      // so validation of the auxiliary spec rejects it.
      DTVar(i + 1)
    }
  })
}

///|
fn nested_succ_term(t : DTerm, steps : Int32) -> DTerm {
  let mut out = t
  for _i in 0..<steps {
    out = DSucc(out)
  }
  out
}

///|
/// Compile an iterated nested declaration to its depth-indexed
/// auxiliary inductive family.
pub fn compile_nested_iter_decl(decl : DNestedIterDecl) -> DNestedIterFamily? {
  if decl.name.length() == 0 ||
    decl.param_name.length() == 0 ||
    decl.level < 0 ||
    decl.param_level < 0 {
    return None
  }
  // The transform must be a type under `A : Type param_level`.
  match
    d_as_type(
      decl.transform,
      schema_env([DVUniv(decl.param_level)]),
      schema_env([DVNeutral(DNVar(9700))]),
      ddim_empty(),
    ) {
    Some(_) => ()
    None => return None
  }
  let constructors : Array[DConstructorSpec] = []
  for ci in 0..<decl.constructors.length() {
    let ctor = decl.constructors[ci]
    let args : Array[DConstructorArg] = [darg_external("__depth", DNatTy)]
    for ai in 0..<ctor.args.length() {
      match ctor.args[ai] {
        DNestedExternal(name, ty) =>
          args.push(darg_external(name, nested_map_abstract_type(decl, ty, ai)))
        DNestedRecursive(name, advance) =>
          if advance <= 0 {
            return None
          } else {
            args.push(
              darg_recursive(name, index=[nested_succ_term(DTVar(ai), advance)]),
            )
          }
      }
    }
    let constraints : Array[DConstructorConstraint] = []
    for i in 0..<ctor.constraints.length() {
      let c = ctor.constraints[i]
      constraints.push(
        dconstructor_constraint(
          nested_map_abstract_type(decl, c.ty, ctor.args.length()),
          nested_map_abstract_type(decl, c.lhs, ctor.args.length()),
          nested_map_abstract_type(decl, c.rhs, ctor.args.length()),
        ),
      )
    }
    constructors.push(
      dconstructor_spec(
        ctor.name,
        args,
        result_index=[DTVar(ctor.args.length())],
        constraints~,
      ),
    )
  }
  let auxiliary = dinductive_spec(
    decl.name + "Aux",
    decl.level,
    [dtelescope_entry(decl.param_name, DUniv(decl.param_level))],
    [dtelescope_entry("depth", DNatTy)],
    constructors,
  )
  if inductive_schema_validate(auxiliary) {
    Some(DNestedIterFamily::{ decl, auxiliary, })
  } else {
    None
  }
}

///|
/// The nested type at a base parameter: depth zero of the auxiliary
/// family.
pub fn nested_iter_type_term(
  family : DNestedIterFamily,
  base_param : DTerm,
) -> DTerm {
  DInductive(family.auxiliary, [base_param, DNatZero])
}

///|
/// An introduction at an explicit auxiliary depth.  Depth is the
/// number of parameter transformations already applied; surface
/// values are built bottom-up with increasing depths.
pub fn nested_iter_intro_term_at(
  family : DNestedIterFamily,
  base_param : DTerm,
  depth : Int32,
  ctor_index : Int32,
  args : Array[DTerm],
) -> DTerm {
  let all = [mutual_nat_term(depth)]
  for i in 0..<args.length() {
    all.push(args[i])
  }
  DIntro(family.auxiliary, ctor_index, [base_param], all)
}

///|
pub fn bush_decl() -> DNestedIterDecl {
  dnested_iter_decl("Bush", 0, "A", 0, DSigma(DTVar(0), DTVar(1)), [
    dnested_constructor("nil", []),
    dnested_constructor("cons", [
      dnested_external("head", DTVar(0)),
      dnested_recursive("tail"),
    ]),
  ])
}

///|
pub fn bush_family() -> DNestedIterFamily? {
  compile_nested_iter_decl(bush_decl())
}

///|
pub fn check_nested_iter_datatype() -> Bool {
  match bush_family() {
    Some(family) => {
      let nil2 = nested_iter_intro_term_at(family, DBoolTy, 2, 0, [])
      let cons1 = nested_iter_intro_term_at(family, DBoolTy, 1, 1, [
        DPair(DBoolLit(true), DBoolLit(false)),
        nil2,
      ])
      let cons0 = nested_iter_intro_term_at(family, DBoolTy, 0, 1, [
        DBoolLit(true),
        cons1,
      ])
      dep_check_closed(cons0, nested_iter_type_term(family, DBoolTy))
    }
    None => false
  }
}

// ---------------------------------------------------------------------------
// Primitive mutual declarations and joint positivity
// ---------------------------------------------------------------------------

///|
/// A mutual block as a declaration, before elaboration to the
/// kernel's tagged family.  Components may refer to one another by
/// target index in recursive/function/nested arguments.
pub struct DMutualDecl {
  name : String
  components : Array[DInductiveSpec]
}

///|
pub struct DMutualPositivityReport {
  strictly_positive : Bool
  cross_edges : Array[(Int32, Int32)]
  offending_component : Int32
}

///|
pub fn dmutual_decl(
  name : String,
  components : Array[DInductiveSpec],
) -> DMutualDecl {
  DMutualDecl::{ name, components, }
}

///|
fn mutual_edge_present(
  edges : Array[(Int32, Int32)],
  edge : (Int32, Int32),
) -> Bool {
  for i in 0..<edges.length() {
    if edges[i] == edge {
      return true
    }
  }
  false
}

///|
fn mutual_external_functor_ok(
  functor : DPositiveFunctor,
  names : Array[String],
) -> Bool {
  match functor {
    DFunctorIdentity(_) => true
    DFunctorConst(ty) => {
      for i in 0..<names.length() {
        if dterm_family_occurs(ty, names[i]) {
          return false
        }
      }
      true
    }
    DFunctorProduct(a, b) | DFunctorSum(a, b) | DFunctorSigma(a, b) =>
      mutual_external_functor_ok(a, names) &&
      mutual_external_functor_ok(b, names)
    DFunctorList(inner) => mutual_external_functor_ok(inner, names)
    DFunctorPi(dom, inner) => {
      for i in 0..<names.length() {
        if dterm_family_occurs(dom, names[i]) {
          return false
        }
      }
      mutual_external_functor_ok(inner, names)
    }
    DFunctorContainer(shape, positions, _) => {
      for i in 0..<names.length() {
        if dterm_family_occurs(shape, names[i]) ||
          dterm_family_occurs(positions, names[i]) {
          return false
        }
      }
      true
    }
    DFunctorSelfFamily(_, _) => false
    DFunctorFamily(spec, pargs, _) => {
      // The applied family must be external to the mutual block,
      // and no explicit parameter term may mention a component.
      // (`Self` arguments and index terms are positions the
      // joint checker accounts for separately, as with the
      // container node's indices.)  A self-family node is by
      // definition internal to its component, and the joint
      // compilation does not support it, hence the rejection
      // above.
      for i in 0..<names.length() {
        if spec.name == names[i] {
          return false
        }
      }
      for i in 0..<pargs.length() {
        match pargs[i] {
          DFunctorParamTerm(t) =>
            for n in 0..<names.length() {
              if dterm_family_occurs(t, names[n]) {
                return false
              }
            }
          DFunctorParamSelf(_) => ()
        }
      }
      true
    }
  }
}

///|
/// Joint strict-positivity analysis of a mutual declaration.  An
/// edge `i -> j` records a recursive occurrence of component `j`
/// in component `i`; external types and function/container domains
/// in every component must mention no component of the block.
pub fn mutual_decl_positivity(decl : DMutualDecl) -> DMutualPositivityReport {
  let names : Array[String] = []
  for i in 0..<decl.components.length() {
    names.push(decl.components[i].name)
  }
  let edges : Array[(Int32, Int32)] = []
  let mut offending = -1
  if decl.name.length() == 0 ||
    decl.components.length() == 0 ||
    !schema_names_unique(names) {
    return DMutualPositivityReport::{
      strictly_positive: false,
      cross_edges: edges,
      offending_component: 0,
    }
  }
  for i in 0..<decl.components.length() {
    let component = decl.components[i]
    for n in 0..<names.length() {
      if schema_telescope_family_occurs(component.params, names[n]) ||
        schema_telescope_family_occurs(component.indices, names[n]) {
        offending = i
      }
    }
    for c in 0..<component.constructors.length() {
      let ctor = component.constructors[c]
      for a in 0..<ctor.args.length() {
        let arg = ctor.args[a]
        let target = if arg.target == -1 { i } else { arg.target }
        match arg.kind {
          DArgExternal =>
            for n in 0..<names.length() {
              if dterm_family_occurs(arg.ty, names[n]) {
                offending = i
              }
            }
          DArgRecursive | DArgFunction | DArgNested => {
            if target < 0 || target >= decl.components.length() {
              offending = i
            } else if !mutual_edge_present(edges, (i, target)) {
              edges.push((i, target))
            }
            if arg.kind == DArgFunction {
              for n in 0..<names.length() {
                if dterm_family_occurs(arg.ty, names[n]) {
                  offending = i
                }
              }
            }
            if arg.kind == DArgNested &&
              !mutual_external_functor_ok(arg.nested, names) {
              offending = i
            }
          }
          DArgDecoded | DArgDecodedFunction => offending = i
        }
      }
    }
  }
  DMutualPositivityReport::{
    strictly_positive: offending < 0,
    cross_edges: edges,
    offending_component: offending,
  }
}

///|
/// Elaborate a mutual declaration after the joint positivity check.
pub fn mutual_decl_elaborate(decl : DMutualDecl) -> DMutualFamily? {
  if mutual_decl_positivity(decl).strictly_positive {
    compile_mutual_inductive(decl.name, decl.components)
  } else {
    None
  }
}

///|
pub fn check_mutual_declaration_positivity() -> Bool {
  let decl = dmutual_decl("EvenOddDecl", even_odd_components())
  let report = mutual_decl_positivity(decl)
  let bad = dmutual_decl("BadMutual", [
    dinductive_spec("BadS", 0, [], [], [
      dconstructor_spec("mk", [
        darg_external(
          "negative",
          DPi(DInductive(dinductive_spec("BadS", 0, [], [], []), []), DBoolTy),
        ),
      ]),
    ]),
  ])
  let good_elaborates = match mutual_decl_elaborate(decl) {
    Some(_) => true
    None => false
  }
  let bad_rejected = match mutual_decl_elaborate(bad) {
    Some(_) => false
    None => true
  }
  report.strictly_positive &&
  report.cross_edges.length() == 2 &&
  good_elaborates &&
  !mutual_decl_positivity(bad).strictly_positive &&
  bad_rejected
}

// ---------------------------------------------------------------------------
// Simultaneous induction-recursion (semantic layer)
// ---------------------------------------------------------------------------

///|
/// One simultaneously defined recursive function.  `result_type`
/// is a type term in the context of the family parameters, indices,
/// and the code itself.  `cases[c]` is read in the context of the
/// parameters and constructor arguments, where after every
/// recursive/function/nested argument there is one recursive
/// hypothesis for every function of the simultaneous block, in
/// declaration order; constraint proofs come last.
pub struct DSimultaneousFunction {
  name : String
  result_type : DTerm
  cases : Array[DTerm]
}

///|
pub struct DSimultaneousIRSpec {
  base : DInductiveSpec
  functions : Array[DSimultaneousFunction]
}

///|
pub fn dsimultaneous_function(
  name : String,
  result_type : DTerm,
  cases : Array[DTerm],
) -> DSimultaneousFunction {
  DSimultaneousFunction::{ name, result_type, cases, }
}

///|
pub fn dsimultaneous_ir_spec(
  base : DInductiveSpec,
  functions : Array[DSimultaneousFunction],
) -> DSimultaneousIRSpec {
  DSimultaneousIRSpec::{ base, functions, }
}

///|
fn simultaneous_result_type(
  spec : DSimultaneousIRSpec,
  function_index : Int32,
  params : Array[DValue],
  indices : Array[DValue],
  code : DValue,
) -> DValue {
  if function_index < 0 || function_index >= spec.functions.length() {
    return DVUnitTy
  }
  let values = schema_concat_values(schema_concat_values(params, indices), [
    code,
  ])
  deval_dim(
    spec.functions[function_index].result_type,
    schema_env(values),
    ddim_empty(),
  )
}

///|
/// Evaluate one function of a simultaneous induction-recursive
/// block by structural recursion.  Cases receive, for each
/// recursive position, the values of *all* functions at that
/// position (pointwise for function arguments and through
/// `positive_functor_map` for nested arguments), so the functions
/// may genuinely call one another on subterms.
pub fn eval_simultaneous_ir(
  spec : DSimultaneousIRSpec,
  function_index : Int32,
  params : Array[DValue],
  indices : Array[DValue],
  code : DValue,
  dlevel : Int32,
) -> DValue {
  if function_index < 0 || function_index >= spec.functions.length() {
    return DVUnit
  }
  match force_value(code) {
    DVIntro(spec2, ctor, params2, args) =>
      if spec2 != spec.base ||
        ctor < 0 ||
        ctor >= spec.base.constructors.length() ||
        ctor >= spec.functions[function_index].cases.length() {
        DVUnit
      } else {
        let ctor_spec = spec.base.constructors[ctor]
        let env_values : Array[DValue] = []
        for i in 0..<params2.length() {
          env_values.push(params2[i])
        }
        let prior : Array[DValue] = []
        for i in 0..<args.length() {
          if i >= ctor_spec.args.length() {
            break
          }
          let arg_spec = ctor_spec.args[i]
          let arg = args[i]
          env_values.push(arg)
          match arg_spec.kind {
            DArgRecursive => {
              let idx = schema_eval_index_terms(params2, prior, arg_spec.index)
              for g in 0..<spec.functions.length() {
                env_values.push(
                  eval_simultaneous_ir(spec, g, params2, idx, arg, dlevel),
                )
              }
            }
            DArgFunction => {
              let dom = schema_eval_under(
                arg_spec.ty,
                schema_concat_values(params2, prior),
                [],
              )
              let prior_copy = schema_concat_values([], prior)
              for g in 0..<spec.functions.length() {
                env_values.push(
                  DVLam(a => {
                    let idx = schema_eval_index_terms(
                      params2,
                      schema_concat_values(prior_copy, [a]),
                      arg_spec.index,
                    )
                    eval_simultaneous_ir(
                      spec,
                      g,
                      params2,
                      idx,
                      dapp_typed(arg, a, dom),
                      dlevel,
                    )
                  }),
                )
              }
            }
            DArgNested =>
              for g in 0..<spec.functions.length() {
                env_values.push(
                  positive_functor_map(
                    arg_spec.nested,
                    params2,
                    prior,
                    idx => DVInductive(spec.base, params2, idx),
                    (idx, x) => {
                      simultaneous_result_type(spec, g, params2, idx, x)
                    },
                    (idx, x) => {
                      eval_simultaneous_ir(spec, g, params2, idx, x, dlevel)
                    },
                    arg,
                  ),
                )
              }
            DArgDecodedFunction => {
              let prior_specs = schema_arg_spec_prefix(ctor_spec.args, i)
              let dom = eval_inductive_decode(
                spec.base,
                params2,
                schema_source_indices(arg_spec, prior_specs, params2, prior),
                schema_source_value(arg_spec, prior),
                dlevel,
              )
              let prior_copy = schema_concat_values([], prior)
              for g in 0..<spec.functions.length() {
                env_values.push(
                  DVLam(a => {
                    let idx = schema_eval_index_terms(
                      params2,
                      schema_concat_values(prior_copy, [a]),
                      arg_spec.index,
                    )
                    eval_simultaneous_ir(
                      spec,
                      g,
                      params2,
                      idx,
                      dapp_typed(arg, a, dom),
                      dlevel,
                    )
                  }),
                )
              }
            }
            DArgExternal | DArgDecoded => ()
          }
          prior.push(arg)
        }
        for i in 0..<ctor_spec.constraints.length() {
          let (_, lhs, _) = schema_constraint_parts(
            ctor_spec.constraints[i],
            params2,
            args,
          )
          env_values.push(DVPathLam(_ => lhs))
        }
        deval_dim(
          spec.functions[function_index].cases[ctor],
          schema_env(env_values),
          ddim_empty(),
        )
      }
    DVNeutral(DNComp(line, branches, base)) =>
      elim_over_comp(
        line,
        branches,
        base,
        v => simultaneous_result_type(spec, function_index, params, indices, v),
        v => {
          eval_simultaneous_ir(spec, function_index, params, indices, v, dlevel)
        },
        dlevel,
      )
    DVNeutral(DNHComp(ty, branches, base)) =>
      elim_over_comp(
        _ => ty,
        branches,
        base,
        v => simultaneous_result_type(spec, function_index, params, indices, v),
        v => {
          eval_simultaneous_ir(spec, function_index, params, indices, v, dlevel)
        },
        dlevel,
      )
    DVNeutral(DNVar(n)) =>
      // A stuck simultaneous application at a fresh variable.  The
      // distinct level keeps hypotheses for different functions and
      // codes apart during case validation.
      DVNeutral(DNVar(24000 + function_index * 1000 + n % 1000))
    DVNeutral(n) => DVNeutral(n)
    _ => DVUnit
  }
}

///|
fn simultaneous_case_validate(
  spec : DSimultaneousIRSpec,
  function_index : Int32,
  ctor_index : Int32,
  param_values : Array[DValue],
  param_types : Array[DValue],
) -> Bool {
  let ctor = spec.base.constructors[ctor_index]
  let types : Array[DValue] = []
  let values : Array[DValue] = []
  for i in 0..<param_types.length() {
    types.push(param_types[i])
    values.push(param_values[i])
  }
  let prior : Array[DValue] = []
  for i in 0..<ctor.args.length() {
    let arg = ctor.args[i]
    let prior_specs = schema_arg_spec_prefix(ctor.args, i)
    let arg_ty = inductive_arg_type_full(
      spec.base,
      arg,
      prior_specs,
      param_values,
      prior,
    )
    let fresh = DVNeutral(DNVar(10000 + ctor_index * 100 + i))
    types.push(arg_ty)
    values.push(fresh)
    match arg.kind {
      DArgRecursive => {
        let idx = schema_eval_index_terms(param_values, prior, arg.index)
        for g in 0..<spec.functions.length() {
          types.push(
            simultaneous_result_type(spec, g, param_values, idx, fresh),
          )
          values.push(
            eval_simultaneous_ir(spec, g, param_values, idx, fresh, 0),
          )
        }
      }
      DArgFunction => {
        let dom = schema_eval_under(
          arg.ty,
          schema_concat_values(param_values, prior),
          [],
        )
        let prior_copy = schema_concat_values([], prior)
        for g in 0..<spec.functions.length() {
          types.push(
            DVPi(dom, a => {
              simultaneous_result_type(
                spec,
                g,
                param_values,
                schema_eval_index_terms(
                  param_values,
                  schema_concat_values(prior_copy, [a]),
                  arg.index,
                ),
                dapp_typed(fresh, a, dom),
              )
            }),
          )
          values.push(
            DVLam(a => {
              eval_simultaneous_ir(
                spec,
                g,
                param_values,
                schema_eval_index_terms(
                  param_values,
                  schema_concat_values(prior_copy, [a]),
                  arg.index,
                ),
                dapp_typed(fresh, a, dom),
                0,
              )
            }),
          )
        }
      }
      DArgNested =>
        for g in 0..<spec.functions.length() {
          types.push(
            positive_functor_ih_type(
              arg.nested,
              param_values,
              prior,
              idx => DVInductive(spec.base, param_values, idx),
              (idx, x) => {
                simultaneous_result_type(spec, g, param_values, idx, x)
              },
              fresh,
            ),
          )
          values.push(
            positive_functor_map(
              arg.nested,
              param_values,
              prior,
              idx => DVInductive(spec.base, param_values, idx),
              (idx, x) => {
                simultaneous_result_type(spec, g, param_values, idx, x)
              },
              (idx, x) => eval_simultaneous_ir(spec, g, param_values, idx, x, 0),
              fresh,
            ),
          )
        }
      DArgDecodedFunction => {
        let dom = eval_inductive_decode(
          spec.base,
          param_values,
          schema_source_indices(arg, prior_specs, param_values, prior),
          schema_source_value(arg, prior),
          0,
        )
        let prior_copy = schema_concat_values([], prior)
        for g in 0..<spec.functions.length() {
          types.push(
            DVPi(dom, a => {
              simultaneous_result_type(
                spec,
                g,
                param_values,
                schema_eval_index_terms(
                  param_values,
                  schema_concat_values(prior_copy, [a]),
                  arg.index,
                ),
                dapp_typed(fresh, a, dom),
              )
            }),
          )
          values.push(
            DVLam(a => {
              eval_simultaneous_ir(
                spec,
                g,
                param_values,
                schema_eval_index_terms(
                  param_values,
                  schema_concat_values(prior_copy, [a]),
                  arg.index,
                ),
                dapp_typed(fresh, a, dom),
                0,
              )
            }),
          )
        }
      }
      DArgExternal | DArgDecoded => ()
    }
    prior.push(fresh)
  }
  for i in 0..<ctor.constraints.length() {
    let (ty, lhs, rhs) = schema_constraint_parts(
      ctor.constraints[i],
      param_values,
      prior,
    )
    types.push(DVPathTy(_ => ty, lhs, rhs))
    values.push(DVPathLam(_ => lhs))
  }
  let expected = simultaneous_result_type(
    spec,
    function_index,
    param_values,
    inductive_result_indices(ctor, param_values, prior),
    DVIntro(spec.base, ctor_index, param_values, prior),
  )
  match
    d_check(
      spec.functions[function_index].cases[ctor_index],
      expected,
      schema_env(types),
      schema_env(values),
      ddim_empty(),
    ) {
    Some(_) => true
    None => false
  }
}

///|
/// Validate a simultaneous induction-recursive block: the base
/// family, every result-type family in its full context, and every
/// case against the corresponding result type with all simultaneous
/// recursive hypotheses present.
pub fn simultaneous_ir_validate(spec : DSimultaneousIRSpec) -> Bool {
  if !inductive_schema_validate(spec.base) || spec.functions.length() == 0 {
    return false
  }
  let names : Array[String] = []
  for i in 0..<spec.functions.length() {
    if spec.functions[i].cases.length() != spec.base.constructors.length() {
      return false
    }
    names.push(spec.functions[i].name)
  }
  if !schema_names_unique(names) {
    return false
  }
  let param_values = schema_fresh_values(spec.base.params.length(), 9800)
  let param_types = inductive_param_types(spec.base, param_values)
  let index_values = schema_fresh_values(spec.base.indices.length(), 9850)
  let index_types = telescope_type_values(
    spec.base.indices,
    param_types,
    param_values,
    index_values,
  )
  let code_value = DVNeutral(DNVar(9900))
  let code_type = DVInductive(spec.base, param_values, index_values)
  for f in 0..<spec.functions.length() {
    let ctx_types = schema_concat_values(
      schema_concat_values(param_types, index_types),
      [code_type],
    )
    let ctx_values = schema_concat_values(
      schema_concat_values(param_values, index_values),
      [code_value],
    )
    match
      d_as_type(
        spec.functions[f].result_type,
        schema_env(ctx_types),
        schema_env(ctx_values),
        ddim_empty(),
      ) {
      Some(_) => ()
      None => return false
    }
    for c in 0..<spec.base.constructors.length() {
      if !simultaneous_case_validate(spec, f, c, param_values, param_types) {
        return false
      }
    }
  }
  true
}

///|
pub fn nat_parity_double_ir() -> DSimultaneousIRSpec {
  dsimultaneous_ir_spec(nat_schema(), [
    dsimultaneous_function("parity", DBoolTy, [
      DBoolLit(true),
      // Context: pred, parity(pred), double(pred); DTVar(1) is the
      // parity hypothesis.
      DBoolElim(DBoolTy, DBoolLit(false), DBoolLit(true), DTVar(1)),
    ]),
    dsimultaneous_function("double", DNatTy, [
      DNatZero,
      // DTVar(0) is the double hypothesis.
      DSucc(DSucc(DTVar(0))),
    ]),
  ])
}

///|
pub fn check_simultaneous_induction_recursion() -> Bool {
  let spec = nat_parity_double_ir()
  let mut three : DValue = DVIntro(spec.base, 0, [], [])
  for _i in 0..<3 {
    three = DVIntro(spec.base, 1, [], [three])
  }
  simultaneous_ir_validate(spec) &&
  conv_at(
    0,
    0,
    DVBoolTy,
    eval_simultaneous_ir(spec, 0, [], [], three, 0),
    DVBool(false),
  ) &&
  conv_at(
    0,
    0,
    DVNatTy,
    eval_simultaneous_ir(spec, 1, [], [], three, 0),
    dv_nat_lit(6),
  )
}

///|
/// A composition whose base is the base point (a face of `loop`)
/// and whose tube traverses the loop cell itself now computes in
/// the lifted cell instead of remaining a formal composition.
pub fn check_hit_moving_dimension_lift() -> Bool {
  let circle = circle_schema()
  let ty = DVHitType(circle, [], [])
  let base = hit_cell_value(circle, 1, [], [], [DZero])
  let branches = dsystem_singleton(FEq0(DVar(0)), j => {
    DVHitCell(circle, 1, [], [], [j])
  })
  let result = hcomp_value(ty, branches, base, 1)
  let canonical = match force_value(result) {
    DVNeutral(_) => false
    _ => true
  }
  canonical && conv_at(0, 1, ty, result, base)
}

// ---------------------------------------------------------------------------
// Compiling one simultaneous function into a plain decode
// ---------------------------------------------------------------------------

///|
/// The universe level of a simultaneous function whose result
/// type computes (at fresh parameters, indices, and a neutral
/// code) to a universe, or -1.  Result types that genuinely
/// depend on the code do not reduce at the neutral probe and are
/// rejected here even when universe-valued.
pub fn simultaneous_ir_function_universe_level(
  spec : DSimultaneousIRSpec,
  function_index : Int32,
) -> Int32 {
  if function_index < 0 || function_index >= spec.functions.length() {
    return -1
  }
  let param_values = schema_fresh_values(spec.base.params.length(), 10600)
  let index_values = schema_fresh_values(spec.base.indices.length(), 10650)
  match
    force_value(
      simultaneous_result_type(
        spec,
        function_index,
        param_values,
        index_values,
        DVNeutral(DNVar(10700)),
      ),
    ) {
    DVUniv(level) => level
    _ => -1
  }
}

///|
fn simultaneous_arg_has_hypothesis(kind : DArgKind) -> Bool {
  match kind {
    DArgExternal | DArgDecoded => false
    _ => true
  }
}

///|
/// Map each position of the simultaneous case context for one
/// constructor (parameters; then per argument the value followed
/// by one hypothesis per function; then constraint proofs) to
/// the corresponding plain-decode context position for
/// `function_index`, with -1 for other functions' hypotheses.
/// Also returns the decode context length.
fn simultaneous_decode_layout(
  spec : DSimultaneousIRSpec,
  function_index : Int32,
  ctor : DConstructorSpec,
) -> (Array[Int32], Int32) {
  let map : Array[Int32] = []
  let mut dec = 0
  for _i in 0..<spec.base.params.length() {
    map.push(dec)
    dec = dec + 1
  }
  for i in 0..<ctor.args.length() {
    map.push(dec)
    dec = dec + 1
    if simultaneous_arg_has_hypothesis(ctor.args[i].kind) {
      for g in 0..<spec.functions.length() {
        map.push(if g == function_index { dec } else { -1 })
      }
      dec = dec + 1
    }
  }
  for _i in 0..<ctor.constraints.length() {
    map.push(dec)
    dec = dec + 1
  }
  (map, dec)
}

///|
/// Whether some case of `function_index` mentions another
/// function's hypothesis (and therefore cannot be compiled to a
/// plain single decode).
pub fn simultaneous_ir_uses_other_hypotheses(
  spec : DSimultaneousIRSpec,
  function_index : Int32,
) -> Bool {
  if function_index < 0 || function_index >= spec.functions.length() {
    return true
  }
  for c in 0..<spec.base.constructors.length() {
    if c >= spec.functions[function_index].cases.length() {
      return true
    }
    let (map, _) = simultaneous_decode_layout(
      spec,
      function_index,
      spec.base.constructors[c],
    )
    let sim_len = map.length()
    let mut foreign = false
    ignore(
      dterm_map_vars_at(spec.functions[function_index].cases[c], 0, (v, depth) => {
        if v >= depth {
          let pos = sim_len - 1 - (v - depth)
          if pos >= 0 && pos < sim_len && map[pos] < 0 {
            foreign = true
          }
        }
        DTVar(v)
      }),
    )
    if foreign {
      return true
    }
  }
  false
}

///|
/// Compile one universe-valued function of a simultaneous
/// induction-recursive block into the plain decode of a copy of
/// the base family (renamed `Base#function`), so the ordinary
/// `DDecode` former, constructor typing with decoded arguments,
/// and `eval_inductive_decode` can consume it.  Compilation is a
/// de Bruijn renumbering of the case terms from the simultaneous
/// case context to the decode case context; it is refused when
/// the block does not validate, when the function is not
/// universe-valued, when any case uses another function's
/// hypothesis (genuine interdependence has no single-decode
/// form), or when the resulting schema fails validation.
pub fn simultaneous_ir_compile_decode(
  spec : DSimultaneousIRSpec,
  function_index : Int32,
) -> DInductiveSpec? {
  if function_index < 0 || function_index >= spec.functions.length() {
    return None
  }
  if !simultaneous_ir_validate(spec) ||
    simultaneous_ir_uses_other_hypotheses(spec, function_index) {
    return None
  }
  let level = simultaneous_ir_function_universe_level(spec, function_index)
  if level < 0 {
    return None
  }
  let decode_cases : Array[DTerm] = []
  for c in 0..<spec.base.constructors.length() {
    let (map, dec_len) = simultaneous_decode_layout(
      spec,
      function_index,
      spec.base.constructors[c],
    )
    let sim_len = map.length()
    let rewritten = dterm_map_vars_at(
      spec.functions[function_index].cases[c],
      0,
      (v, depth) => {
        if v < depth {
          DTVar(v)
        } else {
          let pos = sim_len - 1 - (v - depth)
          if pos >= 0 && pos < sim_len && map[pos] >= 0 {
            DTVar(dec_len - 1 - map[pos] + depth)
          } else {
            DTVar(v)
          }
        }
      },
    )
    decode_cases.push(rewritten)
  }
  let compiled = DInductiveSpec::{
    name: spec.base.name + "#" + spec.functions[function_index].name,
    level: spec.base.level,
    params: spec.base.params,
    indices: spec.base.indices,
    constructors: spec.base.constructors,
    decode_cases,
    decode_level: level,
  }
  if inductive_schema_validate(compiled) &&
    inductive_decode_cases_validate(compiled) {
    Some(compiled)
  } else {
    None
  }
}

///|
fn code_schema_for_simultaneous() -> DInductiveSpec {
  dinductive_spec("CodeS", 0, [], [], [
    dconstructor_spec("cnat", []),
    dconstructor_spec("cbool", []),
    dconstructor_spec("cpair", [
      darg_recursive("first"),
      darg_recursive("second"),
    ]),
    dconstructor_spec("carrow", [darg_recursive("dom"), darg_recursive("cod")]),
  ])
}

///|
/// A small Tarski-style universe given simultaneously with a
/// size function.  The interpretation does not use the size
/// hypotheses, so it compiles to a plain decode (verified in
/// `check_simultaneous_ir_compiled_decode`); the variant whose
/// pair case mentions a size hypothesis does not.
pub fn code_interpretation_ir(use_size : Bool) -> DSimultaneousIRSpec {
  // Binary constructor context positions: a, El a, size a, b,
  // El b, size b (length 6).  El a is DTVar(4); under one binder
  // El b is DTVar(2); size a is DTVar(3).
  let pair_case = if use_size {
    DApp(DLam(DNatTy, DSigma(DTVar(5), DTVar(3))), DTVar(3))
  } else {
    DSigma(DTVar(4), DTVar(2))
  }
  dsimultaneous_ir_spec(code_schema_for_simultaneous(), [
    dsimultaneous_function("El", DUniv(0), [
      DNatTy,
      DBoolTy,
      pair_case,
      DPi(DTVar(4), DTVar(2)),
    ]),
    dsimultaneous_function("size", DNatTy, [
      DSucc(DNatZero),
      DSucc(DNatZero),
      DSucc(DTVar(3)),
      DSucc(DTVar(3)),
    ]),
  ])
}

///|
pub fn check_simultaneous_ir_compiled_decode() -> Bool {
  let spec = code_interpretation_ir(false)
  if !simultaneous_ir_validate(spec) ||
    simultaneous_ir_function_universe_level(spec, 0) != 0 ||
    simultaneous_ir_function_universe_level(spec, 1) != -1 ||
    simultaneous_ir_uses_other_hypotheses(spec, 0) {
    return false
  }
  let compiled = match simultaneous_ir_compile_decode(spec, 0) {
    Some(s) => s
    None => return false
  }
  if compiled.name != "CodeS#El" ||
    compiled.decode_level != 0 ||
    compiled.decode_cases.length() != 4 {
    return false
  }
  // The non-universe function and the size-using variant refuse.
  match simultaneous_ir_compile_decode(spec, 1) {
    Some(_) => return false
    None => ()
  }
  let dependent = code_interpretation_ir(true)
  if !simultaneous_ir_validate(dependent) ||
    !simultaneous_ir_uses_other_hypotheses(dependent, 0) {
    return false
  }
  match simultaneous_ir_compile_decode(dependent, 0) {
    Some(_) => return false
    None => ()
  }
  // Compiled decode agrees with the simultaneous evaluation on
  // concrete codes, semantically and at the term level.
  let cnat_b : DValue = DVIntro(spec.base, 0, [], [])
  let cbool_b : DValue = DVIntro(spec.base, 1, [], [])
  let code_b : DValue = DVIntro(spec.base, 3, [], [
    cnat_b,
    DVIntro(spec.base, 2, [], [cbool_b, cnat_b]),
  ])
  let cnat_c : DValue = DVIntro(compiled, 0, [], [])
  let cbool_c : DValue = DVIntro(compiled, 1, [], [])
  let code_c : DValue = DVIntro(compiled, 3, [], [
    cnat_c,
    DVIntro(compiled, 2, [], [cbool_c, cnat_c]),
  ])
  let expected : DValue = DVPi(DVNatTy, _ => DVSigma(DVBoolTy, _ => DVNatTy))
  if !conv_ty(0, 0, eval_simultaneous_ir(spec, 0, [], [], code_b, 0), expected) ||
    !conv_ty(0, 0, eval_inductive_decode(compiled, [], [], code_c, 0), expected) {
    return false
  }
  let cnat_t = schema_intro_term(compiled, 0, [], [])
  let cbool_t = schema_intro_term(compiled, 1, [], [])
  let code_t = schema_intro_term(compiled, 3, [], [
    cnat_t,
    schema_intro_term(compiled, 2, [], [cbool_t, cnat_t]),
  ])
  dep_check_closed(code_t, schema_type_term(compiled, [])) &&
  dep_nf_closed(decode_term(compiled, [], [], code_t), DUniv(0)) ==
  Some(DPi(DNatTy, DSigma(DBoolTy, DNatTy)))
}
