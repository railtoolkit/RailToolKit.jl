# Contributing

RailToolKit.jl is an **integration harness**, not a domain library. Contracts
grow from active use cases — do not introduce a shared abstract type layer here.

Authoritative sources:

| Document | Role |
|----------|------|
| [`README.md`](https://github.com/railtoolkit/RailToolKit.jl/blob/main/README.md) | Harness overview and use-case lifecycle |
| [`AGENTS.md`](https://github.com/railtoolkit/RailToolKit.jl/blob/main/AGENTS.md) | Agent and contributor scope |
| [`usecases/template/TEMPLATE.md`](https://github.com/railtoolkit/RailToolKit.jl/blob/main/usecases/template/TEMPLATE.md) | Required use-case form |
| [`src/usecases_io.jl`](https://github.com/railtoolkit/RailToolKit.jl/blob/main/src/usecases_io.jl) | Shared `usecase.md` frontmatter I/O (catalogue tests + docs builder) |

## Add a use case

```sh
mkdir -p usecases/UC-00N-short-name/assets
cp usecases/template/TEMPLATE.md usecases/UC-00N-short-name/usecase.md
```

Fill frontmatter and sections; add `assets/` and `test.jl` when binding an
implementation. Set `status: active` only when CI can prove decidable outcomes.

Documentation pages for new cases are generated automatically from `usecase.md`
at the next docs build — no manual doc edits required for the case landing page.

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

Add upstream links and narrative in the active use case's **References** section;
the generator does not maintain a separate package registry.

Add a Julia package to root `Project.toml` only when an **active** use case needs it.
