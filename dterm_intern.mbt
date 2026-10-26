///|
/// Phase 11: hash-consing (interning) for dependent terms.
///
/// `dterm_rebuild` is the exact inverse of `dterm_children`: it
/// reassembles a term from a same-shaped spine and a replacement
/// child list (in `dterm_children` order).  On top of it,
/// `DTermInternTable` implements classical bottom-up hash-consing:
/// children are interned first, then the node is keyed by a local
/// stamp (the cache key of the node with its children replaced by
/// marker variables, which captures the constructor and every
/// non-term field: dimensions, faces, levels, constructor indices
/// and embedded schema descriptors) together with the children's
/// intern ids.  Structurally equal subterms therefore collapse to
/// one shared representative, so repeated subtrees are stored once.
///
/// Interning is purely representational: `dterm_intern(table, t)` is
/// structurally equal to `t` (same `dterm_cache_key`), hence every
/// kernel operation (inference, evaluation, conversion) gives the
/// same answers on interned and uninterned terms.  The table is an
/// explicit value threaded by the caller (the kernel keeps no
/// mutable global state), which is the form in which global
/// hash-consing can be adopted incrementally by the checker and the
/// module system.

///|
/// Reassemble `t` with its `DTerm` children replaced by `cs`
/// (in `dterm_children` order).  If the arity does not match,
/// `t` is returned unchanged.  Non-term fields (schema
/// descriptors, faces, dimensions, levels, indices) are preserved.
pub fn dterm_rebuild(t : DTerm, cs : Array[DTerm]) -> DTerm {
  if cs.length() != dterm_children(t).length() {
    return t
  }
  match t {
    DPi(_, _) => DPi(cs[0], cs[1])
    DSigma(_, _) => DSigma(cs[0], cs[1])
    DLam(_, _) => DLam(cs[0], cs[1])
    DApp(_, _) => DApp(cs[0], cs[1])
    DPair(_, _) => DPair(cs[0], cs[1])
    DAnn(_, _) => DAnn(cs[0], cs[1])
    DCons(_, _) => DCons(cs[0], cs[1])
    DFst(_) => DFst(cs[0])
    DSnd(_) => DSnd(cs[0])
    DLamDim(_) => DLamDim(cs[0])
    DSucc(_) => DSucc(cs[0])
    DListTy(_) => DListTy(cs[0])
    DBoolElim(_, _, _, _) => DBoolElim(cs[0], cs[1], cs[2], cs[3])
    DNatElim(_, _, _, _) => DNatElim(cs[0], cs[1], cs[2], cs[3])
    DListElim(_, _, _, _) => DListElim(cs[0], cs[1], cs[2], cs[3])
    DCircleElim(_, _, _, _) => DCircleElim(cs[0], cs[1], cs[2], cs[3])
    DPartial(branches) => DPartial(dterm_intern_zip_face_terms(branches, cs, 0))
    DPathP(_, _, _) => DPathP(cs[0], cs[1], cs[2])
    DPath(_, _, _) => DPath(cs[0], cs[1], cs[2])
    DAppDim(_, d) => DAppDim(cs[0], d)
    DCoe(_, r, s, _) => DCoe(cs[0], r, s, cs[1])
    DComp(_, tubes, _) =>
      DComp(cs[0], dterm_intern_zip_tube_terms(tubes, cs, 2), cs[1])
    DHComp(_, tubes, _) =>
      DHComp(cs[0], dterm_intern_zip_tube_terms(tubes, cs, 2), cs[1])
    DHFill(_, tubes, _, d) =>
      DHFill(cs[0], dterm_intern_zip_tube_terms(tubes, cs, 2), cs[1], d)
    DTorusElim(_, _, _) => DTorusElim(cs[0], cs[1], cs[2])
    DInductive(spec, _) => DInductive(spec, cs)
    DHitType(spec, _) => DHitType(spec, cs)
    DIntro(spec, k, params, _) =>
      DIntro(
        spec,
        k,
        dterm_intern_slice(cs, 0, params.length()),
        dterm_intern_slice(cs, params.length(), cs.length()),
      )
    DHitIntro(spec, k, params, _, dims) =>
      DHitIntro(
        spec,
        k,
        dterm_intern_slice(cs, 0, params.length()),
        dterm_intern_slice(cs, params.length(), cs.length()),
        dims,
      )
    DInductiveElim(spec, _, cases, params, _, _) =>
      DInductiveElim(
        spec,
        cs[0],
        dterm_intern_slice(cs, 2, 2 + cases.length()),
        dterm_intern_slice(
          cs,
          2 + cases.length(),
          2 + cases.length() + params.length(),
        ),
        dterm_intern_slice(
          cs,
          2 + cases.length() + params.length(),
          cs.length(),
        ),
        cs[1],
      )
    DHitElim(spec, _, cases, params, _, _) =>
      DHitElim(
        spec,
        cs[0],
        dterm_intern_slice(cs, 2, 2 + cases.length()),
        dterm_intern_slice(
          cs,
          2 + cases.length(),
          2 + cases.length() + params.length(),
        ),
        dterm_intern_slice(
          cs,
          2 + cases.length() + params.length(),
          cs.length(),
        ),
        cs[1],
      )
    DEquivTy(_, _) => DEquivTy(cs[0], cs[1])
    DMkEquiv(_, _, _, _, _, _) =>
      DMkEquiv(cs[0], cs[1], cs[2], cs[3], cs[4], cs[5])
    DEquivFwd(_) => DEquivFwd(cs[0])
    DEquivBwd(_) => DEquivBwd(cs[0])
    DEquivSect(_) => DEquivSect(cs[0])
    DEquivRetr(_) => DEquivRetr(cs[0])
    DUa(_) => DUa(cs[0])
    DGlueEquiv(_, branches) =>
      DGlueEquiv(cs[0], dterm_intern_zip_equiv_branches(branches, cs))
    DDecode(spec, params, _, _) =>
      DDecode(
        spec,
        dterm_intern_slice(cs, 1, 1 + params.length()),
        dterm_intern_slice(cs, 1 + params.length(), cs.length()),
        cs[0],
      )
    _ => t
  }
}

///|
fn dterm_intern_slice(
  cs : Array[DTerm],
  lo : Int32,
  hi : Int32,
) -> Array[DTerm] {
  let out : Array[DTerm] = []
  for i in lo..<hi {
    out.push(cs[i])
  }
  out
}

///|
fn dterm_intern_zip_face_terms(
  branches : Array[DFaceTerm],
  cs : Array[DTerm],
  offset : Int32,
) -> Array[DFaceTerm] {
  let out : Array[DFaceTerm] = []
  for i in 0..<branches.length() {
    out.push({ face: branches[i].face, body: cs[offset + i], })
  }
  out
}

///|
fn dterm_intern_zip_tube_terms(
  tubes : Array[DTubeTerm],
  cs : Array[DTerm],
  offset : Int32,
) -> Array[DTubeTerm] {
  let out : Array[DTubeTerm] = []
  for i in 0..<tubes.length() {
    out.push({ face: tubes[i].face, body: cs[offset + i], })
  }
  out
}

///|
fn dterm_intern_zip_equiv_branches(
  branches : Array[DEquivBranch],
  cs : Array[DTerm],
) -> Array[DEquivBranch] {
  let out : Array[DEquivBranch] = []
  for i in 0..<branches.length() {
    out.push({
      face: branches[i].face,
      ty: cs[1 + 2 * i],
      equiv: cs[2 + 2 * i],
    })
  }
  out
}

///|
/// Hash-consing table: maps each distinct node's composite key to
/// its id, with the representatives stored by id.
pub struct DTermInternTable {
  ids : Map[String, Int32]
  terms : Array[DTerm]
}

///|
pub fn dterm_intern_table_new() -> DTermInternTable {
  { ids: {}, terms: [], }
}

///|
pub fn dterm_intern_table_size(table : DTermInternTable) -> Int32 {
  table.terms.length()
}

///|
/// Local stamp: the cache key of the node with every child replaced
/// by a positional marker variable.  Two nodes share a stamp iff
/// they use the same constructor with the same non-term fields
/// (and the same number of children).
pub fn dterm_local_stamp(t : DTerm) -> String {
  let count = dterm_children(t).length()
  let markers : Array[DTerm] = []
  for i in 0..<count {
    markers.push(DTVar(1000000 + i))
  }
  dterm_cache_key(dterm_rebuild(t, markers))
}

///|
/// Intern `t`, returning the shared representative and its id.
/// The representative is structurally equal to `t`; equal subterms
/// anywhere (in this or later calls with the same table) receive
/// the same id and the same stored representative.
pub fn dterm_intern_id(table : DTermInternTable, t : DTerm) -> (DTerm, Int32) {
  let children = dterm_children(t)
  let interned_children : Array[DTerm] = []
  let mut key = dterm_local_stamp(t)
  key = key + "<"
  for i in 0..<children.length() {
    let (child, child_id) = dterm_intern_id(table, children[i])
    interned_children.push(child)
    if i > 0 {
      key = key + ","
    }
    key = key + child_id.to_string()
  }
  key = key + ">"
  match table.ids.get(key) {
    Some(id) => (table.terms[id], id)
    None => {
      let rebuilt = dterm_rebuild(t, interned_children)
      let id = table.terms.length()
      table.terms.push(rebuilt)
      table.ids.set(key, id)
      (rebuilt, id)
    }
  }
}

///|
pub fn dterm_intern(table : DTermInternTable, t : DTerm) -> DTerm {
  dterm_intern_id(table, t).0
}

///|
/// Intern every term, reusing `table`.
pub fn dterm_intern_all(
  table : DTermInternTable,
  ts : Array[DTerm],
) -> Array[DTerm] {
  let out : Array[DTerm] = []
  for i in 0..<ts.length() {
    out.push(dterm_intern(table, ts[i]))
  }
  out
}

///|
/// Number of nodes in the unshared tree.
pub fn dterm_tree_node_count(t : DTerm) -> Int32 {
  let children = dterm_children(t)
  let mut total = 1
  for i in 0..<children.length() {
    total = total + dterm_tree_node_count(children[i])
  }
  total
}

///|
/// Number of structurally distinct subterms (the hash-consed DAG
/// size).  Uses a fresh table.
pub fn dterm_distinct_subterm_count(t : DTerm) -> Int32 {
  let table = dterm_intern_table_new()
  ignore(dterm_intern(table, t))
  dterm_intern_table_size(table)
}

///|
/// The sharing ratio `distinct / tree` as an exact rational pair
/// reduced by gcd: `(distinct/g, tree/g)`.
pub fn dterm_sharing_ratio(t : DTerm) -> (Int32, Int32) {
  let distinct = dterm_distinct_subterm_count(t)
  let tree = dterm_tree_node_count(t)
  let g = int_gcd_nonnegative(distinct, tree)
  if g <= 0 {
    (distinct, tree)
  } else {
    (distinct / g, tree / g)
  }
}

///|
fn int_gcd_nonnegative(a : Int32, b : Int32) -> Int32 {
  let mut x = if a < 0 { 0 - a } else { a }
  let mut y = if b < 0 { 0 - b } else { b }
  while y != 0 {
    let r = x % y
    x = y
    y = r
  }
  x
}
