# cubical-hermitian

Hermitian idempotent projectors and orthogonal eigenspace decomposition;
cubical interval, faces and systems modulo quotient with pruning; Kan comp
by retraction; NbE in three layers (beta-pi, typed eta-long, and dependent
Pi/Sigma with a cumulative universe hierarchy); persistent shared
environments, call-by-need semantic thunks and memoized dimension lines /
type families; a cubical AST with PathP, data types (Bool/Nat/List),
Circle/Torus HITs and coe/comp/hcomp/hfill term constructors whose Kan
operations reduce by type (Pi, Sigma, PathP, Glue, data, HITs and
universes); DSystem composition systems with checked compatibility for raw systems,
first-match normal forms and multi-branch Glue partial values; first-class
AST equivalences, ua and GlueEquiv; checked substitution-respecting type
lines and a schema registry with elaboration caches; generic
strictly-positive inductive-family and arbitrary finite-dimensional HIT
schema generators (nested container functors, mutual families, Tarski induction-recursion,
quotient cells and universe schemes); HOAS on normal forms; symbolic
decision (interned DAG ROBDDs with budgets/DPLL, wirings); exact rational
and algebraic-extension algebra with generalized eigenspaces and Jordan
decompositions; certified exact shadows of the numeric projector/cube
layer; general Glue comp; spheres by iterated suspension (including S3);
certified Hermitian Jacobi iteration by symbolic interval inclusion;
complete BigInt factorization/root isolation/splitting fields and radical
denesting; first-class level-polymorphic, mutual, non-uniform-nested and
simultaneous induction-recursion declarations; a higher-order-unification
bidirectional elaborator extending Miller patterns to repeated-variable,
constructor-spine and distinct flex-flex cases; parameterized modules with
abstract declarations, separate interface compilation/linking and incremental
caching; spherical degree representatives and a classical Hopf linking check; a general
semantic lemIso construction for contractible fibers and automatic
adjointification; internal IntegerS and pi3 quotient presentations with a
canonical spherical-loop representative calculus (not an arbitrary-element
pi3 classification); transactional bounded Huet search; a stable versioned
compiled-module byte/hex codec; and cost controls comprising BDD sifting and
growing apply caches, watched-literal DPLL fallback, sparse/common-denominator
BigInt Karatsuba polynomial multiplication and binary powers; cross-family
nested positive functors (`DFunctorFamily`) with a simultaneous-IR-to-decode
compiler; Face-valued agreement regions with exact DSystem repair;
generic-point lemIso validation and point-valued Circle/Torus composition;
byte-persistent schema registries (`CHREGBIN`) with global DTerm
hash-consing; adaptive mod-p factor-pattern pruning and biquadratic-field
radical denesting; host-opaque cube open-box filling (semantic and exact
polynomial variants), provably optimal BDD variable orders for small n and
CDCL clause learning; the schema circle's universal cover with
encode-by-substitution and decode-by-integer-elimination; exact Jacobi
eigenvalue-cluster separation; deeper HOU search with iterative deepening;
interleaved import/local module items with v1-to-v2 binary migration and an
in-process compiled-module store; same-spec non-uniform recursion
(`DFunctorSelfFamily`) with trusted or lambda-verified positivity
declarations for opaque operators; simultaneous-IR compilation onto base
eliminators in a predicative fragment; relevant-dimension structural
DSystem agreement and repair by verified supplementation; term-level Bool
case-split conversion and path-valued Circle/Torus composition keeping
winding data; an artifact repository over an abstract byte store with
shared DAG module/registry codecs (v3/v2) and version negotiation;
irreducibility certificates, pure-cubic and triquadratic radical towers
and cluster-aware interval Jacobi iteration; subset-DP exact BDD orders
(n<=12), CDCL with LBD clause deletion and replayable RUP proofs;
stratified extensionality checks for host cube functions; single
substitutions accumulating circle windings; connection-rotation unit-law
3-cells on sphere representatives and exact rational Hopf identities; and
a three-state principal-unifier semantics for Miller patterns; host-level
cubical algorithms (KanBox transport/fillers, path algebra, funext and subst);
computational univalence (decidable finite-universe wiring univalence and
checked ua/pathToEquiv, ua-beta, and round-trip certificates for the dependent
AST); a three-package architecture (`cmd/main -> root -> algebra`) governed by
`architecture.json`; and audited bilingual per-symbol
canonical-form/categorification specifications.

Run: `moon check --deny-warn`, `moon test` (95 tests), `moon run cmd/main`
(expected: 74/74 checks), `python3 tools/arch_check.py`, and
`moon info && python3 tools/audit_spec.py --check` (3338 interface symbols,
85 spec entries). Documentation: [English guide](GUIDE.en.md),
[English specification](SPEC.en.md), [中文指南](GUIDE.md),
[中文規格](SPEC.md), and [architecture](ARCHITECTURE.md).
