# Defining new equivalences

Each equivalence must be of a type that is a subtype of `Equivalence`.
To define a new equivalence, one creates a new such type and extends the [`UnitfulEquivalences.edconvert`](@ref) function to enable conversion between the desired dimensions.

As an example, let us implement our own version of the `MassEnergy()` equivalence.
```julia 
struct MyMassEnergy <: Equivalence end
```
For this equivalence, a singleton struct is sufficient.
In general, `Equivalence` types may also have fields and/or type parameters.
To enable our `MassEnergy` type to convert between `Unitful.Mass` (of dimension `𝐌`) and `Unitful.Energy` (of dimension `𝐋^2*𝐌*𝐓^-2`), we need to define two `edconvert` methods (one for the mass-to-energy and one for the energy-to-mass conversion).
The `edconvert` function converts a quantity (its second argument) to an equivalent quantity of the dimension specified by its first argument (the `ed` in `edconvert` stands for “equivalent dimension”).
The third argument is the `MyMassEnergy` equivalence.
```julia
using Unitful: 𝐋, 𝐌, 𝐓, Energy, Mass, c0

UnitfulEquivalence.edconvert(::typeof(𝐋^2*𝐌*𝐓^-2), x::Mass, ::MyMassEnergy) = x * c0^2
UnitfulEquivalence.edconvert(::typeof(𝐌), x::Energy, ::MyMassEnergy) = x / c0^2
```
!!! warning
    This particular example implementation does not work correctly on 32-bit systems, since `c0` is based on an `Int` and `c0^2` therefore overflows on these systems ($$299792458^2 > 2^{31}-1$$).

!!! info
    When defining `edconvert` methods for `DimensionlessQuantity` arguments, the equivalence will also work with plain numbers (like `Float64`s or `Int`s), even though those are not subtypes of `DimensionlessQuantity`.
    Furthermore, `uconvert` and `ustrip` convert affine quantities (like `°C`) to absolute quantities before calling `edconvert`, so `edconvert` only needs to work on `ScalarQuantity`s.

After defining the two `edconvert` methods, `MyMassEnergy()` can be used to convert between mass and energy:
```@meta
DocTestSetup = quote
    using Unitful, UnitfulEquivalences
    struct MyMassEnergy <: Equivalence end
    @eqrelation MyMassEnergy Unitful.Energy/Unitful.Mass = Unitful.c0^2
end
```
```jldoctest
julia> uconvert(u"J", 1u"kg", MyMassEnergy())
89875517873681764 J
```
```@meta
DocTestSetup = :(using Unitful, UnitfulEquivalences)
```

An equivalence can have an arbitrary number of `edconvert` methods defined for it.
For example, the `Spectral` equivalence can convert between energy, frequency, wavelength, and wavenumber.
For each pair of these quantities, there is one pair of `edconvert` methods defined that handles the conversion between them.

### Convenience functions

The definition of the `edconvert` methods above could be simplified in two ways:
* The [`UnitfulEquivalences.dimtype`](@ref) function extracts the `Dimensions` type from a quantity type like `Unitful.Length`.
  It can be used to simplify the declaration of the first `edconvert` argument:
  ```julia
  using Unitful: Energy, Mass, c0
  using UnitfulEquivalences: dimtype
  
  UnitfulEquivalence.edconvert(::dimtype(Energy), x::Mass, ::MyMassEnergy) = x * c0^2
  UnitfulEquivalence.edconvert(::dimtype(Mass), x::Energy, ::MyMassEnergy) = x / c0^2
  ```

* In many cases, including this one, equivalences are simple proportional or antiproportional relations where the quotient or the product of the two equivalent quantities is a constant value (like a physical constant).
  In these cases, the [`@eqrelation`](@ref) macro can be used to define both `edconvert` methods at once.
  In the case of the `MyMassEnergy` equivalence, it would be used as follows:
  ```julia
  using Unitful: Energy, Mass, c0
  
  @eqrelation MyMassEnergy Energy/Mass = c0^2
  ```
  This defines the two `edconvert` methods as shown above.

### API

```@docs
UnitfulEquivalences.dimtype
UnitfulEquivalences.edconvert
UnitfulEquivalences.@eqrelation
```
