# UnitfulEquivalences

[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/U/UnitfulEquivalences.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html)
[![Build Status](https://travis-ci.com/sostock/UnitfulEquivalences.jl.svg?branch=main)](https://travis-ci.com/sostock/UnitfulEquivalences.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/vkfjf3j2w1r3m22v/branch/main?svg=true)](https://ci.appveyor.com/project/sostock/unitfulequivalences-jl/branch/main)
[![codecov](https://codecov.io/gh/sostock/UnitfulEquivalences.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/sostock/UnitfulEquivalences.jl)
[![Coverage Status](https://coveralls.io/repos/github/sostock/UnitfulEquivalences.jl/badge.svg?branch=main)](https://coveralls.io/github/sostock/UnitfulEquivalences.jl?branch=main)

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
