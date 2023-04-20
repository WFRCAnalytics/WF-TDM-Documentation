
/* this file computes AM peak highway times to the airport and CBD, as required by Urbansim */

*(DEL *.PRN)

READ FILE = '..\..\0GeneralParameters.block'
READ FILE = '..\..\1ControlCenter.block'

;*************************************

RUN PGM=HWYLOAD
ZONES=@Usedzones@

FILEI  NETI     = @ParentDir@@ADir@@Ao@@unloadednetprefix@_4pd.load.net
       ZDATI[1] = @ParentDir@@IDir@@Io@Urbanization.dbf


FILEO  MATO[1] = @ParentDir@@ATmp@skm_AMpeak.mtx, mo=1, name = time
 
ZONEMSG = @ZoneMsgRate@  ;reduces print messages in TPP DOS. (i.e. runs faster).

PHASE=LINKREAD
    LW.TPK = (LI.DISTANCE/LI.AM_SPD)*60 
ENDPHASE


PHASE=ILOOP
; Build "time" minimized paths

; Initialize time matrix
   mw[1]=0 

   PATHLOAD CONSOLIDATE=T, PATH=LW.TPK, INCLUDEJ=@Airport@,@ChurchOffice@,
       mw[1]=PATHCOST

JLOOP 

   IF (J==@Airport@ | J==@ChurchOffice@)
	;  add intrazonal times to interzonal travel time matrix (assume intrazonal speed is 20mph)
    	mw[1][i]=(0.5*((ZI.1.SQMILE[i])^0.5)*60)/20

	;  add origin and destination terminal times to all zones
   	mw[1] = mw[1]+ZI.1.TERMTIME[i]+ZI.1.TERMTIME[j]
   ELSE
	mw[1]=0
   ENDIF		

ENDJLOOP

ENDPHASE
ENDRUN


RUN PGM=MATRIX
  FILEI MATI[1]= @ParentDir@@ATmp@skm_AMpeak.mtx	
  	
  ZONEMSG = @ZoneMsgRate@  ;reduces print messages in TPP DOS. (i.e. runs faster).

IF (I == @dummyzones@ | I == @externalzones@)

ELSE

  JLOOP  J=@Airport@
    timepk  = MI.1.time

    PRINT  FILE= @ParentDir@@UDir@@Uo@@demographicyear@procHighwayTimes.tab  FORM= 4.0L LIST= 
      i,'\t',j(3.0L),'\t',timepk(6.2L)
  ENDJLOOP

  JLOOP  J=@ChurchOffice@
    timepk  = MI.1.time

    PRINT  FILE= @ParentDir@@UDir@@Uo@@demographicyear@procHighwayTimes.tab    FORM= 4.0L  LIST= 
      i,'\t',j(3.0L),'\t',timepk(6.2L)
  ENDJLOOP

ENDIF

ENDRUN