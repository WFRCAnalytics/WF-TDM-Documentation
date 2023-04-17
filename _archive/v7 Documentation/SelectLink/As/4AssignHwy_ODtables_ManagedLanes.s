*(echo 4AssignHwy_ODtables_ManagedLanes.s > 4AssignHwy_ODtables_ManagedLanes.txt)  ;In case TP+ crashes during batch, this will halt process & help identify error location.
*(DEL *.PRN)

	;This is a dummy file used to calculate the time it takes to run script
	*(ECHO dummy file to calculate elapsed time > _timchk1.txt)
	
READ FILE = '..\..\0GeneralParameters.block'
READ FILE = '..\..\1ControlCenter.block'

/*
;Elapsed time
RUN PGM = HWYNET
  ZONES = 1
  FILEI NETI = @ParentDir@@IDir@@Io@@unloadednetprefix@.net  ;Only need to print, but must read something to function

PHASE=SUMMARY
;******************  About Elapsed time
;* Mike found this on the Internet.  It can't use paths & names with more than 8-chars per, so I put together a
;* process to create a file at one point that will be checked at another.  A batch file is also created that
;* will be run at the next point.  The format is like this.
;* See end of final assignment for the next check point

  PRINT FORM=8.0C FILE=@ParentDir@@Adir@@As@ElapsedTime_EOfinalAssign.bat  LIST=
    '\n@ParentDir@9tmp\_ElapsedTime\ElapsedTime.exe   9FinlAsn.txt /n  >> @ParentDir@_ElapsedTimeReport.txt', '\n',
    '\necho Above is how long it took to run from BEGIN OF FINAL ASSIGN to END OF FINAL ASSIGN  >> @ParentDir@_ElapsedTimeReport.txt\n\n'

ENDPHASE
ENDRUN
*/

;goto :end
;**************************************************************************
;Purpose:   Factor distributed person trips by time period, and convert
;           to vehicle trips
;**************************************************************************

goto :Step1

:Step1
LOOP vehclass = 1,5,1  
  if (vehclass = 1)
    vtypeA  = 'alone_non'
    vtypeB  = 'alone_non'  ;not used, but must have something in vtypeB to avoid crashing
    filetag = 'da_non'
  elseif (vehclass = 2)
    vtypeA  = 'sr2_non'
    vtypeB  = 'sr3_non'  
    filetag = 'sr_non'
  elseif (vehclass = 3)
    vtypeA  = 'sr2_hov'
    vtypeB  = 'sr3_hov'      
    filetag = 'sr_hov'
  elseif (vehclass = 4)
    vtypeA  = 'alone_toll'
    vtypeB  = 'alone_toll'  ;not used, but must have something in vtypeB to avoid crashing
    filetag = 'da_tol'
  elseif (vehclass = 5)
    vtypeA  = 'sr2_toll'
    vtypeB  = 'sr3_toll'  
    filetag = 'sr_tol'
  endif

RUN PGM=MATRIX

;bypass needs to be fixed to include managed lanes...maybe
;another alternative is that the managed lanes assignment script can be different from the MCbypass version
;this script does not currently do a "detailed" assignment, tracking each trip purpose


 FILEI MATI[1] = @ParentDir@@TempDir@@MTmp@B\HBW_trips_Pk_auto_managedlanes.mtx       ; HBW trip table 
       MATI[2] = @ParentDir@@TempDir@@MTmp@B\HBC_trips_Pk_auto_managedlanes.mtx       ; HBC trip table 
       MATI[3] = @ParentDir@@TempDir@@MTmp@B\HBO_trips_Pk_auto_managedlanes.mtx       ; HBO trip table  
       MATI[4] = @ParentDir@@TempDir@@MTmp@B\NHB_trips_Pk_auto_managedlanes.mtx       ; NHB trip table  

       MATI[5] = @ParentDir@@TempDir@@MTmp@B\HBW_trips_Ok_auto_managedlanes.mtx       ; HBW trip table 
       MATI[6] = @ParentDir@@TempDir@@MTmp@B\HBC_trips_Ok_auto_managedlanes.mtx       ; HBC trip table  - set to 0 for Ok
       MATI[7] = @ParentDir@@TempDir@@MTmp@B\HBO_trips_Ok_auto_managedlanes.mtx       ; HBO trip table  
       MATI[8] = @ParentDir@@TempDir@@MTmp@B\NHB_trips_Ok_auto_managedlanes.mtx       ; NHB trip table  

MATI[11]= @ParentDir@@MDir@@Mo@PA_AllPurp.mtx          ; Commercial, IX/XI, XX vehicle trips (off-peak)
MATI[13]= @ParentDir@@DDir@@Do@skm_AMpk.mtx
  
  
;***** Matrix names must be identical to standardize their use in the assignment block file.
FILEO MATO[1] = @ParentDir@@TempDir@@ATmp@am3hr_managed_tmp.@filetag@.mtx,  mo=21,  name=TOTVEH
FILEO MATO[2] = @ParentDir@@TempDir@@ATmp@md6hr_managed_tmp.@filetag@.mtx,  mo=22,  name=TOTVEH
FILEO MATO[3] = @ParentDir@@TempDir@@ATmp@pm3hr_managed_tmp.@filetag@.mtx,  mo=23,  name=TOTVEH
FILEO MATO[4] = @ParentDir@@TempDir@@ATmp@ev12hr_managed_tmp.@filetag@.mtx, mo=24,  name=TOTVEH

ZONEMSG       = @ZoneMsgRate@                                ;reduces print messages in TPP DOS. (i.e. runs faster).
ZONES = @UsedZones@


READ FILE     = @ParentDir@@ADir@@As@block\4pd_ODtables_managedlanes_WorkMatrixInfo.block  ;FOR REFERENCE ONLY (no calcs)

;JLOOP  ;convert person trips made in autos into auto trips
  
  if (@vehclass@ = 1,4)
    ;peak (am+pm) vehicle trips
    mw[51] = MI.1.@vtypeA@ ;HBW
    mw[52] = MI.2.@vtypeA@ ;HBC
    mw[53] = MI.3.@vtypeA@ ;HBO
    mw[54] = MI.4.@vtypeA@ ;NHB
    ;transpose peak (am+pm) vehicle trips 
    mw[61] = MI.1.@vtypeA@.T ;HBW
    mw[62] = MI.2.@vtypeA@.T ;HBC
    mw[63] = MI.3.@vtypeA@.T ;HBO
    mw[64] = MI.4.@vtypeA@.T ;NHB

    ;off-peak (md+ev) vehicle trips
    mw[71] = MI.5.@vtypeA@ ;HBW
    mw[72] = MI.2.@vtypeA@ ;HBC
    mw[73] = MI.7.@vtypeA@ ;HBO
    mw[74] = MI.8.@vtypeA@ ;NHB
    ;transpose off-peak (md+ev) vehicle trips 
    mw[81] = MI.5.@vtypeA@.T ;HBW
    mw[82] = MI.2.@vtypeA@.T ;HBC
    mw[83] = MI.7.@vtypeA@.T ;HBO
    mw[84] = MI.8.@vtypeA@.T ;NHB
    
  else
    mw[51] = MI.1.@vtypeA@/2 + MI.1.@vtypeB@/3.5 ;HBW
    mw[52] = MI.2.@vtypeA@/2 + MI.2.@vtypeB@/3.5 ;HBC
    mw[53] = MI.3.@vtypeA@/2 + MI.3.@vtypeB@/3.5 ;HBO
    mw[54] = MI.4.@vtypeA@/2 + MI.4.@vtypeB@/3.5 ;NHB
    ;transpose peak (am+pm) vehicle trips
    mw[61] = MI.1.@vtypeA@.T/2 + MI.1.@vtypeB@.T/3.5 ;HBW
    mw[62] = MI.2.@vtypeA@.T/2 + MI.2.@vtypeB@.T/3.5 ;HBC
    mw[63] = MI.3.@vtypeA@.T/2 + MI.3.@vtypeB@.T/3.5 ;HBO
    mw[64] = MI.4.@vtypeA@.T/2 + MI.4.@vtypeB@.T/3.5 ;NHB  

    mw[71] = MI.5.@vtypeA@/2 + MI.5.@vtypeB@/3.5 ;HBW
    mw[72] = MI.2.@vtypeA@/2 + MI.2.@vtypeB@/3.5 ;HBC
    mw[73] = MI.7.@vtypeA@/2 + MI.7.@vtypeB@/3.5 ;HBO
    mw[74] = MI.8.@vtypeA@/2 + MI.8.@vtypeB@/3.5 ;NHB
    ;transpose peak (am+pm) vehicle trips
    mw[81] = MI.5.@vtypeA@.T/2 + MI.5.@vtypeB@.T/3.5 ;HBW
    mw[82] = MI.2.@vtypeA@.T/2 + MI.2.@vtypeB@.T/3.5 ;HBC
    mw[83] = MI.7.@vtypeA@.T/2 + MI.7.@vtypeB@.T/3.5 ;HBO
    mw[84] = MI.8.@vtypeA@.T/2 + MI.8.@vtypeB@.T/3.5 ;NHB  
  endif
  
  ;Note: After mode choice, HBW, HBO, HBC, and NHB are all X100 due to rounding errors.
  ;Multiply all other trips by 100 to make them similar in the period outputs, then
  ;divide all purposes by 100 in HWYLOAD to avoid losing trips.
  
  ;EXTERNAL AND COMMERCIAL TRIPS (DAILY P-A TABLES)
  ; ALL ASSUMED GENERAL PURPOSE FOR NOW, AND SOV
  if (@vehclass@ = 1)
    mw[205] = MI.11.IX * 100 * 1           ; IX Auto Trips (Off-Peak Speeds) (Daily)
    mw[206] = MI.11.XI * 100 * 1           ; XI Auto Trips (Off-Peak Speeds) (Daily)
    mw[207] = MI.11.COMM * 100 * 1         ; Commercial Auto Trips (Off-Peak Speeds) (Daily)
    mw[208] = MI.11.XX   * 100 * 1         ; X-X trips (Daily)

    mw[215] = MI.11.IX.T * 100 * 1           ; IX Auto Trips (Off-Peak Speeds) (Daily)
    mw[216] = MI.11.XI.T * 100 * 1           ; XI Auto Trips (Off-Peak Speeds) (Daily)
    mw[217] = MI.11.COMM.T * 100 * 1         ; Commercial Auto Trips (Off-Peak Speeds) (Daily)
    mw[218] = MI.11.XX.T   * 100 * 1         ; X-X trips (Daily)    
  else
    mw[205] = MI.11.IX * 100 * 0           ; IX Auto Trips (Off-Peak Speeds) (Daily)
    mw[206] = MI.11.XI * 100 * 0           ; XI Auto Trips (Off-Peak Speeds) (Daily)
    mw[207] = MI.11.COMM * 100 * 0         ; Commercial Auto Trips (Off-Peak Speeds) (Daily)
    mw[208] = MI.11.XX   * 100 * 0         ; X-X trips (Daily)

    mw[215] = MI.11.IX.T * 100 * 0           ; IX Auto Trips (Off-Peak Speeds) (Daily)
    mw[216] = MI.11.XI.T * 100 * 0           ; XI Auto Trips (Off-Peak Speeds) (Daily)
    mw[217] = MI.11.COMM.T * 100 * 0         ; Commercial Auto Trips (Off-Peak Speeds) (Daily)
    mw[218] = MI.11.XX.T   * 100 * 0         ; X-X trips (Daily)  
  endif  

READ FILE     = @ParentDir@@ADir@@As@block\4pd_ODtables_managedlanes_PeriodPAandAPpcts.block 

JLOOP

;AM Peak TRIPS
  mw[221]=(mw[51] *HBW_AM_PA + mw[61] *HBW_AM_AP)  ;HBW (% out of peak)  
  mw[222]=(mw[52] *HBC_AM_PA + mw[62] *HBC_AM_AP)  ;HBC (% out of daily)
  mw[223]=(mw[53] *HBO_AM_PA + mw[63] *HBO_AM_AP)  ;HBO (% out of peak)
  mw[224]=(mw[54] *NHB_AM_PA + mw[64] *NHB_AM_AP)  ;NHB (% out of peak)  
  mw[225]=(mw[205]* IX_AM_PA + mw[215]* IX_AM_AP)  ;IX (% out of daily)
  mw[226]=(mw[206]* XI_AM_PA + mw[216]* XI_AM_AP)  ;XI (% out of daily)
  mw[227]=(mw[207]*COM_AM_PA + mw[217]*COM_AM_AP)  ;COMM (% out of daily)
  mw[228]=(mw[208]* XX_AM_PA + mw[218]* XX_AM_AP)  ;XX (% out of daily)
    
;Mid-day TRIPS 
  mw[231]=(mw[71] *HBW_MD_PA + mw[81] *HBW_MD_AP)  ;HBW (% out of peak)  
  mw[232]=(mw[72] *HBC_MD_PA + mw[82] *HBC_MD_AP)  ;HBC (% out of daily)
  mw[233]=(mw[73] *HBO_MD_PA + mw[83] *HBO_MD_AP)  ;HBO (% out of peak)
  mw[234]=(mw[74] *NHB_MD_PA + mw[84] *NHB_MD_AP)  ;NHB (% out of peak)  
  mw[235]=(mw[205]* IX_MD_PA + mw[215]* IX_MD_AP)  ;IX (% out of daily)
  mw[236]=(mw[206]* XI_MD_PA + mw[216]* XI_MD_AP)  ;XI (% out of daily)
  mw[237]=(mw[207]*COM_MD_PA + mw[217]*COM_MD_AP)  ;COMM (% out of daily)
  mw[238]=(mw[208]* XX_MD_PA + mw[218]* XX_MD_AP)  ;XX (% out of daily)

;PM peak TRIPS
  mw[241]=(mw[51] *HBW_PM_PA + mw[61] *HBW_PM_AP)  ;HBW (% out of peak)  
  mw[242]=(mw[52] *HBC_PM_PA + mw[62] *HBC_PM_AP)  ;HBC (% out of daily)
  mw[243]=(mw[53] *HBO_PM_PA + mw[63] *HBO_PM_AP)  ;HBO (% out of peak)
  mw[244]=(mw[54] *NHB_PM_PA + mw[64] *NHB_PM_AP)  ;NHB (% out of peak)  
  mw[245]=(mw[205]* IX_PM_PA + mw[215]* IX_PM_AP)  ;IX (% out of daily)
  mw[246]=(mw[206]* XI_PM_PA + mw[216]* XI_PM_AP)  ;XI (% out of daily)
  mw[247]=(mw[207]*COM_PM_PA + mw[217]*COM_PM_AP)  ;COMM (% out of daily)
  mw[248]=(mw[208]* XX_PM_PA + mw[218]* XX_PM_AP)  ;XX (% out of daily)
  
;Evening TRIPS
  mw[251]=(mw[71] *HBW_EV_PA + mw[81] *HBW_EV_AP)  ;HBW (% out of peak)  
  mw[252]=(mw[72] *HBC_EV_PA + mw[82] *HBC_EV_AP)  ;HBC (% out of daily)
  mw[253]=(mw[73] *HBO_EV_PA + mw[83] *HBO_EV_AP)  ;HBO (% out of peak)
  mw[254]=(mw[74] *NHB_EV_PA + mw[84] *NHB_EV_AP)  ;NHB (% out of peak)  
  mw[255]=(mw[205]* IX_EV_PA + mw[215]* IX_EV_AP)  ;IX (% out of daily)
  mw[256]=(mw[206]* XI_EV_PA + mw[216]* XI_EV_AP)  ;XI (% out of daily)
  mw[257]=(mw[207]*COM_EV_PA + mw[217]*COM_EV_AP)  ;COMM (% out of daily)
  mw[258]=(mw[208]* XX_EV_PA + mw[218]* XX_EV_AP)  ;XX (% out of daily)
  
;Daily TRIPS by purpose
  mw[111]= mw[221] + mw[231] + mw[241] + mw[251]  ;HBW
  mw[112]= mw[222] + mw[232] + mw[242] + mw[252]  ;HBC (% out of daily)
  mw[113]= mw[223] + mw[233] + mw[243] + mw[253]  ;HBO
  mw[114]= mw[224] + mw[234] + mw[244] + mw[254]  ;NHB
  mw[115]= mw[225] + mw[235] + mw[245] + mw[255]  ;IX (% out of daily)
  mw[116]= mw[226] + mw[236] + mw[246] + mw[256]  ;XI (% out of daily)
  mw[117]= mw[227] + mw[237] + mw[247] + mw[257]  ;COMM (% out of daily)
  mw[118]= mw[228] + mw[238] + mw[248] + mw[258]  ;XX (% out of daily)
  
  mw[119]= mw[111] + mw[112] + mw[113] + mw[114] +
  	     mw[115] + mw[116] + mw[117] + mw[118]  ;TOT  
 	     
ENDJLOOP  
  
  
;*********************** Total vehicle trips
    ;TOTAL TRIPS by vehclass
    mw[21]=mw[221]+mw[222]+mw[223]+mw[224]+mw[225]+mw[226]+mw[227]+mw[228]  ;AM O-D vehicle trips
    mw[22]=mw[231]+mw[232]+mw[233]+mw[234]+mw[235]+mw[236]+mw[237]+mw[238]  ;Midday O-D vehicle trips
    mw[23]=mw[241]+mw[242]+mw[243]+mw[244]+mw[245]+mw[246]+mw[247]+mw[248]  ;PM O-D vehicle trips
    mw[24]=mw[251]+mw[252]+mw[253]+mw[254]+mw[255]+mw[256]+mw[257]+mw[258]  ;Evening O-D vehicle trips

ENDRUN

ENDLOOP ;vehclass

;Now open all the vehclass matrices and write them as a single file
:step2
LOOP period = 1,4,1  
  if     (period = 1)
    prd  = 'am3hr'
  elseif (period = 2)
    prd  = 'md6hr'
  elseif (period = 3)
    prd  = 'pm3hr'
  elseif (period = 4)
    prd  = 'ev12hr'
  endif
RUN PGM=MATRIX

FILEI MATI[1] = @ParentDir@@TempDir@@ATmp@@prd@_managed_tmp.da_non.mtx
FILEI MATI[2] = @ParentDir@@TempDir@@ATmp@@prd@_managed_tmp.sr_non.mtx
FILEI MATI[3] = @ParentDir@@TempDir@@ATmp@@prd@_managed_tmp.sr_hov.mtx
FILEI MATI[4] = @ParentDir@@TempDir@@ATmp@@prd@_managed_tmp.da_tol.mtx
FILEI MATI[5] = @ParentDir@@TempDir@@ATmp@@prd@_managed_tmp.sr_tol.mtx

FILEO MATO[1] = @ParentDir@@TempDir@@ATmp@@prd@_managed.mtx, mo=11-15, 31,
					     name=DA_NON, SR_NON, SR_HOV, DA_TOL, SR_TOL, TOT

ZONEMSG       = @ZoneMsgRate@                                ;reduces print messages in TPP DOS. (i.e. runs faster).

  mw[11] = mi.1.TOTVEH
  mw[12] = mi.2.TOTVEH
  mw[13] = mi.3.TOTVEH
  mw[14] = mi.4.TOTVEH
  mw[15] = mi.5.TOTVEH
    
  mw[31] = mw[11] + mw[12] + mw[13] + mw[14] + mw[15]
ENDRUN
ENDLOOP ;purpose



;Calculate Elapsed Time (options: /s=seconds, /n=minutes, /h=hours)
	*(..\..\_ElapsedTime\ElapsedTime.exe   _timchk1.txt /n  >> ..\..\_Log\_ElapsedTimeReport.txt)
	*(ECHO Above is time to run 4AssignHwy_ODtables_ManagedLanes.s >> ..\..\_Log\_ElapsedTimeReport.txt)
	
:end

*(copy *.prn .\out\4AssignHwy_ODtables_ManagedLanes.out)
*(del 4AssignHwy_ODtables_ManagedLanes.txt)
*(del TPPL*)
