# Example Programs

Companion programs for the short course **Hello Fortran: A Modern Fortran
Primer For Engineers And Scientists**.

All four approximate the same quantity — π — and differ only in **how the
input reaches the program** and **where the answer goes**. Holding the
computation fixed makes the input/output progression the visible subject.

| | program | input arrives as | output |
|---|---|---|---|
| **ex1** | `pi_cli.f90` | two command-line arguments | screen |
| **ex2** | `pi_textfile.f90` | a plain-text file named on the command line, comments stripped | screen |
| **ex3** | `pi_namelist.f90` | a namelist file named on the command line | screen |
| **ex4** | `pi_report.f90` | a namelist file named on the command line | screen **and** a report file |

## Building and running

Each folder is self-contained. There is no build system and no third-party
library — just GFortran.

```bash
cd ex1
./build.sh                       # compile with the course's standard flags
./pi_cli.exe midpoint 1000       # run
./cl.sh                          # remove build products and generated output
```

`build.sh` uses the flag set taught in the course:

```
gfortran <src>.f90 -std=f2018 -Wall -Wextra -fcheck=all -g -fbacktrace -O0
```

The course is pitched on Fortran 2023, but `-std=f2018` is the recommended
working flag because GFortran's 2023 support is still partial. Every program
here compiles warning-free under **both** `-std=f2018` and `-std=f2023`
(verified against GFortran 16.1.0).

`cl.sh` removes only build products and generated output. Fortran sources,
build scripts, and input files are never touched.

Run each program with no arguments to see its usage line.

## What each one adds

- **ex1** — `command_argument_count` / `get_command_argument`, deferred-length
  `character(len=:), allocatable`, and converting text to a number with an
  internal read.
- **ex2** — reading a commented input file the hard way. A **pure** comment
  stripper writes a cleaned copy (`pi_input.clean`) that the program then
  reopens and reads, so you can `cat` the intermediate and see exactly what
  happened. Comment out the first pair of values to switch methods.
- **ex3** — the same input as a `namelist`, where the language does the
  parsing. Names may appear in any order and omitted names keep their
  defaults. Every `&pi_input` group in the file is read and run in turn.
- **ex4** — as ex3, plus a written report. All cases share one report file:
  `status='replace'` for the first case, `position='append'` for the rest, so
  rerunning overwrites rather than doubles.

## Two things worth pointing out

**Every program checks itself.** The reference value is computed as
`4.0_rk * atan(1.0_rk)` — never transcribed — and each run prints its own
absolute error against it. Raise `n` and watch the error fall: the midpoint
rule converges as 1/n², the Leibniz series only as 1/n.

**Pure logic, impure shell.** Fortran forbids external file I/O inside a
`pure` procedure, so every example separates the two: all computation and all
string handling are `pure`, and the procedures that open, read, and write are
not. Each one says so in its own comment.

## Layout

Every example is a **single file**, with modules in dependency order and the
main program last:

```
kind_mod         ! ik / rk -- identical in all four
pi_mod           ! the computation, entirely pure -- identical in all four
[extra modules]  ! text_util_mod (ex2), nml_util_mod + report_mod (ex3, ex4)
program ...
```

## Licence

MIT — see `LICENSE` in this directory. Every source file also carries an
`SPDX-License-Identifier: MIT` tag.
