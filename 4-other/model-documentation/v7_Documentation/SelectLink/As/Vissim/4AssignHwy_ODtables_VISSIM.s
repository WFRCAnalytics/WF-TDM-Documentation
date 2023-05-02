*DEL *.PRN
READ FILE = ..\..\..\1ControlCenter.txt  ;all @...@ string replacements located here

/* by purp
;**************************************************************************
;Purpose:   Factor distributed person trips by time period, and convert
;           to vehicle trips
;**************************************************************************
RUN PGM=MATRIX
  
FILEI MATI[1] = @ParentDir@@ATmp@am3hr_ByPurp_Long.mtx
FILEI MATI[2] = @ParentDir@@ATmp@am3hr_ByPurp_Short.mtx
  
FILEI MATI[3] = @ParentDir@@ATmp@md6hr_ByPurp_Long.mtx
FILEI MATI[4] = @ParentDir@@ATmp@md6hr_ByPurp_Short.mtx
  
FILEI MATI[5] = @ParentDir@@ATmp@pm3hr_ByPurp_Long.mtx
FILEI MATI[6] = @ParentDir@@ATmp@pm3hr_ByPurp_Short.mtx
  
FILEI MATI[7] = @ParentDir@@ATmp@ev12hr_ByPurp_Long.mtx
FILEI MATI[8] = @ParentDir@@ATmp@ev12hr_ByPurp_Short.mtx


;FILEO MATO[1] = .\pm3hr_vehOD.mtx,  mo=1  name=PM3HR_TOT

FILEO MATO[1] = .\am3hr_vehOD.x100.@demographicyear@.TXT, PATTERN=IJ:MV, MO=1, MAXFIELDS=1000, DELIMITER=','
FILEO MATO[2] = .\md6hr_vehOD.x100.@demographicyear@.TXT, PATTERN=IJ:MV, MO=2, MAXFIELDS=1000, DELIMITER=','
FILEO MATO[3] = .\pm3hr_vehOD.x100.@demographicyear@.TXT, PATTERN=IJ:MV, MO=3, MAXFIELDS=1000, DELIMITER=','
FILEO MATO[4] = .\ev12hr_vehOD.x100.@demographicyear@.TXT, PATTERN=IJ:MV, MO=4, MAXFIELDS=1000, DELIMITER=','



ZONEMSG       = @ZoneMsgRate@                                ;reduces print messages in TPP DOS. (i.e. runs faster).
ZONES = @UsedZones@

mw[1] = mi.1.TOT +  mi.2.TOT
mw[2] = mi.3.TOT +  mi.4.TOT
mw[3] = mi.5.TOT +  mi.6.TOT
mw[4] = mi.7.TOT +  mi.8.TOT

ENDRUN

*/
;**************************************************************************
;Purpose:   Factor distributed person trips by time period, and convert
;           to vehicle trips
;**************************************************************************
RUN PGM=MATRIX
  
FILEI MATI[1] =  @ParentDir@@ATmp@am3hr_managed.mtx
FILEI MATI[2] =  @ParentDir@@ATmp@md6hr_managed.mtx
FILEI MATI[3] =  @ParentDir@@ATmp@pm3hr_managed.mtx
FILEI MATI[4] =  @ParentDir@@ATmp@ev12hr_managed.mtx

FILEO MATO[1] = .\am3hr_vehOD.x100.managed.@demographicyear@.TXT, PATTERN=IJ:MV, MO=1, MAXFIELDS=1000, DELIMITER=','
FILEO MATO[2] = .\md6hr_vehOD.x100.managed.@demographicyear@.TXT, PATTERN=IJ:MV, MO=2, MAXFIELDS=1000, DELIMITER=','
FILEO MATO[3] = .\pm3hr_vehOD.x100.managed.@demographicyear@.TXT, PATTERN=IJ:MV, MO=3, MAXFIELDS=1000, DELIMITER=','
FILEO MATO[4] = .\ev12hr_vehOD.x100.managed.@demographicyear@.TXT, PATTERN=IJ:MV, MO=4, MAXFIELDS=1000, DELIMITER=','

;FILEO MATO[6] = .\pm3hr_vehOD.mtx,  mo=3  name=PM3HR_TOT


ZONEMSG       = @ZoneMsgRate@                                ;reduces print messages in TPP DOS. (i.e. runs faster).
ZONES = @UsedZones@

mw[1] = mi.1.TOT

mw[2] = mi.2.TOT
        
mw[3] = mi.3.TOT
        
mw[4] = mi.4.TOT
        
ENDRUN
