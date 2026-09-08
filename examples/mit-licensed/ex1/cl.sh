#!/usr/bin/env bash

# Filename: cl.sh
# Purpose: Remove the build products and generated output for the ex1 example.
#          Fortran sources, build scripts, and input files are left alone.

# Set script to fail fast:
#   -e: exit immediately if any command fails
#   -u: treat unset variables as errors
#   -o pipefail: a pipeline fails if any command in it fails (not just the last)
set -euo pipefail

# Change working directory to the folder containing this script
cd "$(dirname "$0")"

# Delete the executable, object files, and compiled module files
#   *.exe: the program produced by build.sh
#   *.o:   object files, present only if the source was compiled in two steps
#   *.mod: module interface files, one written per module in the source
rm -f -- *.exe *.o *.mod

# Delete the macOS debug-symbol bundle produced by the -g flag
#   *.exe.dSYM is a directory, so it needs rm -rf; plain rm -f cannot remove it
#   Harmless no-op on Linux/WSL, where -g embeds the symbols in the binary
rm -rf -- *.dSYM

# Print a message indicating the clean was successful
echo "cleaned $(basename "$PWD")"
