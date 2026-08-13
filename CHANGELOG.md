# Changelog

All notable changes to **RailToolKit.jl** (integration harness, CI, re-exports)
and the **use-case template** (Markdown contract under `usecases/template/`).

Package version follows [`Project.toml`](Project.toml) SemVer. **Use-case template
versions are independent** — a template bump means the documentation/test contract
for describing a workflow changed, not necessarily a package release.

While the harness is WIP, the template may be revised in place; migrate active
cases when you bump `template/versions/vN.md`.

---

## Package

### [1.0.0] — 2026-08-12

- Initial **thin integration harness**: versioned use cases, catalogue validation, CI
- Re-export TrainRuns public API for active cases
- **UC-001-running-time-minimal** — schema-valid YAML assets, regression test against reference running time
- **UC-002-block-section-pois** — labeled block-section POIs with front/rear measures; occupation time from meaningful labels
- `test/catalogue.jl` + `test/runtests.jl` — frontmatter gates and discovery of `status: active` cases

---

## Use-case template

### v1 — 2026-08-12 (current form)

Human + Julia reference form for RailToolKit integration cases. Inspired by
testability-oriented use-case writing (actors, scope, decidable outcomes, worked
examples) without import/quality machinery.

**Required frontmatter:** `id`, `version` (positive integer — workflow revision for
this `id`), `title`, `template_version`, `status`, `owner`,
`created`, `updated`, `packages`, `summary`.

Extra frontmatter keys are allowed (e.g. legacy `layers` on cases not yet
migrated). Do not add `layers` to new cases — the railway layer model is a
future use case, not a catalogue cross-cut.

**Required body sections:** Goal, Scope, Actors & systems, Preconditions, Main
scenario, Artifacts, Expected outcomes, Exceptions, Worked example, Verification,
Assumptions & limits, Reproducibility, Open questions, References.

**ID conventions (within a case):** `ACT-n`, `PRE-n`, `STEP-n`, `OUT-n`,
`EXC-n`, `EX-n`, `TEST-n`, `Q-n`.

**Active gates:** `status: active` requires `test.jl`, matching
`template_version`, no instructional HTML comments, and at least one decidable
`OUT-n` covered by verification (see case narrative + `test.jl`).

**Optional frontmatter:** `lineage` mapping:

- `supersedes: [UC-NNN@M, …]` — this version replaces those (update)
- `split_from: UC-NNN@M` — this case was split from that version
- `merged_from: [UC-NNN@M, …]` — this case merges those versions
- `superseded_by: UC-NNN@M` — replacement when `status: deprecated`

Refs use **`UC-NNN@M`** (`id@version`). CI enforces unique `(id, version)` pairs,
at most one **`status: active`** directory per `id`, and resolvable lineage refs.

#### Migration

*n/a — v1 is the current working form.*

---

## How to record changes (maintainers)

### Package release

1. Bump `version` in `Project.toml`.
2. Add a dated section under **Package** above (Added / Changed / Fixed / Removed).

### Use-case template bump

1. Edit [`usecases/template/TEMPLATE.md`](usecases/template/TEMPLATE.md), then copy it to `usecases/template/versions/vN.md`.
2. Document the change in this file under **Use-case template** (added / removed / renamed fields).
3. Migrate all `status: active` cases in the same change set.
