# MicroMamba.jl

A Julia interface to the [`MicroMamba`](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html) package manager.

## Installation

```
pkg> add MicroMamba
```

## Usage

The API consists of the following functions:
- `cmd([args])` returns a command which calls MicroMamba, optionally with given arguments.
- `executable()` returns the path to a MicroMamba executable.
- `version()` returns the version of this executable.
- `available()` returns true if MicroMamba is available on this system. Use this to check if the above functions will succeed.

In all three cases, MicroMamba will be downloaded and installed if required to the `micromamba` directory in your Julia depot (e.g. `~/.julia/micromamba`).

## Example

The following example creates a new environment in `./env` and installs Python into it.

```julia
run(MicroMamba.cmd(`--prefix ./env create python --yes --channel conda-forge`))
```

## Environment variables

The following environment variables customise the behaviour of this package.
- `JULIA_MICROMAMBA_EXECUTABLE`: If set, it must be the path of a MicroMamba executable to
  use instead of downloading it. It becomes the return value of `executable()`.
- `JULIA_MICROMAMBA_URL`: The URL to download MicroMamba from if required.
  The following string replacements are made:
  - `{platform}` is replaced with the platform, such as `linux-64`.
  - `{version}` is replaced with the desired version, such as `latest` or `0.19.0`.
- `JULIA_MICROMAMBA_VERSION`: If MicroMamba needs to be downloaded, this specifies the version.
- `JULIA_MICROMAMBA_ROOT_PREFIX`: The root prefix used by `cmd()`. Defaults to the `micromamba/root` directory of your Julia depot (e.g. `~/.julia/micromamba/root`).
