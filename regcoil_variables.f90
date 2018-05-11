module regcoil_variables

  use stel_kinds

  implicit none

  integer :: general_option=1
  logical :: verbose = .true.

  integer :: ntheta_plasma=64, nzeta_plasma=64, nzetal_plasma
  integer :: ntheta_coil=64, nzeta_coil=64, nzetal_coil

  integer :: geometry_option_plasma = 0
  integer :: geometry_option_coil = 0

  real(dp) :: R0_plasma = 10.0, R0_coil = 10.0
  real(dp) :: a_plasma = 0.5, a_coil = 1.0
  real(dp) :: separation=0.2

  character(len=200) :: wout_filename=""
  character(len=200) :: shape_filename_plasma=""
  character(len=200) :: nescin_filename=""
  character(len=200) :: nescout_filename=""
  character(len=200) :: efit_filename=""
  character(len=200) :: output_filename

  real(dp), dimension(:), allocatable :: theta_plasma, zeta_plasma, zetal_plasma
  real(dp), dimension(:,:,:), allocatable :: r_plasma, drdtheta_plasma, drdzeta_plasma, normal_plasma

  real(dp), dimension(:,:), allocatable :: g, f_x, f_y, f_z
  real(dp), dimension(:), allocatable :: h, d_x, d_y, d_z

  real(dp), dimension(:,:), allocatable :: Bnormal_from_plasma_current
  real(dp), dimension(:,:), allocatable :: Bnormal_from_net_coil_currents
  real(dp), dimension(:,:), allocatable :: matrix_B, matrix_K, inductance
  real(dp), dimension(:,:), allocatable :: single_valued_current_potential_mn
  real(dp), dimension(:,:,:), allocatable :: single_valued_current_potential_thetazeta
  real(dp), dimension(:,:,:), allocatable :: current_potential
  real(dp), dimension(:), allocatable :: RHS_B, RHS_K
  real(dp), dimension(:,:,:), allocatable :: Bnormal_total
  real(dp), dimension(:,:,:), allocatable :: K2
  real(dp), dimension(:), allocatable :: chi2_B, chi2_K, max_Bnormal, max_K

  real(dp), dimension(:), allocatable :: theta_coil, zeta_coil, zetal_coil
  real(dp), dimension(:,:,:), allocatable :: r_coil, drdtheta_coil, drdzeta_coil, normal_coil

  real(dp), dimension(:,:), allocatable :: norm_normal_plasma, norm_normal_coil
  real(dp), dimension(:,:), allocatable :: basis_functions

  real(dp) :: dtheta_plasma, dzeta_plasma, dtheta_coil, dzeta_coil

  integer :: mpol_coil=12
  integer :: ntor_coil=12
  integer :: mnmax_coil
  integer :: num_basis_functions
  integer, dimension(:), allocatable :: xm_coil, xn_coil

  real(dp), dimension(:), allocatable :: rmns, zmnc, rmnc, zmns
  integer :: mnmax, nfp
  integer, dimension(:), allocatable :: xm, xn
  logical :: lasym

  integer :: save_level = 3
  integer :: nfp_imposed = 1

  integer :: symmetry_option = 1
  real(dp) :: total_time

  integer :: efit_num_modes = 10
  real(dp) :: efit_psiN = 0.98

  real(dp) :: mpol_transform_refinement=5, ntor_transform_refinement=1
  real(dp) :: area_plasma, area_coil, volume_plasma, volume_coil

  real(dp) :: net_poloidal_current_Amperes = 1
  real(dp) :: net_toroidal_current_Amperes = 0
  logical :: load_bnorm = .false.
  character(len=200) :: bnorm_filename=""
  real(dp) :: curpol = 1  ! number which multiplies data in bnorm file.

  integer :: nlambda = 4
  real(dp) :: lambda_min = 1.0d-19, lambda_max = 1.0d-13
  real(dp), dimension(:), allocatable :: lambda

  real(dp), dimension(:,:), allocatable :: matrix, this_current_potential
  real(dp), dimension(:), allocatable :: RHS, solution
  real(dp), dimension(:), allocatable :: KDifference_x, KDifference_y, KDifference_z
  real(dp), dimension(:,:), allocatable :: this_K2_times_N

  ! Variables needed by LAPACK:
  integer :: LAPACK_INFO, LAPACK_LWORK
  real(dp), dimension(:), allocatable :: LAPACK_WORK
  integer, dimension(:), allocatable :: LAPACK_IPIV

  integer :: target_option = 1
  real(dp) :: current_density_target = 8.0d+6
  real(dp) :: lambda_search_tolerance = 1.0d-5
  integer :: exit_code = 0
  real(dp) :: chi2_B_target = 0

  ! Variables added to interact with stellopt
  !
  !     FOR REGCOIL WINDING SURFACE VARIATION - These numbers should match those
  !     in LIBSTELL/Sources/Modules/vparams.f
  !
  INTEGER, PARAMETER :: mpol_rcws = 32    ! maximum poloidal mode number (+/-)
  INTEGER, PARAMETER :: ntor_rcws = 32    ! maximum toroidal mode number (+/-)
  real(dp), dimension(-mpol_rcws:mpol_rcws,-ntor_rcws:ntor_rcws) :: rc_rmnc_stellopt, rc_rmns_stellopt, &
                                                                    rc_zmnc_stellopt, rc_zmns_stellopt

  namelist / regcoil_nml / ntheta_plasma, nzeta_plasma, ntheta_coil, nzeta_coil, &
       geometry_option_plasma, geometry_option_coil, &
       R0_plasma, R0_coil, a_plasma, a_coil, &
       separation, wout_filename, &
       save_level, nfp_imposed, symmetry_option, &
       mpol_coil, ntor_coil, &
       nescin_filename, efit_filename, efit_psiN, efit_num_modes, &
       mpol_transform_refinement, ntor_transform_refinement, &
       net_poloidal_current_Amperes, net_toroidal_current_Amperes, &
       load_bnorm, bnorm_filename, &
       shape_filename_plasma, nlambda, lambda_min, lambda_max, general_option, verbose, nescout_filename, &
       target_option, current_density_target, lambda_search_tolerance

end module regcoil_variables
