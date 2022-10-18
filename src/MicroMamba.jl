module MicroMamba

if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@compiler_options"))
    # Note: compile=min makes --code-coverage not work
    @eval Base.Experimental.@compiler_options optimize=0 infer=false #compile=min
end

import Pkg.Artifacts: ensure_artifact_installed
import Scratch: @get_scratch!

mutable struct State
    root_dir::String
    available::Bool
    executable::String
    version::VersionNumber
end

const STATE = State("", true, "", VersionNumber(0))

const DEFAULT_VERSION = v"0.27.0"
const ARTIFACTS_TOML = joinpath(dirname(@__DIR__), "Artifacts.toml")
const ARTIFACT_NAME = "micromamba-$(DEFAULT_VERSION)"

"""
    executable()

Return the path to a MicroMamba executable.

Will download and install MicroMamba if required.

May throw an error, for example if your platform is not supported. See `available()`.
"""
function executable(; io::IO=stderr)
    if STATE.executable == ""
        # install from artifact
        STATE.available = false
        install_dir = ensure_artifact_installed(ARTIFACT_NAME, ARTIFACTS_TOML, io=io)
        if Sys.iswindows()
            exe = joinpath(install_dir, "Library", "bin", "micromamba.exe")
        else
            exe = joinpath(install_dir, "bin", "micromamba")
        end
        # check the executable is executable and the right version
        versionstr = read(`$exe --version`, String)
        # @assert occursin("micromamba: $(DEFAULT_VERSION)", versionstr)
        @assert strip(versionstr) == string(DEFAULT_VERSION)
        # update the state
        STATE.executable = exe
        STATE.version = DEFAULT_VERSION
        STATE.available = true
        # Check if an old MicroMamba directory is still there (~/.julia/micromamba)
        for depotdir in DEPOT_PATH
            olddir = joinpath(depotdir, "micromamba")
            isdir(olddir) && @warn "Old MicroMamba directory still exists, it can be deleted: $olddir"
        end
    end
    STATE.executable
end

"""
    version()

The version of MicroMamba at `executable()`.

Will download and install MicroMamba if required.

May throw an error, for example if your platform is not supported. See `available()`.
"""
function version(; io::IO=stderr)
    if STATE.version == VersionNumber(0)
        executable(io=io)
    end
    STATE.version
end

"""
    available()

Return `true` if MicroMamba is available.

If so, `executable()` and `version()` will not throw.

Will download and install MicroMamba if required.
"""
function available(; io::IO=stderr)
    if STATE.available && STATE.executable == ""
        try
            executable(io=io)
        catch
        end
    end
    STATE.available
end

function root_dir()
    if STATE.root_dir == ""
        # if the user already has mamba installed, re-use its root
        STATE.root_dir = get(ENV, "MAMBA_ROOT_PREFIX", "")
        if STATE.root_dir == ""
            STATE.root_dir = @get_scratch!("root")
        end
    end
    STATE.root_dir
end

"""
    cmd([args])

Construct a command which calls MicroMamba, optionally with additional arguments.

By default, the root prefix is a folder in the Julia depot. It can be over-ridden with
the environment variable `MAMBA_ROOT_PREFIX`.
"""
function cmd(; io::IO=stderr)
    exe = executable(io=io)
    root = root_dir()
    `$exe -r $root`
end
cmd(args; io::IO=stderr) = `$(cmd(io=io)) $args`

end # module
