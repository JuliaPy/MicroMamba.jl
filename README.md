# MicroMamba.jl
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Test Status](https://github.com/cjdoris/MicroMamba.jl/actions/workflows/tests.yml/badge.svg)](https://github.com/cjdoris/MicroMamba.jl/actions/workflows/tests.yml)
[![Codecov](https://codecov.io/gh/cjdoris/MicroMamba.jl/branch/main/graph/badge.svg?token=PshN9qAKau)](https://codecov.io/gh/cjdoris/MicroMamba.jl)

A Julia interface to the [`MicroMamba`](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html) package manager.

For a higher-level interface, see [`CondaPkg.jl`](https://github.com/cjdoris/CondaPkg.jl).

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

In all cases, MicroMamba will be downloaded and installed if required to a Julia-specific location.

## Example

The following command creates a new environment in `./env` and installs Python into it.

```julia
run(MicroMamba.cmd(`create -y -p ./env python -c conda-forge`))
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
- `JULIA_MICROMAMBA_ROOT_PREFIX`: The root prefix used by `cmd()`.
