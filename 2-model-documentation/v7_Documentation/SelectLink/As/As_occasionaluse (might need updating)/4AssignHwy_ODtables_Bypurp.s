*(echo 4AssignHwy_ODtable_ByPurp.s > 4AssignHwy_ODtable_ByPurp.txt)  ;In case TP+ crashes during batch, this will halt process & help identify error location.
*(DEL *.PRN)

READ FILE = '..\..\0GeneralParameters.block'
READ FILE = '..\..\1ControlCenter.block'

Zone2DistrictFile = 'block\5DistrictMedium_forMatrix.txt'
TripTableFactor   = 1.0  ;Default to 1.0  - Only use for specialized applications

PAGEHEIGHT=32767 ; preclude insertion of page headers
  

;**************************************************************************
;Purpose:   Factor distributed person trips by time period, and convert
;           to vehicle trips
;**************************************************************************
:Step1

RUN PGM=MATRIX


 FILEI MATI[1] = @ParentDir@@TempDir@@MTmp@B\HBW_trips_allsegs_Pk.mtx       ; HBW trip table 
       MATI[2] = @ParentDir@@TempDir@@MTmp@B\HBC_trips_allsegs_Pk.mtx       ; HBC trip table 
       MATI[3] = @ParentDir@@TempDir@@MTmp@B\HBO_trips_allsegs_Pk.mtx       ; HBO trip table  
       MATI[4] = @ParentDir@@TempDir@@MTmp@B\NHB_trips_allsegs_Pk.mtx       ; NHB trip table  

       MATI[5] = @ParentDir@@TempDir@@MTmp@B\HBW_trips_allsegs_Ok.mtx       ; HBW trip table 
       MATI[6] = @ParentDir@@TempDir@@MTmp@B\HBC_trips_allsegs_Ok.mtx       ; HBC trip table 
       MATI[7] = @ParentDir@@TempDir@@MTmp@B\HBO_trips_allsegs_Ok.mtx       ; HBO trip table  
       MATI[8] = @ParentDir@@TempDir@@MTmp@B\NHB_trips_allsegs_Ok.mtx       ; NHB trip table  

MATI[11]= @ParentDir@@MDir@@Mo@PA_AllPurp.mtx          ; Commercial, IX/XI, XX vehicle trips (off-peak)
MATI[13]= @ParentDir@@DDir@@Do@skm_AMpk.mtx
  
  
;***** Matrix names must be identical to standardize their use in the assignment block file.
FILEO MATO[1] = @ParentDir@@TempDir@@ATmp@am3hr_ByPurp_Long.mtx,  mo=11-18,111  name=HBW, HBC, HBO, NHB, IX, XI, COMM, XX, TOT
FILEO MATO[2] = @ParentDir@@TempDir@@ATmp@md6hr_ByPurp_Long.mtx,  mo=21-28,112  name=HBW, HBC, HBO, NHB, IX, XI, COMM, XX, TOT
FILEO MATO[3] = @ParentDir@@TempDir@@ATmp@pm3hr_ByPurp_Long.mtx,  mo=31-38,113  name=HBW, HBC, HBO, NHB, IX, XI, COMM, XX, TOT
FILEO MATO[4] = @ParentDir@@TempDir@@ATmp@ev12hr_ByPurp_Long.mtx, mo=41-48,114  name=HBW, HBC, HBO, NHB, IX, XI, COMM, XX, TOT
FILEO MATO[5] = @ParentDir@@TempDir@@ATmp@dy24hr_ByPurp_Long.mtx, mo=51-58,115  name=HBW, HBC, HBO, NHB, IX, XI, COMM, XX, TOT

FILEO MATO[6] = @ParentDir@@TempDir@@ATmp@am3hr_ByPurp_Short.mtx,  mo=61-68,121  name=HBW, HBC, HBO, NHB, IX, XI, COMM, XX, TOT
FILEO MATO[7] = @ParentDir@@TempDir@@ATmp@md6hr_ByPurp_Short.mtx,  mo=71-78,122  name=HBW, HBC, HBO, NHB, IX, XI, COMM, XX, TOT
FILEO MATO[8] = @ParentDir@@TempDir@@ATmp@pm3hr_ByPurp_Short.mtx,  mo=81-88,123  name=HBW, HBC, HBO, NHB, IX, XI, COMM, XX, TOT
FILEO MATO[9] = @ParentDir@@TempDir@@ATmp@ev12hr_ByPurp_Short.mtx, mo=91-98,124  name=HBW, HBC, HBO, NHB, IX, XI, COMM, XX, TOT
FILEO MATO[10]= @ParentDir@@TempDir@@ATmp@dy24hr_ByPurp_Short.mtx, mo=101-108,125  name=HBW, HBC, HBO, NHB, IX, XI, COMM, XX, TOT

;Debugging outputs
FILEO MATO[11]= @ParentDir@@TempDir@@ATmp@Tot_LongShortVehTrips.mtx, mo=148-149,130,131  name=INVTRIPSMAJ_IN,INVTRIPSALL_IN, OUTTRIPSALL, OUTTRIPSMAJ
;FILEO MATO[12]= @ParentDir@@TempDir@@ATmp@Tot_PyPurp.mtx, mo=151-158  name=HBW,HBC,HBO,NHB,IX, XI, COMM, XX
;FILEO MATO[13]= @ParentDir@@TempDir@@ATmp@Tot_PyPurp.T.mtx, mo=161-168  name=HBW,HBC,HBO,NHB,IX, XI, COMM, XX

FILEO MATO[14]= @ParentDir@@TempDir@@ATmp@TransitOD_forHwyAssign.mtx, mo=170-181,
                name=LCL_OD_PK, LCL_OD_OK, BRT_OD_PK, BRT_OD_OK, EXP_OD_PK, EXP_OD_OK, 
                     LRT_OD_PK, LRT_OD_OK, CRT_OD_PK, CRT_OD_OK, TRN_OD_PK, TRN_OD_OK

ZONEMSG       = @ZoneMsgRate@                                ;reduces print messages in TPP DOS. (i.e. runs faster).
ZONES = @UsedZones@

;JLOOP  ;convert person trips made in autos into auto trips
  mw[301] = (MI.1.DA + MI.1.SR2/2 + MI.1.SR3P/3.5) + (MI.5.DA + MI.5.SR2/2 + MI.5.SR3P/3.5)    ; HBW Auto Trips (Daily)
  mw[302] = (MI.2.DA + MI.2.SR2/2 + MI.2.SR3P/3.5) + (MI.6.DA + MI.6.SR2/2 + MI.6.SR3P/3.5)    ; HBC Auto Trips (Daily)
  mw[303] = (MI.3.DA + MI.3.SR2/2 + MI.3.SR3P/3.5) + (MI.7.DA + MI.7.SR2/2 + MI.7.SR3P/3.5)    ; HBO Auto Trips (Daily)
  mw[304] = (MI.4.DA + MI.4.SR2/2 + MI.4.SR3P/3.5) + (MI.8.DA + MI.8.SR2/2 + MI.8.SR3P/3.5)    ; NHB Auto Trips (Daily)
  
  ;Note: After mode choice, HBW, HBO, HBC, and NHB are all X100 due to rounding errors.
  ;Multiply all other trips by 100 to make them similar in the period outputs, then
  ;divide all purposes by 100 in HWYLOAD to avoid losing trips.
  mw[305] = MI.11.IX * 100               ; IX Auto Trips (Off-Peak Speeds)
  mw[306] = MI.11.XI * 100       	; XI Auto Trips (Off-Peak Speeds)
  mw[307] = MI.11.COMM * 100             ; Commercial Auto Trips (Off-Peak Speeds)
  mw[308] = MI.11.XX   * 100         ; X-X trips
  
  mw[321] = (MI.1.DA.T + MI.1.SR2.T/2 + MI.1.SR3P.T/3.5) + (MI.5.DA.T + MI.5.SR2.T/2 + MI.5.SR3P.T/3.5)    ; HBW
  mw[322] = (MI.2.DA.T + MI.2.SR2.T/2 + MI.2.SR3P.T/3.5) + (MI.6.DA.T + MI.6.SR2.T/2 + MI.6.SR3P.T/3.5)    ; HBC 
  mw[323] = (MI.3.DA.T + MI.3.SR2.T/2 + MI.3.SR3P.T/3.5) + (MI.7.DA.T + MI.7.SR2.T/2 + MI.7.SR3P.T/3.5)    ; HBO 
  mw[324] = (MI.4.DA.T + MI.4.SR2.T/2 + MI.4.SR3P.T/3.5) + (MI.8.DA.T + MI.8.SR2.T/2 + MI.8.SR3P.T/3.5)    ; NHB 
  mw[325] = MI.11.IX.T * 100   
  mw[326] = MI.11.XI.T * 100   
  mw[327] = MI.11.COMM.T * 100 
  mw[328] = MI.11.XX.T * 100 

  ;get a daily OD transit table, then assign to a highway network to get daily transit screenlines  (use factors at each 
  ;screen after that if "peak hour" is desired).

  mw[350] = (MI.1.wLCL   + MI.2.wLCL   + MI.3.wLCL   + MI.4.wLCL   +
             MI.1.dLCL   + MI.2.dLCL   + MI.3.dLCL   + MI.4.dLCL   )  ;Pk
  mw[351] = (MI.5.wLCL   + MI.6.wLCL   + MI.7.wLCL   + MI.8.wLCL   +
             MI.5.dLCL   + MI.6.dLCL   + MI.7.dLCL   + MI.8.dLCL   )  ;Ok

  mw[352] = (MI.1.wLCL.T + MI.2.wLCL.T + MI.3.wLCL.T + MI.4.wLCL.T +
             MI.1.dLCL.T + MI.2.dLCL.T + MI.3.dLCL.T + MI.4.dLCL.T )  ;Pk
  mw[353] = (MI.5.wLCL.T + MI.6.wLCL.T + MI.7.wLCL.T + MI.8.wLCL.T +
             MI.5.dLCL.T + MI.6.dLCL.T + MI.7.dLCL.T + MI.8.dLCL.T )  ;Ok
             
  mw[354] = (MI.1.wBRT   + MI.2.wBRT   + MI.3.wBRT   + MI.4.wBRT   +
             MI.1.dBRT   + MI.2.dBRT   + MI.3.dBRT   + MI.4.dBRT   )  ;Pk
  mw[355] = (MI.5.wBRT   + MI.6.wBRT   + MI.7.wBRT   + MI.8.wBRT   +
             MI.5.dBRT   + MI.6.dBRT   + MI.7.dBRT   + MI.8.dBRT   )  ;Ok

  mw[356] = (MI.1.wBRT.T + MI.2.wBRT.T + MI.3.wBRT.T + MI.4.wBRT.T +
             MI.1.dBRT.T + MI.2.dBRT.T + MI.3.dBRT.T + MI.4.dBRT.T )  ;Pk
  mw[357] = (MI.5.wBRT.T + MI.6.wBRT.T + MI.7.wBRT.T + MI.8.wBRT.T +
             MI.5.dBRT.T + MI.6.dBRT.T + MI.7.dBRT.T + MI.8.dBRT.T )  ;Ok

  mw[358] = (MI.1.wEXP   + MI.2.wEXP   + MI.3.wEXP   + MI.4.wEXP   +
             MI.1.dEXP   + MI.2.dEXP   + MI.3.dEXP   + MI.4.dEXP   )  ;Pk
  mw[359] = (MI.5.wEXP   + MI.6.wEXP   + MI.7.wEXP   + MI.8.wEXP   +
             MI.5.dEXP   + MI.6.dEXP   + MI.7.dEXP   + MI.8.dEXP   )  ;Ok

  mw[360] = (MI.1.wEXP.T + MI.2.wEXP.T + MI.3.wEXP.T + MI.4.wEXP.T +
             MI.1.dEXP.T + MI.2.dEXP.T + MI.3.dEXP.T + MI.4.dEXP.T )  ;Pk
  mw[361] = (MI.5.wEXP.T + MI.6.wEXP.T + MI.7.wEXP.T + MI.8.wEXP.T +
             MI.5.dEXP.T + MI.6.dEXP.T + MI.7.dEXP.T + MI.8.dEXP.T )  ;Ok

  mw[362] = (MI.1.wLRT   + MI.2.wLRT   + MI.3.wLRT   + MI.4.wLRT   +
             MI.1.dLRT   + MI.2.dLRT   + MI.3.dLRT   + MI.4.dLRT   )  ;Pk
  mw[363] = (MI.5.wLRT   + MI.6.wLRT   + MI.7.wLRT   + MI.8.wLRT   +
             MI.5.dLRT   + MI.6.dLRT   + MI.7.dLRT   + MI.8.dLRT   )  ;Ok

  mw[364] = (MI.1.wLRT.T + MI.2.wLRT.T + MI.3.wLRT.T + MI.4.wLRT.T +
             MI.1.dLRT.T + MI.2.dLRT.T + MI.3.dLRT.T + MI.4.dLRT.T )  ;Pk
  mw[365] = (MI.5.wLRT.T + MI.6.wLRT.T + MI.7.wLRT.T + MI.8.wLRT.T +
             MI.5.dLRT.T + MI.6.dLRT.T + MI.7.dLRT.T + MI.8.dLRT.T )  ;Ok
             
  mw[366] = (MI.1.wCRT   + MI.2.wCRT   + MI.3.wCRT   + MI.4.wCRT   +
             MI.1.dCRT   + MI.2.dCRT   + MI.3.dCRT   + MI.4.dCRT   )  ;Pk
  mw[367] = (MI.5.wCRT   + MI.6.wCRT   + MI.7.wCRT   + MI.8.wCRT   +
             MI.5.dCRT   + MI.6.dCRT   + MI.7.dCRT   + MI.8.dCRT   )  ;Ok

  mw[368] = (MI.1.wCRT.T + MI.2.wCRT.T + MI.3.wCRT.T + MI.4.wCRT.T +
             MI.1.dCRT.T + MI.2.dCRT.T + MI.3.dCRT.T + MI.4.dCRT.T )  ;Pk
  mw[369] = (MI.5.wCRT.T + MI.6.wCRT.T + MI.7.wCRT.T + MI.8.wCRT.T +
             MI.5.dCRT.T + MI.6.dCRT.T + MI.7.dCRT.T + MI.8.dCRT.T )  ;Ok
             
  mw[370] =  MI.1.Transit   + MI.2.Transit   + MI.3.Transit   + MI.4.Transit  ;Pk
  mw[371] =  MI.5.Transit   + MI.6.Transit   + MI.7.Transit   + MI.8.Transit  ;Ok
             
  mw[372] =  MI.1.Transit.T + MI.2.Transit.T + MI.3.Transit.T + MI.4.Transit.T ;Pk
  mw[373] =  MI.5.Transit.T + MI.6.Transit.T + MI.7.Transit.T + MI.8.Transit.T ;Ok
             
  mw[170] = mw[350]/2 + mw[352]/2  ;Pk LCL OD
  mw[171] = mw[351]/2 + mw[353]/2  ;Ok LCL OD

  mw[172] = mw[354]/2 + mw[356]/2  ;Pk BRT OD
  mw[173] = mw[355]/2 + mw[357]/2  ;Ok BRT OD
  
  mw[174] = mw[358]/2 + mw[360]/2  ;Pk EXP OD
  mw[175] = mw[359]/2 + mw[361]/2  ;Ok EXP OD
  
  mw[176] = mw[362]/2 + mw[364]/2  ;Pk LRT OD
  mw[177] = mw[363]/2 + mw[365]/2  ;Ok LRT OD
  
  mw[178] = mw[366]/2 + mw[368]/2  ;Pk CRT OD
  mw[179] = mw[367]/2 + mw[369]/2  ;Ok CRT OD
  
  mw[180] = mw[370]/2 + mw[372]/2  ;Pk Transit OD
  mw[181] = mw[371]/2 + mw[373]/2  ;Ok Transit OD 


 ; MW[147]= mw[301]*@VEH_OCCUPANCY_HBW@ + mw[302]*@VEH_OCCUPANCY_HBC@ + mw[303]*@VEH_OCCUPANCY_HBO@ + mw[304]*@VEH_OCCUPANCY_NHB@ + 
 ;        mw[305]+mw[306]+mw[307]+mw[308]  ;total input person trips
         
  MW[148]= mw[301]+mw[302]+mw[303]+mw[304]  						;Major:  Total input person trips when converted to vehicle trips
  MW[149]= mw[305]+mw[306]+mw[307]+mw[308] + mw[148]  	;All:    Total input person trips when converted to vehicle trips

;********************** Convert P/A matrices to O-D matrices for four time periods
;The percentages shown below were derived from the 93 household survey
;IXXI note:  The HIS suggests that the %IXXI by period is somewhere between
;the HBW and the HBO.  Therefore, the %'s shown are about 1/2 way between
;HBW and HBO (based on SL range).  This is to get the directional split of each more correct.

JLOOP
if (mi.13.distance[j] >= @LongTripBreakPt@) ;miles 
;AM Peak
  mw[11]=(mw[301]*.3451 + mw[321]*.0245)*@TripTableFactor@  ;HBW  
  mw[12]=(mw[302]*.3451 + mw[322]*.0245)*@TripTableFactor@  ;HBC  
  mw[13]=(mw[303]*.1432 + mw[323]*.0177)*@TripTableFactor@  ;HBO
  mw[14]=(mw[304]*.0331 + mw[324]*.0331)*@TripTableFactor@  ;NHB
  mw[15]=(mw[305]*.0200 + mw[325]*.2500)*@TripTableFactor@  ;IX
  mw[16]=(mw[306]*.2500 + mw[326]*.0200)*@TripTableFactor@  ;XI
  mw[17]=(mw[307]*.0335 + mw[327]*.0335)*@TripTableFactor@  ;COMM
  mw[18]=(mw[308]*.1000 + mw[328]*.1000)*@TripTableFactor@  ;XX

;Mid-day
  mw[21]=(mw[301]*.0826 + mw[321]*.0895)*@TripTableFactor@  ;HBW
  mw[22]=(mw[302]*.0826 + mw[322]*.0895)*@TripTableFactor@  ;HBC
  mw[23]=(mw[303]*.1349 + mw[323]*.1384)*@TripTableFactor@  ;HBO
  mw[24]=(mw[304]*.2543 + mw[324]*.2543)*@TripTableFactor@  ;NHB
  mw[25]=(mw[305]*.1000 + mw[325]*.1000)*@TripTableFactor@  ;IX
  mw[26]=(mw[306]*.1000 + mw[326]*.1000)*@TripTableFactor@  ;XI
  mw[27]=(mw[307]*.2650 + mw[327]*.2650)*@TripTableFactor@  ;COMM
  mw[28]=(mw[308]*.1450 + mw[328]*.1450)*@TripTableFactor@  ;XX

;PM peak
  mw[31]=(mw[301]*.0194 + mw[321]*.2554)*@TripTableFactor@  ;HBW
  mw[32]=(mw[302]*.0194 + mw[322]*.2554)*@TripTableFactor@  ;HBC
  mw[33]=(mw[303]*.1047 + mw[323]*.1591)*@TripTableFactor@  ;HBO
  mw[34]=(mw[304]*.1316 + mw[324]*.1316)*@TripTableFactor@  ;NHB
  mw[35]=(mw[305]*.2200 + mw[325]*.0600)*@TripTableFactor@  ;IX
  mw[36]=(mw[306]*.0600 + mw[326]*.2200)*@TripTableFactor@  ;XI  
  mw[37]=(mw[307]*.1300 + mw[327]*.1300)*@TripTableFactor@  ;COMM
  mw[38]=(mw[308]*.1300 + mw[328]*.1300)*@TripTableFactor@  ;XX

;Evening
  mw[41]=(mw[301]*.0529 + mw[321]*.1306)*@TripTableFactor@  ;HBW
  mw[42]=(mw[302]*.0529 + mw[322]*.1306)*@TripTableFactor@  ;HBC
  mw[43]=(mw[303]*.1172 + mw[323]*.1848)*@TripTableFactor@  ;HBO
  mw[44]=(mw[304]*.0810 + mw[324]*.0810)*@TripTableFactor@  ;NHB
  mw[45]=(mw[305]*.1600 + mw[325]*.0900)*@TripTableFactor@  ;IX
  mw[46]=(mw[306]*.0900 + mw[326]*.1600)*@TripTableFactor@  ;XI
  mw[47]=(mw[307]*.0715 + mw[327]*.0715)*@TripTableFactor@  ;COMM
  mw[48]=(mw[308]*.1250 + mw[328]*.1250)*@TripTableFactor@  ;XX

;Daily
  mw[51]= mw[11] + mw[21] + mw[31] + mw[41]  ;HBW
  mw[52]= mw[12] + mw[22] + mw[32] + mw[42]  ;HBC
  mw[53]= mw[13] + mw[23] + mw[33] + mw[43]  ;HBO
  mw[54]= mw[14] + mw[24] + mw[34] + mw[44]  ;NHB
  mw[55]= mw[15] + mw[25] + mw[35] + mw[45]  ;IX
  mw[56]= mw[16] + mw[26] + mw[36] + mw[46]  ;XI
  mw[57]= mw[17] + mw[27] + mw[37] + mw[47]  ;COMM
  mw[58]= mw[18] + mw[28] + mw[38] + mw[48]  ;XX

else
  
;AM Peak
  mw[61]=(mw[301]*.3451 + mw[321]*.0245)*@TripTableFactor@  ;HBW  
  mw[62]=(mw[302]*.3451 + mw[322]*.0245)*@TripTableFactor@  ;HBC  
  mw[63]=(mw[303]*.1432 + mw[323]*.0177)*@TripTableFactor@  ;HBO
  mw[64]=(mw[304]*.0331 + mw[324]*.0331)*@TripTableFactor@  ;NHB
  mw[65]=(mw[305]*.0200 + mw[325]*.2500)*@TripTableFactor@  ;IX
  mw[66]=(mw[306]*.2500 + mw[326]*.0200)*@TripTableFactor@  ;XI
  mw[67]=(mw[307]*.0335 + mw[327]*.0335)*@TripTableFactor@  ;COMM
  mw[68]=(mw[308]*.1000 + mw[328]*.1000)*@TripTableFactor@  ;XX

;Mid-day
  mw[71]=(mw[301]*.0826 + mw[321]*.0895)*@TripTableFactor@  ;HBW
  mw[72]=(mw[302]*.0826 + mw[322]*.0895)*@TripTableFactor@  ;HBC
  mw[73]=(mw[303]*.1349 + mw[323]*.1384)*@TripTableFactor@  ;HBO
  mw[74]=(mw[304]*.2543 + mw[324]*.2543)*@TripTableFactor@  ;NHB
  mw[75]=(mw[305]*.1000 + mw[325]*.1000)*@TripTableFactor@  ;IX
  mw[76]=(mw[306]*.1000 + mw[326]*.1000)*@TripTableFactor@  ;XI
  mw[77]=(mw[307]*.2650 + mw[327]*.2650)*@TripTableFactor@  ;COMM
  mw[78]=(mw[308]*.1450 + mw[328]*.1450)*@TripTableFactor@  ;XX

;PM peak
  mw[81]=(mw[301]*.0194 + mw[321]*.2554)*@TripTableFactor@  ;HBW
  mw[82]=(mw[302]*.0194 + mw[322]*.2554)*@TripTableFactor@  ;HBC
  mw[83]=(mw[303]*.1047 + mw[323]*.1591)*@TripTableFactor@  ;HBO
  mw[84]=(mw[304]*.1316 + mw[324]*.1316)*@TripTableFactor@  ;NHB
  mw[85]=(mw[305]*.2200 + mw[325]*.0600)*@TripTableFactor@  ;IX
  mw[86]=(mw[306]*.0600 + mw[326]*.2200)*@TripTableFactor@  ;XI  
  mw[87]=(mw[307]*.1300 + mw[327]*.1300)*@TripTableFactor@  ;COMM
  mw[88]=(mw[308]*.1300 + mw[328]*.1300)*@TripTableFactor@  ;XX

;Evening
  mw[91]=(mw[301]*.0529 + mw[321]*.1306)*@TripTableFactor@  ;HBW
  mw[92]=(mw[302]*.0529 + mw[322]*.1306)*@TripTableFactor@  ;HBC
  mw[93]=(mw[303]*.1172 + mw[323]*.1848)*@TripTableFactor@  ;HBO
  mw[94]=(mw[304]*.0810 + mw[324]*.0810)*@TripTableFactor@  ;NHB
  mw[95]=(mw[305]*.1600 + mw[325]*.0900)*@TripTableFactor@  ;IX
  mw[96]=(mw[306]*.0900 + mw[326]*.1600)*@TripTableFactor@  ;XI
  mw[97]=(mw[307]*.0715 + mw[327]*.0715)*@TripTableFactor@  ;COMM
  mw[98]=(mw[308]*.1250 + mw[328]*.1250)*@TripTableFactor@  ;XX

;Daily
  mw[101]= mw[61] + mw[71] + mw[81] + mw[91]  ;HBW
  mw[102]= mw[62] + mw[72] + mw[82] + mw[92]  ;HBC
  mw[103]= mw[63] + mw[73] + mw[83] + mw[93]  ;HBO
  mw[104]= mw[64] + mw[74] + mw[84] + mw[94]  ;NHB
  mw[105]= mw[65] + mw[75] + mw[85] + mw[95]  ;IX
  mw[106]= mw[66] + mw[76] + mw[86] + mw[96]  ;XI
  mw[107]= mw[67] + mw[77] + mw[87] + mw[97]  ;COMM
  mw[108]= mw[68] + mw[78] + mw[88] + mw[98]  ;XX
  
  if (mi.13.distance[j] <= 4)  ;find the share of short trips that are non-motorized
    mw[401] = MI.1.MOTOR + MI.5.MOTOR
    mw[402] = MI.2.MOTOR + MI.6.MOTOR
    mw[403] = MI.3.MOTOR + MI.7.MOTOR
    mw[404] = MI.4.MOTOR + MI.8.MOTOR

    mw[411] = MI.1.NONMOTOR + MI.5.NONMOTOR
    mw[412] = MI.2.NONMOTOR + MI.6.NONMOTOR
    mw[413] = MI.3.NONMOTOR + MI.7.NONMOTOR
    mw[414] = MI.4.NONMOTOR + MI.8.NONMOTOR

    if (mw[401] + mw[411] <> 0)   
      mw[421] = mw[401] / (mw[401] + mw[411])  ;HBW motorized / HBW total
    else
      mw[421] = 0
    endif
    
    if (mw[402] + mw[412] <> 0)   
      mw[422] = mw[402] / (mw[402] + mw[412])  ;HBC motorized / HBC total
    else
      mw[422] = 0
    endif
    
    if (mw[403] + mw[413] <> 0)   
      mw[423] = mw[403] / (mw[403] + mw[413])  ;HBO motorized / HBO total
    else
      mw[423] = 0
    endif
    
    if (mw[404] + mw[414] <> 0)   
      mw[424] = mw[404] / (mw[404] + mw[414])  ;NHB motorized / NHB total
    else
      mw[424] = 0
    endif
    
  endif
endif
ENDJLOOP  
  
  
;*********************** Total vehicle trips
    mw[111]=mw[11]+mw[12]+mw[13]+mw[14]+mw[15]+mw[16]+mw[17]+mw[18] ;AM O-D vehicle trips
    mw[112]=mw[21]+mw[22]+mw[23]+mw[24]+mw[25]+mw[26]+mw[27]+mw[28] ;Mid-day O-D vehicle trips
    mw[113]=mw[31]+mw[32]+mw[33]+mw[34]+mw[35]+mw[36]+mw[37]+mw[38] ;PM O-D vehicle trips
    mw[114]=mw[41]+mw[42]+mw[43]+mw[44]+mw[45]+mw[46]+mw[47]+mw[48] ;Evening O-D vehicle trips
    mw[115]=mw[51]+mw[52]+mw[53]+mw[54]+mw[55]+mw[56]+mw[57]+mw[58] ;Daily trips
    mw[116]=mw[51]+mw[52]+mw[53]+mw[54]      ;Daily, major purposes only
    mw[119]=mw[111]+mw[112]+mw[113]+mw[114]  ;total up for printing to log file


    mw[121]=mw[61]+mw[62]+mw[63]+mw[64]+mw[65]+mw[66]+mw[67]+mw[68] ;AM O-D vehicle trips
    mw[122]=mw[71]+mw[72]+mw[73]+mw[74]+mw[75]+mw[76]+mw[77]+mw[78] ;Mid-day O-D vehicle trips
    mw[123]=mw[81]+mw[82]+mw[83]+mw[84]+mw[85]+mw[86]+mw[87]+mw[88] ;PM O-D vehicle trips
    mw[124]=mw[91]+mw[92]+mw[93]+mw[94]+mw[95]+mw[96]+mw[97]+mw[98] ;Evening O-D vehicle trips
    mw[125]=mw[101]+mw[102]+mw[103]+mw[104]+mw[105]+mw[106]+mw[107]+mw[108] ;Daily trips
    mw[126]=mw[101]+mw[102]+mw[103]+mw[104]      ;Daily, major purposes only
    mw[129]=mw[121]+mw[122]+mw[123]+mw[124]  ;total up for printing to log file
    
    mw[130]=mw[115] + mw[125]
    mw[131]=mw[116] + mw[126]

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

  /*
  print file=@ParentDir@@ADir@@Ao@Assignment_log.detailed.txt, APPEND=T  form=@lcolw@.0C list=
   ' '(@lcolw@),       '   ', ' * Feedback iteration: @n@\n',
   TotPersTripsByAuto/100, '   ', 'Total daily person trips in 4-county region. (Includes ColAir, XX)\n',
   TotDYTrips/100,         '   ', 'Sum of 4-period OD tables (vehicle trips).\n',
   TotDYTrips2/100,         '   ', 'Sum2 of 4-period OD tables (vehicle trips).\n',
   TotAMTrips/100,         '   ', ' * AM OD table.\n',
   TotMDTrips/100,         '   ', ' * MD OD table.\n',
   TotPMTrips/100,         '   ', ' * PM OD table.\n',
   TotEVTrips/100,         '   ', ' * EV OD table.\n'
   */
  endif

ENDRUN

*(copy *.prn .\out\4AssignHwy_ODtable_ByPurp.out)
*(del 4AssignHwy_ODtable_ByPurp.txt)
*(del TPPL*)
