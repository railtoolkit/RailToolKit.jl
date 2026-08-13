# RailToolKit.jl

Thin **integration harness** for RailToolKit workflows: a versioned catalogue of
use cases, assets, and CI — not a shared domain-types package.

The documentation site is the **use-case catalogue**. Each workflow under
[`usecases/`](https://github.com/railtoolkit/RailToolKit.jl/tree/main/usecases)
has a landing page generated from its `usecase.md`. Active cases are proven in CI
via per-case `test.jl` scripts.

## Quick start

```julia
julia> using Pkg; Pkg.activate("."); Pkg.instantiate()
julia> using Pkg; Pkg.test()
```

## What to read next

| Page | Contents |
|------|----------|
| [Catalogue](generated/catalogue_table.md) | All use cases (draft, active, deprecated) |
| [Packages](generated/packages.md) | Integration surfaces from **active** cases |
| [Harness API](api.md) | Re-exported upstream APIs |
| [Contributing](contributing.md) | Scope, lifecycle, and conventions |

## Re-exports

The [RailToolKit](api.md) module re-exports upstream APIs needed by **active** use cases.
Catalogue packages are broader than harness deps — see [Packages](generated/packages.md)
(only packages named by **active** use cases appear there). See [Harness API](api.md) for the module surface.
