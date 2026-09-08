#!/usr/bin/env bash

# Filename: build.sh
# Purpose: Compile the ex4 example with the course's standard flags.

# Set script to fail fast:
#   -e: exit immediately if any command fails
#   -u: treat unset variables as errors
#   -o pipefail: a pipeline fails if any command in it fails (not just the last)
set -euo pipefail

# Change working directory to the folder containing this script
cd "$(dirname "$0")"

# Set source and executable filenames
src="pi_report.f90"
exe="pi_report.exe"

# Compile the source code into the executable
gfortran "$src" -std=f2018 -Wall -Wextra -fcheck=all -g -fbacktrace -O0 -o "$exe"
# gfortran "$src" -std=f2018 -Wall -Wextra -O2 -o "$exe"

# Print a message indicating the build was successful
echo "built ./$exe"
