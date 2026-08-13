# RailToolKit.jl

[![License: ISC](https://img.shields.io/badge/license-ISC-green.svg)](https://opensource.org/licenses/ISC)
[![Build Status](https://github.com/railtoolkit/RailToolKit.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/railtoolkit/RailToolKit.jl/actions/workflows/CI.yml?query=branch%3Amain)

Thin **integration harness** for RailToolKit workflows: versioned use cases,
assets, and CI — not a shared domain-types package.

Re-exports APIs needed by active use cases (TrainRuns for UC-001):

```julia
using RailToolKit
```

## What this is

| Piece | Role |
|-------|------|
| [`usecases/`](usecases/) | Catalogue of integration workflows + assets + per-case `test.jl` |
| `RailToolKit.jl` | Optional convenience re-exports; no domain logic |
| [`test/catalogue.jl`](test/catalogue.jl) | Frontmatter and section validation |
| [`test/runtests.jl`](test/runtests.jl) | Catalogue gates + discovery of active `UC-*/test.jl` |
| CI | `Pkg.test()` runs catalogue checks and every **`status: active`** case |

Contracts grow from active use cases. Do not introduce a `RailCore`-style abstract
type layer here — see [`AGENTS.md`](AGENTS.md) for agent scope and conventions.

## Use-case lifecycle (draft → active)

Use cases are meant to be **proposed first** and **tested later**, after upstream
packages, schemas, or assets exist. The same `UC-NNN-short-name/` directory carries
the workflow from proposal through integration.

```text
propose (draft)  →  work in parallel  →  integrate & test (active)
     │                    │                        │
 usecase.md          build pkgs,            assets/ + test.jl
 narrative only      resolve Q-n,           Project.toml dep
                     fill Artifacts          status: active → CI
```

| `status` | Catalogue in CI | `test.jl` | Runs in CI | Harness `Project.toml` |
|----------|-----------------|-----------|------------|-------------------------|
| **draft** | yes (structure) | optional | no | not required yet |
| **active** | yes (strict) | required | yes | required for listed Julia pkgs |
| **deprecated** | yes | — | no | remove when unused |

**Draft** — land the contract before code exists:

- Copy [`usecases/template/TEMPLATE.md`](usecases/template/TEMPLATE.md) to
  `usecases/UC-NNN-short-name/usecase.md` with **`status: draft`**
- Fill Goal, Scope, Main scenario, Artifacts, and **Open questions** (`Q-n`) —
  e.g. blocking until a package is published
- List intended integration surface under **`packages:`** (future deps are fine)
- If no decidable **Expected outcomes** (`OUT-n`) exist yet, stay draft

**In between** — months of other work are normal: packages ship elsewhere,
schemas settle, assets are collected. The draft case stays the stable target.

**Active** — when the workflow is runnable and checkable:

1. Add **`assets/`** (inputs); put regression expected values in **`test.jl`**
2. Write **`test.jl`** implementing **Verification** (`TEST-n` / `OUT-n`)
3. Add Julia **`packages:`** to root **`Project.toml`**
4. Set **`status: active`**, update **`updated`**, remove template HTML comments
5. CI discovers and runs the case automatically — nothing is hardcoded

You can run `test.jl` locally before activation; CI ignores it until **`status: active`**.

### Use-case versions (update, split, merge)

Each case has a stable **`id`** (`UC-001`, …) and a workflow **`version`**
(integer). Reference a specific revision as **`UC-001@2`**. Optional **`lineage`**
in frontmatter records how versions relate:

| Change | What to do | `lineage` |
|--------|------------|-----------|
| **Update** | Bump `version` in the same or a new directory; deprecate the old one | `supersedes: [UC-001@1]` |
| **Split** | New ids (e.g. `UC-003`, `UC-004`) from one parent | `split_from: UC-001@2` |
| **Merge** | New id combining workflows | `merged_from: [UC-001@1, UC-002@1]` |
| **Retire** | Set `status: deprecated` | `superseded_by: UC-001@2` |

CI allows at most **one `status: active` directory per `id`**. Each `(id, version)`
pair must be unique across the catalogue. Lineage refs must point at existing
cases when declared.

## What a use case contains

Each `usecase.md` follows [`usecases/template/TEMPLATE.md`](usecases/template/TEMPLATE.md):

- **Human narrative:** Goal, Scope, Actors, Preconditions, Main scenario
- **Artifacts:** inputs and outputs with schema, paths, provenance
- **Testability:** Expected outcomes (`OUT-n`), Exceptions, Worked example, Verification (`TEST-n` + `test.jl`)
- **Context:** Assumptions, Reproducibility, Open questions, References

ID prefixes within a case: `ACT-n`, `PRE-n`, `STEP-n`, `OUT-n`, `EXC-n`, `EX-n`, `TEST-n`, `Q-n`.

Layout: one directory per case — `usecases/UC-<nnn>-<short-name>/` with `usecase.md`,
`assets/`, and (when active) `test.jl`. Keep cases under **`usecases/`**, not under
`src/` or `test/`.

Rules:

1. Declare **`template_version: 1`** (see [`CHANGELOG.md`](CHANGELOG.md#use-case-template)).
2. **`status: active`** requires decidable outcomes, `test.jl`, and passing CI.
3. Do not use a `layers` frontmatter field — model layers as their own use case.
4. Non-Julia data contracts (e.g. `schema`) use `role: data` in `packages:` and are not Pkg deps.

### Add a use case

```sh
mkdir -p usecases/UC-00N-short-name/assets
cp usecases/template/TEMPLATE.md usecases/UC-00N-short-name/usecase.md
# edit frontmatter + sections; add assets/ and test.jl when ready for active
```

Then open a PR. Template snapshots: [`usecases/template/versions/v1.md`](usecases/template/versions/v1.md).

## Quick start

```julia
julia> using Pkg; Pkg.activate("."); Pkg.instantiate()
julia> using Pkg; Pkg.test()
```

First active case: [`usecases/UC-001-running-time-minimal/`](usecases/UC-001-running-time-minimal/).
POI / block sections: [`usecases/UC-002-block-section-pois/`](usecases/UC-002-block-section-pois/).

Single case:

```sh
julia --project=. -e 'include("usecases/UC-001-running-time-minimal/test.jl")'
```

## Dependencies (active cases)

* [TrainRuns.jl](https://github.com/railtoolkit/TrainRuns.jl) — running-time calculation (UC-001)
* Data contracts: [railtoolkit/schema](https://github.com/railtoolkit/schema) (validated by TrainRuns on load)

## License

[![Open Source Initiative Approved License logo](https://opensource.org/files/OSIApproved_100X125.png "Open Source Initiative Approved License logo")](https://opensource.org)

Copyright (c) 2026, Martin Scheidt (ISC License)

see LICENSE file
