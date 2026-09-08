!-----------------------------------------------------------------------------
! File Name:  pi_namelist.f90
! Purpose:    Approximate pi using values read from a Fortran namelist file
!             whose name is supplied as a command-line argument.  Compare
!             with ex2: the same two values, but the language does the
!             parsing.  Names may appear in any order, and a name left out of
!             the file simply keeps the default set in the declaration.
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
! Run:        ./pi_namelist.exe pi_input.nml
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
! nml_util_mod -- count the namelist groups in a file before reading them.
!
! Why this exists: GFortran reports a MALFORMED namelist group exactly the way
! it reports a clean end of file -- iostat is the end-of-file value and iomsg
! is "End of file" in both cases.  A loop that simply reads until end of file
! therefore treats a typo in the last group as "nothing left to read" and
! exits successfully, having silently skipped it.  Counting the group headers
! first turns that silent skip into a hard error, which is what we want: a
! program that quietly does less than you asked is worse than one that stops.
!-----------------------------------------------------------------------------
module nml_util_mod
  use kind_mod, only: ik
  implicit none (type, external)
  private
  public :: count_nml_groups

  integer(ik), parameter :: max_line = 512_ik

  contains

  !> NOT pure -- external file I/O.  Counts the lines whose first token is the
  !> group header, e.g. '&pi_input'.
  subroutine count_nml_groups(file_name, group, n_groups, stat, msg)
    character(len=*), intent(in)  :: file_name, group
    integer(ik),      intent(out) :: n_groups, stat
    character(len=*), intent(out) :: msg

    character(len=max_line) :: line, text
    integer(ik)             :: unit, ios, tok

    n_groups = 0_ik
    stat     = 0_ik
    msg      = ''

    open (newunit=unit, file=file_name, status='old', action='read', &
          iostat=ios, iomsg=msg)
    if (ios /= 0) then
      stat = ios
      return
    end if

    do
      read (unit, '(a)', iostat=ios) line
      if (ios /= 0) exit                  ! end of file
      text = adjustl(line)                ! ignore any leading blanks
      tok  = index(text, ' ')             ! the first blank ends the token
      if (tok > 1_ik) then
        if (text(1:tok-1_ik) == group) n_groups = n_groups + 1_ik
      end if
    end do

    close (unit)
  end subroutine count_nml_groups
end module nml_util_mod

!-----------------------------------------------------------------------------
! Main program: read a namelist file named on the command line, approximate
! pi, report.
!-----------------------------------------------------------------------------
program pi_namelist
  use iso_fortran_env, only: error_unit, iostat_end
  use kind_mod, only: ik, rk
  use pi_mod,   only: pi_ref, pi_estimate, pi_error
  use nml_util_mod, only: count_nml_groups
  implicit none (type, external)

  ! Namelist members are declared with defaults.  Delete either name from the
  ! input file and the program still runs, using the value set here.  A
  ! namelist target must be fixed-length, so method is len=32 rather than
  ! deferred-length.
  character(len=32) :: method = 'midpoint'
  integer(ik)       :: n      = 1000_ik

  namelist /pi_input/ method, n

  character(len=:), allocatable :: nml_file
  character(len=80)             :: why, msg
  integer(ik)                   :: unit, ios, arg_len, stat, n_case, n_groups
  character(len=*), parameter   :: group_name = '&pi_input'
  real(rk)                      :: pi_est
  logical                       :: ok

  ! --- 1. one argument: the name of the namelist file ----------------------
  if (command_argument_count() /= 1) then
    write (error_unit, '(a)') 'usage:   ./pi_namelist.exe <namelist file>'
    write (error_unit, '(a)') 'example: ./pi_namelist.exe pi_input.nml'
    ! error_unit is buffered when stderr is redirected to a file, and the
    ! runtime writes the ERROR STOP text straight to the file descriptor,
    ! bypassing that buffer.  Without this flush the lines above are emitted
    ! last and appear *after* the backtrace in a redirected log.
    flush (error_unit)
    error stop 'expected exactly 1 command-line argument'
  end if

  call get_command_argument(1, length=arg_len, status=stat)
  if (stat /= 0) error stop 'cannot read command-line argument 1'
  allocate (character(len=arg_len) :: nml_file)
  call get_command_argument(1, value=nml_file, status=stat)
  if (stat /= 0) error stop 'cannot read command-line argument 1'

  ! --- 2. how many &pi_input groups does the file hold? --------------------
  ! Count them BEFORE reading.  See nml_util_mod for why a plain
  ! read-until-end-of-file loop cannot be trusted here.
  call count_nml_groups(nml_file, group_name, n_groups, stat, msg)
  if (stat /= 0) error stop 'cannot open ' // nml_file // ': ' // trim(msg)
  if (n_groups == 0_ik) error stop 'no ' // group_name // ' group in ' // nml_file

  open (newunit=unit, file=nml_file, status='old', action='read', &
        iostat=ios, iomsg=msg)
  if (ios /= 0) error stop 'cannot open ' // nml_file // ': ' // trim(msg)

  write (*, '(a)')     ' Hello Fortran -- pi approximation'
  write (*, '(a)')     ' ================================='
  write (*, '(a, a)')  ' source     : namelist ', nml_file
  write (*, '(a, i0)') ' cases      : ', n_groups

  ! Rewind so the search for the first group starts at the top of the file.
  rewind (unit)

  ! Namelist reading is SEQUENTIAL: each read picks up the NEXT matching group
  ! rather than the first, so reading n_groups times without rewinding walks
  ! the whole file.  Variables keep their values between reads, so a name left
  ! out of a later group inherits whatever the previous group set.
  do n_case = 1_ik, n_groups
    read (unit, nml=pi_input, iostat=ios, iomsg=msg)
    ! Because the group count is known, ANY failure here is a real error --
    ! including the malformed group that would otherwise look like end of file.
    if (ios /= 0) then
      write (error_unit, '(a, i0, a, a)') 'failed reading group ', n_case, &
                                          ' of ' // nml_file // ': ', trim(msg)
      ! flush for the same reason as the usage block above
      flush (error_unit)
      error stop 'bad namelist group'
    end if

    ! --- 3. echo this group so the audience can confirm the read -----------
    write (*, '(a)')     ''
    write (*, '(a, i0, a, i0)') ' case       : ', n_case, ' of ', n_groups
    write (*, '(a)')     ' ---------------------------------'
    write (*, '(a, a)')  ' method     : ', trim(method)
    write (*, '(a, i0)') ' n          : ', n

    ! --- 4. compute --------------------------------------------------------
    call pi_estimate(method, n, pi_est, ok, why)
    if (.not. ok) error stop 'bad input: ' // trim(why)

    ! --- 5. report ---------------------------------------------------------
    write (*, '(a, f0.12)')  ' pi (est)   : ', pi_est
    write (*, '(a, f0.12)')  ' pi (ref)   : ', pi_ref
    write (*, '(a, es10.3)') ' abs error  : ', pi_error(pi_est)
  end do

  close (unit)
end program pi_namelist
