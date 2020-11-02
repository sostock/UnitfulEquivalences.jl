module UnitfulEquivalences

export @equivalence, @eqrelation, Equivalence, MassEnergy, Spectral

import Unitful
using Unitful: AbstractQuantity, Dimensions, Level, Quantity, Units, dimension, uconvert

"""
    Equivalence

Abstract supertype for all equivalences. By default, the equivalences [`MassEnergy`](@ref)
and [`Spectral`](@ref) are defined.
"""
abstract type Equivalence end

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

julia> uconvert(u"eV", 589u"nm", Spectral()) # photon energy of sodium D₂ line (≈589 nm)
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
existing equivalence `Name`. The dimensions `a` and `b` must be specified as quantity type
aliases like `Unitful.Energy`.

# Example

```@julia
struct Spectral <: Equivalence end
@eqrelation Spectral Unitful.Energy * Unitful.Length = u"h*c0"
```
Energy and wavelength of a photon are antiproportional, their product is ``hc``. Adding this
relation to the `Spectral` equivalence allows conversion between energies and wavelengths
via `uconvert(energyunit, wavelength, Spectral())` and
`uconvert(lengthunit, energy, Spectral())`.
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

using Unitful: Energy, Frequency, Length, Mass, c0, h

"""
    MassEnergy

Equivalence to convert between mass and energy according to the relation ``E = mc^2``, where
* ``E`` is the energy,
* ``m`` is the mass and
* ``c`` is the speed of light in vacuum.
"""
@equivalence MassEnergy
@eqrelation  MassEnergy Energy/Mass = c0^2

"""
    Spectral

Equivalence that relates the energy of a photon to its frequency and wavelength according to
the relation ``E = hf = hc/λ``, where
* ``E`` is the photon energy,
* ``f`` is the frequency,
* ``λ`` is the wavelength,
* ``h`` is the Planck constant and
* ``c`` is the speed of light in vacuum.

!!! Note
    The `Spectral` equivalence does not include the wavenumber. This is to avoid mistakes,
    since there are two competing definitions of wavenumber (``1/λ`` and ``2π/λ``).
"""
@equivalence Spectral
@eqrelation  Spectral Energy/Frequency = h
@eqrelation  Spectral Energy*Length    = h*c0
@eqrelation  Spectral Length*Frequency = c0

end # module UnitfulEquivalences
