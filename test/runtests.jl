using Unitful
using UnitfulEquivalences
using Test

struct Equiv1 <: Equivalence end
UnitfulEquivalences.edconvert(::typeof(dimension(u"m")), x::Unitful.Time,   ::Equiv1) = x * 10u"m/s"
UnitfulEquivalences.edconvert(::typeof(dimension(u"s")), x::Unitful.Length, ::Equiv1) = x * (1//10)u"s/m"
UnitfulEquivalences.edconvert(::typeof(dimension(u"g")), x::Unitful.Temperature, ::Equiv1) = x * 2u"g/K"
UnitfulEquivalences.edconvert(::typeof(dimension(u"K")), x::Unitful.Mass,        ::Equiv1) = x / 2u"g/K"
UnitfulEquivalences.edconvert(::typeof(NoDims),          x::Unitful.Energy,        ::Equiv1) = x / u"eV"
UnitfulEquivalences.edconvert(::typeof(dimension(u"J")), x::DimensionlessQuantity, ::Equiv1) = x * u"eV"

struct Equiv2 <: Equivalence end
UnitfulEquivalences.edconvert(::typeof(dimension(u"m")), x::Unitful.Time,   ::Equiv2) = ustrip(u"s", x)^3 * u"m"
UnitfulEquivalences.edconvert(::typeof(dimension(u"s")), x::Unitful.Length, ::Equiv2) = cbrt(ustrip(u"m", x)) * u"s"

struct Equiv3 <: Equivalence; val::Int; end
UnitfulEquivalences.edconvert(::typeof(dimension(u"J")),   x::Unitful.Area,   e::Equiv3) = e.val*u"J" / ustrip(u"m^2", x)
UnitfulEquivalences.edconvert(::typeof(dimension(u"m^2")), x::Unitful.Energy, e::Equiv3) = e.val*u"m^2" / ustrip(u"J", x)

struct NoEquiv end
UnitfulEquivalences.edconvert(::typeof(dimension(u"m")), x::Unitful.Time,   ::NoEquiv) = x * 10u"m/s"
UnitfulEquivalences.edconvert(::typeof(dimension(u"s")), x::Unitful.Length, ::NoEquiv) = x * (1//10)u"s/m"

@testset "Conversion" begin
    # Equiv1
    @test uconvert(u"ms", 1u"inch", Equiv1()) === (254//100)u"ms"
    @test uconvert(u"km", 1.0u"d", Equiv1()) === 864.0u"km"
    @test uconvert(u"kg", 10u"K", Equiv1()) === (1//50)u"kg"
    @test uconvert(u"K", 10u"kg", Equiv1()) === 5000.0u"K"
    @test uconvert(u"kg", (10//1)u"°C", Equiv1()) === (5663//10_000)u"kg"
    @test uconvert(u"°C", 10u"kg", Equiv1()) === 4726.85u"°C"
    @test uconvert(u"eV", 10u"mm/m", Equiv1()) === (1//100)u"eV"
    @test uconvert(u"eV", Equiv1())(10u"mm/m") === (1//100)u"eV"
    @test u"eV"(Equiv1())(10u"mm/m") === (1//100)u"eV"
    @test uconvert(u"eV", 10, Equiv1()) === 10u"eV"
    @test uconvert(u"eV", Equiv1())(10) === 10u"eV"
    @test u"eV"(Equiv1())(10) === 10u"eV"
    @test uconvert(NoUnits, 10u"eV", Equiv1()) === 10
    @test ustrip(u"ms", 1u"inch", Equiv1()) === (254//100)
    @test ustrip(u"km", 1.0u"d", Equiv1()) === 864.0
    @test ustrip(u"kg", 10u"K", Equiv1()) === 1//50
    @test ustrip(u"K", 10u"kg", Equiv1()) === 5000.0
    @test ustrip(u"kg", (10//1)u"°C", Equiv1()) === (5663//10_000)
    @test ustrip(u"°C", 10u"kg", Equiv1()) === 4726.85
    @test ustrip(u"eV", 10u"mm/m", Equiv1()) === 1//100
    @test ustrip(u"eV", 10, Equiv1()) === 10
    @test ustrip(NoUnits, 10u"eV", Equiv1()) === 10
    @test ustrip(Float64, u"ms", 1u"inch", Equiv1()) === 2.54
    @test ustrip(Rational{Int}, u"km", 1.0u"d", Equiv1()) === 864//1
    @test ustrip(Float32, u"kg", 10u"K", Equiv1()) === 0.02f0
    @test ustrip(Int, u"K", 10u"kg", Equiv1()) === 5000
    @test ustrip(Float32, u"kg", (10//1)u"°C", Equiv1()) === 0.5663f0
    @test ustrip(Float16, u"°C", 10u"kg", Equiv1()) === Float16(4726.85)
    @test ustrip(Float64, u"eV", 10, Equiv1()) === 10.0
    @test_throws ArgumentError uconvert(u"s", 10u"s", Equiv1())
    @test_throws ArgumentError uconvert(u"kg", 1u"s", Equiv1())
    @test_throws ArgumentError uconvert(u"m", 1, Equiv1())
    @test_throws MethodError   uconvert(u"km", 1u"s", Equiv1) # need instance, not type
    @test_throws ArgumentError ustrip(u"s", 10u"s", Equiv1())
    @test_throws ArgumentError ustrip(u"kg", 1u"s", Equiv1())
    @test_throws ArgumentError ustrip(u"m", 1, Equiv1())
    @test_throws MethodError   ustrip(u"km", 1u"s", Equiv1) # need instance, not type
    @test_throws ArgumentError ustrip(Float64, u"s", 10u"s", Equiv1())
    @test_throws ArgumentError ustrip(Float64, u"kg", 1u"s", Equiv1())
    @test_throws ArgumentError ustrip(Float64, u"m", 1, Equiv1())
    @test_throws MethodError   ustrip(Float64, u"km", 1u"s", Equiv1) # need instance, not type

    # Equiv2
    @test uconvert(u"cm", 1u"minute", Equiv2()) === 21_600_000u"cm"
    @test uconvert(u"km", 2u"minute", Equiv2()) === (1728//1)u"km"
    @test uconvert(u"s", -8u"m", Equiv2()) === -2.0u"s"
    @test uconvert(u"s", 27u"m", Equiv2()) === 3.0u"s"

    # Equiv3
    @test uconvert(u"J", 20u"ha", Equiv3(1)) === 0.000_005u"J"
    @test uconvert(u"J", 20u"ha", Equiv3(-4)) === -0.000_02u"J"
    @test uconvert(u"cm^2", 1u"J", Equiv3(2)) === 20_000.0u"cm^2"
    @test uconvert(u"cm^2", 1u"J", Equiv3(5)) === 50_000.0u"cm^2"

    # NoEquiv
    @test_throws MethodError uconvert(u"km", 1u"minute", NoEquiv()) # !(NoEquiv <: Equivalence)
    @test_throws MethodError ustrip(u"km", 1u"minute", NoEquiv()) # !(NoEquiv <: Equivalence)
    @test_throws MethodError ustrip(Float64, u"km", 1u"minute", NoEquiv()) # !(NoEquiv <: Equivalence)

    @testset "Broadcasting" begin
        @test uconvert.(u"ms", [5u"cm", 10u"cm"], Equiv1()) == [5u"ms", 10u"ms"]
        @test uconvert.(u"km", Quantity[1u"hr", -1u"s"], Equiv1()) == [36u"km", (-1//100)u"km"]
        @test ustrip.(u"ms", [5u"cm", 10u"cm"], Equiv1()) == [5, 10]
        @test ustrip.(u"km", Quantity[1u"hr", -1u"s"], Equiv1()) == [36, -1//100]
        @test ustrip.(Float64, u"ms", [5u"cm", 10u"cm"], Equiv1()) == [5.0, 10.0]
        @test ustrip.(Float64, u"km", Quantity[1u"hr", -1u"s"], Equiv1()) == [36.0, -0.01]
    end
end

struct Equiv4 <: Equivalence end
@eqrelation Equiv4 Unitful.Velocity/Unitful.Voltage = 1.5*u"m/(V*s)"
@eqrelation Equiv4 Unitful.Force*Unitful.Volume = -1u"N*m^3"
@eqrelation Equiv4 Unitful.Energy/DimensionlessQuantity = u"eV"

@testset "@eqrelation" begin
    @test uconvert(u"m/s", 10u"V", Equiv4()) === 15.0u"m/s"
    @test uconvert(u"V", 15u"m/s", Equiv4()) === 10.0u"V"
    @test uconvert(u"N", 10u"m^3", Equiv4()) === -0.1u"N"
    @test uconvert(u"m^3", 5u"N", Equiv4()) === -0.2u"m^3"
    @test uconvert(NoUnits, 5u"eV", Equiv4()) === 5
    @test uconvert(u"keV", 5u"km/m", Equiv4()) === 5u"keV"
    @test uconvert(u"MeV", 5, Equiv4()) === (1//200_000)u"MeV"
    @test_throws ArgumentError uconvert(u"m^3", 1u"V", Equiv4())
    if VERSION ≥ v"1.7.0-DEV"
        @test_throws ErrorException @macroexpand @eqrelation Equiv4 Unitful.Energy = Unitful.Mass * Unitful.c0^2
        @test_throws ErrorException @macroexpand @eqrelation Equiv4 Unitful.Energy + Unitful.Mass = Unitful.c0^2
    else
        @test_throws LoadError @macroexpand @eqrelation Equiv4 Unitful.Energy = Unitful.Mass * Unitful.c0^2
        @test_throws LoadError @macroexpand @eqrelation Equiv4 Unitful.Energy + Unitful.Mass = Unitful.c0^2
    end
end

≈ᵤ(x, y; kwargs...) = unit(x) === unit(y) && ≈(x, y; kwargs...)

@testset "MassEnergy" begin
    @test uconvert(u"keV", 1u"me", MassEnergy()) ≈ᵤ 510.998_95u"keV"
    @test uconvert(u"kg", 938.272_088_16u"MeV", MassEnergy()) ≈ᵤ 1u"mp"
end

@testset "Spectral" begin
    @test Spectral() === Spectral(frequency=:linear, wavelength=:linear, wavenumber=:linear)
    @test Spectral(frequency=:angular) === Spectral(frequency=:angular, wavelength=:linear, wavenumber=:linear)
    @test sprint(show, Spectral()) === "Spectral(frequency=:linear, wavelength=:linear, wavenumber=:linear)"

    # Energy ↔ frequency
    for L = (:linear, :angular), N = (:linear, :angular)
        @test uconvert(u"eV", 1u"MHz", Spectral(frequency=:linear, wavelength=L, wavenumber=N)) ≈ᵤ 4.135_667_697e-09u"eV" # E = h*f
        @test uconvert(u"J", 1u"ns^-1", Spectral(frequency=:angular, wavelength=L, wavenumber=N)) ≈ᵤ 1.054_571_818e-25u"J" # E = ħ*ω
        @test uconvert(u"Hz", 1u"eV", Spectral(frequency=:linear, wavelength=L, wavenumber=N)) ≈ᵤ 2.417_989_242e+14u"Hz" # f = E/h
        @test uconvert(u"fs^-1", 1u"J", Spectral(frequency=:angular, wavelength=L, wavenumber=N)) ≈ᵤ 9.482_521_562e+18u"fs^-1" # ω = E/ħ
    end

    # Energy ↔ wavelength
    for F = (:linear, :angular), N = (:linear, :angular)
        @test uconvert(u"eV", 1u"nm", Spectral(frequency=F, wavelength=:linear, wavenumber=N)) ≈ᵤ 1239.841_984u"eV" # E = h*c/λ
        @test uconvert(u"J", 1u"Å", Spectral(frequency=F, wavelength=:angular, wavenumber=N)) ≈ᵤ 3.161_526_773e-16u"J" # E = ħ*c/ƛ
        @test uconvert(u"nm", 1u"keV", Spectral(frequency=F, wavelength=:linear, wavenumber=N)) ≈ᵤ 1.239_841_984u"nm" # λ = h*c/E
        @test uconvert(u"μm", 1u"J", Spectral(frequency=F, wavelength=:angular, wavenumber=N)) ≈ᵤ 3.161_526_773e-20u"μm" # ƛ = ħ*c/E
    end

    # Energy ↔ wavenumber
    for F = (:linear, :angular), L = (:linear, :angular)
        @test uconvert(u"eV", 1u"cm^-1", Spectral(frequency=F, wavelength=L, wavenumber=:linear)) ≈ᵤ 0.000_123_984_1984u"eV" # E = h*c*ν̃
        @test uconvert(u"J", 1u"m^-1", Spectral(frequency=F, wavelength=L, wavenumber=:angular)) ≈ᵤ 3.161_526_773e-26u"J" # E = ħ*c*k
        @test uconvert(u"cm^-1", 1u"J", Spectral(frequency=F, wavelength=L, wavenumber=:linear)) ≈ᵤ 5.034_116_568e+22u"cm^-1" # ν̃ = E/(h*c)
        @test uconvert(u"m^-1", 1u"eV", Spectral(frequency=F, wavelength=L, wavenumber=:angular)) ≈ᵤ 5.067_730_716e+06u"m^-1" # k = E/(ħ*c)
    end

    # Frequency ↔ wavelength
    for N = (:linear, :angular)
        @test uconvert(u"MHz", 1u"nm", Spectral(frequency=:linear, wavelength=:linear, wavenumber=N)) ≈ᵤ 299_792_458_000u"MHz" # f = c/λ
        @test uconvert(u"ns^-1", 1u"Å", Spectral(frequency=:linear, wavelength=:angular, wavenumber=N)) ≈ᵤ 4.771_345_159e+08u"ns^-1" # f = c/(2π*ƛ)
        @test uconvert(u"fs^-1", 1u"nm", Spectral(frequency=:angular, wavelength=:linear, wavenumber=N)) ≈ᵤ 1883.651_567u"fs^-1" # ω = 2π*c/λ
        @test uconvert(u"Hz", 1u"m", Spectral(frequency=:angular, wavelength=:angular, wavenumber=N)) ≈ᵤ 299_792_458u"Hz" # ω = c/ƛ

        @test uconvert(u"nm", 1u"MHz", Spectral(frequency=:linear, wavelength=:linear, wavenumber=N)) ≈ᵤ 299_792_458_000u"nm" # λ = c/f
        @test uconvert(u"Å", 1u"ns^-1", Spectral(frequency=:linear, wavelength=:angular, wavenumber=N)) ≈ᵤ 4.771_345_159e+08u"Å" # ƛ = c/(2π*f)
        @test uconvert(u"nm", 1u"fs^-1", Spectral(frequency=:angular, wavelength=:linear, wavenumber=N)) ≈ᵤ 1883.651_567u"nm" # λ = 2π*c/ω
        @test uconvert(u"m", 1u"Hz", Spectral(frequency=:angular, wavelength=:angular, wavenumber=N)) ≈ᵤ 299_792_458u"m" # ƛ = c/ω
    end

    # Frequency ↔ wavenumber
    for L = (:linear, :angular)
        @test uconvert(u"MHz", 1u"cm^-1", Spectral(frequency=:linear, wavelength=L, wavenumber=:linear)) ≈ᵤ 29_979.2458u"MHz" # f = c*ν̃
        @test uconvert(u"ns^-1", 1u"m^-1", Spectral(frequency=:linear, wavelength=L, wavenumber=:angular)) ≈ᵤ 0.047_713_451_59u"ns^-1" # f = c*k/2π
        @test uconvert(u"fs^-1", 1u"cm^-1", Spectral(frequency=:angular, wavelength=L, wavenumber=:linear)) ≈ᵤ 0.000_188_365_1567u"fs^-1" # ω = 2π*c*ν̃
        @test uconvert(u"Hz", 1u"m^-1", Spectral(frequency=:angular, wavelength=L, wavenumber=:angular)) ≈ᵤ 299_792_458u"Hz" # ω = c*k

        @test uconvert(u"cm^-1", 1u"MHz", Spectral(frequency=:linear, wavelength=L, wavenumber=:linear)) ≈ᵤ 3.335_640_952e-05u"cm^-1" # ν̃ = f/c
        @test uconvert(u"m^-1", 1u"ns^-1", Spectral(frequency=:linear, wavelength=L, wavenumber=:angular)) ≈ᵤ 20.958_450_22u"m^-1" # k = 2π*f/c
        @test uconvert(u"cm^-1", 1u"fs^-1", Spectral(frequency=:angular, wavelength=L, wavenumber=:linear)) ≈ᵤ 5308.837_459u"cm^-1" # ν̃ = ω/(2π*c)
        @test uconvert(u"m^-1", 1u"Hz", Spectral(frequency=:angular, wavelength=L, wavenumber=:angular)) ≈ᵤ 3.335_640_952e-09u"m^-1" # k = ω/c
    end

    # Wavelength ↔ wavenumber
    for F = (:linear, :angular)
        @test uconvert(u"nm", 1u"cm^-1", Spectral(frequency=F, wavelength=:linear, wavenumber=:linear)) ≈ᵤ 10_000_000u"nm" # λ = 1/ν̃
        @test uconvert(u"Å", 1u"m^-1", Spectral(frequency=F, wavelength=:linear, wavenumber=:angular)) ≈ᵤ 6.283_185_307e+10u"Å" # λ = 2π/k
        @test uconvert(u"nm", 1u"cm^-1", Spectral(frequency=F, wavelength=:angular, wavenumber=:linear)) ≈ᵤ 1.591_549_431e+06u"nm" # ƛ = 1/(2π*ν̃)
        @test uconvert(u"m", 1u"m^-1", Spectral(frequency=F, wavelength=:angular, wavenumber=:angular)) ≈ᵤ 1u"m" # ƛ = 1/k

        @test uconvert(u"cm^-1", 1u"nm", Spectral(frequency=F, wavelength=:linear, wavenumber=:linear)) ≈ᵤ 10_000_000u"cm^-1" # ν̃ = 1/λ
        @test uconvert(u"m^-1", 1u"Å", Spectral(frequency=F, wavelength=:linear, wavenumber=:angular)) ≈ᵤ 6.283_185_307e+10u"m^-1" # k = 2π/λ
        @test uconvert(u"cm^-1", 1u"nm", Spectral(frequency=F, wavelength=:angular, wavenumber=:linear)) ≈ᵤ 1.591_549_431e+06u"cm^-1" # ν̃ = 1/(2π*ƛ)
        @test uconvert(u"m^-1", 1u"m", Spectral(frequency=F, wavelength=:angular, wavenumber=:angular)) ≈ᵤ 1u"m^-1" # k = 1/ƛ
    end
end

@testset "Thermal" begin
    @test uconvert(u"meV", 20u"°C", Thermal()) ≈ᵤ 25.261_712_457_979u"meV"
    @test uconvert(u"eV", 5000u"K", Thermal()) ≈ᵤ 0.430_866_663_107u"eV"
    @test uconvert(u"K", 1u"eV", Thermal()) ≈ᵤ 11_604.518_121_550u"K"
    @test uconvert(u"°C", 1e-20u"J", Thermal()) ≈ᵤ 451.147_051_603_992u"°C"
end
