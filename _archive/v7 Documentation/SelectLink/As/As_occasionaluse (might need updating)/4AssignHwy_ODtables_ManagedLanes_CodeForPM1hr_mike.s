*(echo 4AssignHwy_ODtables_ManagedLanes.s > 4AssignHwy_ODtables_ManagedLanes.txt)  ;In case TP+ crashes during batch, this will halt process & help identify error location.
*(DEL *.PRN)

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
if (RunMCbypass = 0)
  MCN = ';'
  MCY = ' '
else
  MCN = ' '
  MCY = ';'
endif  

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

@MCN@ FILEI MATI[1] = @ParentDir@@TempDir@@MTmp@B\HBW_trips_Pk_auto_managedlanes.MCbypass.mtx       ; HBW trip table 
@MCN@       MATI[2] = @ParentDir@@TempDir@@MTmp@B\HBC_trips_Pk_auto_managedlanes.MCbypass.mtx       ; HBC trip table 
@MCN@       MATI[3] = @ParentDir@@TempDir@@MTmp@B\HBO_trips_Pk_auto_managedlanes.MCbypass.mtx       ; HBO trip table  
@MCN@       MATI[4] = @ParentDir@@TempDir@@MTmp@B\NHB_trips_Pk_auto_managedlanes.MCbypass.mtx       ; NHB trip table  

@MCN@       MATI[5] = @ParentDir@@TempDir@@MTmp@B\HBW_trips_Ok_auto_managedlanes.MCbypass.mtx       ; HBW trip table 
@MCN@       MATI[6] = @ParentDir@@TempDir@@MTmp@B\HBC_trips_Ok_auto_managedlanes.MCbypass.mtx       ; HBC trip table - set to 0 for Ok
@MCN@       MATI[7] = @ParentDir@@TempDir@@MTmp@B\HBO_trips_Ok_auto_managedlanes.MCbypass.mtx       ; HBO trip table  
@MCN@       MATI[8] = @ParentDir@@TempDir@@MTmp@B\NHB_trips_Ok_auto_managedlanes.MCbypass.mtx       ; NHB trip table  


@MCY@ FILEI MATI[1] = @ParentDir@@TempDir@@MTmp@B\HBW_trips_Pk_auto_managedlanes.mtx       ; HBW trip table 
@MCY@       MATI[2] = @ParentDir@@TempDir@@MTmp@B\HBC_trips_Pk_auto_managedlanes.mtx       ; HBC trip table 
@MCY@       MATI[3] = @ParentDir@@TempDir@@MTmp@B\HBO_trips_Pk_auto_managedlanes.mtx       ; HBO trip table  
@MCY@       MATI[4] = @ParentDir@@TempDir@@MTmp@B\NHB_trips_Pk_auto_managedlanes.mtx       ; NHB trip table  

@MCY@       MATI[5] = @ParentDir@@TempDir@@MTmp@B\HBW_trips_Ok_auto_managedlanes.mtx       ; HBW trip table 
@MCY@       MATI[6] = @ParentDir@@TempDir@@MTmp@B\HBC_trips_Ok_auto_managedlanes.mtx       ; HBC trip table  - set to 0 for Ok
@MCY@       MATI[7] = @ParentDir@@TempDir@@MTmp@B\HBO_trips_Ok_auto_managedlanes.mtx       ; HBO trip table  
@MCY@       MATI[8] = @ParentDir@@TempDir@@MTmp@B\NHB_trips_Ok_auto_managedlanes.mtx       ; NHB trip table  

MATI[11]= @ParentDir@@MDir@@Mo@PA_AllPurp.mtx          ; Commercial, IX/XI, XX vehicle trips (off-peak)
MATI[13]= @ParentDir@@DDir@@Do@skm_AMpk.mtx
  
  
;***** Matrix names must be identical to standardize their use in the assignment block file.
FILEO MATO[1] = @ParentDir@@TempDir@@ATmp@am3hr_managed_tmp.@filetag@.mtx,  mo=21,25,  name=LONG, SHORT
FILEO MATO[2] = @ParentDir@@TempDir@@ATmp@md6hr_managed_tmp.@filetag@.mtx,  mo=22,26,  name=LONG, SHORT
FILEO MATO[3] = @ParentDir@@TempDir@@ATmp@pm3hr_managed_tmp.@filetag@.mtx,  mo=23,27,  name=LONG, SHORT
FILEO MATO[4] = @ParentDir@@TempDir@@ATmp@ev12hr_managed_tmp.@filetag@.mtx, mo=24,28,  name=LONG, SHORT
FILEO MATO[5] = @ParentDir@@TempDir@@ATmp@pm1hr_managed_tmp.@filetag@.mtx,  mo=40,41,  name=LONG, SHORT

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

if (mi.13.distance[j] >= @LongTripBreakPt@) ;miles 
;AM Peak LONG TRIPS
  mw[221]=(mw[51] *HBW_AM_PA + mw[61] *HBW_AM_AP)    ;HBW (% out of peak)  
  mw[222]=(mw[52] *HBC_AM_PA + mw[62] *HBC_AM_AP)   ;HBC (% out of daily)
  mw[223]=(mw[53] *HBO_AM_PA + mw[63] *HBO_AM_AP)    ;HBO (% out of peak)
  mw[224]=(mw[54] *NHB_AM_PA + mw[64] *NHB_AM_AP)    ;NHB (% out of peak)  
  mw[225]=(mw[205]* IX_AM_PA + mw[215]* IX_AM_AP)  ;IX (% out of daily)
  mw[226]=(mw[206]* XI_AM_PA + mw[216]* XI_AM_AP)  ;XI (% out of daily)
  mw[227]=(mw[207]*COM_AM_PA + mw[217]*COM_AM_AP)  ;COMM (% out of daily)
  mw[228]=(mw[208]* XX_AM_PA + mw[218]* XX_AM_AP)  ;XX (% out of daily)
    
;Mid-day LONG TRIPS 
  mw[231]=(mw[71] *HBW_MD_PA + mw[81] *HBW_MD_AP)    ;HBW (% out of peak)  
  mw[232]=(mw[72] *HBC_MD_PA + mw[82] *HBC_MD_AP)   ;HBC (% out of daily)
  mw[233]=(mw[73] *HBO_MD_PA + mw[83] *HBO_MD_AP)    ;HBO (% out of peak)
  mw[234]=(mw[74] *NHB_MD_PA + mw[84] *NHB_MD_AP)    ;NHB (% out of peak)  
  mw[235]=(mw[205]* IX_MD_PA + mw[215]* IX_MD_AP)  ;IX (% out of daily)
  mw[236]=(mw[206]* XI_MD_PA + mw[216]* XI_MD_AP)  ;XI (% out of daily)
  mw[237]=(mw[207]*COM_MD_PA + mw[217]*COM_MD_AP)  ;COMM (% out of daily)
  mw[238]=(mw[208]* XX_MD_PA + mw[218]* XX_MD_AP)  ;XX (% out of daily)

;PM peak LONG TRIPS
  mw[241]=(mw[51] *HBW_PM_PA + mw[61] *HBW_PM_AP)    ;HBW (% out of peak)  
  mw[242]=(mw[52] *HBC_PM_PA + mw[62] *HBC_PM_AP)   ;HBC (% out of daily)
  mw[243]=(mw[53] *HBO_PM_PA + mw[63] *HBO_PM_AP)    ;HBO (% out of peak)
  mw[244]=(mw[54] *NHB_PM_PA + mw[64] *NHB_PM_AP)    ;NHB (% out of peak)  
  mw[245]=(mw[205]* IX_PM_PA + mw[215]* IX_PM_AP)  ;IX (% out of daily)
  mw[246]=(mw[206]* XI_PM_PA + mw[216]* XI_PM_AP)  ;XI (% out of daily)
  mw[247]=(mw[207]*COM_PM_PA + mw[217]*COM_PM_AP)  ;COMM (% out of daily)
  mw[248]=(mw[208]* XX_PM_PA + mw[218]* XX_PM_AP)  ;XX (% out of daily)
  
;Evening LONG TRIPS
  mw[251]=(mw[71] *HBW_EV_PA + mw[81] *HBW_EV_AP)    ;HBW (% out of peak)  
  mw[252]=(mw[72] *HBC_EV_PA + mw[82] *HBC_EV_AP)   ;HBC (% out of daily)
  mw[253]=(mw[73] *HBO_EV_PA + mw[83] *HBO_EV_AP)    ;HBO (% out of peak)
  mw[254]=(mw[74] *NHB_EV_PA + mw[84] *NHB_EV_AP)    ;NHB (% out of peak)  
  mw[255]=(mw[205]* IX_EV_PA + mw[215]* IX_EV_AP)  ;IX (% out of daily)
  mw[256]=(mw[206]* XI_EV_PA + mw[216]* XI_EV_AP)  ;XI (% out of daily)
  mw[257]=(mw[207]*COM_EV_PA + mw[217]*COM_EV_AP)  ;COMM (% out of daily)
  mw[258]=(mw[208]* XX_EV_PA + mw[218]* XX_EV_AP)  ;XX (% out of daily)
  
;Daily LONG TRIPS by purpose
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
 	     
else ;short trip

;AM Peak SHORT TRIPS
  mw[261]=(mw[51] *HBW_AM_PA + mw[61] *HBW_AM_AP)    ;HBW (% out of peak)  
  mw[262]=(mw[52] *HBC_AM_PA + mw[62] *HBC_AM_AP)   ;HBC (% out of daily)
  mw[263]=(mw[53] *HBO_AM_PA + mw[63] *HBO_AM_AP)    ;HBO (% out of peak)
  mw[264]=(mw[54] *NHB_AM_PA + mw[64] *NHB_AM_AP)    ;NHB (% out of peak)  
  mw[265]=(mw[205]* IX_AM_PA + mw[215]* IX_AM_AP)  ;IX (% out of daily)
  mw[266]=(mw[206]* XI_AM_PA + mw[216]* XI_AM_AP)  ;XI (% out of daily)
  mw[267]=(mw[207]*COM_AM_PA + mw[217]*COM_AM_AP)  ;COMM (% out of daily)
  mw[268]=(mw[208]* XX_AM_PA + mw[218]* XX_AM_AP)  ;XX (% out of daily)

;Mid-day SHORT TRIPS 
  mw[271]=(mw[71] *HBW_MD_PA + mw[81] *HBW_MD_AP)    ;HBW (% out of peak)  
  mw[272]=(mw[72] *HBC_MD_PA + mw[82] *HBC_MD_AP)   ;HBC (% out of daily)
  mw[273]=(mw[73] *HBO_MD_PA + mw[83] *HBO_MD_AP)    ;HBO (% out of peak)
  mw[274]=(mw[74] *NHB_MD_PA + mw[84] *NHB_MD_AP)    ;NHB (% out of peak)  
  mw[275]=(mw[205]* IX_MD_PA + mw[215]* IX_MD_AP)  ;IX (% out of daily)
  mw[276]=(mw[206]* XI_MD_PA + mw[216]* XI_MD_AP)  ;XI (% out of daily)
  mw[277]=(mw[207]*COM_MD_PA + mw[217]*COM_MD_AP)  ;COMM (% out of daily)
  mw[278]=(mw[208]* XX_MD_PA + mw[218]* XX_MD_AP)  ;XX (% out of daily)
   
;PM peak SHORT TRIPS
  mw[281]=(mw[51] *HBW_PM_PA + mw[61] *HBW_PM_AP)    ;HBW (% out of peak)  
  mw[282]=(mw[52] *HBC_PM_PA + mw[62] *HBC_PM_AP)   ;HBC (% out of daily)
  mw[283]=(mw[53] *HBO_PM_PA + mw[63] *HBO_PM_AP)    ;HBO (% out of peak)
  mw[284]=(mw[54] *NHB_PM_PA + mw[64] *NHB_PM_AP)    ;NHB (% out of peak)  
  mw[285]=(mw[205]* IX_PM_PA + mw[215]* IX_PM_AP)  ;IX (% out of daily)
  mw[286]=(mw[206]* XI_PM_PA + mw[216]* XI_PM_AP)  ;XI (% out of daily)
  mw[287]=(mw[207]*COM_PM_PA + mw[217]*COM_PM_AP)  ;COMM (% out of daily)
  mw[288]=(mw[208]* XX_PM_PA + mw[218]* XX_PM_AP)  ;XX (% out of daily)

;Evening SHORT TRIPS
  mw[291]=(mw[71] *HBW_EV_PA + mw[81] *HBW_EV_AP)    ;HBW (% out of peak)  
  mw[292]=(mw[72] *HBC_EV_PA + mw[82] *HBC_EV_AP)   ;HBC (% out of daily)
  mw[293]=(mw[73] *HBO_EV_PA + mw[83] *HBO_EV_AP)    ;HBO (% out of peak)
  mw[294]=(mw[74] *NHB_EV_PA + mw[84] *NHB_EV_AP)    ;NHB (% out of peak)  
  mw[295]=(mw[205]* IX_EV_PA + mw[215]* IX_EV_AP)  ;IX (% out of daily)
  mw[296]=(mw[206]* XI_EV_PA + mw[216]* XI_EV_AP)  ;XI (% out of daily)
  mw[297]=(mw[207]*COM_EV_PA + mw[217]*COM_EV_AP)  ;COMM (% out of daily)
  mw[298]=(mw[208]* XX_EV_PA + mw[218]* XX_EV_AP)  ;XX (% out of daily)
 
  
;Daily SHORT TRIPS by purpose
  mw[151]= mw[261] + mw[271] + mw[281] + mw[291]  ;HBW
  mw[152]= mw[262] + mw[272] + mw[282] + mw[292]  ;HBC
  mw[153]= mw[263] + mw[273] + mw[283] + mw[293]  ;HBO
  mw[154]= mw[264] + mw[274] + mw[284] + mw[294]  ;NHB
  mw[155]= mw[265] + mw[275] + mw[285] + mw[295]  ;IX 
  mw[156]= mw[266] + mw[276] + mw[286] + mw[296]  ;XI 
  mw[157]= mw[267] + mw[277] + mw[287] + mw[297]  ;COMM 
  mw[158]= mw[268] + mw[278] + mw[288] + mw[298]  ;XX 
  
  mw[159]= mw[151] + mw[152] + mw[153] + mw[154] +
  	   mw[155] + mw[156] + mw[157] + mw[158]  ;TOT  

endif
ENDJLOOP  
  
  
;*********************** Total vehicle trips
    ;TOTAL LONG TRIPS by vehclass
    mw[21]=mw[221]+mw[222]+mw[223]+mw[224]+mw[225]+mw[226]+mw[227]+mw[228]  ;AM O-D vehicle trips
    mw[22]=mw[231]+mw[232]+mw[233]+mw[234]+mw[235]+mw[236]+mw[237]+mw[238]  ;Midday O-D vehicle trips
    mw[23]=mw[241]+mw[242]+mw[243]+mw[244]+mw[245]+mw[246]+mw[247]+mw[248]  ;PM O-D vehicle trips
    mw[24]=mw[251]+mw[252]+mw[253]+mw[254]+mw[255]+mw[256]+mw[257]+mw[258]  ;Evening O-D vehicle trips
    mw[40]=mw[23] * .38 ;Evening O-D vehicle trips
    
    ;TOTAL SHORT TRIPS by vehclass
    mw[25]=mw[261]+mw[262]+mw[263]+mw[264]+mw[265]+mw[266]+mw[267]+mw[268]  ;AM O-D vehicle trips
    mw[26]=mw[271]+mw[272]+mw[273]+mw[274]+mw[275]+mw[276]+mw[277]+mw[278]  ;Midday O-D vehicle trips
    mw[27]=mw[281]+mw[282]+mw[283]+mw[284]+mw[285]+mw[286]+mw[287]+mw[288]  ;PM O-D vehicle trips
    mw[28]=mw[291]+mw[292]+mw[293]+mw[294]+mw[295]+mw[296]+mw[297]+mw[298]  ;Evening O-D vehicle trips
    mw[41]=mw[27] * .38 ;Evening O-D vehicle trips

      
  /*
  TotINTrips      = TotINTrips + rowsum(149)
  TotDYTripsL1    = TotDYTripsL1    + rowsum(115)
  TotDYTripsS1    = TotDYTripsS1    + rowsum(125)
  
  TOTMOT_HBW = TOTMOT_HBW + rowsum(401)
  TOTALL_HBW = TOTALL_HBW + rowsum(401) + rowsum(411)
    
  TOTMOT_HBC = TOTMOT_HBC + rowsum(402)
  TOTALL_HBC = TOTALL_HBC + rowsum(402) + rowsum(412)
    
  TOTMOT_HBO = TOTMOT_HBO + rowsum(403)
  TOTALL_HBO = TOTALL_HBO + rowsum(403) + rowsum(413)
    
  TOTMOT_NHB = TOTMOT_NHB + rowsum(404)
  TOTALL_NHB = TOTALL_NHB + rowsum(404) + rowsum(414)
  
 ; TotMDTrips    = TotMDTrips    + rowsum(62)
 ; TotPMTrips    = TotPMTrips    + rowsum(63)
 ; TotEVTrips    = TotEVTrips    + rowsum(64)
 ; TotDYTrips    = TotDYTrips    + rowsum(65)
 ; TotDYTrips2    = TotDYTrips2    + rowsum(69)

 if (i = @UsedZones@)
 
   MOToverALL_HBW = TOTMOT_HBW / TOTALL_HBW
   MOToverALL_HBC = TOTMOT_HBC / TOTALL_HBC
   MOToverALL_HBO = TOTMOT_HBO / TOTALL_HBO
   MOToverALL_NHB = TOTMOT_NHB / TOTALL_NHB
  
   TotDYTrips1 = TotDYTripsL1 + TotDYTripsS1
  print file=@ParentDir@@ADir@@Ao@Assignment_log.detailed.txt, APPEND=F  form=@lcolw@.0C list=
     TotINTrips/100,         '   ', 'Input person trips by auto converted to vehicle trips.\n',
     TotDYTripsL1/100,       '   ', 'DY trips - Long\n',
     TotDYTripsS1/100,       '   ', 'DY trips - Short\n',
     TotDYTrips1/100,        '   ', 'DY trips - L&S\n'
  
  print file=@ParentDir@@ADir@@Ao@Assignment_log.detailed.txt, APPEND=F  form=@lcolw@.0C list=
     '   '(@lcolw@),                    '   ', 'For trips under 3 miles long, what share are motorized?\n',
     MOToverALL_HBW(@lcolw@.3),         '   ', ' - HBW share motorized.\n',
     MOToverALL_HBC(@lcolw@.3),         '   ', ' - HBC share motorized.\n',
     MOToverALL_HBO(@lcolw@.3),         '   ', ' - HBO share motorized.\n',
     MOToverALL_NHB(@lcolw@.3),         '   ', ' - NHB share motorized.\n'

          
  print file=@ParentDir@@ADir@@Ao@Assignment_log.detailed.txt, APPEND=T  form=@lcolw@.0C list=
   ' '(@lcolw@),       '   ', ' * Feedback iteration: @n@\n',
   TotPersTripsByAuto/100, '   ', 'Total daily person trips in 4-county region. (Includes ColAir, XX)\n',
   TotDYTrips/100,         '   ', 'Sum of 4-period OD tables (vehicle trips).\n',
   TotDYTrips2/100,         '   ', 'Sum2 of 4-period OD tables (vehicle trips).\n',
   TotAMTrips/100,         '   ', ' * AM OD table.\n',
   TotMDTrips/100,         '   ', ' * MD OD table.\n',
   TotPMTrips/100,         '   ', ' * PM OD table.\n',
   TotEVTrips/100,         '   ', ' * EV OD table.\n'
  endif
   */

ENDRUN

ENDLOOP ;vehclass

;Now open all the vehclass matrices and write them as a single file
:step2
LOOP period = 1,5,1  
  if     (period = 1)
    prd  = 'am3hr'
  elseif (period = 2)
    prd  = 'md6hr'
  elseif (period = 3)
    prd  = 'pm3hr'  
  elseif (period = 4)
    prd  = 'pm1hr'
  elseif (period = 5)
    prd  = 'ev12hr'
  endif
RUN PGM=MATRIX

FILEI MATI[1] = @ParentDir@@TempDir@@ATmp@@prd@_managed_tmp.da_non.mtx
FILEI MATI[2] = @ParentDir@@TempDir@@ATmp@@prd@_managed_tmp.sr_non.mtx
FILEI MATI[3] = @ParentDir@@TempDir@@ATmp@@prd@_managed_tmp.sr_hov.mtx
FILEI MATI[4] = @ParentDir@@TempDir@@ATmp@@prd@_managed_tmp.da_tol.mtx
FILEI MATI[5] = @ParentDir@@TempDir@@ATmp@@prd@_managed_tmp.sr_tol.mtx

FILEO MATO[1] = @ParentDir@@TempDir@@ATmp@@prd@_managed.mtx, mo=11-20, 31-33,
					     name=DA_NON_LONG, DA_NON_SHORT, SR_NON_LONG, SR_NON_SHORT, SR_HOV_LONG, SR_HOV_SHORT, 
					          DA_TOL_LONG, DA_TOL_SHORT, SR_TOL_LONG, SR_TOL_SHORT, TOT_LONG, TOT_SHORT, TOT
ZONEMSG       = @ZoneMsgRate@                                ;reduces print messages in TPP DOS. (i.e. runs faster).

  mw[11] = mi.1.LONG
  mw[12] = mi.1.SHORT

  mw[13] = mi.2.LONG
  mw[14] = mi.2.SHORT
  
  mw[15] = mi.3.LONG
  mw[16] = mi.3.SHORT
  
  mw[17] = mi.4.LONG
  mw[18] = mi.4.SHORT
  
  mw[19] = mi.5.LONG
  mw[20] = mi.5.SHORT
    
  mw[31] = mw[11] + mw[13] + mw[15] + mw[17] + mw[19]
  mw[32] = mw[12] + mw[14] + mw[16] + mw[18] + mw[20]
  mw[33] = mw[31] + mw[32]
ENDRUN
ENDLOOP ;purpose
:end

*(copy *.prn .\out\4AssignHwy_ODtables_ManagedLanes.out)
*(del 4AssignHwy_ODtables_ManagedLanes.txt)
*(del TPPL*)
