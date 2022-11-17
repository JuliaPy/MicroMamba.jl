module MicroMamba

if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@compiler_options"))
    # Note: compile=min makes --code-coverage not work
    @eval Base.Experimental.@compiler_options optimize=0 infer=false #compile=min
end

using Scratch: @get_scratch!
using micromamba_jll: micromamba_jll

mutable struct State
    root_dir::String
    executable::String
    version::VersionNumber
end

const STATE = State("", "", VersionNumber(0))

"""
    executable()

Return the path to a MicroMamba executable.

Will download and install MicroMamba if required.

May throw an error, for example if your platform is not supported. See `available()`.
"""
function executable(; io::IO=stderr)
    if STATE.executable == ""
        if !available()
            error("MicroMamba is not currently supported on your platform")
        end
        STATE.executable = micromamba_jll.get_micromamba_path()
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
        exe = executable(io=io)
        ver = VersionNumber(chomp(read(`$exe --version`, String)))
        STATE.version = ver
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
    return micromamba_jll.is_available()
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
