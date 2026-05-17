# Contributing to `ocelli`

This document defines the working conventions for `ocelli`. It is written to be
followed by both human contributors and coding agents. The rules are concrete on
purpose: an agent should be able to act on them without further interpretation.

`ocelli` follows three published conventions:

- [Conventional Branch](https://conventional-branch.github.io/) for branch names.
- [Conventional Commits](https://www.conventionalcommits.org/) for commit message
  structure.
- [gitmoji](https://gitmoji.dev/) for the leading emoji on commit messages.

This file follows its own conventions: changes to it are `docs`-type commits on a
`chore/` branch (see below).

## Project conventions at a glance

- Work happens on **branches**, one per roadmap phase/sub-phase or one focused
  fix/chore.
- Every change reaches `main` through a **pull request**, even for solo work.
- PRs are **squash-merged**: `main` gets one clean commit per merged unit.
- `main` history is **append-only** — never force-push or rewrite it.
- Progress is tracked by checking boxes in `docs/ROADMAP.md`.

## Toolchain

The expected development setup:

```text
GHC:           9.6.7   (and more recent releases supported by HLS)
cabal-install: 3.14.x
HLS:           2.14.x
Cabal spec:    3.8     (kept at 3.8 for HLS compatibility)
```

Standard commands:

```bash
cabal build                            # build; must be clean under -Wall
cabal check                            # package metadata check; must be clean
cabal test                             # run the test suite (once Phase 3 lands)
cabal run ocelli -- check examples/    # run the tool against the examples
```

## Branching

Branch off the latest `main`. One branch per roadmap phase/sub-phase, or one
focused fix or chore.

Branch names follow [Conventional Branch](https://conventional-branch.github.io/):
the form is `<type>/<description>`, lowercase alphanumerics and hyphens only, no
leading/trailing/consecutive hyphens, no underscores or spaces.

Branch types used in this project (all from the Conventional Branch spec — no
custom types):

- `feature/` — new features and roadmap-phase work.
- `fix/` — bug fixes.
- `hotfix/` — urgent fixes.
- `chore/` — non-code tasks: dependencies, docs, metadata, tooling, housekeeping.
- `release/` — release-preparation branches.

### Roadmap phases use `feature/` with the phase number in the description

The Conventional Branch spec allows a ticket-style identifier inside the
description. Roadmap phases use that slot for the phase number, so the branch
name still says which phase it is while staying fully spec-compliant:

```text
feature/phase-1-ghc-lib-parse
feature/phase-2-json-output
feature/phase-3-golden-tests
feature/phase-4a-hls-diagnostics
feature/phase-4b-hls-hover
feature/phase-4c-hls-code-actions
```

Non-phase work uses a plain description:

```text
fix/lazyrecord-qualified-names
chore/dependency-bounds
chore/roadmap-restructure
```

Keep one branch focused on one unit of work. If a branch starts sprawling across
unrelated concerns, split it.

## Branch type, commit type, and gitmoji

The three conventions do **not** map one-to-one, and treating them as if they did
is the most common mistake. Two facts make the relationship clear:

1. **A branch type matches its *primary* commit — not all of its commits.** A
   branch is a container; its type describes the overall intent of the work. The
   individual commits inside it will have *several* types. A `feature/` branch
   for a roadmap phase will contain `test`, `refactor`, `docs`, and `build`
   commits alongside the `feat` commits that are the point of the branch.
2. **Some mismatches are deliberate.** There is no `docs` or `test` *branch*
   type — documentation-only or test-only work goes on a `chore/` branch while
   still using `docs:` / `test:` *commits*. And `hotfix/` has no matching commit
   type; its commits are just `fix:`. Seeing "I'm writing a `docs:` commit" is
   **not** a signal to create a `docs/` branch — that branch type does not exist.

### Reference

Branch type → commit types it hosts → gitmoji commonly used for each. The gitmoji
column lists common choices, not an exhaustive set; pick the gitmoji that best
describes the specific change (full list at [gitmoji.dev](https://gitmoji.dev/)).
The **primary** commit type for each branch — the one whose type the branch name
takes — is marked.

| Branch type | Commit type         | gitmoji (common)             | Use for                               |
| ----------- | ------------------- | ---------------------------- | ------------------------------------- |
| `feature/`  | `feat` *(primary)*  | 🎉 `:tada:`                  | the project's very first commit       |
| `feature/`  | `feat` *(primary)*  | ✨ `:sparkles:`              | a new feature                         |
| `feature/`  | `feat` *(primary)*  | 🏷️ `:label:`                 | add or update types                   |
| `feature/`  | `test`              | ✅ `:white_check_mark:`      | add, update, or pass tests            |
| `feature/`  | `test`              | 🧪 `:test_tube:`             | add a deliberately failing test       |
| `feature/`  | `refactor`          | ♻️ `:recycle:`               | refactor with no behavior change      |
| `feature/`  | `refactor`          | 🏗️ `:building_construction:` | architectural change                  |
| `feature/`  | `perf`              | ⚡️ `:zap:`                   | improve performance                   |
| `feature/`  | `docs`              | 📝 `:memo:`                  | add or update documentation           |
| `feature/`  | `docs`              | 💡 `:bulb:`                  | add or update code comments           |
| `feature/`  | `build`             | ➕ `:heavy_plus_sign:`       | add a dependency                      |
| `feature/`  | `build`             | ⬆️ `:arrow_up:`              | upgrade dependencies                  |
| `feature/`  | `build`             | 📌 `:pushpin:`               | pin a dependency to a version         |
| `feature/`  | `chore`             | 🔧 `:wrench:`                | add or update configuration           |
| `fix/`      | `fix` *(primary)*   | 🐛 `:bug:`                   | fix a bug                             |
| `fix/`      | `fix` *(primary)*   | 🩹 `:adhesive_bandage:`      | minor, non-critical fix               |
| `fix/`      | `fix` *(primary)*   | 🚨 `:rotating_light:`        | fix compiler / linter warnings        |
| `fix/`      | `fix` *(primary)*   | 🥅 `:goal_net:`              | catch errors                          |
| `fix/`      | `test`              | ✅ `:white_check_mark:`      | add the regression test for the fix   |
| `fix/`      | `refactor`          | ♻️ `:recycle:`               | refactor done as part of the fix      |
| `fix/`      | `docs`              | 📝 `:memo:`                  | document the fix                      |
| `hotfix/`   | `fix` *(primary)*   | 🚑️ `:ambulance:`             | critical hotfix                       |
| `hotfix/`   | `fix` *(primary)*   | 🐛 `:bug:`                   | the bug being urgently fixed          |
| `hotfix/`   | `ci`                | 💚 `:green_heart:`           | fix a broken CI build                 |
| `chore/`    | `chore` *(primary)* | 🔧 `:wrench:`                | configuration                         |
| `chore/`    | `chore` *(primary)* | 🔥 `:fire:`                  | remove code or files                  |
| `chore/`    | `chore` *(primary)* | 🙈 `:see_no_evil:`           | update `.gitignore`                   |
| `chore/`    | `chore` *(primary)* | ⚰️ `:coffin:`                | remove dead code                      |
| `chore/`    | `chore` *(primary)* | 🗑️ `:wastebasket:`           | deprecate code to be cleaned up later |
| `chore/`    | `docs`              | 📝 `:memo:`                  | add or update documentation           |
| `chore/`    | `docs`              | ✏️ `:pencil2:`               | fix typos                             |
| `chore/`    | `docs`              | 📄 `:page_facing_up:`        | add or update the license             |
| `chore/`    | `build`             | ⬆️ `:arrow_up:`              | upgrade dependencies                  |
| `chore/`    | `build`             | ⬇️ `:arrow_down:`            | downgrade dependencies                |
| `chore/`    | `build`             | ➕ `:heavy_plus_sign:`       | add a dependency                      |
| `chore/`    | `build`             | ➖ `:heavy_minus_sign:`      | remove a dependency                   |
| `chore/`    | `build`             | 📌 `:pushpin:`               | pin a dependency to a version         |
| `chore/`    | `ci`                | 👷 `:construction_worker:`   | add or update CI                      |
| `chore/`    | `ci`                | 💚 `:green_heart:`           | fix a broken CI build                 |
| `chore/`    | `test`              | ✅ `:white_check_mark:`      | test-only maintenance                 |
| `release/`  | `chore` *(primary)* | 🔖 `:bookmark:`              | release / version tag                 |
| `release/`  | `docs`              | 📝 `:memo:`                  | update the changelog for the release  |

## Commits

Commit messages combine [gitmoji](https://gitmoji.dev/) and
[Conventional Commits](https://www.conventionalcommits.org/). The form is:

```text
<emoji> <type>: <short imperative summary>

<optional body: what and why, not how>
```

- `<emoji>` is a gitmoji, written as the **unicode character** (`✨`), not the
  shortcode (`:sparkles:`), so it renders everywhere including `git log`. The
  shortcode is given in the reference table only for lookup.
- `<type>` is a Conventional Commits type: `feat`, `fix`, `docs`, `chore`,
  `test`, `refactor`, `perf`, `build`, `ci`. Use the table above to pick the
  type and gitmoji for the change.
- The summary is imperative mood ("add", not "added"), no trailing period,
  ideally under ~70 characters.

### Examples

```text
✨ feat: parse modules with ghc-lib-parse instead of line scanning
🐛 fix: handle qualified foldl' in the Foldl rule
♻️ refactor: make rule functions pure over the parsed AST
✅ test: add golden cases for the LazyRecord rule
📝 docs: restructure roadmap around parser-first plan
📌 build: pin ghc-lib-parse to a single release series
🚨 fix: silence -Wall warnings in Ocelli.Parse
```

### Commit hygiene

- **One concern per commit.** A roadmap restructure and a code change are two
  commits, even on the same branch. Documentation that accompanies a feature can
  ride with it; unrelated documentation changes do not.
- Commits on a feature branch may be messy while work is in progress — the
  squash-merge produces the clean final commit. But prefer reasonably scoped
  commits anyway; they make review easier.
- Do not commit build artifacts, editor files, or local agent configuration.
  `.gitignore` already covers `dist-newstyle/`, `.stack-work/`, `.ghc.environment.*`,
  `.codex/`, `.claude/`, `.gemini/`, `.cursor/`, `.agents/`, and similar.
- Commit author should be a real human name and email. When a coding agent
  produces the work, the commit is authored by the human running the agent, with
  the agent credited via a `Co-authored-by:` trailer. This keeps a human
  accountable for every commit while still recording the agent's contribution
  honestly.

## Pull requests

Every change reaches `main` via a PR — including solo work. The PR is the review
surface and the record of why a change was made.

A PR should:

- Target `main`.
- Correspond to one roadmap phase/sub-phase, or one focused fix/chore.
- Have a title in the same `<emoji> <type>: <summary>` form as a commit.
- In the description, link the roadmap phase it advances (if any) and copy the
  relevant **acceptance criteria** as a checklist, so the PR can be checked
  against them.
- Be opened only when `cabal build` is clean under `-Wall` and, once the test
  suite exists, `cabal test` passes.

### Acceptance criteria gate

A PR implementing a roadmap phase is not ready to merge until every acceptance
criterion for that phase (or sub-phase) is satisfied. The PR description's
checklist and the `docs/ROADMAP.md` checkboxes should agree.

## Merging

- PRs are **squash-merged** into `main`. This collapses a branch's history into a
  single, coherent commit. Enable "Allow squash merging" in the repository
  settings and prefer it as the default merge button.
- The squash commit message uses the `<emoji> <type>: <summary>` form and a body
  summarizing the change.
- Delete the branch after merge.
- Do not merge a PR whose acceptance criteria are unmet.

## History rules

- **Never rewrite `main`.** No force-push, no rebase that changes already-pushed
  `main` history. The repository is public; others may have cloned it.
- **Rewriting an unmerged feature branch is fine.** Rebasing, squashing, or
  amending your own branch before it is merged is encouraged if it produces a
  cleaner result.
- Keep `main` always building. A commit on `main` that does not build is a bug to
  fix immediately.

## Updating the roadmap

`docs/ROADMAP.md` is the source of truth for progress.

- Check a task box `[x]` only when it is implemented.
- Check an acceptance-criteria box `[x]` only when that criterion is verified.
- A phase is "done" only when every box under it — tasks and acceptance criteria —
  is checked.
- Roadmap checkbox updates normally land in the same PR as the work they reflect.
  A pure roadmap restructure (changing the plan itself, not ticking boxes) is its
  own `chore/` PR with `docs`-type commits.

## Working as a coding agent

If you are an agent picking up work, first determine what kind of work it is.

**For roadmap-phase work:**

1. Read `docs/ROADMAP.md` and identify the lowest-numbered phase with unchecked
   boxes. Work phases in order unless told otherwise.
2. Resolve that phase's "design decisions to lock first" before writing code, and
   record the decisions where the roadmap says to.
3. Create a branch named `feature/phase-<N>-<description>` (see Branching).
4. Implement the tasks, checking roadmap boxes as criteria are met.

**For a fix or chore not tied to the roadmap:**

1. Create a branch named `fix/<description>` or `chore/<description>` as
   appropriate (see Branching).
2. Scope it to that one concern; do not fold in unrelated changes.

**In all cases:**

- Keep commits scoped by concern, each message in `<emoji> <type>: <summary>`
  form, using the reference table to pick type and gitmoji.
- Before opening the PR: `cabal build` clean under `-Wall`, `cabal check` clean,
  `cabal test` passing (once it exists).
- Open a PR targeting `main`. For roadmap work, include the acceptance criteria
  as a checklist.
- Do not self-merge until every acceptance criterion (for roadmap work) is
  genuinely met, or the fix/chore is complete and verified.
- Never force-push `main`. Never commit secrets, build artifacts, or local
  agent/editor config.
