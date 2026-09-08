!-----------------------------------------------------------------------------
! File Name:  pi_cli.f90
! Purpose:    Approximate pi from a method name and a term count supplied as
!             command-line arguments.  Demonstrates the project kind module,
!             command_argument_count / get_command_argument, deferred-length
!             character variables, and pure computational procedures.
!
! Course:     Hello Fortran: A Modern Fortran Primer for Engineers and
!             Scientists
! Author:     Robert S. Browning
! Date:       02SEP2026
!
! SPDX-License-Identifier: MIT
! Copyright (c) 2026 Robert S. Browning
! Released under the MIT License.  See ../LICENSE for the full text.
!
! Build:      ./build.sh
! Run:        ./pi_cli.exe midpoint 1000
! Clean:      ./cl.sh
!-----------------------------------------------------------------------------

!-----------------------------------------------------------------------------
! kind_mod -- the single place the project's integer and real kinds are named.
! Every other unit takes its kinds from here, so changing precision is a
! one-line edit instead of a repo-wide search.
!-----------------------------------------------------------------------------
module kind_mod
  use iso_fortran_env, only: int32, real64
  implicit none (type, external)
  private
  integer, parameter, public :: ik = int32    ! integer kind
  integer, parameter, public :: rk = real64   ! real kind
end module kind_mod

!-----------------------------------------------------------------------------
! pi_mod -- the whole computation, and every procedure in it is pure.
! Nothing here reads, writes, or prints, so it can be reasoned about and
! reused without worrying about side effects.  The same module appears
! unchanged in all four examples.
!-----------------------------------------------------------------------------
module pi_mod
  use kind_mod, only: ik, rk
  implicit none (type, external)
  private
  public :: pi_ref, n_max, pi_leibniz, pi_midpoint, pi_estimate, pi_error

  ! The reference value is computed by the compiler, not transcribed from a
  ! book.  That is what lets every example check its own answer.
  real(rk), parameter :: pi_ref = 4.0_rk * atan(1.0_rk)

  ! Upper bound on the term count.  Keeps 2*k+1 inside the range of ik and
  ! keeps a live demo from appearing to hang.
  integer(ik), parameter :: n_max = 100000000_ik

  contains

  !> Leibniz series:  pi = 4 * sum over k of (-1)**k / (2k+1).
  !> Simple to read, and painfully slow -- the error falls only as 1/n.
  pure function pi_leibniz(n_terms) result(pi_est)
    integer(ik), intent(in) :: n_terms
    real(rk) :: pi_est

    real(rk)    :: total, sign_k
    integer(ik) :: k

    total  = 0.0_rk
    sign_k = 1.0_rk   ! toggled rather than (-1)**k: cheaper, and cannot overflow
    do k = 0_ik, n_terms - 1_ik
      total  = total + sign_k / real(2_ik*k + 1_ik, rk)
      sign_k = -sign_k
    end do
    pi_est = 4.0_rk * total
  end function pi_leibniz

  !> Midpoint rule on the integral of 4/(1+x**2) from 0 to 1, which is pi.
  !> The error falls as 1/n**2, so it reaches machine precision far sooner.
  pure function pi_midpoint(n_panels) result(pi_est)
    integer(ik), intent(in) :: n_panels
    real(rk) :: pi_est

    real(rk)    :: h, x_mid, total
    integer(ik) :: i

    h     = 1.0_rk / real(n_panels, rk)
    total = 0.0_rk
    do i = 1_ik, n_panels
      x_mid = (real(i, rk) - 0.5_rk) * h        ! centre of panel i
      total = total + 4.0_rk / (1.0_rk + x_mid*x_mid)
    end do
    pi_est = h * total
  end function pi_midpoint

  !> Validate the input and dispatch on the method name.
  !>
  !> This is a pure SUBROUTINE rather than a pure function on purpose: a pure
  !> function may not have intent(out) dummy arguments, and this has to hand
  !> back a value, a status, and a reason.  Note that the internal write below
  !> is legal here -- the restriction on pure procedures covers external file
  !> I/O, not writing into a character variable.
  pure subroutine pi_estimate(method, n, pi_est, ok, why)
    character(len=*), intent(in)  :: method
    integer(ik),      intent(in)  :: n
    real(rk),         intent(out) :: pi_est
    logical,          intent(out) :: ok
    character(len=*), intent(out) :: why

    pi_est = 0.0_rk
    ok     = .false.
    why    = ''

    if (n < 1_ik) then
      why = 'n must be 1 or greater'
      return
    end if

    if (n > n_max) then
      write (why, '(a, i0)') 'n exceeds the supported maximum of ', n_max
      return
    end if

    select case (trim(adjustl(method)))
    case ('midpoint')
      pi_est = pi_midpoint(n)
      ok     = .true.
    case ('leibniz')
      pi_est = pi_leibniz(n)
      ok     = .true.
    case default
      why = 'unknown method "' // trim(adjustl(method)) // &
            '" (expected midpoint or leibniz)'
    end select
  end subroutine pi_estimate

  !> Absolute error against the reference.  This is the self-check: the
  !> program reports how wrong it is without being told the answer.
  pure function pi_error(pi_est) result(err)
    real(rk), intent(in) :: pi_est
    real(rk) :: err

    err = abs(pi_est - pi_ref)
  end function pi_error
end module pi_mod

!-----------------------------------------------------------------------------
! Main program: read two command-line arguments, approximate pi, report.
!-----------------------------------------------------------------------------
program pi_cli
  use iso_fortran_env, only: error_unit
  use kind_mod, only: ik, rk
  use pi_mod,   only: pi_ref, pi_estimate, pi_error
  implicit none (type, external)

  character(len=:), allocatable :: method, n_text
  character(len=80) :: why
  integer(ik)       :: n, ios, arg_len, stat
  real(rk)          :: pi_est
  logical           :: ok

  ! --- 1. exactly two arguments are required -------------------------------
  if (command_argument_count() /= 2) then
    write (error_unit, '(a)') 'usage:   ./pi_cli.exe <midpoint|leibniz> <n>'
    write (error_unit, '(a)') 'example: ./pi_cli.exe midpoint 1000'
    ! error_unit is buffered when stderr is redirected to a file, and the
    ! runtime writes the ERROR STOP text straight to the file descriptor,
    ! bypassing that buffer.  Without this flush the usage lines are emitted
    ! last and appear *after* the backtrace in a redirected log.
    flush (error_unit)
    error stop 'expected exactly 2 command-line arguments'
  end if

  ! --- 2. fetch the arguments ----------------------------------------------
  ! Ask for the length first, allocate exactly that many characters, then
  ! fetch the value.  That is why method and n_text are deferred-length
  ! (len=:) -- no guessing at a buffer size, and no truncation.
  call get_command_argument(1, length=arg_len, status=stat)
  if (stat /= 0) error stop 'cannot read command-line argument 1'
  allocate (character(len=arg_len) :: method)
  call get_command_argument(1, value=method, status=stat)
  if (stat /= 0) error stop 'cannot read command-line argument 1'

  call get_command_argument(2, length=arg_len, status=stat)
  if (stat /= 0) error stop 'cannot read command-line argument 2'
  allocate (character(len=arg_len) :: n_text)
  call get_command_argument(2, value=n_text, status=stat)
  if (stat /= 0) error stop 'cannot read command-line argument 2'

  ! --- 3. convert argument 2 to an integer (an internal read) --------------
  read (n_text, *, iostat=ios) n
  if (ios /= 0) error stop 'argument 2 is not an integer: ' // n_text

  ! --- 4. echo the input so the audience can confirm it was read correctly -
  write (*, '(a)')     ' Hello Fortran -- pi approximation'
  write (*, '(a)')     ' ---------------------------------'
  write (*, '(a)')     ' source     : command line'
  write (*, '(a, a)')  ' method     : ', method
  write (*, '(a, i0)') ' n          : ', n

  ! --- 5. compute ----------------------------------------------------------
  call pi_estimate(method, n, pi_est, ok, why)
  if (.not. ok) error stop 'bad input: ' // trim(why)

  ! --- 6. report, including the program's own error ------------------------
  write (*, '(a)')         ' ---------------------------------'
  write (*, '(a, f0.12)')  ' pi (est)   : ', pi_est
  write (*, '(a, f0.12)')  ' pi (ref)   : ', pi_ref
  write (*, '(a, es10.3)') ' abs error  : ', pi_error(pi_est)
end program pi_cli
