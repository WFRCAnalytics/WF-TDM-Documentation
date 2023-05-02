*(echo 4AssignHwy.s > 4AssignHwy.txt)  ;In case TP+ crashes during batch, this will halt process & help identify error location.
*(DEL *.PRN)

READ FILE = '..\..\0GeneralParameters.block'
READ FILE = '..\..\1ControlCenter.block'

PathsTransitGY = ' '
PathsTransitY  = ';'
PathsTransitN  = ';'
PathsGroupField = 'DISTLRG'
PathsGroupFieldValues = '9'

goto :step1

:step1

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

FILEO MATO[1]= @ParentDir@@TempDir@@ATmp@TransitOD_forHwyAssign.mtx, mo=184-195,
                name=LCL_OD_PK, LCL_OD_OK, BRT_OD_PK, BRT_OD_OK, EXP_OD_PK, EXP_OD_OK, 
                     LRT_OD_PK, LRT_OD_OK, CRT_OD_PK, CRT_OD_OK, TRN_OD_PK, TRN_OD_OK


ZONEMSG       = @ZoneMsgRate@                                ;reduces print messages in TPP DOS. (i.e. runs faster).
ZONES = @UsedZones@



 ;get a daily OD transit table, then assign to a highway network to get daily transit screenlines  (use factors at each 
  ;screen after that if "peak hour" is desired).

  mw[1] = (MI.1.wLCL   + MI.2.wLCL   + MI.3.wLCL   + MI.4.wLCL   +
           MI.1.dLCL   + MI.2.dLCL   + MI.3.dLCL   + MI.4.dLCL   )  ;Pk
  mw[2] = (MI.5.wLCL   + MI.6.wLCL   + MI.7.wLCL   + MI.8.wLCL   +
           MI.5.dLCL   + MI.6.dLCL   + MI.7.dLCL   + MI.8.dLCL   )  ;Ok

  mw[3] = (MI.1.wLCL.T + MI.2.wLCL.T + MI.3.wLCL.T + MI.4.wLCL.T +
           MI.1.dLCL.T + MI.2.dLCL.T + MI.3.dLCL.T + MI.4.dLCL.T )  ;Pk
  mw[4] = (MI.5.wLCL.T + MI.6.wLCL.T + MI.7.wLCL.T + MI.8.wLCL.T +
           MI.5.dLCL.T + MI.6.dLCL.T + MI.7.dLCL.T + MI.8.dLCL.T )  ;Ok
             
  mw[5] = (MI.1.wBRT   + MI.2.wBRT   + MI.3.wBRT   + MI.4.wBRT   +
           MI.1.dBRT   + MI.2.dBRT   + MI.3.dBRT   + MI.4.dBRT   )  ;Pk
  mw[6] = (MI.5.wBRT   + MI.6.wBRT   + MI.7.wBRT   + MI.8.wBRT   +
           MI.5.dBRT   + MI.6.dBRT   + MI.7.dBRT   + MI.8.dBRT   )  ;Ok

  mw[7] = (MI.1.wBRT.T + MI.2.wBRT.T + MI.3.wBRT.T + MI.4.wBRT.T +
           MI.1.dBRT.T + MI.2.dBRT.T + MI.3.dBRT.T + MI.4.dBRT.T )  ;Pk
  mw[8] = (MI.5.wBRT.T + MI.6.wBRT.T + MI.7.wBRT.T + MI.8.wBRT.T +
           MI.5.dBRT.T + MI.6.dBRT.T + MI.7.dBRT.T + MI.8.dBRT.T )  ;Ok

  mw[9] = (MI.1.wEXP   + MI.2.wEXP   + MI.3.wEXP   + MI.4.wEXP   +
           MI.1.dEXP   + MI.2.dEXP   + MI.3.dEXP   + MI.4.dEXP   )  ;Pk
  mw[10] =(MI.5.wEXP   + MI.6.wEXP   + MI.7.wEXP   + MI.8.wEXP   +
           MI.5.dEXP   + MI.6.dEXP   + MI.7.dEXP   + MI.8.dEXP   )  ;Ok

  mw[11] = (MI.1.wEXP.T + MI.2.wEXP.T + MI.3.wEXP.T + MI.4.wEXP.T +
            MI.1.dEXP.T + MI.2.dEXP.T + MI.3.dEXP.T + MI.4.dEXP.T )  ;Pk
  mw[12] = (MI.5.wEXP.T + MI.6.wEXP.T + MI.7.wEXP.T + MI.8.wEXP.T +
            MI.5.dEXP.T + MI.6.dEXP.T + MI.7.dEXP.T + MI.8.dEXP.T )  ;Ok

  mw[13] = (MI.1.wLRT   + MI.2.wLRT   + MI.3.wLRT   + MI.4.wLRT   +
            MI.1.dLRT   + MI.2.dLRT   + MI.3.dLRT   + MI.4.dLRT   )  ;Pk
  mw[14] = (MI.5.wLRT   + MI.6.wLRT   + MI.7.wLRT   + MI.8.wLRT   +
            MI.5.dLRT   + MI.6.dLRT   + MI.7.dLRT   + MI.8.dLRT   )  ;Ok

  mw[15] = (MI.1.wLRT.T + MI.2.wLRT.T + MI.3.wLRT.T + MI.4.wLRT.T +
            MI.1.dLRT.T + MI.2.dLRT.T + MI.3.dLRT.T + MI.4.dLRT.T )  ;Pk
  mw[16] = (MI.5.wLRT.T + MI.6.wLRT.T + MI.7.wLRT.T + MI.8.wLRT.T +
            MI.5.dLRT.T + MI.6.dLRT.T + MI.7.dLRT.T + MI.8.dLRT.T )  ;Ok
             
  mw[17] = (MI.1.wCRT   + MI.2.wCRT   + MI.3.wCRT   + MI.4.wCRT   +
            MI.1.dCRT   + MI.2.dCRT   + MI.3.dCRT   + MI.4.dCRT   )  ;Pk
  mw[18] = (MI.5.wCRT   + MI.6.wCRT   + MI.7.wCRT   + MI.8.wCRT   +
            MI.5.dCRT   + MI.6.dCRT   + MI.7.dCRT   + MI.8.dCRT   )  ;Ok

  mw[19] = (MI.1.wCRT.T + MI.2.wCRT.T + MI.3.wCRT.T + MI.4.wCRT.T +
            MI.1.dCRT.T + MI.2.dCRT.T + MI.3.dCRT.T + MI.4.dCRT.T )  ;Pk
  mw[20] = (MI.5.wCRT.T + MI.6.wCRT.T + MI.7.wCRT.T + MI.8.wCRT.T +
            MI.5.dCRT.T + MI.6.dCRT.T + MI.7.dCRT.T + MI.8.dCRT.T )  ;Ok
             
  mw[21] =  MI.1.Transit   + MI.2.Transit   + MI.3.Transit   + MI.4.Transit  ;Pk
  mw[22] =  MI.5.Transit   + MI.6.Transit   + MI.7.Transit   + MI.8.Transit  ;Ok
             
  mw[23] =  MI.1.Transit.T + MI.2.Transit.T + MI.3.Transit.T + MI.4.Transit.T ;Pk
  mw[24] =  MI.5.Transit.T + MI.6.Transit.T + MI.7.Transit.T + MI.8.Transit.T ;Ok
             
  mw[184] = mw[1]/2 + mw[3]/2  ;Pk LCL OD
  mw[185] = mw[2]/2 + mw[4]/2  ;Ok LCL OD

  mw[186] = mw[5]/2 + mw[7]/2  ;Pk BRT OD
  mw[187] = mw[7]/2 + mw[8]/2  ;Ok BRT OD
  
  mw[188] = mw[9]/2  + mw[11]/2  ;Pk EXP OD
  mw[189] = mw[10]/2 + mw[12]/2  ;Ok EXP OD
  
  mw[190] = mw[13]/2 + mw[15]/2  ;Pk LRT OD
  mw[191] = mw[14]/2 + mw[16]/2  ;Ok LRT OD
  
  mw[192] = mw[17]/2 + mw[19]/2  ;Pk CRT OD
  mw[193] = mw[18]/2 + mw[20]/2  ;Ok CRT OD
  
  mw[194] = mw[21]/2 + mw[23]/2  ;Pk Transit OD
  mw[195] = mw[22]/2 + mw[24]/2  ;Ok Transit OD 
  
ENDRUN



;**************************************************************************
;Purpose:	Assign AM trip table to loaded network
;**************************************************************************
:step2
RUN PGM=HWYLOAD
  ZONEMSG       = @ZoneMsgRate@  ;reduces print messages in TPP DOS. (i.e. runs faster).  ;reduces print messages in TPP DOS. (i.e. runs faster).
  FILEI MATI[1] = @ParentDir@@TempDir@@ATmp@TransitOD_forHwyAssign.mtx
  FILEI NETI    = @ParentDir@@ADir@Ao_@AssignType@\@unloadednetprefix@_4pd.@AssignType@.MNGremoved.net
  FILEO NETO    = @ParentDir@@TempDir@@ATmp@tmp_transit.net	   ; alternate tmpa & tmpb until final network achieved
  @PathsTransitY@  FILEO PATHO[1]=@ParentDir@@TempDir@@ATmp@TransitPaths.@RID@.pth,  costdec=1, iters=0
  @PathsTransitGY@ FILEO PATHO[1]=@ParentDir@@TempDir@@ATmp@TransitPaths.@RID@.@PathsGroupField@.pth,  costdec=1, iters=0
  
  FUNCTION {
    V=VOL[1]+VOL[2]+VOL[3]+VOL[4]+VOL[5]+VOL[6]+VOL[7]+VOL[8]+VOL[9]+VOL[10]
;    COST[1] = (@ShortTripTimeShare@*TIME + @ShortTripDistShare@*LI.DISTANCE)
;    TC[1]=BASE_TIME*(1 + @VDF_Fwy_coef@*(min(V/C, @maxfwyVCforVDF@))^@VDF_Fwy_exp@)  ; BPR Equation Fwys
    }
    
PHASE=LINKREAD
    LW.TIMEPK = (LI.DISTANCE/LI.AM_SPD)*60 
    LW.TIMEOK = (LI.DISTANCE/LI.MD_SPD)*60 
 ;  C  = LI.CAP1HR1LN*LI.lanes*24  ;Period's LOS E link capacity
  @PathsTransitGY@ IF (LI.@PathsGroupField@==@PathsGroupFieldValues@) ADDTOGROUP=1 
ENDPHASE

PHASE=ILOOP
    mw[1] = MI.1.LCL_OD_PK 
    mw[2] = MI.1.BRT_OD_PK 
    mw[3] = MI.1.EXP_OD_PK 
    mw[4] = MI.1.LRT_OD_PK 
    mw[5] = MI.1.CRT_OD_PK 

    mw[6] = MI.1.LCL_OD_OK 
    mw[7] = MI.1.BRT_OD_OK 
    mw[8] = MI.1.EXP_OD_OK 
    mw[9] = MI.1.LRT_OD_OK 
    mw[10] = MI.1.CRT_OD_OK 
                     
 @PathsTransitGY@ PATHLOAD PATH=LW.TIMEPK, PATHO=1, PATHOGROUP=1, FULLPATH=T, INCLUDECOST=F, NAME=COST_PATH, ALLJ=F,
 @PathsTransitY@  PATHLOAD PATH=LW.TIMEPK, PATHO=1, INCLUDECOST=F, NAME=COST_PATH, ALLJ=F,
 @PathsTransitN@  PATHLOAD PATH=LW.TIMEPK, 
      VOL[1]=mw[1]/100,
      VOL[2]=mw[2]/100,
      VOL[3]=mw[3]/100,
      VOL[4]=mw[4]/100,
      VOL[5]=mw[5]/100

 @PathsTransitGY@ PATHLOAD PATH=LW.TIMEOK, PATHO=1, PATHOGROUP=1, FULLPATH=T, INCLUDECOST=F, NAME=COST_PATH, ALLJ=F,
 @PathsTransitY@  PATHLOAD PATH=LW.TIMEOK, PATHO=1, INCLUDECOST=F, NAME=COST_PATH, ALLJ=F,
 @PathsTransitN@  PATHLOAD PATH=LW.TIMEOK, 
      VOL[6]=mw[6]/100,
      VOL[7]=mw[7]/100,
      VOL[8]=mw[8]/100,
      VOL[9]=mw[9]/100,
      VOL[10]=mw[10]/100
        
  PARAMETERS MAXITERS = 2
  ENDPHASE
  
  PHASE=ADJUST
    PARAMETERS COMBINE=EQUI  ; Combine Iterative Arc Solution Sets to attain system equilibrium
  ENDPHASE

ENDRUN

; ******************************************************************************
; Purpose:  HWYLOAD won't let me name the volumes in the output network 
; anything but V_1, V_2, etc. So read them into HWYNET and write them 
; back out with the names I want
; ******************************************************************************
:step2
RUN PGM=HWYNET
  FILEI NETI[1] = @ParentDir@@TempDir@@ATmp@tmp_transit.net	   ; alternate tmpa & tmpb until final network achieved
  FILEO NETO    = @ParentDir@@ADir@@Ao@@Ao_Transit@@unloadednetprefix@_4pd.@AssignType@.screentransit.net, INCLUDE = 
                  DISTANCE, STREET_N, LANES, FT, COUNTY, ORIENT, SCRNMED, SCRNLRG, 
                  DY_TRAN, DY_TRAN2WY_RND, DY_TRAN2WY_100,
                  PK_TRAN, OK_TRAN, PKPCT_TRAN, OKPCT_TRAN,
                  PK_LCL, PK_BRT, PK_EXP, PK_LRT, PK_CRT,  PKPCT_LCL, PKPCT_BRT, PKPCT_EXP, PKPCT_LRT, PKPCT_CRT,
                  OK_LCL, OK_BRT, OK_EXP, OK_LRT, OK_CRT,  OKPCT_LCL, OKPCT_BRT, OKPCT_EXP, OKPCT_LRT, OKPCT_CRT

  DY_TRAN     = round(V_1)
  PK_LCL      = round(V1_1)
  PK_BRT      = round(V2_1)
  PK_EXP      = round(V3_1)
  PK_LRT      = round(V4_1)
  PK_CRT      = round(V5_1)

  OK_LCL      = round(V6_1)
  OK_BRT      = round(V7_1)
  OK_EXP      = round(V8_1)
  OK_LRT      = round(V9_1)
  OK_CRT      = round(V10_1)  
  
  PK_TRAN = PK_LCL+PK_BRT+PK_EXP+PK_LRT+PK_CRT
  OK_TRAN = OK_LCL+OK_BRT+OK_EXP+OK_LRT+OK_CRT
  
  if (PK_TRAN > 0)
    PKPCT_LCL = round ((PK_LCL / PK_TRAN)*100)
    PKPCT_BRT = round ((PK_BRT / PK_TRAN)*100)
    PKPCT_EXP = round ((PK_EXP / PK_TRAN)*100)
    PKPCT_LRT = round ((PK_LRT / PK_TRAN)*100)
    PKPCT_CRT = round ((PK_CRT / PK_TRAN)*100)
  endif
  if (OK_TRAN > 0)
    OKPCT_LCL = round ((OK_LCL / OK_TRAN)*100)
    OKPCT_BRT = round ((OK_BRT / OK_TRAN)*100)
    OKPCT_EXP = round ((OK_EXP / OK_TRAN)*100)
    OKPCT_LRT = round ((OK_LRT / OK_TRAN)*100)
    OKPCT_CRT = round ((OK_CRT / OK_TRAN)*100)
  endif 
  if (DY_TRAN > 0)
    PKPCT_TRAN = round ((PK_TRAN / DY_TRAN)*100)
    OKPCT_TRAN = round ((OK_TRAN / DY_TRAN)*100)
  endif   

  DY_TRAN2WY_RND   = round(VT_1/100)*100
  DY_TRAN2WY_100   = round(VT_1/100)
 
  if     (LI.1.ORIENT = 2)  
    if     (LI.1.FT = 29-39)  
      _VMTFWYT_NS = _VMTFWYT_NS + (DY_TRAN* LI.1.distance)/1.15  ;auto occ.
    elseif (LI.1.FT <> 1)
      _VMTARTT_NS = _VMTARTT_NS + (DY_TRAN* LI.1.distance)/1.15  ;auto occ.
    endif
  else
    if     (LI.1.FT = 29-39)  
      _VMTFWYT_EW = _VMTFWYT_EW + (DY_TRAN* LI.1.distance)/1.15  ;auto occ.
    elseif (LI.1.FT <> 1)
      _VMTARTT_EW = _VMTARTT_EW + (DY_TRAN* LI.1.distance)/1.15  ;auto occ.
    endif
  endif
       
  _VMTLCLT = _VMTLCLT + (DY_TRAN* LI.1.distance)/1.15  ;auto occ.

  PHASE=SUMMARY
    _VMTTOT_NS   = _VMTFWYT_NS + _VMTARTT_NS 
    _VMTTOT_EW   = _VMTFWYT_EW + _VMTARTT_EW 
    _VMTTOT      = _VMTTOT_NS  + _VMTTOT_EW 
    _VMTPCT_NS   = (_VMTTOT_NS / _VMTTOT)*100
    _VMTPCT_EW   = (_VMTTOT_EW / _VMTTOT)*100
  
    _VMTFWYT     = _VMTFWYT_NS + _VMTFWYT_EW
    _VMTARTT     = _VMTARTT_NS + _VMTARTT_EW
    _VMTPCT_FWY  = (_VMTFWYT / _VMTTOT)*100
    _VMTPCT_ART  = (_VMTARTT / _VMTTOT)*100

    
    print file=@ParentDir@@ADir@@Ao@@Ao_Transit@TransitVMTequivalent.txt, APPEND=F  form=12.0C list=
    '======= 4AssignHwy_ScreenlineTransit.s\n',
      _VMTTOT,    '         Pct',   '   ', 'Total Transit VMT equivalent\n',
      _VMTTOT_NS, _VMTPCT_NS,  '   ', ' - VMT on NS links \n',
      _VMTTOT_EW, _VMTPCT_EW,  '   ', ' - VMT on EW links \n\n',
      
      _VMTFWYT, _VMTPCT_FWY,    '   ', ' - VMT Fwy (FT=29-39)\n',
      _VMTARTT, _VMTPCT_ART,    '   ', ' - VMT Art (FT=2-5,9-11,22-24,42-44)\n',

    'Note:  \n',
    '  This was produced from the acompanying highway assignment. \n',
    '  The transit trip table was "assigned" by free flow times. Thus the link \n',
    '  volumes should represent the vehicle paths these trips would have taken in \n',
    '  the absence of transit.  Also, the "VMT" is the VMT that would have been produced. \n'
    ENDPHASE
ENDRUN


:end
*(del 4AssignHwy.txt)
*(del TPPL*)