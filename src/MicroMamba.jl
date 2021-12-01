module MicroMamba

import Base: @kwdef
import CodecBzip2: Bzip2DecompressorStream
import Downloads: download
import Tar

@kwdef mutable struct State
    available::Bool = true
    platform::String = ""
    url::String = ""
    executable::String = ""
    version::VersionNumber = VersionNumber(0)
end

const STATE = State()

function platform()
    if STATE.platform == ""
        arch = Sys.ARCH
        STATE.platform =
            arch == :x86_64 ?
                Sys.iswindows() ? "win-64" :
                Sys.islinux() ? "linux-64" :
                Sys.isapple() ? "osx-64" :
                error("unsupported platform") :
            arch == :aarch64 ?
                Sys.islinux() ? "linux-64" :
                error("unsupported platform") :
            arch == :powerpc64le ?
                Sys.islinux() ? "powerpc64le" :
                error("unsupported platform") :
            error("unsupported platform")
    end
    STATE.platform
end

const DEFAULT_URL = "https://micro.mamba.pm/api/micromamba/{platform}/{version}"
const MIN_VERSION = v"0.19.0"

function url()
    if STATE.url == ""
        ver = get(ENV, "JULIA_MICROMAMBA_VERSION", "latest")
        url = get(ENV, "JULIA_MICROMAMBA_URL", DEFAULT_URL)
        url = replace(url, "{platform}" => _->platform()) # _->platform() to skip calling platform() (which might raise) when not needed
        url = replace(url, "{version}" => ver)
        STATE.url = url
    end
    STATE.url
end

"""
    executable()

Return the path to a MicroMamba executable.

Will download and install MicroMamba if required.

May throw an error, for example if your platform is not supported. See `available()`.
"""
function executable()
    if STATE.executable == ""
        # Set to true again below, unless any errors are thrown
        STATE.available = false
        # Find the MicroMamba executable
        fromenv = false
        if haskey(ENV, "JULIA_MICROMAMBA_EXECUTABLE")
            fromenv = true
            STATE.executable = ENV["JULIA_MICROMAMBA_EXECUTABLE"]
        else
            # Use version installed in the package dir
            exename = Sys.iswindows() ? "micromamba.exe" : "micromamba"
            exe = joinpath(DEPOT_PATH[1], "micromamba", exename)
            if _version(exe) < MIN_VERSION
                # If doesn't exist or too old, download and install
                mktempdir() do dir
                    file = joinpath(dir, "micromamba.tar.bz2")
                    @info "Downloading MicroMamba from $(url())"
                    download(url(), file)
                    @info "Installing MicroMamba to $exe"
                    odir = joinpath(dir, "micromamba")
                    open(file) do io
                        Tar.extract(Bzip2DecompressorStream(io), odir)
                    end
                    iexe = Sys.iswindows() ? joinpath(odir, "Library", "bin", exename) : joinpath(odir, "bin", exename)
                    mkpath(dirname(exe))
                    cp(iexe, exe, force=true)
                end
            end
            STATE.executable = exe
        end
        # Check the MicroMamba version
        STATE.version = _version(STATE.executable)
        if STATE.version == VersionNumber(0)
            # Zero means the version could not be determined
            STATE.available = false
            error("$(STATE.executable) does not seem to be a MicroMamba executable")
        elseif STATE.version < MIN_VERSION
            # Too low, raise an error unless the user explicitly specified the executable or version
            if !fromenv && get(ENV, "JULIA_MICROMAMBA_VERSION", "latest") != string(STATE.version)
                error("MicroMamba at $(STATE.executable) is version $(STATE.version) which is older than the minimum supported version $(MIN_VERSION) of this package")
            end
        end
        STATE.available = true
    end
    STATE.executable
end

function _version(exe)
    ans = VersionNumber(0)
    try
        for line in eachline(`$exe --version`)
            m = match(r"^micromamba: *([^ ]+)$", line)
            if m !== nothing
                ans = VersionNumber(m.captures[1])
            end
        end
    catch
    end
    ans
end

"""
    version()

The version of MicroMamba at `executable()`.

Will download and install MicroMamba if required.

May throw an error, for example if your platform is not supported. See `available()`.
"""
function version()
    executable()
    STATE.version
end

"""
    available()

Return `true` if MicroMamba is available.

If so, `executable()` and `version()` will not throw.

Will download and install MicroMamba if required.
"""
function available()
    if STATE.available && STATE.executable == ""
        try
            executable()
        catch
            STATE.available = false
        end
    end
    STATE.available
end

"""
    cmd([args])

Construct a command which calls MicroMamba, optionally with additional arguments.

By default, the root prefix is a folder in the Julia depot. It can be over-ridden with
the environment variable `JULIA_MICROMAMBA_ROOT_PREFIX`. To use the default root prefix
instead (e.g. as set by `~/.mambarc`) set this variable to the empty string.
"""
function cmd()
    ans = `$(executable())`
    root = get(ENV, "JULIA_MICROMAMBA_ROOT_PREFIX") do
        joinpath(DEPOT_PATH[1], "micromamba", "root")
    end
    if root != ""
        ans = `$ans --root-prefix $root`
    end
    ans
end
cmd(args) = `$(cmd()) $args`

end # module
