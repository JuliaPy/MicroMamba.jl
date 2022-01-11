using MicroMamba
using Test

@testset "MicroMamba" begin
    @test MicroMamba.available()
    @test isfile(MicroMamba.executable())
    @test MicroMamba.version() isa VersionNumber
    help = read(MicroMamba.cmd(`--help`), String)
    @test occursin("--help", help)
end
