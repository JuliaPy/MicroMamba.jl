using TestItemRunner

@run_package_tests

@testitem "MicroMamba" begin
    MicroMamba.STATE.version = VersionNumber(0)
    MicroMamba.STATE.executable = ""
    @test MicroMamba.available()
    @test MicroMamba.executable() != ""
    @test isfile(MicroMamba.executable())
    @test MicroMamba.version() isa VersionNumber
    @test MicroMamba.version() > VersionNumber(0)
    help = read(MicroMamba.cmd(`--help`), String)
    @test occursin("--help", help)
    # this fails on v1.4.3, succeeds on 1.4.7
    run(MicroMamba.cmd(`create -y -p ./testenv -c conda-forge pip`))
end
