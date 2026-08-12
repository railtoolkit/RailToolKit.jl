#!/usr/bin/env julia
# -*- coding: UTF-8 -*-
# __author__        = "Martin Scheidt"
# __copyright__     = "2026"
# __license__       = "ISC"

"""
    RailToolKit

Thin integration harness for RailToolKit use cases.

This package does **not** own domain types or algorithms. It re-exports the
public APIs needed by *active* use cases under `usecases/` so tutorial-style
scripts can `using RailToolKit`. Calculation ownership stays upstream
(TrainRuns.jl for UC-001).
"""
module RailToolKit

using Reexport
@reexport using TrainRuns

end
