      module Photons_FlatSP
      use ModuleForCompScatEsti
      use PhotoElectron
      implicit none 

      type, public, extends(Photon_ForEstimation) :: Photon_FlatSP 
      contains 
!******************************************************************************************************* 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
          !procedure, public :: Calc_Phot_Inform_At_Observer_Diffuse_Reflec_phi   =>   &
          !                     Calc_Phot_Inform_At_Observer_Diffuse_Reflec_phi_Sub 
          procedure, public :: Set_Initial_Values_For_Photon_Parameters    =>    &
                               Set_Initial_Values_For_Photon_Parameters_Sub
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          procedure, public :: Generate_A_Photon   =>   Generate_A_Photon_Sub
          procedure, public :: Determine_P_Of_Scatt_Site_And_Quantities_At_p    =>   &
                               Determine_P_Of_Scatt_Site_And_Quantities_At_p_sub
          procedure, public :: Set_InI_Conditions_For_Next_Scattering    =>    &
                               Set_InI_Conditions_For_Next_Scattering_Sub
          procedure, public :: FIRST_SCATTERING_OF_PHOT_ELCE   =>    FIRST_SCATTERING_OF_PHOT_ELCE_Sub
          procedure, public :: Photon_Electron_Scattering   =>   Photon_Electron_Scattering_Sub 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      end type Photon_FlatSP
  
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
      !private :: Calc_Phot_Inform_At_Observer_Diffuse_Reflec_phi_Sub 
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      private :: Set_Initial_Values_For_Photon_Parameters_Sub
      private :: Determine_P_Of_Scatt_Site_And_Quantities_At_p_sub
      private :: Set_InI_Conditions_For_Next_Scattering_Sub
      private :: FIRST_SCATTERING_OF_PHOT_ELCE_Sub
      private :: Photon_Electron_Scattering_Sub 
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
 
      contains     
  

!*******************************************************************************************************
      subroutine Set_Initial_Values_For_Photon_Parameters_Sub( this, T_elec, T_bb, tau, &
                            Emitter, CrossSec_filename )
!*******************************************************************************************************
      implicit none
      class(Photon_FlatSP) :: this
      TYPE(Photon_Emitter_BB), intent(inout) :: Emitter 
      real(mcp), intent(in) :: T_elec, T_bb, tau
      character*80, intent(inout) :: CrossSec_filename
      integer :: i
      real(mcp) :: dy

!~~~~~~~~~~~~~~~~~~~~Emitte a photon and take its parameters as initial values~~~~~~~~~~~~~~~~~~~~~~~~~~
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
!| Set Initial conditions for the Emitter
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !this%n_e = 1.D19
      Emitter%tau_max = tau
      !Emitter%Z_max = tau / Sigma_T / phot%n_e  
      Emitter%T_s = T_bb !1.D-6 * 10.D0
      CALL Emitter%Set_Emin_Emax()   
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!| Set Initial conditions for the Photon                     !
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !E_low = !Emitter%E_low1 !1.D-5
      !E_up = !Emitter%E_up1 !1.D1 
      !this%nu_low = Emitter%nu_low
      !this%nu_up = Emitter%nu_up
      this%ln_nu1 = Emitter%ln_nu1
      this%ln_nu2 = Emitter%ln_nu2
      this%logE_low = DLOG10(1.D-6)
      this%logE_up = DLOG10(1.D1) 
      this%T_e = T_elec !0.11D0 * mec2
      this%T_s = T_bb
      this%log10_Tbb = dlog10(mec2)!( T_bb )
      !write(*, fmt="(' ', 'mest=', 2ES16.7)")DLOG10(Emitter%E_low1), DLOG10(Emitter%E_up1)
      
      this%tau_max = tau 
      this%n_e1 = 1.D20
      !this%n_e2 = 1.D27
      this%ne_times_SigmaT = this%n_e1 * Sigma_T
      this%z_max = tau / this%ne_times_SigmaT
      this%z_max1 = tau * 100000.00001D0 / this%ne_times_SigmaT
      this%effect_number = 0
      write(*, *)'fsd', tau, this%ne_times_SigmaT, this%z_max
      !stop
      this%CrossSectFileName = CrossSec_filename !'./data/SigmaArrayFST11.dat'

      CALL this%Set_Cross_Section_3Te()
      CALL Set_psi_phi_chi_zera_array() 
      CALL PhotoElect_1H_COH_INCOH_CSect()
      CALL Set_PhotoElect_CS_array()
     
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !this%mu_esti(1) = 0.49D0
      !this%smu_esti(1) = dsqrt(one - this%mu_esti(1)**2)
      !this%mu_esti(2) = 0.65D0
      !this%smu_esti(2) = dsqrt(one - this%mu_esti(2)**2)
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      this%y1 = -5.D0
      this%y2 = 1.D0
      this%dy = ( this%y2 - this%y1 ) / vL_sc_up
      do i = 0, vL_sc_up
          this%E_array_esti(i) = T_bb * 10.D0**(this%y1 + this%dy * i)
      enddo
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      dy = one / Num_mu
      !do i = 0, Num_mu 
          !this%mu_estimates(1) = 0.1D0
          !this%smu_estimates(1) = dsqrt(one - this%mu_estimates(1)**2)
          !this%mu_estimates(2) = 0.5D0
          !this%smu_estimates(2) = dsqrt(one - this%mu_estimates(2)**2)
          !this%mu_estimates(3) = 0.9D0
          !this%smu_estimates(3) = dsqrt(one - this%mu_estimates(3)**2)

          this%mu_estimates(1) = 0.11D0
          this%mu_estimates(2) = 0.5D0
          !this%mu_estimates(3) = 0.1D0 
          this%smu_estimates = dsqrt(one - this%mu_estimates **2)
      !enddo 
      dy = twopi / Num_phi
      do i = 0, Num_phi-1
          !x = ( ( bb - aa ) * x100(j) + ( bb + aa ) ) / two 
          this%phi_estimates(i) = twopi / (Num_phi-1) * i !( twopi * x100(i) + twopi ) / two 
          this%sin_phi_esti(i) = dsin(this%phi_estimates(i))
          this%cos_phi_esti(i) = dcos(this%phi_estimates(i))
          !write(*, *)'f1 = ', dy, this%phi_estimates(i), this%sin_phi_esti(i)
      enddo 
      this%P_mu_normal = one / twopi !6.D0 / 7.D0 
      this%P_nu_normal = one / ( Emitter%ln_nu2 - Emitter%ln_nu1 )
      
      !write(*, *)'f2 = ', one / ( Emitter%ln_nu2 - Emitter%ln_nu1 ), Emitter%ln_nu2, Emitter%ln_nu1, &
      !    dlog10(Emitter%E_up1 / T_bb), dlog10( Emitter%E_low1 / T_bb )
      !stop
      !dy = twopi / N_esti_phi
      !do i = 0, N_esti_phi
      !    this%phi_esti(i) = dy * i
      !    this%sin_phi_esti(i) = dsin(this%phi_esti(i))
      !    this%cos_phi_esti(i) = dcos(this%phi_esti(i))
      !enddo 
      !this%v_L_v_i_mu011 = zero
      !this%v_L_v_i_mu050 = zero  
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      end subroutine Set_Initial_Values_For_Photon_Parameters_Sub


!*******************************************************************************************************
      subroutine Generate_A_Photon_Sub( this, Emitter )
!*******************************************************************************************************
      implicit none
      class(Photon_FlatSP) :: this
      TYPE(Photon_Emitter_BB), intent(inout) :: Emitter  
      
      
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      CALL Emitter%get_Phot4k_CtrCF_CovCF_BoundReflec() 
      !Emitter%Vector_of_Momentum(1:3) = Emitter%Phot4k_CtrCF(2:4) / Emitter%Phot4k_CtrCF(1)
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
      this%z_tau = this%z_max
      this%f4_CF = Emitter%f4_CF 
      this%Vector_of_Momentum_ini = Emitter%Vector_of_Momentum
      !this%Vector_of_position_ini = Emitter%Vector_of_position
      this%Phot4k_CtrCF_ini = Emitter%Phot4k_CtrCF  
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
      this%E_ini = DABS( Emitter%Phot4k_CtrCF(1) ) 
      !write(*, *)'f1 = ', this%E_ini
      this%Sigma_a_E_ini = this%sigma_fn( this%E_ini )! * this%n_e1 
      this%ne_times_Sigma_a = this%Sigma_a_E_ini * this%n_e1 
      !write(*, *)'f1333 = ', this%Sigma_KN_E_ini, this%E_ini
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
      this%w_ini = Emitter%w_ini_em 
      this%w_ini0 = Emitter%w_ini_em
      this%Q_sp = zero
      this%U_sp = zero
      this%V_sp = zero
      this%delta_pd = zero
      this%Psi_I = one
      this%Psi_Q = zero
      this%Psi_U = zero
      this%Psi_V = zero
      this%Vector_Stokes4_CF(1) = one
      this%Vector_Stokes4_CF(2) = zero
      this%Vector_Stokes4_CF(3) = zero
      this%Vector_Stokes4_CF(4) = one
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
      !call this%get_J_emissivity_for_estimation()
      call this%get_J_emissivity_for_estimation_Phiarr()
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
      END SUBROUTINE Generate_A_Photon_Sub

!************************************************************************************
      SUBROUTINE Determine_P_Of_Scatt_Site_And_Quantities_At_p_sub( this ) 
!************************************************************************************
      IMPLICIT NONE
      class(Photon_FlatSP) :: this  
   
      this%z_tau = this%Get_scatter_distance_BoundReflec_new( )    
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
      this%w_ini = this%w_ini * this%NormalA  ! * dexp( - this%CROS_absorption )
      this%Phot4k_CtrCF_At_p = this%Phot4k_CtrCF_ini   
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~      
      RETURN
      END SUBROUTINE Determine_P_Of_Scatt_Site_And_Quantities_At_p_sub



!************************************************************************************
      SUBROUTINE FIRST_SCATTERING_OF_PHOT_ELCE_Sub( this, sphot )
!************************************************************************************
      IMPLICIT NONE
      class(Photon_FlatSP) :: this
      TYPE(ScatPhoton_KN), INTENT(INOUT) :: sphot
      real(mcp) :: Sigma_COH, Sigma_INCOH, P_Rayl, P_Comp, P_fluor, xi_1, vLv
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
      sphot%Phot4k_CtrCF = this%Phot4k_CtrCF_At_p 
      sphot%delta_pd = this%delta_pd
      sphot%f4_CF    = this%f4_CF 
      sphot%Vector_Stokes4_CF = this%Vector_Stokes4_CF 
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      CALL sphot%Set_Photon_Tetrad_In_CF()
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !CALL sphot%Get_gama_mu_phi_Of_Scat_Elec( T_e )
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      CALL sphot%Get_gama_mu_phi_Of_Scatter_Electron_HXM( this%T_e ) 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      CALL sphot%Set_Elec_Tetrad_In_CF()
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      CALL sphot%StokesPara_Rotation_Matrix(sphot%Elec_Phot_phi, sphot%Vector_Stokes4_CF)
      !sphot%Vector_Stokes4_ECF = sphot%Vector_Stokes4_CF
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      CALL sphot%Set_Phot4k_In_Elec_CF()
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
      CALL sphot%Set_Phot_Tetrad1_In_Elec_CF() 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      CALL this%Making_An_Estimation_One_MC_Component_1( sphot )
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
      CALL sphot%Compton_Scattering_With_Zero_QU_StokesVec()
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
      END SUBROUTINE FIRST_SCATTERING_OF_PHOT_ELCE_Sub
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
 

!************************************************************************************
      SUBROUTINE Set_InI_Conditions_For_Next_Scattering_Sub( this, sphot )
!************************************************************************************
      IMPLICIT NONE
      class(Photon_FlatSP) :: this 
      TYPE(ScatPhoton_KN), INTENT(INOUT) :: sphot
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      this%Phot4k_CtrCF_ini = sphot%Scattered_Phot4k_CF 
      this%Vector_of_Momentum_ini(1:3) = this%Phot4k_CtrCF_ini(2:4) / dabs( this%Phot4k_CtrCF_ini(1) )
      if( isnan( this%Vector_of_Momentum_ini(3) ) )write(*, *)'mmsf=', this%Phot4k_CtrCF_ini

!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
      this%Vector_Stokes4_CF = sphot%Vector_Stokes4_ECF_scat 
      this%f4_CF    = sphot%f4_scat_CF 
      !write(*, fmt="(' ', A5, 1ES18.7)")'ss1=', &
      !    Vector3D_Inner_Product( this%Phot4k_CtrCF_ini(2: 4), this%f4_CF(2: 4) ) 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
      this%E_ini = DABS( this%Phot4k_CtrCF_ini(1) ) 
      !write(*, fmt = "(' ', A10, ES20.6, I10)")'f1 = ', this%E_ini, this%scatter_times
      this%Sigma_a_E_ini = this%sigma_fn( this%E_ini )
      this%ne_times_Sigma_a = this%Sigma_a_E_ini * this%n_e1
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
      END SUBROUTINE Set_InI_Conditions_For_Next_Scattering_Sub
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
 

!************************************************************************************
      SUBROUTINE Photon_Electron_Scattering_Sub( this, sphot )
!************************************************************************************
      IMPLICIT NONE
      class(Photon_FlatSP) :: this 
      TYPE(ScatPhoton_KN), INTENT(INOUT) :: sphot
      real(mcp) :: Sigma_COH, Sigma_INCOH, P_Rayl, P_Comp, P_fluor, xi_1
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
      sphot%Phot4k_CtrCF = this%Phot4k_CtrCF_At_p 
      !sphot%delta_pd = this%delta_pd
      sphot%f4_CF    = this%f4_CF 
      sphot%Vector_Stokes4_CF = this%Vector_Stokes4_CF 
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
      !write(*, fmt="(' ', A5, 1ES18.7)")'ss2=', &
      !    Vector3D_Inner_Product( sphot%Phot4k_CtrCF(2: 4), sphot%f4_CF(2: 4) ) 
      !write(*, fmt = "(' ', A40)")'******************************************************'
      CALL sphot%Set_Photon_f3_Tetrad_In_CF()
      !write(*, fmt = "(' ', A40)")'******************************************************'
      !write(*, fmt = * )'tts= ', this%Vector_Stokes4_CF 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !CALL sphot%Get_gama_mu_phi_Of_Scatter_Electron_HXM( this%T_e )
      CALL sphot%Get_gama_mu_phi_Of_Scat_Elec( this%T_e )
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      CALL sphot%Set_Elec_Tetrad_In_CF()
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      CALL sphot%StokesPara_Rotation_Matrix(sphot%Elec_Phot_phi, sphot%Vector_Stokes4_CF)
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      CALL sphot%Set_Phot4k_In_Elec_CF()
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !CALL sphot%Set_f4_In_Elec_CF()
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !CALL sphot%Set_Phot_f4_Tetrad_In_Elec_CF()    
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
      CALL sphot%Set_Phot_Tetrad1_In_Elec_CF() 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
      sphot%Vector_Stokes4_ECF = sphot%Vector_Stokes4_CF
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !this%Phot4k_In_Elec_CF = sphot%Phot4k_In_Elec_CF
      !this%f4_In_Elec_CF = sphot%f4_In_Elec_CF
      !this%Phot_f4_AxisX = sphot%Phot_f4_AxisX
      !this%Elec_Phot_mu = sphot%Elec_Phot_mu
      !this%Elec_Phot_sin = sphot%Elec_Phot_sin
      !this%Elec_gama = sphot%Elec_gama
      !this%Elec_V = sphot%Elec_V
      !this%Matrix_Of_Tetrad_Of_ElecAxis = sphot%Matrix_Of_Tetrad_Of_ElecAxis
      !this%Matrix_Of_Tetrad_Of_PhotAxis = sphot%Matrix_Of_Tetrad_Of_PhotAxis
      !this%Matrix_Of_Tetrad_Of_Phot_f4_Axis = sphot%Matrix_Of_Tetrad_Of_Phot_f4_Axis
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      this%Vector_Stokes4_ECF = sphot%Vector_Stokes4_ECF
      this%Phot4k_In_Elec_CF = sphot%Phot4k_In_Elec_CF
      this%Elec_Phot_mu = sphot%Elec_Phot_mu
      this%Elec_Phot_sin = sphot%Elec_Phot_sin
      this%Elec_Phot_phi = sphot%Elec_Phot_phi
      this%Elec_gama = sphot%Elec_gama
      this%Elec_V = sphot%Elec_V

      this%Elec_Phot_sin_In_Elec_CF = sphot%Elec_Phot_sin_In_Elec_CF 
      this%Elec_Phot_mu_In_Elec_CF = sphot%Elec_Phot_mu_In_Elec_CF

      this%Matrix_Of_Tetrad_Of_ElecAxis = sphot%Matrix_Of_Tetrad_Of_ElecAxis
      this%Matrix_Of_Tetrad_Of_PhotAxis = sphot%Matrix_Of_Tetrad_Of_PhotAxis  
      this%Matrix_Of_Tetrad1_Of_photAxis = sphot%Matrix_Of_Tetrad1_Of_photAxis
      this%Matrix_ECF_2_ECF1 = sphot%Matrix_ECF_2_ECF1
      this%Matrix_ECF1_2_ECF = sphot%Matrix_ECF1_2_ECF
      !CALL this%Get_K_P1_P2_Scat_Kernel_InECF_for_Estimation() 
      CALL this%Get_K_P1_P2_Scat_Kernel_InECF_for_Estimation_withpol()  
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !CALL sphot%Compton_Scattering_With_Zero_QU()
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !CALL this%Get_K_P1_P2_Scat_Kernel_InECF_for_Esti_withpol_medium2(1)  
      !CALL this%Get_K_P1_P2_Scat_Kernel_InECF_for_Esti_withpol_medium2(2) 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
      !if( sphot%delta_pd /= zero )then 
      !write(*, fmt = "(' ', A40)")'rrrrr******************************************************'
      CALL sphot%Compton_Scattering_With_Polar_StokesVec() 
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
      END SUBROUTINE Photon_Electron_Scattering_Sub
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

!*******************************************************************************************************
!*******************************************************************************************************
!*******************************************************************************************************
 
      end module Photons_FlatSP




 
