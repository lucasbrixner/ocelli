# Revision history for ocelli

## 0.1.0.0 -- 2026-05-08

Initial MVP.

### Added

- Created the `ocelli` CLI.
- Added `check <path>` command for scanning Haskell source files.
- Added source-level heuristic diagnostics for:
  - lazy `foldl` usage;
  - lazy record fields;
  - lazy `State` imports.
- Added example files demonstrating current diagnostics.
- Added initial README, roadmap, and project metadata.
