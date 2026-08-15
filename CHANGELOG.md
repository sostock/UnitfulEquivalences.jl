# UnitfulEquivalences.jl changelog

## master

* ![Feature](https://img.shields.io/badge/-feature-green) The `SpectralDensity(at)` equivalence is added, which relates spectral flux densities per unit wavelength, per unit frequency, and per unit photon energy for a sample located at the spectral coordinate `at`.

## v0.2.0

* ![BREAKING](https://img.shields.io/badge/-BREAKING-red) `PhotonEnergy` is renamed to `Spectral`. ([#14](https://github.com/sostock/UnitfulEquivalences.jl/pull/14))
* ![Feature](https://img.shields.io/badge/-feature-green) The `Thermal()` equivalence is added. ([#13](https://github.com/sostock/UnitfulEquivalences.jl/pull/13))

## v0.1.1

* ![Enhancement](https://img.shields.io/badge/-enhancement-blue) Affine quantities are now converted to absolute quantities before calling `edconvert`, thereby eliminating the need to account for affine quantities when implementing new `edconvert` methods. ([#11](https://github.com/sostock/UnitfulEquivalences.jl/pull/11))

## v0.1.0

Initial release.
