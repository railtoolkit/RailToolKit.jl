# RailToolKit.jl

[![License: ISC](https://img.shields.io/badge/license-ISC-green.svg)](https://opensource.org/licenses/ISC)
[![Build Status](https://github.com/kaat0/RailToolKit.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/kaat0/RailToolKit.jl/actions/workflows/CI.yml?query=branch%3Amain)

Thin **integration harness** for RailToolKit workflows: versioned use cases,
fixtures, and CI — not a shared domain-types package.

Re-exports APIs needed by active use cases (TrainRuns for UC-001)
```julia
using RailToolKit
```

## What this is

| Piece | Role |
|-------|------|
| [`usecases/`](usecases/) | Catalogue of integration workflows + fixtures + `test.jl` |
| `RailToolKit.jl` | Optional convenience re-exports; no domain logic |
| CI | Frontmatter gates + active use-case tests |

Contracts grow from active use cases. Do not introduce a `RailCore`-style abstract
type layer here — see [`railtoolkit.jl-concept.md`](railtoolkit.jl-concept.md)
and [`AGENTS.md`](AGENTS.md).


## License

[![Open Source Initiative Approved License logo](https://opensource.org/files/OSIApproved_100X125.png "Open Source Initiative Approved License logo")](https://opensource.org)

Copyright (c) 2026, Martin Scheidt (ISC License)

see LICENSE file
