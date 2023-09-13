# MicroMamba.jl
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Test Status](https://github.com/JuliaPy/MicroMamba.jl/actions/workflows/tests.yml/badge.svg)](https://github.com/JuliaPy/MicroMamba.jl/actions/workflows/tests.yml)
[![Codecov](https://codecov.io/gh/JuliaPy/MicroMamba.jl/branch/main/graph/badge.svg?token=PshN9qAKau)](https://codecov.io/gh/JuliaPy/MicroMamba.jl)

A Julia interface to the [`MicroMamba`](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html) package manager.

For a higher-level interface, see [`CondaPkg.jl`](https://github.com/JuliaPy/CondaPkg.jl).

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

The command returned from `cmd()` includes the root prefix `-r` argument. By default this is some Julia-specific directory, but can be over-ridden with the environment variable `MAMBA_ROOT_PREFIX`.

## Example

The following command creates a new environment in `./env` and installs Python into it.

```julia
run(MicroMamba.cmd(`create -y -p ./env python -c conda-forge`))
```
