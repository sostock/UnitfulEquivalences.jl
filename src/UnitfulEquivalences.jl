module UnitfulEquivalences

export @equivalence, @eqrelation, Equivalence, MassEnergy, PhotonEnergy

import Unitful
using Unitful: AbstractQuantity, Dimensions, Level, Quantity, Units, dimension, uconvert

"""
    Equivalence

Abstract supertype for all equivalences. By default, the equivalences [`MassEnergy`](@ref)
and [`PhotonEnergy`](@ref) are defined.
"""
abstract type Equivalence end

Base.broadcastable(x::Equivalence) = Ref(x)

"""
    @equivalence Name

Shorthand for `struct Name <: Equivalence end` to simplify the definition of equivalences.
"""
macro equivalence(name)
    quote
        Base.@__doc__ struct $(esc(name)) <: Equivalence end
    end
end

"""
    edconvert(d::Dimensions, x::AbstractQuantity, e::Equivalence)

Convert `x` to the equivalent dimension `d` using the equivalence `e`. (not exported)

# Example

```jldoctest
julia> edconvert(dimension(u"J"), 1u"kg", MassEnergy()) # E = m*c^2
89875517873681764 kg m^2 s^-2
```
"""
edconvert(d::Dimensions, x::AbstractQuantity, e::Equivalence) =
    throw(ArgumentError("$e defines no equivalence between dimensions $(dimension(x)) and $d."))

"""
    uconvert(a::Units, x::Quantity, e::Equivalence)

Convert `x` to the units `a` (of different dimensions) by using the specified equivalence.

# Examples

```jldoctest
julia> uconvert(u"keV", 1u"me", MassEnergy()) # electron rest mass is equivalent to ≈511 keV
510.9989499961642 keV

julia> uconvert(u"eV", 589u"nm", PhotonEnergy()) # photon energy of sodium D₂ line (≈589 nm)
2.104994880020378 eV
```
"""
Unitful.uconvert(u::Units, x::AbstractQuantity, e::Equivalence) =
    uconvert(u, edconvert(dimension(u), x, e))

"""
    dimtype(x)

For a quantity type alias as created by `Unitful.@dimension` or `Unitful.@derived_dimension`
(e.g., `Unitful.Energy`), return its `Dimensions` type. (not exported)

# Example

```jldoctest
julia> dimtype(Unitful.Length)
Unitful.Dimensions{(Unitful.Dimension{:Length}(1//1),)}
```
"""
dimtype(::Type{Union{Quantity{T,D,U}, Level{L,S,Quantity{T,D,U}} where {L,S}} where {T,U}}) where D = typeof(D)

"""
    @eqrelation Name a/b = c
    @eqrelation Name a*b = c

Add a proportional or antiproportional relation between dimensions `a` and `b` to an
existing equivalence type `Name <: Equivalence`. The dimensions `a` and `b` must be
specified as quantity type aliases like `Unitful.Energy`.

# Example

```@julia
struct PhotonEnergy <: Equivalence end
@eqrelation PhotonEnergy Unitful.Energy * Unitful.Length = u"h*c0"
```
Energy and wavelength of a photon are antiproportional, their product is ``hc``. Adding this
relation to the `PhotonEnergy` equivalence allows conversion between energies and wavelengths
via `uconvert(energyunit, wavelength, PhotonEnergy())` and
`uconvert(lengthunit, energy, PhotonEnergy())`.
"""
macro eqrelation(name, relation)
    relation isa Expr && relation.head == :(=) || _eqrelation_error()
    lhs, rhs = relation.args
    lhs isa Expr && lhs.head == :call && length(lhs.args) == 3 || _eqrelation_error()
    op, a, b = lhs.args
    if op == :/
        quote
            UnitfulEquivalences.edconvert(::dimtype($(esc(a))), x::$(esc(b)), ::$(esc(name))) = x * $(esc(rhs))
            UnitfulEquivalences.edconvert(::dimtype($(esc(b))), x::$(esc(a)), ::$(esc(name))) = x / $(esc(rhs))
            nothing
        end
    elseif op == :*
        quote
            UnitfulEquivalences.edconvert(::dimtype($(esc(a))), x::$(esc(b)), ::$(esc(name))) = $(esc(rhs)) / x
            UnitfulEquivalences.edconvert(::dimtype($(esc(b))), x::$(esc(a)), ::$(esc(name))) = $(esc(rhs)) / x
            nothing
        end
    else
        _eqrelation_error()
    end
end

_eqrelation_error() = error("second macro argument must be an (anti-)proportionality relation " *
                            "`a/b = c` or `a*b = c`, cf. the documentation for `@equivalence` " *
                            "or `@eqrelation`.")

include("pkgdefaults.jl")

end # module UnitfulEquivalences
