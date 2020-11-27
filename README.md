# UnitfulEquivalences

[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/U/UnitfulEquivalences.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html)
![CI](https://github.com/sostock/UnitfulEquivalences.jl/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/sostock/UnitfulEquivalences.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/sostock/UnitfulEquivalences.jl)

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://sostock.github.io/UnitfulEquivalences.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://sostock.github.io/UnitfulEquivalences.jl/dev)

This package extends the [Unitful.jl](https://github.com/PainterQubits/Unitful.jl) package to enable conversion between quantities of different dimensions, related by an equivalence (e.g., conversion between mass and energy using the mass–energy equivalence *E* = *mc*²).
For its usage, see the [documentation](https://sostock.github.io/UnitfulEquivalences.jl/stable).

## Installation

This package is compatible with Julia ≥ 1.0 and Unitful ≥ 1.0. It can be installed by typing
```
] add UnitfulEquivalences
```
in the Julia REPL.

## Example usage

```julia
julia> using Unitful, UnitfulEquivalences

julia> uconvert(u"keV", 1u"me", MassEnergy()) # electron rest mass equals ≈511 keV
510.9989499961642 keV
```
