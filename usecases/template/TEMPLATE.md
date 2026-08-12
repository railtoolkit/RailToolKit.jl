---
# Required frontmatter (template v1). Rewrite in place while the harness is WIP.
# ID conventions in body: ACT-n, PRE-n, STEP-n, OUT-n, EXC-n, EX-n, TEST-n, Q-n
id: UC-000                     # unique; matches directory UC-000-slug
title: ""                      # short human title
template_version: 1            # MUST match latest template/versions/vN.md when status is active
status: draft                  # draft | active | deprecated
owner: ""                      # GitHub handle or name
created: YYYY-MM-DD
updated: YYYY-MM-DD

# Packages exercised by this case (integration surface).
# Julia packages with calculate/import/… roles must be in the harness Project.toml.
# Non-Julia data contracts (e.g. railtoolkit/schema) use role: data and are not Pkg deps.
packages:
  - name: TrainRuns
    role: calculate            # calculate | data | import | optimize | visualize | other
  # - name: schema
  #   role: data
  # - name: OtherPkg
  #   role: ...

# One-line pitch for listings and CI summaries
summary: ""
---

# {{ title }}

<!-- Copy this file to usecases/UC-NNN-slug/usecase.md and replace placeholders.
     Do not leave instructional HTML comments in active cases. -->

## Goal

What result does this workflow produce, for whom?
What decision or result should a reader trust afterward?
What happens if this workflow does not exist or fails?

## Scope

**In scope:**

> What does this use case cover?

**Out of scope:**

> What does this use case explicitly NOT cover? Mandatory — without it, no end
> condition is definable.

## Actors & systems

Who or what sends data, runs code, or consumes results? Every actor referenced
in the main scenario or verification must appear here.

| ID | Actor | Type | Role | What they need |
|----|-------|------|------|----------------|
| ACT-1 | … | person / system / package | … | … |

## Preconditions

What must be true before this use case starts? Which artifacts must already
exist? What event triggers the flow?

| ID | Precondition |
|----|--------------|
| PRE-1 | … |

## Main scenario

Numbered steps a human (or script) follows. One action per step: *Actor — Action —
affected data*. Name packages and entrypoints explicitly.

| ID | Actor | Action | Data |
|----|-------|--------|------|
| STEP-1 | … | … | … |

```julia
# Minimal sketch of the happy path (optional but preferred)
```

## Artifacts

Inputs **and** outputs: data, settings, seeds, tolerances, reference files.
List every **result-affecting** artifact.

| ID | Direction | Artifact | Format / schema | Location | Notes |
|----|-----------|----------|-----------------|----------|-------|
| … | input / output | … | e.g. rolling-stock YAML | `assets/…` | units, provenance |

## Expected outcomes

What is true after this use case completes? This section determines whether the
case is usable as a test.

| ID | Result | Where you observe it | Pass criterion (decidable) |
|----|--------|----------------------|----------------------------|
| OUT-1 | … | e.g. `test.jl`, column `:t` | concrete value or tolerance |

If no decidable `OUT-n` exists yet, set `status: draft`.

## Exceptions

What can go wrong or deviate from the main scenario?

| ID | Trigger condition | Expected behaviour | Severity |
|----|-------------------|--------------------|----------|
| EXC-1 | … | … | error / warning / skip |

## Worked example

At least one complete, realistic input→output pair with real values or asset
paths. Non-negotiable for cases moving toward `status: active`.

**EX-1:** Given … → When … → Then …

## Verification

Formulate tests. Each `TEST-n` should reference at least one `OUT-n`, artifact,
or exception. Use concrete values in Given and Then.

| ID | Given (input with values) | When | Then (expected result with values) | Verifies |
|----|---------------------------|------|-------------------------------------|----------|
| TEST-1 | … | … | … | OUT-1 |

**Julia test hook** (required for `status: active`):

- Script: `test.jl`
- Command: `julia --project=. -e 'include("usecases/UC-NNN-slug/test.jl")'`

## Assumptions & limits

Model assumptions, operating domain, known non-goals, and failure modes.
Do not use this section as a substitute for Scope.

## Reproducibility

- Julia version / harness `Project.toml` compat bounds
- Package versions (or compat bounds)
- Asset pins and reference files
- OS / CI runner notes if relevant
- Random seeds / solver settings if they affect results

## Open questions

List anything not yet decided. Mark blocking items; agents must not silently
invent answers.

| ID | Question | Status | Owner | Blocking |
|----|----------|--------|-------|----------|
| Q-1 | … | open / resolved | … | true / false |

## References

- Upstream packages, schema docs, papers / DOIs
- Related use cases (`UC-…`)
- Issues / ADRs
