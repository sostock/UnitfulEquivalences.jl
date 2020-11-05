using Unitful: Energy, Frequency, Length, Mass, Wavenumber, c0, h, ħ, unit, ustrip

"""
    MassEnergy()

Equivalence to convert between mass and energy according to the relation ``E = mc^2``, where
* ``E`` is the energy,
* ``m`` is the mass and
* ``c`` is the speed of light in vacuum.

# Example

```jldoctest
julia> uconvert(u"keV", 1u"me", MassEnergy()) # electron rest mass is equivalent to ≈511 keV
510.9989499961642 keV
```
"""
@equivalence MassEnergy

const c² = Quantity(convert(Int64, ustrip(c0)), unit(c0))^2

@eqrelation MassEnergy Energy/Mass = c²

"""
    PhotonEnergy(; frequency=:linear, wavelength=:linear, wavenumber=:linear)

Equivalence that relates the energy of a photon to its (linear or angular) frequency,
wavelength, and wavenumber. Whether to convert to linear or angular quantities is
determined by optional keyword arguments, `:linear` is the default for all quantities.

Equivalent quantities are converted according to the relations
``E = hf = ħω = hc/λ = ħc/ƛ = hcν̃ = ħck``, where
* ``E`` is the photon energy,
* ``f`` is the (temporal) frequency (`frequency=:linear`),
* ``ω`` is the angular frequency (`frequency=:angular`),
* ``λ`` is the wavelength (`wavelength=:linear`),
* ``ƛ`` is the angular (also called reduced) wavelength (`wavelength=:angular`),
* ``ν̃`` is the spectroscopic wavenumber (`wavenumber=:linear`),
* ``k`` is the angular wavenumber (`wavelength=:angular`),
* ``h`` is the Planck constant,
* ``ħ`` is the reduced Planck constant and
* ``c`` is the speed of light in vacuum.

# Examples

```jldoctest
julia> uconvert(u"nm", 13.6u"eV", PhotonEnergy()) # photon wavelength needed to ionize hydrogen
91.16485178911785 nm

julia> uconvert(u"Hz", 589u"nm", PhotonEnergy(frequency=:angular)) # angular frequency of sodium D line
3.1980501991661345e15 Hz
```
"""
struct PhotonEnergy{freq, len, num} <: Equivalence
    function PhotonEnergy{freq, len, num}() where {freq, len, num}
        check_photonarg(freq)
        check_photonarg(len)
        check_photonarg(num)
        new()
    end
end

@inline check_photonarg(s::Symbol) =
    s === :linear || s === :angular || throw(ArgumentError("PhotonEnergy parameter must be :linear or :angular"))

PhotonEnergy(; frequency=:linear, wavelength=:linear, wavenumber=:linear) =
    PhotonEnergy{frequency, wavelength, wavenumber}()

Base.show(io::IO, e::PhotonEnergy{freq, len, num}) where {freq, len, num} =
    print(io, PhotonEnergy, "(frequency=", repr(freq), ", wavelength=", repr(len), ", wavenumber=", repr(num), ")")

@eqrelation PhotonEnergy{:linear}  Energy/Frequency = h
@eqrelation PhotonEnergy{:angular} Energy/Frequency = ħ

@eqrelation PhotonEnergy{F,:linear}  where F Energy*Length = h*c0
@eqrelation PhotonEnergy{F,:angular} where F Energy*Length = ħ*c0

@eqrelation PhotonEnergy{F,L,:linear}  where {F,L} Energy/Wavenumber = h*c0
@eqrelation PhotonEnergy{F,L,:angular} where {F,L} Energy/Wavenumber = ħ*c0

function edconvert(::dimtype(Frequency), x::Length, ::PhotonEnergy{F,L}) where {F,L}
    F === L       ? c0/x      :
    F === :linear ? c0/(π*2x) : 2c0*(π/x)
end
function edconvert(::dimtype(Length), x::Frequency, ::PhotonEnergy{F,L}) where {F,L}
    F === L       ? c0/x      :
    F === :linear ? c0/(π*2x) : 2c0*(π/x)
end

function edconvert(::dimtype(Frequency), x::Wavenumber, ::PhotonEnergy{F,L,N}) where {F,L,N}
    F === N       ? c0*x       :
    F === :linear ? c0/2*(x/π) : 2c0*(π*x)
end
function edconvert(::dimtype(Wavenumber), x::Frequency, ::PhotonEnergy{F,L,N}) where {F,L,N}
    F === N       ? x/c0       :
    F === :linear ? 2*(π*x)/c0 : (x/π)/2c0
end

function edconvert(::dimtype(Length), x::Wavenumber, ::PhotonEnergy{F,L,N}) where {F,L,N}
    L === N       ? inv(x)  :
    L === :linear ? 2*(π/x) : inv(2*(π*x))
end
function edconvert(::dimtype(Wavenumber), x::Length, ::PhotonEnergy{F,L,N}) where {F,L,N}
    L === N       ? inv(x)  :
    L === :linear ? 2*(π/x) : inv(2*(π*x))
end
