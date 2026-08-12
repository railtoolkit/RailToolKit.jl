# AGENTS.md

Instructions for coding agents (and contributors) working in this repository.

**Audience:** LLM agents implementing or extending `RailToolKit.jl` for humans and julia.  
**Scope:** Thin integration harness — use cases, assets, CI, optional re-exports.  
**Non-goal:** A classical shared-types package (`RailCore.jl` was rejected). Do not invent abstract domain APIs “for the ecosystem” in this harness.

## Mission

`RailToolKit.jl` is a **thin integration harness**, not a domain library.

1. **Collect use cases** — versioned Markdown under `usecases/` (issue-template style).
2. **Test interplay** — executable tests proving packages work together on real assets.
3. **Re-export what active cases need** — convenience `using RailToolKit` without owning upstream types or algorithms.

The product is the **use-case catalogue + CI**. Registry publication is optional.

The harness is **WIP** — rewrite use-case forms freely when improving cases; do not treat the template as a frozen public API.

**First concrete target:** `UC-001-running-time-minimal` — TrainRuns running-time workflow on schema-valid YAML, gated by tests.

Success: clone → `Pkg.instantiate()` → `Pkg.test()` → reproduce UC-001 from versioned assets without a shared core types package.

## What this is and is not

### Is

- A Julia project that depends on packages required by **active** use cases, may re-export their public APIs, runs integration tests keyed to `usecases/UC-*/test.jl`, and validates use-case Markdown frontmatter in CI.
- A **curated catalogue** of workflows that drive future interface decisions *from evidence*.

### Is not

- A home for shared abstract types (`RailVehicle`, `Formation`, `RunningPath`, `SimulatedRun`, …) or a `RailCore` package.
- An owner of TrainRuns algorithms, physics, or schema definitions (those stay upstream).
- A place to reimplement rolling-stock / path parsing unless a case explicitly needs a thin test adapter.
- A big-bang layer-model implementation (`shortest_path`, interlocking, timetabling, …).

**Rule:** Contracts grow *from* active use cases. Extract shared Julia types only when evidence from cases demands it — not in this phase.

## Authoritative sources

| Document | Role |
|----------|------|
| [`README.md`](README.md) | Harness overview, **use-case lifecycle** (draft → active), how to add cases |
| [`usecases/template/TEMPLATE.md`](usecases/template/TEMPLATE.md) + [`versions/vN.md`](usecases/template/versions/) + [`CHANGELOG.md`](CHANGELOG.md) | Required fields; migration when the form changes |
| [`usecases/UC-001-running-time-minimal/usecase.md`](usecases/UC-001-running-time-minimal/usecase.md) | First active case (early draft body — migrate when touched) |
| TrainRuns.jl + RailToolKit `schema` | Public API and data contracts for UC-001 |

If sources conflict on *scope*, prefer this file. On *use-case form*, prefer `README.md` and the template. On *TrainRuns behaviour*, prefer TrainRuns + schema.

## Do / don't

**Do**

- Start from an active or draft `UC-*` and stabilize assets + `test.jl`
- Depend inward on calculation packages (TrainRuns for UC-001); pin compat in `Project.toml`
- List every result-affecting artifact in **Artifacts**; state decidable **Expected outcomes** (`OUT-n`)
- Use **Scope** (mandatory out-of-scope) and **Verification** (`TEST-n` + `test.jl`)
- Add `template/versions/vN.md` and migrate all active cases when you need a formal template break
- Read authoritative sources before adding files
- Prefer assets + tests over speculative package API surface

**Don't**

- Invent shared abstract types or a `RailCore` package
- Wrap TrainRuns in a parallel API (`RailToolKit.trainrun` that hides inputs)
- Reimplement schema parsing or TrainRuns physics in this repo
- Add dependencies that no active use case lists under `packages:`
- Use `layers` frontmatter or layer-model as a catalogue cross-cut (model layers as their own use case)
- Mark `status: active` without a passing `test.jl` and matching `template_version`
- Vendor schema JSON into Julia types unless required for a test helper
- Silently fork upstream behaviour — record gaps in Open questions / References or open upstream issues

## Layout

```text
Project.toml              # deps for active cases only
src/RailToolKit.jl        # re-exports only; no domain logic
test/
  catalogue.jl            # frontmatter vs latest template/versions/vN.md
  runtests.jl             # catalogue gates + active UC-*/test.jl
usecases/
  template/               # TEMPLATE.md, versions/
  UC-NNN-slug/
    usecase.md
    assets/
    test.jl
```

Keep `usecases/` at repo root; case-local `test.jl` and assets stay colocated with `usecase.md`.

## Commands

```sh
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. -e 'using Pkg; Pkg.test()'
```

Single case:

```sh
julia --project=. -e 'include("usecases/UC-001-running-time-minimal/test.jl")'
```

## Use-case conventions (template v1)

Required sections: Goal, Scope, Actors & systems, Preconditions, Main scenario,
Artifacts, Expected outcomes, Exceptions, Worked example, Verification,
Assumptions & limits, Reproducibility, Open questions, References.

- **`status: draft`** — propose workflow before packages or tests exist; CI validates structure only
- **`status: active`** — requires `test.jl`, decidable `OUT-n`, matching `template_version`, passing CI
- `packages:` may include non-Julia data contracts (`schema`, `role: data`); only Julia calculate/import/… packages belong in `Project.toml`
- Active cases: no instructional HTML comments; `template_version` matches latest `template/versions/vN.md`
- Prefer regression against `assets/reference.*` with an explicit tolerance; smoke-only only while `status: draft`
- ID prefixes: `ACT-n`, `PRE-n`, `STEP-n`, `OUT-n`, `EXC-n`, `EX-n`, `TEST-n`, `Q-n`

Full lifecycle: [`README.md`](README.md#use-case-lifecycle-draft--active).

`UC-001-running-time-minimal` still uses an early draft body; migrate it when touched — do not copy its section names for new cases.

## Harness policies

### Re-exports

- Re-export **only** symbols needed by documented active cases (UC-001: TrainRuns public API).
- Do not wrap TrainRuns in a parallel API.

### Dependencies

- Depend **inward** on calculation packages, never the reverse.
- Add a new `Project.toml` dependency only when an **active** use case lists it under `packages:`.

### CI gates

- CI fails if any `status: active` case has `template_version` ≠ latest `usecases/template/versions/vN.md`, or missing required frontmatter.
- CI fails if an active case lacks a runnable `test.jl`.
- Template field changes: add `versions/vN.md`, document in [`CHANGELOG.md`](CHANGELOG.md), migrate all active cases in the **same** change set.

## UC-001 requirements

Workflow surface (not a new RailCore package):

| Layer | Contract | Source of truth |
|-------|----------|-----------------|
| Data | Rolling-stock YAML + running-path YAML | RailToolKit/schema |
| Compute | `Train` / `Path` + `trainrun(train, path)` | TrainRuns.jl |
| Integration | Assets + assertions + `usecase.md` | This harness |

Naming guidance (do not force renames in TrainRuns): formation ≈ `Train`; running path ≈ `Path`; simulated run ≈ `trainrun` result.

Deliverables:

1. Filled `usecase.md` — set `status: active` only when tests pass in CI.
2. **Assets** under `assets/` — schema-valid YAML with provenance in Artifacts.
3. **`test.jl`** — load via TrainRuns, run `trainrun`, assert finite positive time; prefer regression against `assets/reference.*` within explicit tolerance.
4. **Reproducibility** — pinned compat in `Project.toml` so CI is non-flaky.

Statelessness: every result-affecting input listed in Artifacts; tests do not mutate asset files or rely on hidden globals.

## Out of scope (phase 1)

- Shared abstract type package or extracting `Formation` / `RunningPath` / `SimulatedRun` into RailToolKit
- TimetableOpt, InfraModel, capacity, energy integration cases (beyond listing future IDs)
- RailML import/export, OSM fetchers, Python bridges
- Reverse layer-model design from architecture docs
- Publishing to General registry as a blocker for UC-001
- Redesigning TrainRuns internals

## Upstream gaps

If TrainRuns or schema behaviour blocks a case, record it in the use case (Open questions / References) or open an upstream issue — do not fork behaviour silently.

When tempted to add abstract types “for cleanliness,” refuse — record the need in the use case or an issue instead.

## Acceptance checklist (phase 1)

- [ ] No shared domain-type core package introduced
- [ ] Template v1 process respected (`versions/` + root [`CHANGELOG.md`](CHANGELOG.md) / migration rule)
- [ ] UC-001 documents TrainRuns + schema contracts and lists all result-affecting inputs
- [ ] Versioned assets load and `trainrun` runs in automated tests
- [ ] Harness `Project.toml` depends on TrainRuns; optional re-exports only
- [ ] Active-case CI gates defined for template version + tests
- [ ] Out-of-scope items absent from the implementation
