using TestItemRunner

@run_package_tests

@testitem "MicroMamba" begin
    @test MicroMamba.available()
    @test isfile(MicroMamba.executable())
    MicroMamba.STATE.version = VersionNumber(0)
    MicroMamba.STATE.executable = ""
    @test MicroMamba.version() isa VersionNumber
    help = read(MicroMamba.cmd(`--help`), String)
    @test occursin("--help", help)
end
