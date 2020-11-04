using Unitful: Energy, Frequency, Length, Mass, Wavenumber, c0, h, ħ

"""
    MassEnergy()

Equivalence to convert between mass and energy according to the relation ``E = mc^2``, where
* ``E`` is the energy,
* ``m`` is the mass and
* ``c`` is the speed of light in vacuum.
"""
@equivalence MassEnergy
@eqrelation  MassEnergy Energy/Mass = c0^2

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
    s == :linear || s == :angular || throw(ArgumentError("PhotonEnergy parameter must be :linear or :angular"))

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

@eqrelation PhotonEnergy                   Frequency*Length = c0
@eqrelation PhotonEnergy{:linear,:angular} Frequency*Length = c0/2π
@eqrelation PhotonEnergy{:angular,:linear} Frequency*Length = c0*2π

@eqrelation PhotonEnergy                             Frequency/Wavenumber = c0
@eqrelation PhotonEnergy{:linear,L,:angular} where L Frequency/Wavenumber = c0/2π
@eqrelation PhotonEnergy{:angular,L,:linear} where L Frequency/Wavenumber = c0*2π

@eqrelation PhotonEnergy                             Length*Wavenumber = 1
@eqrelation PhotonEnergy{F,:linear,:angular} where F Length*Wavenumber = 2π
@eqrelation PhotonEnergy{F,:angular,:linear} where F Length*Wavenumber = inv(2π)
