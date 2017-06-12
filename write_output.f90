subroutine write_output

  use global_variables
  use ezcdf

  implicit none

  integer :: ierr, ncid

  ! Same convention as in VMEC:
  ! Prefix vn_ indicates the variable name used in the .nc file.

  ! Scalars:
  character(len=*), parameter :: &
       vn_nfp = "nfp", &
       vn_geometry_option_plasma = "geometry_option_plasma", &
       vn_geometry_option_coil = "geometry_option_coil", &
       vn_ntheta_plasma = "ntheta_plasma", &
       vn_nzeta_plasma = "nzeta_plasma", &
       vn_nzetal_plasma = "nzetal_plasma", &
       vn_ntheta_coil = "ntheta_coil", &
       vn_nzeta_coil = "nzeta_coil", &
       vn_nzetal_coil = "nzetal_coil", &
       vn_a_plasma  = "a_plasma", &
       vn_a_coil  = "a_coil", &
       vn_R0_plasma  = "R0_plasma", &
       vn_R0_coil  = "R0_coil", &
       vn_mpol_coil = "mpol_coil", &
       vn_ntor_coil = "ntor_coil", &
       vn_mnmax_coil = "mnmax_coil", &
       vn_num_basis_functions = "num_basis_functions", &
       vn_symmetry_option = "symmetry_option", &
       vn_area_plasma = "area_plasma", &
       vn_area_coil = "area_coil", &
       vn_volume_plasma = "volume_plasma", &
       vn_volume_coil = "volume_coil", &
       vn_net_poloidal_current_Amperes = "net_poloidal_current_Amperes", &
       vn_net_toroidal_current_Amperes = "net_toroidal_current_Amperes", &
       vn_curpol = "curpol", &
       vn_nlambda = "nlambda", &
       vn_totalTime = "totalTime", &
       vn_exit_code = "exit_code", &
       vn_chi2_B_target = "chi2_B_target", &
       vn_sensitivity_option = "sensitivity_option", &
       vn_normal_displacement_option = "normal_displacemenet_option", &
       vn_nmax_sensitivity = "nmax_sensitivity", &
       vn_mmax_sensitivity = "mmax_sensitivity", &
       vn_mnmax_sensitivity = "mnmax_sensitivity", &
       vn_nomega_coil = "nomega_coil"

  ! Arrays with dimension 1
  character(len=*), parameter :: &
       vn_theta_plasma = "theta_plasma", &
       vn_zeta_plasma = "zeta_plasma", &
       vn_zetal_plasma = "zetal_plasma", &
       vn_theta_coil = "theta_coil", &
       vn_zeta_coil = "zeta_coil", &
       vn_zetal_coil = "zetal_coil", &
       vn_xm_coil = "xm_coil", &
       vn_xn_coil = "xn_coil", &
       vn_h = "h", &
       vn_RHS_B = "RHS_B", &
       vn_RHS_K = "RHS_K", &
       vn_lambda = "lambda", &
       vn_chi2_B = "chi2_B", &
       vn_chi2_K = "chi2_K", &
       vn_max_Bnormal = "max_Bnormal", &
       vn_max_K = "max_K", &
       vn_xn_sensitivity = "xn_sensitivity", &
       vn_xm_sensitivity = "xm_sensitivity", &
       vn_d_x = "d_x", &
       vn_d_y = "d_y", &
       vn_d_z = "d_z", &
       vn_omega_coil = "omega_coil"

  ! Arrays with dimension 2
  character(len=*), parameter :: &
     vn_norm_normal_plasma  = "norm_normal_plasma", &
     vn_norm_normal_coil  = "norm_normal_coil", &
     vn_Bnormal_from_plasma_current = "Bnormal_from_plasma_current", &
     vn_Bnormal_from_net_coil_currents = "Bnormal_from_net_coil_currents", &
     vn_inductance = "inductance", &
     vn_g = "g", &
     vn_matrix_B = "matrix_B", &
     vn_matrix_K = "matrix_K", &
     vn_single_valued_current_potential_mn = "single_valued_current_potential_mn", &
! Sensitivity Output
     vn_dchi2Bdomega = "dchi2Bdomega", &
     vn_dchi2Kdomega = "dchi2Kdomega", &
     vn_dchi2domega = "dchi2domega", &
     vn_f_x = "f_x", &
     vn_f_y = "f_y", &
     vn_f_z = "f_z", &
     vn_dhdomega = "dhdomega", &
     vn_dchi2dr_normal = "dchi2dr_normal", &
     vn_domegadx = "domegadx", &
     vn_domegady = "domegady", &
     vn_domegadz = "domegadz"

  ! Arrays with dimension 3
  character(len=*), parameter :: &
    vn_r_plasma  = "r_plasma", &
    vn_r_coil  = "r_coil", &
    vn_drdtheta_plasma  = "drdtheta_plasma", &
    vn_drdtheta_coil  = "drdtheta_coil", &
    vn_drdzeta_plasma  = "drdzeta_plasma", &
    vn_drdzeta_coil  = "drdzeta_coil", &
    vn_normal_plasma = "normal_plasma", &
    vn_normal_coil = "normal_coil", &
    vn_single_valued_current_potential_thetazeta = "single_valued_current_potential_thetazeta", &
    vn_current_potential = "current_potential", &
    vn_Bnormal_total = "Bnormal_total", &
    vn_K2 = "K2", &
    vn_dnorm_normaldomega = "dnorm_normaldomega", &
    vn_dddomega = "dddomega", &
    vn_dgdomega = "dgdomega", &
    vn_dinductancedomega = "dinductancedomega", &
    vn_dnormxdomega = "dnormxdomega", &
    vn_dnormydomega = "dnormydomega", &
    vn_dnormzdomega = "dnormzdomega", &
    vn_dfxdomega = "dfxdomega", &
    vn_dfydomega = "dfydomega", &
    vn_dfzdomega = "dfzdomega"

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! Now create variables that name the dimensions.
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  ! Arrays with dimension 1:
  character(len=*), parameter, dimension(1) :: &
       ntheta_plasma_dim = (/'ntheta_plasma'/), &
       nzeta_plasma_dim = (/'nzeta_plasma'/), &
       nzetal_plasma_dim = (/'nzetal_plasma'/), &
       ntheta_coil_dim = (/'ntheta_coil'/), &
       nzeta_coil_dim = (/'nzeta_coil'/), &
       nzetal_coil_dim = (/'nzetal_coil'/), &
       mnmax_coil_dim = (/'mnmax_coil'/), &
       nthetanzeta_plasma_dim = (/'ntheta_nzeta_plasma'/), &
       num_basis_functions_dim = (/'num_basis_functions'/), &
       nlambda_dim = (/'nlambda'/), &
       nomega_coil_dim = (/'nomega_coil'/), &
       ntheta_times_nzeta_coil_dim = (/'ntheta_times_nzeta_coil'/)

  ! Arrays with dimension 2:
  ! The form of the array declarations here is inspired by
  ! http://stackoverflow.com/questions/21552430/gfortran-does-not-allow-character-arrays-with-varying-component-lengths
  character(len=*), parameter, dimension(2) :: &
       ntheta_nzeta_plasma_dim = (/ character(len=50) :: 'ntheta_plasma','nzeta_plasma'/), &
       ntheta_nzeta_coil_dim = (/ character(len=50) :: 'ntheta_coil','nzeta_coil'/), &
       nthetanzeta_plasma_nthetanzeta_coil_dim = (/ character(len=50) :: &
         'ntheta_nzeta_plasma','ntheta_times_nzeta_coil'/), &
       nthetanzeta_plasma_basis_dim = (/ character(len=50) :: &
         'ntheta_nzeta_plasma','num_basis_functions'/), &
       basis_basis_dim = (/ character(len=50) :: &
         'num_basis_functions','num_basis_functions'/), &
       basis_nlambda_dim = (/ character(len=50) :: 'num_basis_functions','nlambda'/), &
       nomega_coil_nlambda_dim = (/ character(len=50) :: 'nomega_coil', 'nlambda'/), &
       nthetanzeta_coil_basis_dim = (/ character(len=50) :: &
         'ntheta_times_nzeta_coil','num_basis_functions'/), &
       nomega_coil_nthetanzeta_plasma_dim = (/character(len=50) :: &
         'nomega_coil','ntheta_nzeta_plasma'/), &
       nlambda_nthetanzeta_coil_dim = (/character(len=50) :: &
          'nlambda', 'ntheta_times_nzeta_coil'/)

  ! Arrays with dimension 3:
  character(len=*), parameter, dimension(3) :: &
       xyz_ntheta_nzetal_plasma_dim = (/ character(len=50) :: 'xyz','ntheta_plasma','nzetal_plasma'/), &
       xyz_ntheta_nzetal_coil_dim = (/ character(len=50) :: 'xyz','ntheta_coil','nzetal_coil'/), &
       ntheta_nzeta_coil_nlambda_dim = (/ character(len=50) :: 'ntheta_coil','nzeta_coil','nlambda'/), &
       ntheta_nzeta_plasma_nlambda_dim = (/ character(len=50) :: 'ntheta_plasma','nzeta_plasma','nlambda'/), &
       nomega_coil_ntheta_nzeta_coil_dim = (/ character(len=50) :: 'nomega_coil', 'ntheta_coil', 'nzeta_coil'/), &
       xyz_nomega_coil_ntheta_nzetal_coil_dim = (/character(len=50) :: 'xyz', 'nomega_coil', 'ntheta_times_nzetal_coil'/), &
       nomega_coil_ntheta_times_nzeta_num_basis_functions_dim = (/character(len=50) :: 'nomega_coil', 'ntheta_times_nzeta_plasma', 'num_basis_functions' /), &
       nomega_coil_ntheta_times_nzeta_plasma_coil_dim = (/character(len=50) :: 'nomega_coil', &
         'ntheta_times_nzeta_plasma', 'ntheta_times_nzeta_coil'/), &
       nomega_coil_ntheta_nzetal_coil_dim = (/character(len=50) :: 'nomega_coil', 'ntheta_coil', &
         'nzetal_coil'/), &
       nomega_coil_ntheta_times_nzeta_coil_basis_dim = (/character(len=50):: 'nomega_coil', 'ntheta_times_nzeta_coil','num_basis_functions' /)

  print *,"Beginning write output."

  call cdf_open(ncid,outputFilename,'w',ierr)
  IF (ierr .ne. 0) then
     print *,"Error opening output file ",outputFilename
     stop
  end IF

  ! Scalars

  call cdf_define(ncid, vn_nfp, nfp)
  call cdf_define(ncid, vn_geometry_option_plasma, geometry_option_plasma)
  call cdf_define(ncid, vn_geometry_option_coil, geometry_option_coil)
  call cdf_define(ncid, vn_ntheta_plasma, ntheta_plasma)
  call cdf_define(ncid, vn_nzeta_plasma, nzeta_plasma)
  call cdf_define(ncid, vn_nzetal_plasma, nzetal_plasma)
  call cdf_define(ncid, vn_ntheta_coil, ntheta_coil)
  call cdf_define(ncid, vn_nzeta_coil, nzeta_coil)
  call cdf_define(ncid, vn_nzetal_coil, nzetal_coil)
  call cdf_define(ncid, vn_a_plasma, a_plasma)
  call cdf_define(ncid, vn_a_coil, a_coil)
  call cdf_define(ncid, vn_R0_plasma, R0_plasma)
  call cdf_define(ncid, vn_R0_coil, R0_coil)
  call cdf_define(ncid, vn_mpol_coil, mpol_coil)
  call cdf_define(ncid, vn_ntor_coil, ntor_coil)
  call cdf_define(ncid, vn_mnmax_coil, mnmax_coil)
  call cdf_define(ncid, vn_num_basis_functions, num_basis_functions)
  call cdf_define(ncid, vn_symmetry_option, symmetry_option)
  call cdf_define(ncid, vn_area_plasma, area_plasma)
  call cdf_define(ncid, vn_area_coil, area_coil)
  call cdf_define(ncid, vn_volume_plasma, volume_plasma)
  call cdf_define(ncid, vn_volume_coil, volume_coil)
  call cdf_define(ncid, vn_net_poloidal_current_Amperes, net_poloidal_current_Amperes)
  call cdf_define(ncid, vn_net_toroidal_current_Amperes, net_toroidal_current_Amperes)
  call cdf_define(ncid, vn_curpol, curpol)
  call cdf_define(ncid, vn_nlambda, nlambda)
  call cdf_define(ncid, vn_totalTime, totalTime)
  call cdf_define(ncid, vn_exit_code, exit_code)
  if (general_option==4 .or. general_option==5) call cdf_define(ncid, vn_chi2_B_target, chi2_B_target)
  call cdf_define(ncid, vn_sensitivity_option, sensitivity_option)
  call cdf_define(ncid, vn_normal_displacement_option, normal_displacement_option)
  if (sensitivity_option > 1) then
    call cdf_define(ncid, vn_mmax_sensitivity, mmax_sensitivity)
    call cdf_define(ncid, vn_nmax_sensitivity, nmax_sensitivity)
    call cdf_define(ncid, vn_mnmax_sensitivity, mnmax_sensitivity)
    call cdf_define(ncid, vn_nomega_coil, nomega_coil)
  endif

  ! Arrays with dimension 1

  call cdf_define(ncid, vn_theta_plasma, theta_plasma, dimname=ntheta_plasma_dim)
  call cdf_define(ncid, vn_zeta_plasma, zeta_plasma, dimname=nzeta_plasma_dim)
  call cdf_define(ncid, vn_zetal_plasma, zetal_plasma, dimname=nzetal_plasma_dim)
  call cdf_define(ncid, vn_theta_coil, theta_coil, dimname=ntheta_coil_dim)
  call cdf_define(ncid, vn_zeta_coil, zeta_coil, dimname=nzeta_coil_dim)
  call cdf_define(ncid, vn_zetal_coil, zetal_coil, dimname=nzetal_coil_dim)
  call cdf_define(ncid, vn_xm_coil, xm_coil, dimname=mnmax_coil_dim)
  call cdf_define(ncid, vn_xn_coil, xn_coil, dimname=mnmax_coil_dim)
  call cdf_define(ncid, vn_h, h, dimname=nthetanzeta_plasma_dim)
  call cdf_define(ncid, vn_RHS_B, RHS_B, dimname=num_basis_functions_dim)
  call cdf_define(ncid, vn_RHS_K, RHS_K, dimname=num_basis_functions_dim)
  call cdf_define(ncid, vn_lambda, lambda(1:Nlambda), dimname=nlambda_dim)
  call cdf_define(ncid, vn_chi2_B, chi2_B(1:Nlambda), dimname=nlambda_dim)
  call cdf_define(ncid, vn_chi2_K, chi2_K(1:Nlambda), dimname=nlambda_dim)
  call cdf_define(ncid, vn_max_Bnormal, max_Bnormal(1:Nlambda), dimname=nlambda_dim)
  call cdf_define(ncid, vn_max_K, max_K(1:Nlambda), dimname=nlambda_dim) ! We only write elements 1:Nlambda in case of a lambda search.
  if (sensitivity_option > 1) then
    call cdf_define(ncid, vn_xn_sensitivity, xn_sensitivity, dimname=nomega_coil_dim)
    call cdf_define(ncid, vn_xm_sensitivity, xm_sensitivity, dimname=nomega_coil_dim)
    call cdf_define(ncid, vn_omega_coil, omega_coil, dimname=nomega_coil_dim)
    if (save_level<1) then
      call cdf_define(ncid, vn_d_x, d_x, dimname=ntheta_times_nzeta_coil_dim)
      call cdf_define(ncid, vn_d_y, d_y, dimname=ntheta_times_nzeta_coil_dim)
      call cdf_define(ncid, vn_d_z, d_z, dimname=ntheta_times_nzeta_coil_dim)
    endif
  endif

  ! Arrays with dimension 2

  call cdf_define(ncid, vn_norm_normal_plasma,  norm_normal_plasma,  dimname=ntheta_nzeta_plasma_dim)
  call cdf_define(ncid, vn_norm_normal_coil,  norm_normal_coil,  dimname=ntheta_nzeta_coil_dim)
  call cdf_define(ncid, vn_Bnormal_from_plasma_current, Bnormal_from_plasma_current, dimname=ntheta_nzeta_plasma_dim)
  call cdf_define(ncid, vn_Bnormal_from_net_coil_currents, Bnormal_from_net_coil_currents, dimname=ntheta_nzeta_plasma_dim)
  if (save_level<1) then
  call cdf_define(ncid, vn_inductance, inductance, dimname=nthetanzeta_plasma_nthetanzeta_coil_dim)
  end if
  if (save_level<2) then
     call cdf_define(ncid, vn_g, g, dimname=nthetanzeta_plasma_basis_dim)
  end if
  call cdf_define(ncid, vn_single_valued_current_potential_mn, single_valued_current_potential_mn(:,1:Nlambda), &
       dimname=basis_nlambda_dim)
  ! Sensitivity output
  if (sensitivity_option > 1) then
    call cdf_define(ncid, vn_dchi2Bdomega, dchi2Bdomega(:,1:Nlambda),dimname=nomega_coil_nlambda_dim)
    call cdf_define(ncid, vn_dchi2Kdomega, dchi2Kdomega(:,1:Nlambda),dimname=nomega_coil_nlambda_dim)
    call cdf_define(ncid, vn_dchi2domega, dchi2domega(:,1:Nlambda),dimname=nomega_coil_nlambda_dim)
    call cdf_define(ncid, vn_dhdomega, dhdomega, dimname=nomega_coil_nthetanzeta_plasma_dim)
    call cdf_define(ncid, vn_dchi2dr_normal, dchi2dr_normal, dimname=&
      nlambda_nthetanzeta_coil_dim)

    if (save_level < 1) then
      call cdf_define(ncid, vn_f_x, f_x, dimname=nthetanzeta_coil_basis_dim)
      call cdf_define(ncid, vn_f_y, f_y, dimname=nthetanzeta_coil_basis_dim)
      call cdf_define(ncid, vn_f_z, f_z, dimname=nthetanzeta_coil_basis_dim)
    endif

  endif

  ! Arrays with dimension 3

  call cdf_define(ncid, vn_r_plasma,  r_plasma,  dimname=xyz_ntheta_nzetal_plasma_dim)
  call cdf_define(ncid, vn_r_coil,  r_coil,  dimname=xyz_ntheta_nzetal_coil_dim)

  if (save_level < 3) then
     call cdf_define(ncid, vn_drdtheta_plasma,  drdtheta_plasma,  dimname=xyz_ntheta_nzetal_plasma_dim)
     call cdf_define(ncid, vn_drdtheta_coil,  drdtheta_coil,  dimname=xyz_ntheta_nzetal_coil_dim)
     
     call cdf_define(ncid, vn_drdzeta_plasma,  drdzeta_plasma,  dimname=xyz_ntheta_nzetal_plasma_dim)
     call cdf_define(ncid, vn_drdzeta_coil,  drdzeta_coil,  dimname=xyz_ntheta_nzetal_coil_dim)

     call cdf_define(ncid, vn_normal_plasma,  normal_plasma,  dimname=xyz_ntheta_nzetal_plasma_dim)
     call cdf_define(ncid, vn_normal_coil,  normal_coil,  dimname=xyz_ntheta_nzetal_coil_dim)

  end if

  call cdf_define(ncid, vn_single_valued_current_potential_thetazeta, single_valued_current_potential_thetazeta(:,:,1:Nlambda), &
       dimname=ntheta_nzeta_coil_nlambda_dim)
  call cdf_define(ncid, vn_current_potential, current_potential(:,:,1:Nlambda), dimname=ntheta_nzeta_coil_nlambda_dim)
  call cdf_define(ncid, vn_Bnormal_total, Bnormal_total(:,:,1:Nlambda), dimname=ntheta_nzeta_plasma_nlambda_dim)
  call cdf_define(ncid, vn_K2, K2(:,:,1:Nlambda), dimname=ntheta_nzeta_coil_nlambda_dim)
  if (sensitivity_option > 1) then
    if (save_level < 1) then
      call cdf_define(ncid, vn_dnorm_normaldomega, dnorm_normaldomega, dimname=nomega_coil_ntheta_nzeta_coil_dim)
      call cdf_define(ncid, vn_dddomega, dddomega, dimname=xyz_nomega_coil_ntheta_nzetal_coil_dim)
      call cdf_define(ncid, vn_dgdomega, dgdomega, dimname=nomega_coil_ntheta_times_nzeta_num_basis_functions_dim)
      call cdf_define(ncid, vn_dinductancedomega, dinductancedomega, dimname = &
        nomega_coil_ntheta_times_nzeta_plasma_coil_dim)
      call cdf_define(ncid, vn_dnormxdomega, dnormxdomega, dimname=nomega_coil_ntheta_nzetal_coil_dim)
      call cdf_define(ncid, vn_dnormydomega, dnormydomega, dimname=nomega_coil_ntheta_nzetal_coil_dim)
      call cdf_define(ncid, vn_dnormzdomega, dnormzdomega, dimname=nomega_coil_ntheta_nzetal_coil_dim)
      call cdf_define(ncid, vn_dfxdomega, dfxdomega, dimname=nomega_coil_ntheta_times_nzeta_coil_basis_dim)
      call cdf_define(ncid, vn_dfydomega, dfydomega, dimname=nomega_coil_ntheta_times_nzeta_coil_basis_dim)
      call cdf_define(ncid, vn_dfzdomega, dfzdomega, dimname=nomega_coil_ntheta_times_nzeta_coil_basis_dim)
    endif
endif

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
  ! Done with cdf_define calls. Now write the data.
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1

  ! Scalars

  call cdf_write(ncid, vn_nfp, nfp)
  call cdf_write(ncid, vn_geometry_option_plasma, geometry_option_plasma)
  call cdf_write(ncid, vn_geometry_option_coil, geometry_option_coil)
  call cdf_write(ncid, vn_ntheta_plasma, ntheta_plasma)
  call cdf_write(ncid, vn_nzeta_plasma, nzeta_plasma)
  call cdf_write(ncid, vn_nzetal_plasma, nzetal_plasma)
  call cdf_write(ncid, vn_ntheta_coil, ntheta_coil)
  call cdf_write(ncid, vn_nzeta_coil, nzeta_coil)
  call cdf_write(ncid, vn_nzetal_coil, nzetal_coil)
  call cdf_write(ncid, vn_a_plasma, a_plasma)
  call cdf_write(ncid, vn_a_coil, a_coil)
  call cdf_write(ncid, vn_R0_plasma, R0_plasma)
  call cdf_write(ncid, vn_R0_coil, R0_coil)
  call cdf_write(ncid, vn_mpol_coil, mpol_coil)
  call cdf_write(ncid, vn_ntor_coil, ntor_coil)
  call cdf_write(ncid, vn_mnmax_coil, mnmax_coil)
  call cdf_write(ncid, vn_num_basis_functions, num_basis_functions)
  call cdf_write(ncid, vn_symmetry_option, symmetry_option)
  call cdf_write(ncid, vn_area_plasma, area_plasma)
  call cdf_write(ncid, vn_area_coil, area_coil)
  call cdf_write(ncid, vn_volume_plasma, volume_plasma)
  call cdf_write(ncid, vn_volume_coil, volume_coil)
  call cdf_write(ncid, vn_net_poloidal_current_Amperes, net_poloidal_current_Amperes)
  call cdf_write(ncid, vn_net_toroidal_current_Amperes, net_toroidal_current_Amperes)
  call cdf_write(ncid, vn_curpol, curpol)
  call cdf_write(ncid, vn_nlambda, nlambda)
  call cdf_write(ncid, vn_totalTime, totalTime)
  call cdf_write(ncid, vn_exit_code, exit_code)
  if (general_option==4 .or. general_option==5) call cdf_write(ncid, vn_chi2_B_target, chi2_B_target)
  call cdf_write(ncid, vn_sensitivity_option, sensitivity_option)
  call cdf_write(ncid, vn_normal_displacement_option, normal_displacement_option)
  if (sensitivity_option > 1) then
    call cdf_write(ncid, vn_mmax_sensitivity, mmax_sensitivity)
    call cdf_write(ncid, vn_nmax_sensitivity, nmax_sensitivity)
    call cdf_write(ncid, vn_mnmax_sensitivity, mnmax_sensitivity)
    call cdf_write(ncid, vn_nomega_coil, nomega_coil)
  endif

  ! Arrays with dimension 1

  call cdf_write(ncid, vn_theta_plasma, theta_plasma)
  call cdf_write(ncid, vn_zeta_plasma, zeta_plasma)
  call cdf_write(ncid, vn_zetal_plasma, zetal_plasma)
  call cdf_write(ncid, vn_theta_coil, theta_coil)
  call cdf_write(ncid, vn_zeta_coil, zeta_coil)
  call cdf_write(ncid, vn_zetal_coil, zetal_coil)
  call cdf_write(ncid, vn_xm_coil, xm_coil)
  call cdf_write(ncid, vn_xn_coil, xn_coil)
  call cdf_write(ncid, vn_h, h)
  call cdf_write(ncid, vn_RHS_B, RHS_B)
  call cdf_write(ncid, vn_RHS_K, RHS_K)
  call cdf_write(ncid, vn_lambda, lambda(1:Nlambda))
  call cdf_write(ncid, vn_chi2_B, chi2_B(1:Nlambda))
  call cdf_write(ncid, vn_chi2_K, chi2_K(1:Nlambda))
  call cdf_write(ncid, vn_max_Bnormal, max_Bnormal(1:Nlambda))
  call cdf_write(ncid, vn_max_K, max_K(1:Nlambda))
  if (sensitivity_option > 1) then
    call cdf_write(ncid, vn_xn_sensitivity, xn_sensitivity)
    call cdf_write(ncid, vn_xm_sensitivity, xm_sensitivity)
    call cdf_write(ncid, vn_omega_coil, omega_coil)
    if (save_level < 1) then
      call cdf_write(ncid, vn_d_x, d_x)
      call cdf_write(ncid, vn_d_y, d_y)
      call cdf_write(ncid, vn_d_z, d_z)
    endif
  endif

  ! Arrays with dimension 2

  call cdf_write(ncid, vn_norm_normal_plasma,  norm_normal_plasma)
  call cdf_write(ncid, vn_norm_normal_coil,  norm_normal_coil)
  call cdf_write(ncid, vn_Bnormal_from_plasma_current, Bnormal_from_plasma_current)
  call cdf_write(ncid, vn_Bnormal_from_net_coil_currents, Bnormal_from_net_coil_currents)
  if (save_level<1) then
     call cdf_write(ncid, vn_inductance, inductance)
  end if
  if (save_level<2) then
     call cdf_write(ncid, vn_g, g)
  end if

  call cdf_write(ncid, vn_single_valued_current_potential_mn, single_valued_current_potential_mn(:,1:Nlambda))
  if (sensitivity_option > 1) then
    call cdf_write(ncid, vn_dchi2Bdomega, dchi2Bdomega(:,1:Nlambda))
    call cdf_write(ncid, vn_dchi2Kdomega, dchi2Kdomega(:,1:Nlambda))
    call cdf_write(ncid, vn_dchi2domega, dchi2domega(:,1:Nlambda))
    !call cdf_write(ncid, vn_domegadx, domegadx)
    !call cdf_write(ncid, vn_domegady, domegady)
    !call cdf_write(ncid, vn_domegadz, domegadz)
    call cdf_write(ncid, vn_dchi2dr_normal, dchi2dr_normal(1:nlambda,:))

    if (save_level < 1) then
      call cdf_write(ncid, vn_f_x, f_x)
      call cdf_write(ncid, vn_f_y, f_y)
      call cdf_write(ncid, vn_f_z, f_z)
      call cdf_write(ncid, vn_dhdomega, dhdomega)
    endif
  endif

  ! Arrays with dimension 3

  call cdf_write(ncid, vn_r_plasma, r_plasma)
  call cdf_write(ncid, vn_r_coil, r_coil)

  if (save_level < 3) then
     call cdf_write(ncid, vn_drdtheta_plasma, drdtheta_plasma)
     call cdf_write(ncid, vn_drdtheta_coil, drdtheta_coil)

     call cdf_write(ncid, vn_drdzeta_plasma, drdzeta_plasma)
     call cdf_write(ncid, vn_drdzeta_coil, drdzeta_coil)

     call cdf_write(ncid, vn_normal_plasma, normal_plasma)
     call cdf_write(ncid, vn_normal_coil, normal_coil)

  end if

  call cdf_write(ncid, vn_single_valued_current_potential_thetazeta, single_valued_current_potential_thetazeta(:,:,1:Nlambda))
  call cdf_write(ncid, vn_current_potential, current_potential(:,:,1:Nlambda))
  call cdf_write(ncid, vn_Bnormal_total, Bnormal_total(:,:,1:Nlambda))
  call cdf_write(ncid, vn_K2, K2(:,:,1:Nlambda))
  if (sensitivity_option > 1) then
    if (save_level < 1) then
      call cdf_write(ncid, vn_dnorm_normaldomega, dnorm_normaldomega)
      call cdf_write(ncid, vn_dddomega, dddomega)
      call cdf_write(ncid, vn_dgdomega, dgdomega)
      call cdf_write(ncid, vn_dinductancedomega, dinductancedomega)
      call cdf_write(ncid, vn_dnormxdomega, dnormxdomega)
      call cdf_write(ncid, vn_dnormydomega, dnormydomega)
      call cdf_write(ncid, vn_dnormzdomega, dnormzdomega)
      call cdf_write(ncid, vn_dfxdomega, dfxdomega)
      call cdf_write(ncid, vn_dfydomega, dfydomega)
      call cdf_write(ncid, vn_dfzdomega, dfzdomega)
    endif
  endif

  ! Finish up:
  call cdf_close(ncid)

  print *,"Write output complete."

end subroutine write_output
