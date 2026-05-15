# `ocelli`

`ocelli` is an experimental operational-analysis tool for Haskell. Its purpose
is to make normally implicit runtime properties — such as laziness, strictness,
thunk accumulation, allocation, retention, missed specialization, and profiling
evidence — more visible to developers.

Haskell’s semantic elegance often comes with operational opacity: programmers
can write highly compositional code, but it is not always clear when values are
evaluated, retained, or optimized away. By making these costs easier to inspect
and explain, `ocelli` aims to reduce one of the main practical barriers to
industrial Haskell adoption: the perception that lazy functional programs are
difficult to reason about operationally.

The current MVP provides source-level heuristic diagnostics for common
performance pitfalls. The long-term goal is to combine static analysis, GHC/Core
information, runtime profiling data, and editor integration.

## Name

The name `ocelli` comes from biology. Ocelli are simple eyes found in many
invertebrates, including insects and spiders. They often appear in multiple
positions: spiders have several ocelli arranged to cover different directions,
while many insects have lateral ocelli (stemmata) or dorsal ocelli that
complement the main compound eyes.

This is the metaphor behind `ocelli`. Haskell programs often have non-local
operational behavior: a local expression may allocate, retain data, defer
evaluation, or depend on optimizations that only become clear by looking
elsewhere — across other files, module boundaries, GHC Core/STG, demand
analysis, or runtime profiling data.

`ocelli` aims to provide multiple small “eyes” over these blind spots. Some
diagnostics look locally at source patterns, some look across modules, some look
inward into the compiler, and future ones may look backward into profiling
history or forward into performance regressions.

## Current status

`ocelli` is currently a minimal working prototype.

Implemented diagnostics:

- lazy `foldl` usage
- lazy record fields
- lazy `State` imports

Current limitations:

- diagnostics are heuristic;
- source parsing is line-based;
- there is no GHC parser integration yet;
- there is no Core/STG inspection yet;
- there is no demand/strictness analysis integration yet;
- there is no runtime profiling integration yet;
- there is no HLS/editor integration yet.

The MVP is intentionally small. Its purpose is to demonstrate the research
direction and establish a foundation for future GHC-aware and profile-guided
diagnostics.

## Toolchain

The current development setup is:

```text
GHC:              9.6.7
cabal-install:    3.14.2.0
HLS:              2.14.0.0
Cabal spec:       3.8
```

Recommended setup:

```text
GHCup → installs GHC, cabal-install, and HLS
cabal → builds and manages the project
HLS   → provides editor integration
Stack → not used for this project
```

Although `cabal-install` may be newer, the `.cabal` file currently uses:

```cabal
cabal-version: 3.8
```

This keeps the package description compatible with the HLS version used during
development.

## Building

From the project root:

```bash
cabal build
```

## Running

Run `ocelli` against the example files:

```bash
cabal run ocelli -- check examples/
```

Example output:

```text
examples/LazyRecord.hs:3:3
  [LazyRecordFields/Heuristic] Record fields are lazy by default.
  Suggestion: For performance-sensitive records, consider StrictData, selected strict fields with !, or explicit laziness where needed.
examples/FoldlThunk.hs:5:3
  [ThunkAccumulation/Heuristic] Possible thunk accumulation via lazy foldl.
  Suggestion: Use Data.List.foldl' for strict accumulation when the accumulator should be evaluated eagerly.
examples/LazyState.hs:3:8
  [LazyStateImport/Heuristic] Lazy State imported. Lazy state can accumulate thunks when state is repeatedly updated.
  Suggestion: Consider Control.Monad.State.Strict or Control.Monad.Trans.State.Strict for strict state accumulation.
```

At the moment, `ocelli` exits with a non-zero status when diagnostics are found.
This is intentional: later versions should be usable in CI pipelines.

## MVP diagnostics

### Lazy `foldl`

`foldl` is lazy in the accumulator and can build a chain of thunks when used for
accumulation.

Example:

```hs
total :: [Int] -> Int
total xs =
  foldl (+) 0 xs
```

Suggested alternative:

```hs
import Data.List (foldl')

total :: [Int] -> Int
total xs =
  foldl' (+) 0 xs
```

### Lazy record fields

Haskell record fields are lazy by default. In performance-sensitive code, this
can lead to unintended thunks or retention.

Example:

```hs
data Position = Position
  { accountId :: String
  , amount :: Int
  , metadata :: [(String, String)]
  }
```

Possible alternatives include:

```hs
{-# LANGUAGE StrictData #-}
```

or selected strict fields:

```hs
data Position = Position
  { accountId :: !String
  , amount :: !Int
  , metadata :: ![(String, String)]
  }
```

The right choice depends on the intended evaluation behavior.

### Lazy `State`

The lazy `State` monad can accumulate thunks when state is repeatedly updated.

Example:

```hs
import Control.Monad.State
```

Suggested alternative:

```hs
import Control.Monad.State.Strict
```

or:

```hs
import Control.Monad.Trans.State.Strict
```

## Diagnostic confidence

`ocelli` classifies diagnostics by confidence level.

Current confidence levels:

```hs
data Confidence
  = Heuristic
  | GHCInferred
  | RuntimeObserved
  | Proven
```

The current MVP emits only `Heuristic` diagnostics.

The long-term goal is to distinguish between:

- source-level heuristics;
- facts inferred from GHC demand/strictness analysis;
- runtime observations from profiling;
- properties that can be proven by stronger static analyses.

## Roadmap

Check [docs/ROADMAP.md](docs/ROADMAP.md) for more details.

## Research direction

`ocelli` is motivated by the idea that Haskell’s operational costs should be
more inspectable.

The broader research question is:

> How can static and profile-guided analysis make the operational behavior of
  lazy functional programs visible to programmers?

Possible research contributions include:

- a taxonomy of operational performance issues in lazy functional programs;
- a diagnostic framework for laziness, strictness, allocation, and retention;
- a prototype implementation for Haskell;
- an evaluation on small examples and selected open-source Haskell projects;
- a discussion of how GHC-derived evidence and runtime profiling evidence can be
  combined.

## Repository structure

```text
ocelli/
├── app/
│   └── Main.hs
├── docs/
│   └── ROADMAP.md
├── examples/
│   ├── Clean.hs
│   ├── FoldlThunk.hs
│   ├── LazyRecord.hs
│   └── LazyState.hs
├── src/
│   └── Ocelli/
│       ├── Rules/
│       │   ├── Foldl.hs
│       │   ├── LazyRecord.hs
│       │   └── LazyState.hs
│       ├── Check.hs
│       ├── Diagnostic.hs
│       ├── FileDiscovery.hs
│       └── Render.hs
├── .gitignore
├── CHANGELOG.md
├── LICENSE
├── ocelli.cabal
└── README.md
```

## License

[BSD-3-Clause](LICENSE).
