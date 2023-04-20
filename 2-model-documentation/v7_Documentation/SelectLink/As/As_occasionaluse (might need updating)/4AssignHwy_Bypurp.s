*(echo 4AssignHwy_ByPurp.s > 4AssignHwy_ByPurp.txt)  ;In case TP+ crashes during batch, this will halt process & help identify error location.
*(DEL *.PRN)

READ FILE = '..\..\0GeneralParameters.block'
READ FILE = '..\..\1ControlCenter.block'

Zone2DistrictFile = 'block\5DistrictMedium_forMatrix.txt'
TripTableFactor   = 1.0  ;Default to 1.0  - Only use for specialized applications

PAGEHEIGHT=32767 ; preclude insertion of page headers
  
MilesPerCar = 200000
/* **************************************************************************
File:       4AssignHwy.s
Purpose:    1. Take the trip tables assigned to autos by the Mode Choice 
               and convert them to directional OD tables by period. (Some
               are person-trips and some are vehicle-trips).
            2. Assign the OD tables by period.
Authors:       Mick Crandall, Mike Brown
*************************************************************************** */

goto :Step1

:Step1

if (OptimizeLanes_Distrib <> 0)
RUN PGM=HWYNET  ;Step 1
  FILEI NETI = @ParentDir@@DDir@@Do@@unloadednetprefix@.load.net
  FILEO NETO = @ParentDir@@TempDir@@ATmp@tmp_start.net
ENDRUN
else
RUN PGM=HWYNET  ;Step 1
  FILEI NETI = @ParentDir@@NDir@@No@@unloadednetprefix@.net
  FILEO NETO = @ParentDir@@TempDir@@ATmp@tmp_start.net
ENDRUN
endif


LOOP iter=1,3,1
if (iter = 1) goto :AfterOptimize  ;must first run a basic 4-pd assign.
if (iter > 1) ;assign again, if optimizing, but for Optimized lanes.
  if (OptimizeLanes_Final = 0)
    goto :EndAssign
  else

; ******************************************************************************
; Purpose:  Adjust lanes up if VC is too high, and down if too low. 
;           (If user specifies this test).
; ******************************************************************************
RUN PGM=HWYNET
  FILEI NETI = @ParentDir@@ADir@@Ao@@unloadednetprefix@_4pd.load.bypurp.net 
  FILEO NETO = @ParentDir@@TempDir@@ATmp@tmp_start.net       ;can't write the file that I read, so use intermediate
      
  PHASE = LINKMERGE
    
    LANES@iter@ = LI.1.lanes
    
  if (ft <> 1 || lanes <> 7)
    _cap = (LI.1.cap1hr1ln * LI.1.lanes * 3 * @OptimizeLanes_TargetVC@) ; 3hrs; lowering cap to target will cause it to build more lanes (i.e. cap threshold)
    if (LI.1.am_vol > LI.1.pm_vol)
      _highvol = LI.1.am_vol
      _highvc  = LI.1.am_vc
    else
      _highvol = LI.1.pm_vol
      _highvc  = LI.1.pm_vc
    endif
    _VolCapDif = _highvol - _cap
    _LaneChange = _VolCapDif / (LI.1.cap1hr1ln * 3) ;3hrs
    
    
    if     (_highvc > 1.4)  ;anticipate high latent demand and add additional
      _lanefac = 1.6
    elseif (_highvc <= 1.4 && _highvc > 1.0)
      _lanefac = 1.4
    else
      _lanefac = 1.0
    endif
    
    LANES = LI.1.LANES + (_LaneChange * _lanefac)
    if (LANES <= .5)  LANES = .5
    
    if (LANES >= 4 && LI.1.ft < 29 && @OptimizeLanes_GradeSeparate@ <> 0)  ;if it wants to make lanes too big, turn it into freeway.
      cap1hr1ln = 2115
      ft = 31
      LANES = LANES * (2/5) ;a little less than 1/2 a freeway lane is comparable to a regular arterial lane
      sff     = 65  ;redefine speeds for distribution.
      am_spd1 = 60
      md_spd1 = 60
      am_spd2 = 60
      md_spd2 = 60
      am_spd3 = 60
      md_spd3 = 60
    endif
  endif
      
  ENDPHASE

ENDRUN

  endif
endif

:AfterOptimize
if (RunFinalAssignFromPM <> 0) 
  goto :stepPM
endif

;**************************************************************************
;Purpose:	Assign four trip tables (AM,Mid,PM,Eve) to a single network. 
;Authors:   Mick Crandall, Mike Brown
;**************************************************************************

;**************************************************************************
;Purpose:	Assign AM trip table to loaded network
;**************************************************************************
:StepAM
RUN PGM=HWYLOAD
  ZONEMSG       = @ZoneMsgRate@  ;reduces print messages in TPP DOS. (i.e. runs faster).  ;reduces print messages in TPP DOS. (i.e. runs faster).
  FILEI MATI[1] = @ParentDir@@TempDir@@ATmp@am3hr_ByPurp_Long.mtx  ;trip tables by purpose & total
  FILEI MATI[2] = @ParentDir@@TempDir@@ATmp@am3hr_ByPurp_Short.mtx  
  FILEI NETI    = @ParentDir@@TempDir@@ATmp@tmp_start.net       
  FILEO NETO    = @ParentDir@@TempDir@@ATmp@tmp_am.net	   ; alternate tmpa & tmpb until final network achieved

  hrsinperiod   = 3
  whatperiod    = 1

  PARAMETERS GAP= .00001  ;convergence criteria (system cost)
  PARAMETERS RMSE= 1  ;convergence criteria (link-based)
  PARAMETERS MAXITERS = 20  ;maximum iterations

  READ FILE     = @ParentDir@@ADir@@As@block\4pd_mainbody_bypurp.block
ENDRUN

;**************************************************************************
;Purpose:	Assign Mid-day trip table to loaded network
;**************************************************************************
:StepMD
RUN PGM=HWYLOAD
  ZONEMSG       = @ZoneMsgRate@  ;reduces print messages in TPP DOS. (i.e. runs faster).  ;reduces print messages in TPP DOS. (i.e. runs faster).
  FILEI MATI[1] = @ParentDir@@TempDir@@ATmp@md6hr_ByPurp_Long.mtx  ;trip tables by purpose & total
  FILEI MATI[2] = @ParentDir@@TempDir@@ATmp@md6hr_ByPurp_Short.mtx  
  FILEI NETI     = @ParentDir@@TempDir@@ATmp@tmp_am.net	   ; alternate tmpa & tmpb until final network achieved
  FILEO NETO     = @ParentDir@@TempDir@@ATmp@tmp_md.net	   ; alternate tmpa & tmpb until final network achieved

  hrsinperiod    = 6
  whatperiod     = 2

  PARAMETERS GAP= .00001  ;convergence criteria (system cost)
  PARAMETERS RMSE= 1  ;convergence criteria (link-based)
  PARAMETERS MAXITERS = 10  ;maximum iterations

  READ FILE      = @ParentDir@@ADir@@As@block\4pd_mainbody_bypurp.block
ENDRUN

;**************************************************************************
;Purpose:	Assign PM trip table to loaded network
;**************************************************************************
:StepPM
RUN PGM=HWYLOAD
  ZONEMSG       = @ZoneMsgRate@  ;reduces print messages in TPP DOS. (i.e. runs faster).  ;reduces print messages in TPP DOS. (i.e. runs faster).
  FILEI MATI[1] = @ParentDir@@TempDir@@ATmp@pm3hr_ByPurp_Long.mtx  ;trip tables by purpose & total
  FILEI MATI[2] = @ParentDir@@TempDir@@ATmp@pm3hr_ByPurp_Short.mtx  
  FILEI NETI    = @ParentDir@@TempDir@@ATmp@tmp_md.net	   ; alternate tmpa & tmpb until final network achieved
  FILEO NETO    = @ParentDir@@TempDir@@ATmp@tmp_pm.net	   ; alternate tmpa & tmpb until final network achieved

  hrsinperiod   = 3
  whatperiod    = 3

  PARAMETERS GAP= .00001  ;convergence criteria (system cost)
  PARAMETERS RMSE= 1  ;convergence criteria (link-based)
  PARAMETERS MAXITERS = 30  ;maximum iterations

  READ FILE     = @ParentDir@@ADir@@As@block\4pd_mainbody_bypurp.block
ENDRUN

;**************************************************************************
;Purpose:	Assign evening trip table loaded network
;**************************************************************************
:StepEV
RUN PGM=HWYLOAD
  ZONEMSG       = @ZoneMsgRate@  ;reduces print messages in TPP DOS. (i.e. runs faster).  ;reduces print messages in TPP DOS. (i.e. runs faster).
  FILEI MATI[1] = @ParentDir@@TempDir@@ATmp@ev12hr_ByPurp_Long.mtx  ;trip tables by purpose & total
  FILEI MATI[2] = @ParentDir@@TempDir@@ATmp@ev12hr_ByPurp_Short.mtx  
  FILEI NETI    = @ParentDir@@TempDir@@ATmp@tmp_pm.net	   ; alternate tmpa & tmpb until final network achieved
  FILEO NETO    = @ParentDir@@TempDir@@ATmp@tmp_ev.net	   ; alternate tmpa & tmpb until final network achieved

  hrsinperiod   = 12
  whatperiod    = 4

  PARAMETERS GAP= .00001  ;convergence criteria (system cost)
  PARAMETERS RMSE= 1  ;convergence criteria (link-based)
  PARAMETERS MAXITERS = 10  ;maximum iterations

  READ FILE     = @ParentDir@@ADir@@As@block\4pd_mainbody_bypurp.block
ENDRUN

; ******************************************************************************
; Purpose:  HWYLOAD won't let me name the volumes in the output network 
; anything but V_1, V_2, etc. So read them into HWYNET and write them 
; back out with the names I want
; ******************************************************************************
:Step6
RUN PGM=HWYNET
  FILEI NETI[1] = @ParentDir@@TempDir@@ATmp@tmp_ev.net	   ; alternate tmpa & tmpb until final network achieved
  FILEI NETI[2] = @ParentDir@@TempDir@@ATmp@tmp_ev.net	   ; alternate tmpa & tmpb until final network achieved
  FILEO NETO    = @ParentDir@@TempDir@@ATmp@tmp_final.net	   ; alternate tmpa & tmpb until final network achieved
  
  MERGE RECORD=F
  
  PHASE=INPUT, FILEI=li.2  ;UAG website FAQ says this is how you set ONEWAY.
    _temp=a
    a=b
    b=_temp
  ENDPHASE 
  
    
; ** Rounding examples:  The round() function rounds a tenth to the nearest integer.
; Here's an example to accomplish other types of rounding
; Round 1.4367 to 1.44:  1.4367*100=143.67,  round(143.67) = 144.  Divide result by 100 = 1.44
; Round 10495 to 10500:  10495/100=104.95,  round(104.95) = 105.  Multiply by 100 = 10500.

 AM_VOL      = round(V_1)
 AM_VOL2WY   = round(VT_1)
 
 AML_HBW     = round(V1_1)
 AML_HBC     = round(V2_1)
 AML_HBO     = round(V3_1)
 AML_NHB     = round(V4_1)
 AML_IX      = round(V5_1)
 AML_XI      = round(V6_1)
 AML_COMM    = round(V7_1)
 AML_XX      = round(V8_1)
 
 AMS_HBW     = round(V11_1)
 AMS_HBC     = round(V12_1)
 AMS_HBO     = round(V13_1)
 AMS_NHB     = round(V14_1)
 AMS_IX      = round(V15_1)
 AMS_XI      = round(V16_1)
 AMS_COMM    = round(V17_1)
 AMS_XX      = round(V18_1)
 
 AML_VOL     =  AML_HBW + AML_HBC + AML_HBO + AML_NHB + AML_IX + AML_XI + AML_COMM + AML_XX
 AMS_VOL     =  AMS_HBW + AMS_HBC + AMS_HBO + AMS_NHB + AMS_IX + AMS_XI + AMS_COMM + AMS_XX
 
 AM_Time     = round(TIME_1*1000)/1000
 AM_SPD      = round((distance/TIME_1)*60*10)/10
 AM_VC       = round(VC_1*100)/100

 MD_VOL     = round(V_2)
 MD_VOL2WY  = round(VT_2)
 
 MDL_HBW     = round(V1_2)
 MDL_HBC     = round(V2_2)
 MDL_HBO     = round(V3_2)
 MDL_NHB     = round(V4_2)
 MDL_IX      = round(V5_2)
 MDL_XI      = round(V6_2)
 MDL_COMM    = round(V7_2)
 MDL_XX      = round(V8_2)
 
 MDS_HBW     = round(V11_2)
 MDS_HBC     = round(V12_2)
 MDS_HBO     = round(V13_2)
 MDS_NHB     = round(V14_2)
 MDS_IX      = round(V15_2)
 MDS_XI      = round(V16_2)
 MDS_COMM    = round(V17_2)
 MDS_XX      = round(V18_2)

 MDL_VOL     =  MDL_HBW + MDL_HBC + MDL_HBO + MDL_NHB + MDL_IX + MDL_XI + MDL_COMM + MDL_XX
 MDS_VOL     =  MDS_HBW + MDS_HBC + MDS_HBO + MDS_NHB + MDS_IX + MDS_XI + MDS_COMM + MDS_XX
  
 MD_Time    = round(TIME_2*1000)/1000
 MD_SPD     = round((distance/TIME_2)*60*10)/10
 MD_VC      = round(VC_2*100)/100

 PM_VOL     = round(V_3)
 PM_1000    = round(PM_VOL/1000)
 PM_VOL2WY  = round(VT_3)
 
 PML_HBW     = round(V1_3)
 PML_HBC     = round(V2_3)
 PML_HBO     = round(V3_3)
 PML_NHB     = round(V4_3)
 PML_IX      = round(V5_3)
 PML_XI      = round(V6_3)
 PML_COMM    = round(V7_3)
 PML_XX      = round(V8_3)
 
 PMS_HBW     = round(V11_3)
 PMS_HBC     = round(V12_3)
 PMS_HBO     = round(V13_3)
 PMS_NHB     = round(V14_3)
 PMS_IX      = round(V15_3)
 PMS_XI      = round(V16_3)
 PMS_COMM    = round(V17_3)
 PMS_XX      = round(V18_3)

 PML_VOL     =  PML_HBW + PML_HBC + PML_HBO + PML_NHB + PML_IX + PML_XI + PML_COMM + PML_XX
 PMS_VOL     =  PMS_HBW + PMS_HBC + PMS_HBO + PMS_NHB + PMS_IX + PMS_XI + PMS_COMM + PMS_XX
  
 PM_Time    = round(TIME_3*1000)/1000
 PM_SPD     = round((distance/TIME_3)*60*10)/10
 PM_VC      = round(VC_3*100)/100
 
 if (LI.1.VC_3 >= LI.2.VC_3)
   PM_VC2     = round(LI.1.VC_3*100)/100
 else
   PM_VC2     = round(LI.2.VC_3*100)/100
 endif

 EV_VOL     = round(V_4)
 EV_VOL2WY  = round(VT_4)
 
 EVL_HBW     = round(V1_4)
 EVL_HBC     = round(V2_4)
 EVL_HBO     = round(V3_4)
 EVL_NHB     = round(V4_4)
 EVL_IX      = round(V5_4)
 EVL_XI      = round(V6_4)
 EVL_COMM    = round(V7_4)
 EVL_XX      = round(V8_4)
 
 EVS_HBW     = round(V11_4)
 EVS_HBC     = round(V12_4)
 EVS_HBO     = round(V13_4)
 EVS_NHB     = round(V14_4)
 EVS_IX      = round(V15_4)
 EVS_XI      = round(V16_4)
 EVS_COMM    = round(V17_4)
 EVS_XX      = round(V18_4)

 EVL_VOL     =  EVL_HBW + EVL_HBC + EVL_HBO + EVL_NHB + EVL_IX + EVL_XI + EVL_COMM + EVL_XX
 EVS_VOL     =  EVS_HBW + EVS_HBC + EVS_HBO + EVS_NHB + EVS_IX + EVS_XI + EVS_COMM + EVS_XX
  
 EV_Time    = round(TIME_4*1000)/1000
 EV_SPD     = round((distance/TIME_4)*60*10)/10
 EV_VC      = round(VC_4*100)/100

DY_VOL     = round(AM_VOL    + MD_VOL    + PM_VOL    + EV_VOL)	
DY_1000    = round(DY_VOL/1000)	
DY_VOL2WY  = round(AM_VOL2WY + MD_VOL2WY + PM_VOL2WY + EV_VOL2WY)	
DY_2WY1000 = round(DY_VOL2WY/1000)	

DYL_HBW     = round(AML_HBW + MDL_HBW + PML_HBW + EVL_HBW)	
DYL_HBC     = round(AML_HBC + MDL_HBC + PML_HBC + EVL_HBC)	
DYL_HBO     = round(AML_HBO + MDL_HBO + PML_HBO + EVL_HBO)	
DYL_NHB     = round(AML_NHB + MDL_NHB + PML_NHB + EVL_NHB)	
DYL_IX      = round(AML_IX  + MDL_IX  + PML_IX  + EVL_IX )	
DYL_XI      = round(AML_XI  + MDL_XI  + PML_XI  + EVL_XI )	
DYL_COMM    = round(AML_COMM+ MDL_COMM+ PML_COMM+ EVL_COMM)	
DYL_XX      = round(AML_XX  + MDL_XX  + PML_XX  + EVL_XX )

DYS_HBW     = round(AMS_HBW + MDS_HBW + PMS_HBW + EVS_HBW)	
DYS_HBC     = round(AMS_HBC + MDS_HBC + PMS_HBC + EVS_HBC)	
DYS_HBO     = round(AMS_HBO + MDS_HBO + PMS_HBO + EVS_HBO)	
DYS_NHB     = round(AMS_NHB + MDS_NHB + PMS_NHB + EVS_NHB)	
DYS_IX      = round(AMS_IX  + MDS_IX  + PMS_IX  + EVS_IX )	
DYS_XI      = round(AMS_XI  + MDS_XI  + PMS_XI  + EVS_XI )	
DYS_COMM    = round(AMS_COMM+ MDS_COMM+ PMS_COMM+ EVS_COMM)	
DYS_XX      = round(AMS_XX  + MDS_XX  + PMS_XX  + EVS_XX )

DYL_VOL     =  DYL_HBW + DYL_HBC + DYL_HBO + DYL_NHB + DYL_IX + DYL_XI + DYL_COMM + DYL_XX
DYS_VOL     =  DYS_HBW + DYS_HBC + DYS_HBO + DYS_NHB + DYS_IX + DYS_XI + DYS_COMM + DYS_XX
 
if (DY_VOL = 0)
  DY_Time = .3 ;must be non-zero for future calcs
else
  DY_Time = round((((AM_VOL*AM_Time)+(MD_VOL*MD_Time)+(PM_VOL*PM_Time)+(EV_VOL*EV_Time)) / DY_VOL)*1000)/1000 ;Time=weighted average
endif
if (DY_Time = 0)
  DY_SPD = 26  ;must be non-zero for future calcs
else
  DY_SPD  = round((distance/DY_Time)*60*10)/10
endif	

    if     (LI.1.FT = 29-40)  
      _VMTFWYT = _VMTFWYT + DY_VOL* LI.1.distance
    elseif (LI.1.FT = 2,3,9-11,22-23,42-43)
      _VMTARTT = _VMTARTT + DY_VOL* LI.1.distance
    else
      _VMTLCLT = _VMTLCLT + DY_VOL* LI.1.distance
    endif

    PHASE=SUMMARY
    _VMTTOT   = _VMTFWYT + _VMTARTT + _VMTLCLT
  
    print file=@ParentDir@@RID@_log.txt, APPEND=T  form=@lcolw@.0C list=
    ' '(@lcolw@), '   ', '*****  4AssignHwy.s:  Final Highway Assignment key values\n',
      _VMTTOT,    '   ', 'VMT from final highway assignment\n',
      _VMTFWYT,   '   ', ' * VMT Fwy (FT=29-40)\n',
      _VMTARTT,   '   ', ' * VMT Art (FT=2,3,9-11,22-23,42-43)\n',
      _VMTLCLT,   '   ', ' * VMT Lcl (FT=1)\n'
    ENDPHASE
ENDRUN

; ******************************************************************************
; Purpose:  Delete junk
; ******************************************************************************
:Step7
RUN PGM=HWYNET
  FILEI LINKI = @ParentDir@@TempDir@@ATmp@tmp_final.net,
    EXCLUDE   = V_1,V1_1,V2_1,V3_1,V4_1,V5_1,V6_1,V7_1,V8_1,  V11_1,V12_1,V13_1,V14_1,V15_1,V16_1,V17_1,V18_1, 
    EXCLUDE   = V_2,V1_2,V2_2,V3_2,V4_2,V5_2,V6_2,V7_2,V8_2,  V11_2,V12_2,V13_2,V14_2,V15_2,V16_2,V17_2,V18_2, 
    EXCLUDE   = V_3,V1_3,V2_3,V3_3,V4_3,V5_3,V6_3,V7_3,V8_3,  V11_3,V12_3,V13_3,V14_3,V15_3,V16_3,V17_3,V18_3, 
    EXCLUDE   = V_4,V1_4,V2_4,V3_4,V4_4,V5_4,V6_4,V7_4,V8_4,  V11_4,V12_4,V13_4,V14_4,V15_4,V16_4,V17_4,V18_4, 
    EXCLUDE   = VT_1,V1T_1,V2T_1,V3T_1,V4T_1,V5T_1,V6T_1,V7T_1,V8T_1,  V11T_1,V12T_1,V13T_1,V14T_1,V15T_1,V16T_1,V17T_1,V18T_1, 
    EXCLUDE   = VT_2,V1T_2,V2T_2,V3T_2,V4T_2,V5T_2,V6T_2,V7T_2,V8T_2,  V11T_2,V12T_2,V13T_2,V14T_2,V15T_2,V16T_2,V17T_2,V18T_2, 
    EXCLUDE   = VT_3,V1T_3,V2T_3,V3T_3,V4T_3,V5T_3,V6T_3,V7T_3,V8T_3,  V11T_3,V12T_3,V13T_3,V14T_3,V15T_3,V16T_3,V17T_3,V18T_3, 
    EXCLUDE   = VT_4,V1T_4,V2T_4,V3T_4,V4T_4,V5T_4,V6T_4,V7T_4,V8T_4,  V11T_4,V12T_4,V13T_4,V14T_4,V15T_4,V16T_4,V17T_4,V18T_4, 
    EXCLUDE   = TIME_1, TIME_2, TIME_3, TIME_4,  VC_1, VC_2, VC_3, VC_4,
    EXCLUDE   = VDT_1, VDT_2, VDT_3, VDT_4,   VHT_1, VHT_2, VHT_3, VHT_4,   CSPD_1, CSPD_2, CSPD_3, CSPD_4,
    EXCLUDE   = SPDPK, SPDOPK, CAPPK, CAPOPK, CAP24, S_AM, S_MD, S_EV, S_PM
  FILEO NETO  = @ParentDir@@ADir@@Ao@@unloadednetprefix@_4pd.load.bypurp.detailed.net
ENDRUN 

; ******************************************************************************
; Purpose:  Filter the detailed assignment to just the most useful information.
; ******************************************************************************
:Step8
RUN PGM=HWYNET
  FILEI LINKI = @ParentDir@@ADir@@Ao@@unloadednetprefix@_4pd.load.bypurp.detailed.net,
    EXCLUDE   = AML_HBW,AML_HBC,AML_NHB,AML_HBO,AML_IX,AML_XI,AML_COMM,AML_XX,  AMS_HBW,AMS_HBC,AMS_NHB,AMS_HBO,AMS_IX,AMS_XI,AMS_COMM,AMS_XX,
    EXCLUDE   = MDL_HBW,MDL_HBC,MDL_NHB,MDL_HBO,MDL_IX,MDL_XI,MDL_COMM,MDL_XX,  MDS_HBW,MDS_HBC,MDS_NHB,MDS_HBO,MDS_IX,MDS_XI,MDS_COMM,MDS_XX,
    EXCLUDE   = PML_HBW,PML_HBC,PML_NHB,PML_HBO,PML_IX,PML_XI,PML_COMM,PML_XX,  PMS_HBW,PMS_HBC,PMS_NHB,PMS_HBO,PMS_IX,PMS_XI,PMS_COMM,PMS_XX,
    EXCLUDE   = EVL_HBW,EVL_HBC,EVL_NHB,EVL_HBO,EVL_IX,EVL_XI,EVL_COMM,EVL_XX,  EVS_HBW,EVS_HBC,EVS_NHB,EVS_HBO,EVS_IX,EVS_XI,EVS_COMM,EVS_XX

  FILEO NETO = @ParentDir@@ADir@@Ao@@unloadednetprefix@_4pd.load.bypurp.net	
      
  PHASE=SUMMARY
    print file=@ParentDir@@ADir@@Ao@About_@unloadednetprefix@_4pd.load.txt, APPEND=F  form=12.0C list=
      '\nA more detailed copy of this assignment is available in:\n',
      '@ParentDir@@ADir@@Ao@@unloadednetprefix@_4pd.detailed.load.net\n',
      '\nThe detailed version breaks all the period volumes into their',
      '\ncomponents by purpose. (i.e. How much of AM vol is HBW, ',
      '\nCommercial, XX, etc.)'
  ENDPHASE
ENDRUN

:EndAssign
ENDLOOP

;**************************************************************************
;Purpose:	Final auto skims
;**************************************************************************
RUN PGM=HWYLOAD  
ZONES=@UsedZones@
ZONEMSG = @ZoneMsgRate@  ;reduces print messages in TPP DOS. (i.e. runs faster).

FILEI  NETI    = @ParentDir@@ADir@@Ao@@unloadednetprefix@_4pd.load.bypurp.net	
      ZDATI[1] = @ParentDir@@IDir@@Io@Urbanization.DBF  ;termtime, square miles

FILEO  MATO[1] = @ParentDir@@ADir@@Ao@skm_autotime.mtx, mo=2,1,3,5 name = DISTANCE, TIME_SFF, TIME_AM, TIME_PM

PHASE=LINKREAD
    _DIST = LI.DISTANCE - LI.DISTEXCEPT   ;Long external links should not be included in distrib because it affects IXXI trip lengths.
    LW.BASE_TIME = (_DIST/LI.SFF)*60 
    LW.TPKAM     = (_DIST/LI.AM_SPD)*60 
    LW.TPKPM     = (_DIST/LI.PM_SPD)*60 
ENDPHASE

PHASE=ILOOP
   PATHLOAD CONSOLIDATE=T, PATH=LW.BASE_TIME,
            EXCLUDEJ=@dummyzones@,  ; exclude "dummy" zones
            mw[1]=PATHCOST, NOACCESS=0,  ; zone-to-zone times (no access = 10000)
            mw[2]=PATHTRACE(LI.DISTANCE), NOACCESS=0.0 ; zone-to-zone distances (no access = 0.0)

   PATHLOAD CONSOLIDATE=T, PATH=LW.TPKAM,
            EXCLUDEJ=@dummyzones@,  ; exclude "dummy" zones
            mw[3]=PATHCOST, NOACCESS=0  ; zone-to-zone times (no access = 10000)

   PATHLOAD CONSOLIDATE=T, PATH=LW.TPKPM,
            EXCLUDEJ=@dummyzones@,  ; exclude "dummy" zones
            mw[5]=PATHCOST, NOACCESS=0  ; zone-to-zone times (no access = 10000)

;  add intrazonal times and distances to interzonal cells (assume intrazonal speed is 20mph)
   mw[2][i]= 0.5*((ZI.1.SQMILE[i])^0.5)  ;half square root of square miles = average distance (in miles)
   mw[4][i]= 0.5*((ZI.1.SQMILE[i])^0.5)
   mw[6][i]= 0.5*((ZI.1.SQMILE[i])^0.5)
   
   mw[1][i]= (mw[2][i]/20)*60
   mw[3][i]= (mw[4][i]/20)*60
   mw[5][i]= (mw[6][i]/20)*60

   if (mw[2][i] = 0) ;Having dist=0 can cause divide by 0 errors in unused zone fields.
     mw[2][i] = 1
   endif

;  add origin and destination terminal times to all zones
   mw[1]=mw[1]+ZI.1.TERMTIME[j]
   mw[3]=mw[3]+ZI.1.TERMTIME[j]
   mw[5]=mw[5]+ZI.1.TERMTIME[j]

  jloop
    if (mw[2] = 0 && i >=1) mw[2] = 1 ;Having dist=0 can cause divide by 0 errors in unused zone fields.
  endjloop
ENDPHASE
ENDRUN


/*
;**************************************************************************
;Purpose:	Consolidate PA by purpose matrices to from Zones to Counties
;**************************************************************************
:Step9
RUN PGM=MATRIX

  FILEI MATI[1] = @ParentDir@@TempDir@@ATmp@SelectLink_AM.mtx
        MATI[2] = @ParentDir@@TempDir@@ATmp@SelectLink_MD.mtx
        MATI[3] = @ParentDir@@TempDir@@ATmp@SelectLink_PM.mtx
        MATI[4] = @ParentDir@@TempDir@@ATmp@SelectLink_EV.mtx

  FILEO MATO[2] = @ParentDir@@TempDir@@ATmp@SelectLink_TAZ.mtx, MO=1-5, NAME=AM, MD, PM, EV, ALL
  ZONEMSG       = @ZoneMsgRate@                                ;reduces print messages in TPP DOS. (i.e. runs faster).


  MW[1]=MI.1.1
  MW[2]=MI.2.1
  MW[3]=MI.3.1
  MW[4]=MI.4.1
  MW[5]=mw[1]+mw[2]+mw[3]+mw[4]

  JLOOP    ;It will put zero-value cells in the wrong place, so force "no zero-values"
    if (mw[1][j] == 0) mw[1][j] = .00000001
    if (mw[2][j] == 0) mw[2][j] = .00000001
    if (mw[3][j] == 0) mw[3][j] = .00000001
    if (mw[4][j] == 0) mw[4][j] = .00000001
    if (mw[5][j] == 0) mw[5][j] = .00000001
  ENDJLOOP

;@SelLinkReduceToDistricts@  renumber file=@Zone2DistrictFile@, missingzi=m, missingzo=w
ENDRUN
*/

:end
*(copy *.prn .\out\4AssignHwy_ByPurp.out)
*(del 4AssignHwy_ByPurp.txt)
*(del TPPL*)


