---
# Required frontmatter (template v1). Rewrite in place while the harness is WIP.
# ID conventions in body: ACT-n, PRE-n, STEP-n, A-n, OUT-n, EXC-n, EX-n, TEST-n, Q-n
id: UC-NNN                     # stable id; matches directory prefix UC-NNN-short-name
title: ""                      # short human title
template_version: 1            # MUST match latest template/versions/vN.md when status is active
version: 1                     # workflow version for this id (integer); bump on material change
status: draft                  # draft | active | deprecated
owner: ""                      # GitHub handle or name
created: YYYY-MM-DD
updated: YYYY-MM-DD

# Optional lineage — refs use UC-NNN@M (id@version). Omit for first versions.
#lineage:
#  supersedes: []             # this version replaces those (update in place or new directory)
#  split_from: null          # parent version this case was split from (split)
#  merged_from: []           # source versions merged into this case (merge)
#  superseded_by: null       # replacement ref when status: deprecated

# Optional catalogue links — refs use UC-NNN@M. Navigation / planning only; NOT CI gates.
# Each active case remains self-contained (own assets/ + test.jl). Do not import another
# case's test or require another case to be active before activation.
#related: []                 # peer cases (shared assets, same tutorial source, …)
#builds_on: []               # intent dependency — read these first when binding; re-compute locally

# Packages: integration surface. Julia calculate/import/… roles → harness Project.toml when active.
# Non-Julia data contracts (e.g. railtoolkit/schema) use role: data and are not Pkg deps.
packages:
  - name: TrainRuns
    role: calculate            # calculate | data | import | optimize | visualize | other
  # - name: schema
  #   role: data
  # - name: OtherPkg
  #   role: ...

# One-line pitch for listings and CI summaries (prefer intent, not API names)
summary: ""
---

# <title from frontmatter>

<!-- Scaffold: mkdir assets/; copy TEMPLATE.md → usecase.md and template/test.jl
     (see README “Add a use case”). Set frontmatter; H1 = title field.
     Remove this comment block when status is active (CI enforces).
     Replace every > **Hint:** block with case content; remove hints you do not need.

     Draft vs active:
     - draft: domain language in Goal → Expected outcomes; packages may be candidates;
       stay draft until decidable OUT-n exist.
     - active: bind packages:, assets/, APIs, and test.jl; concrete asset paths; no HTML comments. -->

## Goal

> **Hint:** What result does this workflow produce, for whom? What decision or result
> should a reader trust afterward? What happens if this workflow does not exist or fails?
> Write in **domain / intent** language. Avoid tying the goal to a specific package or
> API name unless that *is* the requirement.

…

## Scope

**In scope:**

> **Hint:** What capability or workflow does this use case cover? Prefer outcomes and
> data needs over tool names.

…

**Out of scope:**

> **Hint:** What does this use case explicitly NOT cover? Mandatory — without it, no end
> condition is definable.

…

## Actors & systems

> **Hint:** Who or what sends data, runs code, or consumes results? Every actor referenced
> in the main scenario or verification must appear here. Prefer **roles** (planner,
> calculation service, data contract). Name concrete packages when binding for
> `status: active`.

| ID | Actor | Type | Role | What they need |
|----|-------|------|------|----------------|
| ACT-1 | … | person / system / package | … | … |

## Preconditions

> **Hint:** What must be true before this use case starts? Which artifacts must already
> exist? What event triggers the flow? Draft: domain terms. Active: may name concrete
> asset paths and deps.

| ID | Precondition |
|----|--------------|
| PRE-1 | … |

## Main scenario

> **Hint:** Numbered steps a human (or script) follows. One action per step:
> *Actor — Action — affected data*. **Draft:** describe *what* happens (load formation,
> compute run, read total time) without requiring a specific API. **Active:** name bound
> packages and entrypoints; include a minimal code sketch that matches `test.jl`.

| ID | Actor | Action | Data |
|----|-------|--------|------|
| STEP-1 | … | … | … |

```julia
# Hint (active): minimal sketch of the bound happy path (must match test.jl)
```

## Artifacts

> **Hint:** List every **result-affecting** input and output (data, settings, seeds,
> tolerances, reference files). Draft: describe formats and meaning (even if files do not
> exist yet). Active: concrete paths under `assets/` with provenance.

| ID | Direction | Artifact | Format / schema | Location | Notes |
|----|-----------|----------|-----------------|----------|-------|
| A-1 | input / output | … | e.g. rolling-stock YAML | `assets/…` | units, provenance |

## Expected outcomes

> **Hint:** What is true after this use case completes? This section determines whether
> the case is usable as a test. Prefer **decidable results** (values, tolerances,
> invariants) over “package X returned”. If no decidable `OUT-n` exists yet, set
> `status: draft`.

| ID | Result | Where you observe it | Pass criterion (decidable) |
|----|--------|----------------------|----------------------------|
| OUT-1 | … | e.g. total time, `test.jl` | concrete value or tolerance |

## Exceptions

> **Hint:** What can go wrong or deviate from the main scenario?

| ID | Trigger condition | Expected behaviour | Severity |
|----|-------------------|--------------------|----------|
| EXC-1 | … | … | error / warning / skip |

## Worked example

> **Hint:** At least one complete, realistic input→output pair with real values or asset
> paths. Non-negotiable for cases moving toward `status: active`.

**EX-1:** Given … → When … → Then …

## Verification

> **Hint:** Formulate tests. Each `TEST-n` should reference at least one `OUT-n`, `A-n`,
> or `EXC-n`. Use concrete values in Given and Then.

| ID | Given (input with values) | When | Then (expected result with values) | Verifies |
|----|---------------------------|------|-------------------------------------|----------|
| TEST-1 | … | … | … | OUT-1 |

**Implementation binding** (required for `status: active`; may shorten to script + command once binding is documented above):

- Concrete `packages:` in frontmatter (+ harness `Project.toml` for Julia deps)
- Versioned `assets/` for every result-affecting input
- Script: `test.jl` that proves the `OUT-n` / `TEST-n` checks
- Command: `julia --project=. -e 'include("usecases/UC-NNN-short-name/test.jl")'`

## Assumptions & limits

> **Hint:** Model assumptions, operating domain, and failure modes. Not a substitute for
> Scope **Out of scope**.

…

## Reproducibility

> **Hint:** Required in substance for `status: active` — document what pins results:

- Julia version / harness `Project.toml` compat bounds
- Package versions (or compat bounds)
- Asset pins and reference values (in assets or `test.jl`)
- OS / CI runner notes if relevant
- Random seeds / solver settings if they affect results

## Open questions

> **Hint:** List anything not yet decided — including *which* implementation to bind.
> Mark blocking items; agents must not silently invent answers.

| ID | Question | Status | Owner | Blocking |
|----|----------|--------|-------|----------|
| Q-1 | … | open / resolved | … | true / false |

## References

> **Hint:**
>
> - Domain / standards references (implementation-agnostic)
> - Upstream packages, schema docs, papers / DOIs (when bound)
> - Related use cases — see `related:` / `builds_on:` in frontmatter
> - Issues / ADRs
