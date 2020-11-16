# Converting between equivalent quantities

This package extends the `uconvert` and `ustrip` functions from [Unitful.jl](https://github.com/PainterQubits/Unitful.jl) to accept an additional argument of type [`Equivalence`](@ref).
Supplying this argument allows converting between units of different dimensions that are linked by the specified equivalence, e.g., the mass--energy equivalence $$E=mc^2$$:
```@repl
using Unitful, UnitfulEquivalences
uconvert(u"keV", 1u"me", MassEnergy()) # electron rest mass is equivalent to ≈511 keV
ustrip(u"keV", 1u"me", MassEnergy())
```

The equivalences [`MassEnergy`](@ref) and [`PhotonEnergy`](@ref) are defined and exported by this package:
```@docs
MassEnergy
PhotonEnergy
```

### API

```@docs
Equivalence
UnitfulEquivalences.uconvert
UnitfulEquivalences.ustrip
```
