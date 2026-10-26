# Project Agents.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project.

You can browse and install extra skills here:
<https://github.com/moonbitlang/skills>

## Project Structure

- MoonBit packages are organized per directory; each directory contains a
  `moon.pkg` file listing its dependencies. Each package has its files and
  blackbox test files (ending in `_test.mbt`) and whitebox test files (ending in
  `_wbtest.mbt`).

- In the toplevel directory, there is a `moon.mod` file listing module
  metadata.

## Coding convention

- MoonBit code is organized in block style, each block is separated by `///|`,
  the order of each block is irrelevant. In some refactorings, you can process
  block by block independently.

- Try to keep deprecated blocks in file called `deprecated.mbt` in each
  directory.

## Tooling

- `moon fmt` is used to format your code properly.

- `moon ide` provides project navigation helpers like `peek-def`, `outline`, and
  `find-references`. See $moonbit-agent-guide for details.

- `moon info` is used to update the generated interface of the package, each
  package has a generated interface file `.mbti`, it is a brief formal
  description of the package. If nothing in `.mbti` changes, this means your
  change does not bring the visible changes to the external package users, it is
  typically a safe refactoring.

- In the last step, run `moon info && moon fmt` to update the interface and
  format the code. Check the diffs of `.mbti` file to see if the changes are
  expected.

- Run `moon test` to check tests pass. MoonBit supports snapshot testing; when
  changes affect outputs, run `moon test --update` to refresh snapshots.

- Prefer `assert_eq` or `assert_true(pattern is Pattern(...))` for results that
  are stable or very unlikely to change. For snapshot tests that record
  structured debugging output, derive `Debug` and use `debug_inspect`, rather
  than deriving `Show` for debugging. For solid, well-defined results (e.g.
  scientific computations), prefer assertion tests. You can use
  `moon coverage analyze > uncovered.log` to see which parts of your code are
  not covered by tests.

## This project (cubical-hermitian)

- Packages: `cmd/main -> root -> algebra`; every `.mbt` file is owned by
  exactly one component in `architecture.json` (see `ARCHITECTURE.md`).
  Root consumes `@algebra` only through the explicit list in
  `algebra_imports.mbt`.
- Acceptance gates (all must pass before committing):
  `moon fmt`, `moon info`, `moon check --deny-warn`, `moon test`,
  `moon run cmd/main`, `python3 tools/arch_check.py`,
  `python3 tools/audit_spec.py --check`.
- New public symbols must be classified in `tools/audit_spec.py`
  (the bilingual `SPEC-APPENDIX*.md` files are generated, never hand-edited)
  and, when they carry a checkable law, registered in `verify.mbt`
  and `spec.mbt`. Counts in prose docs come from the tools, not by hand.
- White-box test files (`*_wbtest.mbt`) call the `check_*` laws defined
  next to the implementations; law-style checks live in `*_laws.mbt`.
