# Contributing

RailToolKit.jl is an **integration harness**, not a domain library. The product is
the **use-case catalogue + CI**: versioned workflows under `usecases/`, assets,
catalogue validation, and optional re-exports of upstream APIs.

**The most valuable contributions are use cases** — propose new workflows, sharpen
draft intent, or bind and prove outcomes by moving cases to **`status: active`**.

Contracts grow from active use cases. Do not introduce a shared abstract type layer
(`RailCore`-style) or reimplement upstream algorithms here.

When contributing, please discuss substantial changes via issue or discussion first.
We have a [code of conduct](https://github.com/railtoolkit/RailToolKit.jl/blob/main/CODE_OF_CONDUCT.md); please follow it in all project
interactions.

## Authoritative sources

| Document | Role |
|----------|------|
| [`README.md`](https://github.com/railtoolkit/RailToolKit.jl/blob/main/README.md) | Harness overview and use-case lifecycle |
| [`AGENTS.md`](https://github.com/railtoolkit/RailToolKit.jl/blob/main/AGENTS.md) | Agent and contributor scope |
| [`usecases/template/TEMPLATE.md`](https://github.com/railtoolkit/RailToolKit.jl/blob/main/usecases/template/TEMPLATE.md) | Required use-case form |
| [`CHANGELOG.md`](https://github.com/railtoolkit/RailToolKit.jl/blob/main/CHANGELOG.md) | Template version history and migration rules |
| [`src/catalogue_io.jl`](https://github.com/railtoolkit/RailToolKit.jl/blob/main/src/catalogue_io.jl) | Shared `usecase.md` frontmatter I/O (catalogue tests + docs builder) |

## Add a use case

```sh
mkdir -p usecases/UC-00N-short-name/assets
cp usecases/template/TEMPLATE.md usecases/UC-00N-short-name/usecase.md
```

Fill frontmatter and sections. Start with **`status: draft`** when the workflow is
still implementation-agnostic. Add `assets/` and `test.jl` when binding a concrete
implementation. Set **`status: active`** only when CI can prove decidable **Expected
outcomes** (`OUT-n`).

Documentation pages for new cases are generated automatically from `usecase.md` at
the next docs build — no manual doc edits are required for the case landing page.

Then open a pull request against `main`.

## Improve an existing use case

| Stage | What helps |
|-------|------------|
| **Draft** | Clear Goal and Scope, concrete Artifacts, decidable `OUT-n`, resolved or tracked `Q-n` open questions, candidate `packages:` |
| **Draft → active** | Bind `packages:`, add regression assets, write `test.jl` for `TEST-n` / `OUT-n`, name APIs in the main scenario, bump `version` / `lineage` when the workflow changes |
| **Active** | Tighter regression constants, better assets and provenance, clearer verification, upstream fixes recorded in References instead of forks here |
| **Deprecated** | Set `status: deprecated`, record `superseded_by` / lineage, remove unused harness deps |

Harness rules worth repeating:

- Add Julia packages to root [`Project.toml`](https://github.com/railtoolkit/RailToolKit.jl/blob/main/Project.toml) only when an **active** use case lists them under `packages:`.
- Re-export upstream APIs in [`src/RailToolKit.jl`](https://github.com/railtoolkit/RailToolKit.jl/blob/main/src/RailToolKit.jl) only when active cases need them — do not wrap or hide inputs.
- Bump case **`version`** and record **`lineage`** when updating, splitting, or merging workflows.
- When the use-case template changes, add `usecases/template/versions/vN.md`, document in [`CHANGELOG.md`](https://github.com/railtoolkit/RailToolKit.jl/blob/main/CHANGELOG.md), and migrate all active cases in the same change set.

Run a single case locally:

```sh
julia --project=. -e 'include("usecases/UC-NNN-short-name/test.jl")'
```

Run the full harness:

```sh
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.test()'
```

## Contribution ideas

**Use cases (preferred)**

- Propose draft workflows: timetabling, capacity, RailML import/export, energy
  accounting, corridor comparisons, visualization, formation studies, …
- Activate draft cases once packages and assets can prove `OUT-n` in CI
- Split or merge cases when scope changes; use `lineage` and version bumps
- Improve assets, regression tests, and References (upstream links live in the case)

**Harness and docs**

- Catalogue validation, CI reliability, docs generation
- Clearer package landing pages driven from active-case metadata

**Out of scope here**

- Shared domain-type packages extracted “for the ecosystem”
- Reimplementing parsers, physics, or solvers that belong upstream
- Adding dependencies not required by active use cases

Package feature work (new models, APIs, schemas) belongs in the upstream packages
named by each case — link issues and PRs from the use case’s **References** section.

## Packages in the docs

The **Packages** section lists names from **`status: active`** use-case `packages:` only.
Draft and deprecated cases do not trigger package pages or the reverse index.

All package landing pages are **generated automatically** at docs build time — there is
no hand-maintained `docs/src/packages/` directory.

| Output | Source |
|--------|--------|
| `docs/src/generated/packages.md` | Reverse index (overview) |
| `docs/src/generated/packages/<Name>.md` | One landing page per active-case package |
| `docs/src/generated/packages.toml` | Machine-readable inventory |

Add upstream links and narrative in the active use case’s **References** section;
the generator does not maintain a separate package registry.

## Julia development environment

Link your local clone into Julia’s dev environment:

```console
ln -s ~/path/to/RailToolKit.jl ~/.julia/dev/RailToolKit
```

See [Julia package development](https://github.com/ShozenD/julia-pkg-dev). [Revise.jl](https://github.com/timholy/Revise.jl) speeds up iterative work:

```julia
using Pkg; Pkg.add("Revise")
```

Load the harness from your dev checkout:

```julia
julia> # use the ] key
pkg> activate ~/path/to/RailToolKit.jl
pkg> instantiate
julia> using RailToolKit
```

When working on an upstream package listed by an active case, `develop` that package
in the same environment rather than forking behaviour inside this repo.

## Reporting issues

- Search for an existing issue before opening a new one
- Include minimal reproduction steps and expected vs actual behaviour
- For harness bugs, note Julia version (`versioninfo()`), branch/commit, and which
  use case or catalogue check fails
- For workflow gaps, consider opening a **draft use case** PR instead of a feature
  request against the harness alone

## Style guidelines

- Julia code: [SciMLStyle](https://github.com/SciML/SciMLStyle)
- Documentation: [Diátaxis](https://diataxis.fr/) — tutorials, how-to, reference, explanation as appropriate

## Git recommendations for pull requests

- Work on a feature branch, not your fork’s `main`
- Open PRs against this repository’s `main` branch
- Run `Pkg.test()` locally before pushing; CI runs the full catalogue and every active case
- Prefer `git rebase` over merge commits when updating your branch with upstream `main`
- Use descriptive commit messages; `git add -p` helps avoid unrelated changes
- Mark work-in-progress PRs as **Draft** until ready for review
- When linking to code on GitHub, press `y` on a file view so line links include the commit SHA
- Avoid drive-by formatting outside the lines you are changing

## Add yourself as a contributor

To add yourself to the contributors list, follow the
[all-contributors bot usage instructions](https://allcontributors.org/docs/en/bot/usage).
