*(echo 4AssignHwy_ScreenlineAdjuster.s > 4AssignHwy_ScreenlineAdjuster.txt)  ;In case TP+ crashes during batch, this will halt process & help identify error location.

READ FILE = '..\..\0GeneralParameters.block'
READ FILE = '..\..\1ControlCenter.block'


;Summarize screenline crossings for AM, PM, and DY_VOL
Observed1WyVol    = 'AWDT01SF1W'   ; The field that contains observed volumes (Traffic On Utah Highways Counts, separated by direction)
BaseYearModelVol  = 'DY_VOL'       ;'DY_VOL' field from the base year assigned network.
FutrYearModelVol  = 'DY_VOL'       ;'DY_VOL' field from the forecast year.
ScrnLineField     = 'ScrnMed'      ; Medium Screenline Field


*(DEL *.prn, *.var)
Asize = 30000
BaseYearNet = 'V42_2001_4PD.LOAD.NET'

goto :step1

:step1

RUN PGM = HWYNET
  NETI[1]=@ParentDir@@ADir@Ao\@unloadednetprefix@_4pd.@AssignType@.MNGremoved.net
  NETO   =@ParentDir@@TempDir@@ATmp@screenadj_working.net
  PHASE=SUMMARY
     LOOP _iter=1,13000
       PRINT FORM=12.0 FILE=@ParentDir@@TempDir@@ATmp@tmpnodes.txt  APPEND=F  LIST=_iter, 404250, 4521000
     ENDLOOP
  ENDPHASE
ENDRUN

;*********************************************************************************
;Task 0:  Set file headers.
;*********************************************************************************
RUN PGM = HWYNET
  NETI[1]  = @ParentDir@@ADir@Ao\@unloadednetprefix@_4pd.@AssignType@.MNGremoved.net
  NODEI[2] = @ParentDir@@TempDir@@ATmp@tmpnodes.txt, VAR= N, X, Y
  NETO     = @ParentDir@@TempDir@@ATmp@screenadj_working.net
  MERGE RECORD=T  ;Make sure any new links in one or the other are added to the compare net
  
  PHASE = NODEMERGE
    if (NI.1.X > 0)
      X = NI.1.X
      Y = NI.1.Y
    else
      X = NI.2.X
      Y = NI.2.Y
    endif
  ENDPHASE
   

  PHASE=SUMMARY

      PRINT FORM=12.0 FILE=@ParentDir@@TempDir@@ATmp@scrn_Tmp_AllLinks.txt  APPEND=F  LIST=
        '/*   N           A           B        SCRN       FLG     VOL_OBS     VOL_BAS     VOL_FUT     CAP_BAS     CAP_FUT     CAP_NEW  */'

      PRINT FORM=12.0 FILE=@ParentDir@@TempDir@@ATmp@scrn_Tmp_ScrnSum.txt  APPEND=F  LIST=
        '/*   N     VOL_OBS     VOL_BAS     VOL_FUT     CAP_BAS     CAP_FUT     CAP_NEW */'

      PRINT FORM=12.0 FILE=@ParentDir@@TempDir@@ATmp@scrn_Tmp_ScrnSum2.txt  APPEND=F  LIST=
        '/*   N     MSTOT */'
        
      PRINT FORM=12.0 FILE=@ParentDir@@TempDir@@ATmp@scrn_Tmp_AllLinksP.txt  APPEND=F  LIST=
        '/*   N           A           B        SCRN       FLG    ',
        'VOL_OBS    VOL_OBST    VOL_OBSP     ',
        'VOL_BAS    VOL_BAST    VOL_BASP     ',
        'VOL_FUT    VOL_FUTT    VOL_FUTP     ',
        'MODPDIF    REDISTPF    REDISTVF     ',
        'CAP_BAS    CAP_BAST    CAP_BASP     ',
        'CAP_FUT    CAP_FUTT    CAP_FUTP     ',
        'CAP_NEW    CAP_NEWT    CAP_NEWP   */  '
         
      PRINT FORM=12.0 FILE=@ParentDir@@TempDir@@ATmp@scrn_Tmp_AllLinksP2.txt  APPEND=F  LIST=
        '/*   N           A           B        SCRN       FLG    ',
        'VOL_OBS    VOL_OBST    VOL_OBSP     ',
        'VOL_BAS    VOL_BAST    VOL_BASP     ',
        'VOL_FUT    VOL_FUTT    VOL_FUTP     ',
        'MODPDIF    REDISTPF    REDISTVF     ',
        'CAP_BAS    CAP_BAST    CAP_BASP     ',
        'CAP_FUT    CAP_FUTT    CAP_FUTP     ',
        'CAP_NEW    CAP_NEWT    CAP_NEWP   */  '
               
      PRINT FORM=12.0 FILE=@ParentDir@@TempDir@@ATmp@scrn_1PotentialMissingData.txt  APPEND=F  LIST=
        ';Note:  There are often base year links in a screenline that do not have an observed \n',
        ';count.  This is usually because the link is a collector that we include in the base model \n',
        ';but UDOT does not have an HPMS count for it.  This script does not adjust cases where \n',
        ';the observed volume is zero. \n\n',
        ';This file identifies links that had a zero count, but the model allocated a substantial\n',
        ';volume to it - suggesting that it may not be a collector, and may be a road that truly\n',
        ';does have a count available somewhere.  Please double check the links below and see if \n',
        ';you can find a count.  Then fill in the count in the Master network for the next time.\n\n',
        '/*   N   ROW           A           B        SCRN     VOL_OBS     VOL_BAS  */'  
                    
   ENDPHASE
ENDRUN

;*********************************************************************************
;Task 1:  Parse all links in both base and scenario nets.  Write key fields to
;         with screenline ID.  Obtain screenline totals and write them too.
;*********************************************************************************
:step2
RUN PGM = HWYNET
  NETI[1]  = @ParentDir@@TempDir@@ATmp@screenadj_working.net
  NETI[2]  = @ParentDir@@ADir@As\@BaseYearNet@  
  
  ARRAY Vo=@Asize@ 
  ARRAY Vb=@Asize@ 
  ARRAY Vf=@Asize@ 
  ARRAY Cb=@Asize@ 
  ARRAY Cf=@Asize@ 
  ARRAY Cn=@Asize@ 
  ARRAY VALID=@Asize@

  ARRAY VbTot=@Asize@  ;need these as dummies so block1 won't crash
  ARRAY VfTot=@Asize@ 


  PHASE = LINKMERGE
    
    _blockflag = 0
    READ FILE     = @ParentDir@@ADir@@As@block\4AssignHwy_ScreenlineAdjuster1.block

            
      ;If observed is 0 (due to no count), but base model has volume, then the Redistp can go negative (not good)
      ;Simple Solution: If there is no count, assume that the base model is correct, and replace the observed
      ;volume (zero) with the modeled vol.  Then record in the database that this occurred, and write out
      ;any high-modelled volume links (>5000) as roads that may actually have a count available.

      if (_Fg = 1 && _Vb > 5000)
        _bad = _bad + 1
        PRINT FORM=12.0 FILE=@ParentDir@@TempDir@@ATmp@scrn_1PotentialMissingData.txt  APPEND=T  LIST=
        _bad(6), _n(6), _a, _b, _index, _Vo, _Vb      
        
        if (_bad % 40 = 39)
          PRINT FORM=12.0 FILE=@ParentDir@@TempDir@@ATmp@scrn_1PotentialMissingData.txt  APPEND=T  LIST=
          '\n\n',
          '/*   N   ROW           A           B        SCRN     VOL_OBS     VOL_BAS  */'  
        endif
      endif      
      

      
      Vo[_index] = Vo[_index] + _Vo
      Vb[_index] = Vb[_index] + _Vb
      Vf[_index] = Vf[_index] + _Vf
      Cb[_index] = Cb[_index] + _Cb   
      Cf[_index] = Cf[_index] + _Cf   
      Cn[_index] = Cn[_index] + _Cn  
       
       PRINT FORM=12.0 FILE=@ParentDir@@TempDir@@ATmp@scrn_Tmp_AllLinks.txt  APPEND=T  LIST=
        _n(6), _a, _b, _index,  _Fg, _Vo, _Vb, _Vf, _Cb, _Cf, _Cn
    endif
  ENDPHASE
  
   PHASE=SUMMARY
     LOOP _iter=1,@Asize@
       if (Vb[_iter] = 0)
         VoVbR = 0
       else
         VoVbR = Vo[_iter] / Vb[_iter]
       endif
       VoVbD = Vo[_iter] - Vb[_iter]

       if (VALID[_iter] <> 0)
         PRINT FORM=12.0 FILE=@ParentDir@@TempDir@@ATmp@scrn_Tmp_ScrnSum.txt  APPEND=T  LIST=
         _iter(6), Vo[_iter], Vb[_iter], VoVbR(12.4), VoVbD(12.1), Vf[_iter], Cb[_iter], Cf[_iter], Cn[_iter]  
       endif
     ENDLOOP
   ENDPHASE
ENDRUN

;*********************************************************************************
;Task 1b:  Convert txt to dbf for easier processing.
;*********************************************************************************
:step3
RUN PGM=HWYNET 

FILEI NODEI = @ParentDir@@TempDir@@ATmp@scrn_Tmp_AllLinks.txt, VAR= N, A, B, SCRN, FLG, VOL_OBS, VOL_BAS, VOL_FUT, CAP_BAS, CAP_FUT, CAP_NEW
FILEO NODEO = @ParentDir@@TempDir@@ATmp@scrn_Tmp_AllLinks.dbf, FORMAT=DBF
ZONES = 1438
ENDRUN

:step4
RUN PGM=HWYNET
FILEI NODEI = @ParentDir@@TempDir@@ATmp@scrn_Tmp_ScrnSum.txt, VAR= N, VOL_OBS, VOL_BAS, VOVB_R, VOVB_D, VOL_FUT, CAP_BAS, CAP_FUT, CAP_NEW
FILEO NODEO = @ParentDir@@TempDir@@ATmp@scrn_Tmp_ScrnSum.dbf, FORMAT=DBF
ZONES = 1438
ENDRUN


;*********************************************************************************
;Task 2:  Add percentage share of screenline totals to link data by parse links again
;         and dividing by the totals obtained earlier.
;*********************************************************************************
:step5
RUN PGM = HWYNET
  NETI[1] =@ParentDir@@TempDir@@ATmp@screenadj_working.net
  NETI[2] =@ParentDir@@ADir@As\@BaseYearNet@  
  NODEI[3]=@ParentDir@@TempDir@@ATmp@scrn_Tmp_ScrnSum.dbf
  
 ; NETO = Adjusted.net, INCLUDE = DISTANCE, STREET_N, LANESb, LANESf, FTb, FTf,
 ;                                COUNTY, SFF, CAP1HR1LN, SEG_ID, Orient, @ScrnLineField@, AWDT01SF1W, DY_VOLb,
 ;                                DY_VOLf, VoP, MPdiff, Redistp, RedistV, RedistVA, VoT, VbT, VfT, VfTA

  ARRAY MSTot=@Asize@ 
  
  ARRAY VoTot=@Asize@ 
  ARRAY VbTot=@Asize@ 
  ARRAY VoVbD=@Asize@ 
  ARRAY VbTotD=@Asize@ 
  ARRAY VfTot=@Asize@ 
  ARRAY VfTotD=@Asize@ 
  ARRAY CbTot=@Asize@ 
  ARRAY CfTot=@Asize@ 
  ARRAY CnTot=@Asize@ 
  ARRAY VALID=@Asize@

  PHASE = NODEMERGE  ;These are not "Nodes", but screenline totals where the screenline mascarades as a node.


    VoTot[NI.3.N]  = NI.3.VOL_OBS
    VbTot[NI.3.N]  = NI.3.VOL_BAS
    VoVbD[NI.3.N]  = NI.3.VOVB_D
    VbTotD[NI.3.N] = NI.3.VOL_BAS + NI.3.VOVB_D
    VfTot[NI.3.N]  = NI.3.VOL_FUT
    VfTotD[NI.3.N] = NI.3.VOL_FUT + NI.3.VOVB_D
    CbTot[NI.3.N]  = NI.3.CAP_BAS
    CfTot[NI.3.N]  = NI.3.CAP_FUT
    CnTot[NI.3.N]  = NI.3.CAP_NEW

  ENDPHASE

  PHASE = LINKMERGE
   ;if ((LI.1.@ScrnLineField@ <> 0 ) || (LI.2.@ScrnLineField@ <> 0 ))  
 ;   LANESb = li.1.LANES
 ;   LANESf = li.2.LANES
 ;   FTb    = li.1.FT
 ;   FTf    = li.2.FT
 
    _blockflag = 1
    READ FILE     = @ParentDir@@ADir@@As@block\4AssignHwy_ScreenlineAdjuster1.block
    READ FILE     = @ParentDir@@ADir@@As@block\4AssignHwy_ScreenlineAdjuster2.block

      MSTot[_index] = MSTot[_index] + _ModScrn

       PRINT FORM=12.0 FILE=@ParentDir@@TempDir@@ATmp@scrn_Tmp_AllLinksP.txt  APPEND=T  LIST=
        _n(6), _a, _b, _index, _Fg, 
        _Vo, VoTot[_index], _Vop(12.2), 
        _Vb, VbTot[_index], _Vbp(12.2), 
        _VbD, VbTotD[_index],
        _Vf, VfTot[_index], _Vfp(12.2), 
        _VfD, VfTotD[_index],
        _VfVbR(12.2), _VfTVbTR(12.2), _ModScrn(12.2),
        Mpdiff(12.2), 
        _Cb, CbTot[_index], _Cbp(12.2),
        _Cf, CfTot[_index], _Cfp(12.2),
        _Cn, CnTot[_index], _Cnp(12.2),
        _Cna
        
     
    endif
  ENDPHASE

   PHASE=SUMMARY
     LOOP _iter=1,@Asize@

       if (VALID[_iter] <> 0)
         PRINT FORM=12.0 FILE=@ParentDir@@TempDir@@ATmp@scrn_Tmp_ScrnSum2.txt  APPEND=T  LIST=
         _iter(6), MSTot[_iter](12.2)
       endif
     ENDLOOP
   ENDPHASE



ENDRUN

;*********************************************************************************
;Task 1b:  Convert txt to dbf for easier processing.
;*********************************************************************************
:step6
RUN PGM=HWYNET
FILEI NODEI = @ParentDir@@TempDir@@ATmp@scrn_Tmp_AllLinksP.txt, VAR= N, A, B, SCRN, FLG,
              V_OBS, V_OBST, V_OBSP,
              V_BAS, V_BAST, V_BASP,
              V_BASD, V_BASDT,
              V_FUT,  V_FUTT, V_FUTP,
              V_FUTD, V_FUTDT,
              VFVBR, VFTVBTR, MODSCRN, MODSCRNT,
              MODPDIF,  
              C_BAS, C_BAST, C_BASP,
              C_FUT, C_FUTT, C_FUTP,          
              C_NEW, C_NEWT, C_NEWP     
              
FILEO NODEO = @ParentDir@@TempDir@@ATmp@scrn_Tmp_AllLinksP.dbf, FORMAT=DBF
ZONES = 1438
ENDRUN

:step7
RUN PGM=HWYNET
FILEI NODEI = @ParentDir@@TempDir@@ATmp@scrn_Tmp_ScrnSum2.txt, VAR= N, MSTot
FILEO NODEO = @ParentDir@@TempDir@@ATmp@scrn_Tmp_ScrnSum2.dbf, FORMAT=DBF
ZONES = 1438
ENDRUN


;*********************************************************************************
;Task 2:  Add percentage share of screenline totals to link data by parse links again
;         and dividing by the totals obtained earlier.
;*********************************************************************************
:step8
RUN PGM = HWYNET
  NETI[1] =@ParentDir@@TempDir@@ATmp@screenadj_working.net
  NETI[2] =@ParentDir@@ADir@As\@BaseYearNet@  
  NODEI[3]=@ParentDir@@TempDir@@ATmp@scrn_Tmp_ScrnSum.dbf
  NODEI[4]=@ParentDir@@TempDir@@ATmp@scrn_Tmp_ScrnSum2.dbf
  
  NETO = @ParentDir@@TempDir@@ATmp@@unloadednetprefix@_4pd.@AssignType@.screenadj.net, INCLUDE = DISTANCE, STREET_N, LANESb, LANESf, FTb, FTf,
                                 COUNTY, SFF, CAP1HR1LN, SEG_ID, Orient, @ScrnLineField@, FLAG_SCRN, DY_OBS, DY_BAS,
                                 DY_FUT, DY_FIN, VC_FIN, VFVBR, MODSCRNSCL, VoT_1000, VbT_1000, VfT_1000
  MERGE RECORD=F  ;Make sure any new links in one or the other are added to the compare net
 
  ARRAY VoTot=@Asize@ 
  ARRAY VbTot=@Asize@ 
  ARRAY VoVbD=@Asize@ 
  ARRAY VbTotD=@Asize@ 
  ARRAY VfTot=@Asize@ 
  ARRAY VfTotD=@Asize@ 
  ARRAY CbTot=@Asize@ 
  ARRAY CfTot=@Asize@ 
  ARRAY CnTot=@Asize@ 
  ARRAY VALID=@Asize@
  
  ARRAY ModScrnT=@Asize@ 

  PHASE = NODEMERGE  ;These are not "Nodes", but screenline totals where the screenline mascarades as a node.


    VoTot[NI.3.N]  = NI.3.VOL_OBS
    VbTot[NI.3.N]  = NI.3.VOL_BAS
    VoVbD[NI.3.N]  = NI.3.VOVB_D
    VbTotD[NI.3.N] = NI.3.VOL_BAS + NI.3.VOVB_D
    VfTot[NI.3.N]  = NI.3.VOL_FUT
    VfTotD[NI.3.N] = NI.3.VOL_FUT + NI.3.VOVB_D
    CbTot[NI.3.N]  = NI.3.CAP_BAS
    CfTot[NI.3.N]  = NI.3.CAP_FUT
    CnTot[NI.3.N]  = NI.3.CAP_NEW
    
    ModScrnT[NI.4.N]  = NI.4.MSTot
    
  ;  PRINT FORM=12.0 FILE=miketmp2.txt  APPEND=F  LIST= NI.3.N, VbTot[NI.3.N]

  ENDPHASE

  PHASE = LINKMERGE
   ;if ((LI.1.@ScrnLineField@ <> 0 ) || (LI.2.@ScrnLineField@ <> 0 ))  
   
    _blockflag = 1
    READ FILE     = @ParentDir@@ADir@@As@block\4AssignHwy_ScreenlineAdjuster1.block
    READ FILE     = @ParentDir@@ADir@@As@block\4AssignHwy_ScreenlineAdjuster2.block
 
     
      if (ModScrnT[_index] = 0)
        _ModScrnScale  = 0
      else
        _ModScrnScale = _ModScrn / ModScrnT[_index]
      endif
      
      if (VfTotD[_index] > VoTot[_index])
        Vfin = _Vo + (VfTotD[_index] - VoTot[_index]) * _ModScrnScale
      else
        Vfin = _Vo
      endif
      
    endif  ;end block1 if
    
    Vfin2 = _Vo + (_Vf - _Vb)  ;orig + model change
    if ((_Vf - _Vb) < -500)  ;if future is reduced over base
      Vfin2 = _Vo + (_Vf - _Vb)*.3  ;don't reduce as much or you'll get negatives.
    endif
    
    Vfin3 = _Vo * _VfVbR  ;orig * link growth rate.
    if (_fg = 2)      Vfin3 = Vfin2
      
    if (_Vf < 5000 ) ;then weight more toward absolute diff
      _wt2 = .75
    elseif (_Vf >= 5000 && _Vf < 25000)  ;average between absolute diff and ratios
      _wt2 = .50
    else
      _wt2 = .25  ;weight more toward ratios
    endif
    Vfin4   = (Vfin2 * _wt2) + (Vfin3 * (1-_wt2))  ;Share of one method plus appropriate share of other method
    _VC_FIN  = (Vfin4*.1) / _Cf  ;assume 10% of DY is PM peak hour typically
     VC_FIN  = round(_VC_FIN*100)/100
    FLAG_SCRN = _fg

    if ((LI.1.@ScrnLineField@ <> 0 & LI.1.FT<>1) || (LI.2.@ScrnLineField@ <> 0 & LI.2.FT<>1)); Excluding the Centroid Connectors (FT=1)  

       PRINT FORM=12.0 FILE=@ParentDir@@TempDir@@ATmp@scrn_Tmp_AllLinksP2.txt  APPEND=T  LIST=
        _n(6), _a, _b, _index, _Fg, 
        _Vo, VoTot[_index], _Vop(12.2), 
        _Vb, VbTot[_index], _Vbp(12.2), 
        _VbD, VbTotD[_index],
        _Vf, VfTot[_index], _Vfp(12.2), 
        _VfD, VfTotD[_index],
        _VfVbR(12.2), _VfTVbTR(12.2), _ModScrn(12.2), _ModScrnScale(12.2), _wt2(12.2),Vfin,Vfin2,Vfin3,Vfin4,VC_FIN(12.2),
        Mpdiff(12.2), 
        _Cb, CbTot[_index], _Cbp(12.2),
        _Cf, CfTot[_index], _Cfp(12.2),
        _Cn, CnTot[_index], _Cnp(12.2),
        _Cna
        
      ;******* Stuff for output network

      DY_OBS  = li.2.AWDT01SF1W
      DY_BAS  = li.2.DY_VOL
      DY_FUT  = li.1.DY_VOL      
      DY_FIN  = round(Vfin4)    
      VFVBR   = _VfVbR
      MODSCRNSCL=_ModScrnScale
    endif
    LANESb = li.2.LANES  ;outside if so that all links get labeled
    LANESf = li.1.LANES
    FTb    = li.2.FT
    FTf    = li.1.FT   
    
  ENDPHASE
ENDRUN


;*********************************************************************************
;Task 1b:  Convert txt to dbf for easier processing.
;*********************************************************************************
:step9
RUN PGM=HWYNET
FILEI NODEI = @ParentDir@@TempDir@@ATmp@scrn_Tmp_AllLinksP2.txt, VAR= N, A, B, SCRN, FLG,
              V_OBS, V_OBST, V_OBSP,
              V_BAS, V_BAST, V_BASP,
              V_BASD, V_BASDT,
              V_FUT,  V_FUTT, V_FUTP,
              V_FUTD, V_FUTDT,
              VFVBR, VFTVBTR, MODSCRN, MODSCRNSCL, WT2,VFIN,VFIN2,VFIN3,VFIN4,VCFIN4,
              MODPDIF, 
              C_BAS, C_BAST, C_BASP,
              C_FUT, C_FUTT, C_FUTP,          
              C_NEW, C_NEWT, C_NEWP     
              
FILEO NODEO = @ParentDir@@ADir@@Ao@@Ao_Observed@@unloadednetprefix@_4pd_ScreenadjLinks.dbf, FORMAT=DBF
ZONES = 1438
ENDRUN

:step10
RUN PGM = HWYNET
  NETI[1] =@ParentDir@@TempDir@@ATmp@@unloadednetprefix@_4pd.@AssignType@.screenadj.net
  NETI[2] =@ParentDir@@TempDir@@ATmp@@unloadednetprefix@_4pd.@AssignType@.screenadj.net

  NETO = @ParentDir@@ADir@@Ao@@Ao_Observed@@unloadednetprefix@_4pd.@AssignType@.screenadj.net
  MERGE RECORD=F  ;Make sure any new links in one or the other are added to the compare net

  
  PHASE=INPUT, FILEI=li.2  ;UAG website FAQ says this is how you set ONEWAY.
    _temp=a
    a=b
    b=_temp
  ENDPHASE
  
  PHASE=LINKMERGE
    DY_OBS2 = LI.1.DY_OBS  + LI.2.DY_OBS
    DY_BAS2 = LI.1.DY_BAS  + LI.2.DY_BAS
    DY_FUT2 = LI.1.DY_FUT  + LI.2.DY_FUT
    DY_FIN2 = LI.1.DY_FIN  + LI.2.DY_FIN
    
    DY_OBS2_1K = round(DY_OBS2/1000)	
    DY_BAS2_1K = round(DY_BAS2/1000)	
    DY_FUT2_1K = round(DY_FUT2/1000)	
    DY_FIN2_1K = round(DY_FIN2/1000)	

  ENDPHASE

ENDRUN

:end
*(copy *.prn .\out\4AssignHwy_ScreenlineAdjuster.out)
*(del 4AssignHwy_ScreenlineAdjuster.txt)
*(del TPPL*)