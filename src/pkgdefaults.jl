using Unitful: @derived_dimension, Energy, Frequency, Length, Mass, Temperature, Wavenumber, c0, h, ħ, k, unit, ustrip, 𝐋, 𝐌, 𝐓

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
struct MassEnergy <: Equivalence end

const c² = Quantity(convert(Int64, ustrip(c0)), unit(c0))^2

@eqrelation MassEnergy Energy/Mass = c²

"""
    Spectral(; frequency=:linear, wavelength=:linear, wavenumber=:linear)

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
julia> uconvert(u"nm", 13.6u"eV", Spectral()) # photon wavelength needed to ionize hydrogen
91.16485178911785 nm

julia> uconvert(u"Hz", 589u"nm", Spectral(frequency=:angular)) # angular frequency of sodium D line
3.1980501991661345e15 Hz
```
"""
struct Spectral{freq, len, num} <: Equivalence
    function Spectral{freq, len, num}() where {freq, len, num}
        check_photonarg(freq, :frequency)
        check_photonarg(len, :wavelength)
        check_photonarg(num, :wavenumber)
        new()
    end
end

@inline check_photonarg(s::Symbol, arg::Symbol) =
    s === :linear || s === :angular || throw(ArgumentError("`$arg` argument must be :linear or :angular"))

Spectral(; frequency=:linear, wavelength=:linear, wavenumber=:linear) =
    Spectral{frequency, wavelength, wavenumber}()

Base.show(io::IO, e::Spectral{freq, len, num}) where {freq, len, num} =
    print(io, Spectral, "(frequency=", repr(freq), ", wavelength=", repr(len), ", wavenumber=", repr(num), ")")

@eqrelation Spectral{:linear}  Energy/Frequency = h
@eqrelation Spectral{:angular} Energy/Frequency = ħ

@eqrelation Spectral{F,:linear}  where F Energy*Length = h*c0
@eqrelation Spectral{F,:angular} where F Energy*Length = ħ*c0

@eqrelation Spectral{F,L,:linear}  where {F,L} Energy/Wavenumber = h*c0
@eqrelation Spectral{F,L,:angular} where {F,L} Energy/Wavenumber = ħ*c0

function edconvert(::dimtype(Frequency), x::Length, ::Spectral{F,L}) where {F,L}
    F === L       ? c0/x      :
    F === :linear ? c0/(π*2x) : 2c0*(π/x)
end
function edconvert(::dimtype(Length), x::Frequency, ::Spectral{F,L}) where {F,L}
    F === L       ? c0/x      :
    F === :linear ? c0/(π*2x) : 2c0*(π/x)
end

function edconvert(::dimtype(Frequency), x::Wavenumber, ::Spectral{F,L,N}) where {F,L,N}
    F === N       ? c0*x       :
    F === :linear ? c0/2*(x/π) : 2c0*(π*x)
end
function edconvert(::dimtype(Wavenumber), x::Frequency, ::Spectral{F,L,N}) where {F,L,N}
    F === N       ? x/c0       :
    F === :linear ? 2*(π*x)/c0 : (x/π)/2c0
end

function edconvert(::dimtype(Length), x::Wavenumber, ::Spectral{F,L,N}) where {F,L,N}
    L === N       ? inv(x)  :
    L === :linear ? 2*(π/x) : inv(2*(π*x))
end
function edconvert(::dimtype(Wavenumber), x::Length, ::Spectral{F,L,N}) where {F,L,N}
    L === N       ? inv(x)  :
    L === :linear ? 2*(π/x) : inv(2*(π*x))
end

# Flux density dimensions related by `SpectralDensity` (cf. astropy's spectral_density).
@derived_dimension FluxDensityPerWavelength 𝐌 * 𝐋^-1 * 𝐓^-3
@derived_dimension FluxDensityPerFrequency 𝐌 * 𝐓^-2
@derived_dimension FluxDensityPerEnergy 𝐋^-2 * 𝐓^-1

"""
    SpectralDensity(at)

Equivalence between the three spectral flux density conventions: per unit wavelength (``F_λ``, e.g., W m^-2 nm^-1), per unit frequency (``F_ν``, e.g., W m^-2 Hz^-1), and per unit photon energy (``F_E``, e.g., W m^-2 eV^-1). The three conventions describe the same energy flux distributed over equivalent spectral intervals, ``F_λ |dλ| = F_ν |dν| = F_E |dE|``, which gives ``F_ν = F_λ λ^2/c`` and ``F_E = F_ν/h``, where:

- ``λ`` is the wavelength,
- ``h`` is the Planck constant, and
- ``c`` is the speed of light in vacuum.

Unlike the other equivalences, `SpectralDensity` is parameterized by the location of the flux density sample: `at` is the spectral coordinate at which the density is evaluated, and may itself be given as a wavelength, frequency (``ν = c/λ``), or photon energy (``E = hν``).

# Example

```jldoctest
julia> F_λ = 1e-15u"W/m^2/nm";

julia> uconvert(u"W/m^2/Hz", F_λ, SpectralDensity(500u"nm")) ≈ F_λ * (500u"nm")^2 / Unitful.c0
true
```
"""
struct SpectralDensity{Q<:Union{Length, Frequency, Energy}} <: Equivalence
    at::Q
end

Base.show(io::IO, e::SpectralDensity) = print(io, SpectralDensity, "(", e.at, ")")

# The wavelength equivalent of the sample's spectral coordinate.
_at_wavelength(at::Length) = at
_at_wavelength(at::Frequency) = c0 / at
_at_wavelength(at::Energy) = h * c0 / at

edconvert(::dimtype(FluxDensityPerFrequency), x::FluxDensityPerWavelength, e::SpectralDensity) = x * _at_wavelength(e.at)^2 / c0
edconvert(::dimtype(FluxDensityPerWavelength), x::FluxDensityPerFrequency, e::SpectralDensity) = x * c0 / _at_wavelength(e.at)^2
edconvert(::dimtype(FluxDensityPerEnergy), x::FluxDensityPerFrequency, e::SpectralDensity) = x / h
edconvert(::dimtype(FluxDensityPerFrequency), x::FluxDensityPerEnergy, e::SpectralDensity) = x * h
edconvert(::dimtype(FluxDensityPerEnergy), x::FluxDensityPerWavelength, e::SpectralDensity) = x * _at_wavelength(e.at)^2 / (h * c0)
edconvert(::dimtype(FluxDensityPerWavelength), x::FluxDensityPerEnergy, e::SpectralDensity) = x * h * c0 / _at_wavelength(e.at)^2

"""
    Thermal()

Equivalence to convert between temperature and energy according to the relation ``E = kT``,
where
* ``E`` is the energy,
* ``T`` is the temperature and
* ``k`` is the Boltzmann constant.

# Example

```jldoctest
julia> uconvert(u"eV", 20u"°C", Thermal()) # room temperature is equivalent to ≈1/40 eV
0.025261712457978588 eV
```
"""
struct Thermal <: Equivalence end

@eqrelation Thermal Energy/Temperature = k
