# Roadmap

## Phase 1 — Source-level heuristic diagnostics

- Detect common laziness and performance smells.
- Emit actionable diagnostics.
- Provide explanatory messages.
- Keep the implementation small and understandable.

Current implemented rules:

- `foldl`
- lazy record fields
- lazy `State`

This would make `ocelli` easier to integrate with editors, CI, and code review
workflows.

## Phase 2 — Structured output

Planned:

- JSON diagnostics
- SARIF output
- rule configuration
- severity levels
- machine-readable diagnostic codes

This would make `ocelli` easier to integrate with editors, CI, and code review
workflows.

## Phase 3 — GHC-aware analysis

Planned:

- parse/typecheck using the GHC API;
- inspect GHC Core;
- surface strictness and demand information;
- detect missed specialization;
- detect missed fusion;
- distinguish source-level false positives from optimized code.

The goal is to move from heuristic source scanning toward compiler-informed
diagnostics.

## Phase 4 — Runtime profiling integration

Planned:

- cost-centre profiling integration;
- heap profiling integration;
- eventlog integration;
- correlation between runtime evidence and source-level diagnostics;
- performance regression reports.

This would allow ocelli to say not only “this code may allocate” but also “this
code did allocate significantly in this run.”

## Phase 5 — HLS/editor integration

Planned:

- Haskell Language Server plugin;
- inline diagnostics;
- hover explanations;
- code actions;
- links to profiling evidence;
- editor-visible strictness/demand information.

The long-term vision is to make Haskell’s operational behavior visible during
normal development.
