"""
This script generates micromamba artifacts.

Update the parameters (usually just the version) and run `julia src/generate_artifacts.jl`
from the root of the package. Requires ArtifactUtils to be installed.

The latest version and supported platforms can be found at
https://anaconda.org/conda-forge/micromamba
"""

import ArtifactUtils: add_artifact!
import Pkg.Artifacts: Platform

toml = "Artifacts.toml"
version = "0.23.0"
name = "micromamba-$(version)"
platforms = [
    "linux-64" => Platform("x86_64", "linux"),
    "linux-aarch64" => Platform("aarch64", "linux"),
    "linux-ppc64le" => Platform("powerpc64le", "linux"),
    "osx-64" => Platform("x86_64", "macos"),
    "osx-arm64" => Platform("aarch64", "macos"),
    "win-64" => Platform("x86_64", "windows"),
]

@show toml version name

for platform in platforms
    @show platform
    url = "https://micro.mamba.pm/api/micromamba/$(platform[1])/$(version)"
    add_artifact!(toml, name, url; platform=platform[2], lazy=true, clear=true)
end
