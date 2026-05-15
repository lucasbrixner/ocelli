# `ocelli` — Engineering Roadmap

This is a spec-driven engineering plan. Each phase has a goal, concrete tasks,
and acceptance criteria. Tasks and criteria are tracked with checkboxes: mark
`[x]` only when the work is implemented **and** its acceptance criteria are
satisfied. A phase is "done" when every box under it is checked.

This document is scoped to engineering work.

## Status legend

- `[ ]` not started / in progress
- `[x]` implemented and acceptance criteria satisfied
- Effort sizing: **S** (hours), **M** (a few days), **L** (a week or more)

## Current state

- CLI `ocelli check <path>` scans `.hs`/`.lhs` files and emits heuristic diagnostics.
- Three rules implemented: lazy `foldl`, lazy record fields, lazy `State` imports.
- Rules are **line-based** (`lines` + `isInfixOf`), with known false positives
  (strings, comments, qualified names) and false negatives (multi-line expressions).
- Output is human-readable text only. Exit code is non-zero when diagnostics are found.
- No automated tests beyond `examples/` and manual inspection.

## Version support policy

`ocelli` targets GHC **9.6.7** (current GHCup recommended set with HLS) and more
recent GHC releases supported by HLS.

Decision for the parser work: build against a **single recent `ghc-lib-parse`
series** (track the latest stable line, e.g. 9.8.x or 9.10.x) rather than
attempting per-version parsing. Parsing is forgiving across minor versions, so
one recent `ghc-lib-parse` can parse the dialects `ocelli` cares about. Strict
per-version locking only becomes necessary at Phase 5 (Core/demand), which is
genuinely version-fragile. The exact pin is a task in Phase 1.

## Phase ordering rationale

The order is impact-to-effort, with hard dependencies respected:

1. **Parser first.** Every rule sits on line-scanning today. A real AST kills the
   false positives, and — critically — forces the rules into the shape HLS will
   hand them later. Skipping this means writing the rules twice.
2. **JSON output** turns `ocelli` from "a CLI that prints text" into an engine
   something else can consume. It also defines a stable, testable contract.
3. **Golden tests** must land before further rule work: the parser refactor will
   touch every rule and there is currently no safety net.
4. **HLS plugin** is the practical-tool payoff. Diagnostics first (the big leap),
   then hover (cheap), then code actions for select rules (expensive, lower ROI).
5. **Core/demand analysis** is what makes `ocelli` more than a linter, but it has
   the worst short-term impact-to-effort ratio. It comes after a solid parsed-AST
   foundation and a working plugin, and needs its own design pass.

---

## Phase 1 — Parser foundation (`ghc-lib-parse`)

**Goal.** Replace line-based scanning with a real parsed AST. Rules become pure
functions over the AST, not over raw source text.
**Effort.** L

### Baseline (before starting)

- [ ] Confirm `cabal build`, `cabal check`, and `cabal run ocelli -- check examples/`
      all succeed on a clean checkout.
- [ ] `cabal build` is clean under `-Wall` and `cabal check` reports no warnings.

### Design decisions to lock first

- [ ] Pick and pin the `ghc-lib-parse` version (latest stable 9.8.x or 9.10.x);
      record the choice and reasoning in this file.
- [ ] Decide the shared rule signature. Target shape: rules take the parsed module
      produced by `ghc-lib-parse` and return `[Diagnostic]` — pure, no `IO`, no
      `FilePath`/`String`. The CLI does `read → parse → run rules`; HLS will reuse
      the *same* rule functions against the `ParsedModule` it already has.
- [ ] Decide parse-failure behavior. Recommended: emit a structured diagnostic
      with a new `DiagnosticKind` (e.g. `ParseFailure`) so JSON consumers and CI
      see it, rather than silently skipping.

### Tasks

- [ ] Add `ghc-lib-parse` as a dependency with the pinned bound.
- [ ] Create `Ocelli.Parse`: takes a `FilePath` + source, returns either a parsed
      module or parse errors. Centralizes parser flags and language-extension setup.
- [ ] Add `ParseFailure` to `DiagnosticKind` (per the decision above).
- [ ] Rewrite `Ocelli.Rules.Foldl` to consume the AST: detect `foldl` in expression
      position, correctly distinguish `foldl'`, and handle qualified names
      (`L.foldl`, `Data.List.foldl`). No more matching inside strings or comments.
- [ ] Rewrite `Ocelli.Rules.LazyRecord` to consume the AST: detect `data`/`newtype`
      record fields lacking a strictness annotation; respect a `StrictData` /
      `Strict` language pragma in the module; no more multi-line guessing.
- [ ] Rewrite `Ocelli.Rules.LazyState` to consume the AST: inspect import
      declarations for lazy `State` modules, excluding `.Strict` variants.
- [ ] Replace the hand-rolled `findColumn` logic with real `SrcSpan`-derived
      line/column positions.
- [ ] Update `Ocelli.Check` orchestration to parse once per file, then run all
      rules over the parsed result.
- [ ] Add example files that previously caused false positives (e.g. `foldl` in a
      string literal, in a comment, a qualified `foldl'`) and a multi-line
      expression that was previously missed.

### Acceptance criteria

- [ ] All pre-existing `examples/` files produce the same or strictly better
      diagnostics than before.
- [ ] The new false-positive example files produce **zero** spurious diagnostics.
- [ ] Qualified names are handled correctly in all three rules.
- [ ] `LazyRecord` does not warn when `StrictData` is enabled or all fields are strict.
- [ ] Rule functions are pure and AST-typed (no `IO`, no `FilePath`/`String` args).
- [ ] `cabal build` clean under `-Wall`; `cabal run ocelli -- check examples/` works.

---

## Phase 2 — Structured (JSON) output

**Goal.** Make diagnostics machine-readable so downstream consumers (tests, CI,
the HLS plugin) have a stable contract.
**Effort.** S–M

### Design decisions to lock first

- [ ] Flag design: `--format=text|json`, defaulting to `text` for backwards
      compatibility.
- [ ] JSON schema for `Diagnostic`, including a top-level schema/format version
      field so the contract can evolve safely.

### Tasks

- [ ] Add a JSON serialization path for `Diagnostic` (and the diagnostic list).
- [ ] Add the `--format` flag to the CLI argument handling in `app/Main.hs`.
- [ ] Document the JSON schema in `docs/` (field names, types, the version field,
      how `confidence` and `kind` are encoded).
- [ ] Ensure exit-code behavior is unchanged regardless of output format.

### Acceptance criteria

- [ ] `ocelli check --format=json examples/` emits valid, well-formed JSON.
- [ ] Default (`text`) output is byte-identical to the previous behavior.
- [ ] The JSON schema is documented and includes a version field.
- [ ] Exit code is non-zero when diagnostics are found, in both formats.

---

## Phase 3 — Golden tests

**Goal.** A regression safety net before any further rule work. The Phase 1
refactor touched every rule; nothing currently guards against silent breakage.
**Effort.** S–M

### Design decisions to lock first

- [ ] Pick a test framework (e.g. `tasty` + `tasty-golden`, or `hspec`).

### Tasks

- [ ] Add a test-suite stanza to `ocelli.cabal`.
- [ ] Create golden cases: input `.hs` file → expected JSON output, for each rule.
- [ ] Include negative cases (clean files that should produce nothing) and the
      false-positive cases introduced in Phase 1.
- [ ] Include at least one parse-failure case.
- [ ] Wire the suite into `cabal test`.

### Acceptance criteria

- [ ] `cabal test` runs and passes on a clean checkout.
- [ ] Every rule has at least one positive and one negative golden case.
- [ ] A parse-failure case is covered.
- [ ] The suite is runnable in CI with no extra setup (CI wiring itself is a
      separate concern).

---

## Phase 4 — HLS plugin

**Goal.** Surface `ocelli` diagnostics inside the editor. This is the practical-tool
payoff. The plugin depends on the `ocelli` library and reuses the Phase 1 rule
functions directly — no rule logic is duplicated.
**Effort.** 4a: L · 4b: M · 4c: M

### Open question to resolve before 4a

- [ ] Decide the plugin distribution story. Third-party HLS plugins generally
      require building HLS with the plugin linked in; confirm the intended
      distribution/install path and document it before investing in 4b/4c.

### 4a — Diagnostics

#### Tasks

- [ ] Add a plugin component to the project (its own package or cabal component)
      depending on the `ocelli` library.
- [ ] Implement a `PluginDescriptor` that obtains the parsed module from HLS and
      runs ocelli's rule functions over it.
- [ ] Map `Diagnostic` values to LSP diagnostics with correct source ranges.

#### Acceptance criteria

- [ ] With the plugin enabled, `ocelli` diagnostics appear inline (squiggles) in a
      supported editor on a known-bad file.
- [ ] Diagnostic ranges point at the right span.
- [ ] No rule logic is duplicated between the CLI and the plugin.

### 4b — Hover explanations

#### Tasks

- [ ] Add a hover handler that, on an `ocelli` diagnostic, shows the `message` and
      `suggestion`.
- [ ] Optionally include a short "why" explanation per rule (e.g. why lazy `foldl`
      accumulates thunks). This is the one place explanatory depth is in scope, if
      it is useful to the developer.

#### Acceptance criteria

- [ ] Hovering over a diagnostic shows message and suggestion text.
- [ ] Hover content is sourced from the diagnostic, not re-derived.

### 4c — Code actions (select rules)

#### Tasks

- [ ] Implement an auto-fix code action for the unambiguous case: `foldl` → `foldl'`,
      including the `Data.List` import if not already present.
- [ ] Optionally implement the lazy `State` import swap to the `.Strict` module.
- [ ] Do **not** attempt code actions for rules where the correct fix is ambiguous.

#### Acceptance criteria

- [ ] The `foldl` → `foldl'` action applies a correct edit, including import handling,
      and does nothing wrong when an import already exists or is qualified.
- [ ] Code actions only appear for rules with an unambiguous fix.

---

## Phase 5 — GHC-aware analysis (Core / demand) — not yet specced

**Goal (direction only).** Move from syntactic heuristics toward
compiler-informed diagnostics: read GHC's strictness/demand analysis so `ocelli` can
confirm or retract a heuristic ("the compiler proved this is strict — false
positive") and surface properties the developer cannot otherwise see.

This phase is **not specced**. It is genuinely GHC-version-fragile and the
integration path into HLS is not yet clear. It needs its own design pass before
tasks and acceptance criteria can be written. Placeholder here only so the
ordering is explicit.

### Pre-spec tasks

- [ ] Dedicated design pass: feasibility, version strategy, where Core access comes
      from (GHC API directly vs. HLS-provided), and how results map onto the
      existing `Confidence` levels.
