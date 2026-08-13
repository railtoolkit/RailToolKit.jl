# AGENTS.md

Instructions for **coding agents** (and contributors) changing this repository.

For project overview, use-case lifecycle, and versioning, read [`README.md`](README.md) first. This file states **harness boundaries**, layout, and rules agents should follow when adding or changing use cases, tests, or dependencies.

This repository is an **integration harness**, not a domain library: versioned workflows under `usecases/`, assets, catalogue validation, CI, and optional re-exports. Do not add a shared-types layer (`RailCore`-style) or invent abstract domain APIs ahead of evidence from active cases.

## Mission

`RailToolKit.jl` is a **thin integration harness**, not a domain library.

1. **Collect use cases** — versioned Markdown under `usecases/` (issue-template style).
2. **Test interplay** — executable tests proving packages work together on real assets.
3. **Re-export what active cases need** — convenience `using RailToolKit` without owning upstream types or algorithms.

The product is the **use-case catalogue + CI**. Registry publication is optional.

The harness is **WIP** — rewrite use-case forms freely when improving cases; do not treat the template as a frozen public API.

Success: clone → `Pkg.instantiate()` → `Pkg.test()` → reproduce every **`status: active`** case from its versioned assets, without a shared core types package.

## What this is and is not

### Is

- A Julia project that depends on packages required by **active** use cases, may re-export their public APIs, runs integration tests keyed to `usecases/UC-*/test.jl`, and validates use-case Markdown frontmatter in CI.
- A **curated catalogue** of workflows that drive future interface decisions *from evidence*.

### Is not

- A home for shared abstract domain types or a `RailCore` package.
- An owner of upstream algorithms, physics, schemas, or data formats (those stay in the packages / contracts each case lists).
- A place to reimplement upstream parsers or solvers unless a case explicitly needs a thin test adapter.
- A big-bang architecture layer that invents APIs ahead of use cases.

**Rule:** Contracts grow *from* active use cases. Extract shared Julia types only when evidence from cases demands it — not prophylactically.

## Authoritative sources

| Document | Role |
|----------|------|
| [`README.md`](README.md) | Harness overview, **use-case lifecycle** (draft → active), versioning / lineage, how to add cases |
| [`usecases/template/TEMPLATE.md`](usecases/template/TEMPLATE.md) + [`versions/vN.md`](usecases/template/versions/) + [`CHANGELOG.md`](CHANGELOG.md) | Required fields; migration when the form changes |
| [`usecases/UC-*/usecase.md`](usecases/) | Per-case workflow narrative, artifacts, verification (`status: active` cases are CI gates) |
| Upstream packages + data contracts | As declared in each case's `packages:` frontmatter |

If sources conflict on *harness scope*, prefer this file. On *use-case form*, prefer `README.md` and the template. On *package behaviour*, prefer the upstream package and data contract named by the case.

## Do / don't

**Do**

- Start from an active or draft `UC-*`; keep intent clear, then stabilize the binding (`assets/` + `test.jl`)
- Depend inward on packages listed by **active** cases; pin compat in `Project.toml`
- List every result-affecting artifact in **Artifacts**; state decidable **Expected outcomes** (`OUT-n`)
- Use **Scope** (mandatory out-of-scope) and **Verification** (`TEST-n` + `test.jl` when active)
- Write Goal / main scenario in domain language; name concrete APIs only when binding for `status: active`
- Bump case **`version`** and record **`lineage`** when updating, splitting, or merging workflows
- Add `template/versions/vN.md` and migrate all active cases when you need a formal template break
- Read authoritative sources before adding files
- Prefer assets + tests over speculative package API surface

**Don't**

- Invent shared abstract types or a `RailCore` package
- Wrap upstream APIs in a parallel harness API that hides inputs
- Reimplement upstream parsing, physics, or solvers in this repo
- Add dependencies that no active use case lists under `packages:`
- Use `layers` frontmatter or layer-model as a catalogue cross-cut (model layers as their own use case)
- Mark `status: active` without a passing `test.jl` and matching `template_version`
- Vendor external schemas into Julia types unless required for a test helper
- Silently fork upstream behaviour — record gaps in Open questions / References or open upstream issues

## Layout

```text
Project.toml              # deps for active cases only
src/RailToolKit.jl        # re-exports only; no domain logic
test/
  catalogue.jl            # frontmatter vs latest template/versions/vN.md
  runtests.jl             # catalogue gates + active UC-*/test.jl
usecases/
  template/               # TEMPLATE.md, test.jl, versions/
  UC-NNN-short-name/
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
julia --project=. -e 'include("usecases/UC-NNN-short-name/test.jl")'
```

## Use-case conventions

Required sections and frontmatter: see the current [`TEMPLATE.md`](usecases/template/TEMPLATE.md)
and [`CHANGELOG.md`](CHANGELOG.md#use-case-template).

- **`status: draft`** — propose **implementation-agnostic** intent; CI validates structure only
- **`status: active`** — requires a concrete **implementation binding** (`packages:`, assets, APIs, `test.jl`), decidable `OUT-n`, matching `template_version`, passing CI
- **`version`** — workflow revision for the stable `id`; use **`lineage`** for update/split/merge (refs `UC-NNN@M`)
- **`related:`** / **`builds_on:`** — optional catalogue links (refs `UC-NNN@M`); navigation and binding order only — **not** CI gates; each active case stays self-contained
- `packages:` may be candidates while draft; only Julia calculate/import/… packages for **active** cases belong in `Project.toml`
- Active cases: no instructional HTML comments; `template_version` matches latest `template/versions/vN.md`
- Prefer regression constants in `test.jl` with an explicit tolerance; smoke-only only while `status: draft`
- ID prefixes: `ACT-n`, `PRE-n`, `STEP-n`, `A-n`, `OUT-n`, `EXC-n`, `EX-n`, `TEST-n`, `Q-n`

Full lifecycle and versioning: [`README.md`](README.md#use-case-lifecycle-draft--active).

## Harness policies

### Re-exports

- Re-export **only** symbols needed by documented active cases.
- Do not wrap upstream packages in a parallel API.

### Dependencies

- Depend **inward** on calculation / integration packages, never the reverse.
- Add a new `Project.toml` dependency only when an **active** use case lists it under `packages:`.

### CI gates

- CI fails if any `status: active` case has `template_version` ≠ latest `usecases/template/versions/vN.md`, or missing required frontmatter.
- CI fails if an active case lacks a runnable `test.jl`.
- CI fails on duplicate `(id, version)`, unresolved `lineage` refs, or multiple active directories for the same `id`.
- Template field changes: add `versions/vN.md`, document in [`CHANGELOG.md`](CHANGELOG.md), migrate all active cases in the **same** change set.

## Active case requirements

For every **`status: active`** case:

| Layer | Contract | Source of truth |
|-------|----------|-----------------|
| Data | Inputs listed in **Artifacts** | Data contracts / schemas named under `packages:` |
| Compute | Public APIs named in the main scenario | Upstream Julia packages under `packages:` |
| Integration | Assets + assertions + `usecase.md` | This harness |

Deliverables:

1. Filled `usecase.md` — set `status: active` only when tests pass in CI.
2. **Assets** under `assets/` — every result-affecting input, with provenance in Artifacts.
3. **`test.jl`** — exercises the documented workflow; prefer regression constants with explicit tolerance.
4. **Reproducibility** — pinned compat in `Project.toml` so CI is non-flaky.

Statelessness: every result-affecting input listed in Artifacts; tests do not mutate asset files or rely on hidden globals.

## Out of scope (harness)

- Shared abstract type package extracted “for the ecosystem”
- Implementing domain algorithms that belong upstream
- Reverse-engineering a full layer-model API from architecture docs ahead of cases
- Publishing to General registry as a blocker for landing use cases
- Silently redesigning or forking upstream package internals

Future workflows (timetabling, capacity, RailML, …) belong as **draft or active use cases**, not as harness APIs.

## Upstream gaps

If an upstream package or data contract blocks a case, record it in that case (Open questions / References) or open an upstream issue — do not fork behaviour silently here.

When tempted to add abstract types “for cleanliness,” refuse — record the need in the use case or an issue instead.

## Acceptance checklist

- [ ] No shared domain-type core package introduced
- [ ] Template process respected (`versions/` + root [`CHANGELOG.md`](CHANGELOG.md) / migration rule)
- [ ] Each active case documents its packages/contracts and lists all result-affecting inputs
- [ ] Versioned assets load and the documented workflow runs in automated tests
- [ ] Harness `Project.toml` depends only on packages required by active cases; optional re-exports only
- [ ] Active-case CI gates defined for template version, lineage/version uniqueness, and tests
- [ ] Out-of-scope items absent from the harness implementation
