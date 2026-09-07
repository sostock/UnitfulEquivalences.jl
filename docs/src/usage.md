# Converting between equivalent quantities

This package extends the `uconvert` and `ustrip` functions from [Unitful.jl](https://github.com/PainterQubits/Unitful.jl) to accept an additional argument of type [`Equivalence`](@ref).
Supplying this argument allows converting between units of different dimensions that are linked by the specified equivalence, e.g., the mass--energy equivalence $$E=mc^2$$:
```@repl
using Unitful, UnitfulEquivalences
uconvert(u"keV", 1u"me", MassEnergy()) # electron rest mass is equivalent to ≈511 keV
ustrip(u"keV", 1u"me", MassEnergy())
```

To simplify conversion, a partially applied method of `uconvert` can be used: `uconvert(unit, equivalence)` returns a function that converts to  `unit` via the specified `equivalence`.
Since units itself are callable (`unit(x)` is equivalent to `uconvert(unit, x)`), this enables a convenient syntax for conversion:
```@repl
using Unitful, UnitfulEquivalences # hide
1u"me" |> uconvert(u"keV", MassEnergy())
1u"me" |> u"keV"(MassEnergy())
```

The equivalences [`MassEnergy`](@ref), [`Spectral`](@ref), [`SpectralDensity`](@ref), and [`Thermal`](@ref) are defined and exported by this package:
```@docs
MassEnergy
Spectral
SpectralDensity
Thermal
```

### API

```@docs
Equivalence
UnitfulEquivalences.uconvert
UnitfulEquivalences.ustrip
```
