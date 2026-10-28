#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
nix flake update nixpkgs delta-upstream
nix flake check --print-build-logs
nix build .#default --no-link --print-build-logs
