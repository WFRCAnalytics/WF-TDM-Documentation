;****************************************************************************************
;
;                                     4HwySummary.s
;
;  Date Modified:
;  Update Notes:
;****************************************************************************************

;Purpose: 
;	1) Compare model estimated volume with observed volume.

;Steps:
;   1) Read in loaded network and export link dbf and node dbf.
;	2) Loop through highway records, sumarize observed / estimated volume by AADT_ID, calculate number of links, and identiy oneway, FT, & AT.
;	3) Loop through AADT_ID's, calculate RMSE, & print summary reports.
;	4) Add Observed volume and calibration statitics onto link dbf, and rebuild network.

;System
	;In case TP+ crashes during batch, this will halt process & help identify error.
	*(ECHO model crashed > 4HwySummarys.txt)
	
	;This is a dummy file used to calculate the time it takes to run script
	*(ECHO dummy file to calculate elapsed time > _timchk2.txt)
	  
	*(DEL *.PRN *.VAR)

;Parameters
	READ FILE = '..\..\0GeneralParameters.block'
	READ FILE = '..\..\1ControlCenter.block'

;Write out assigned network links & nodes to dbf & log number of network links
RUN PGM=NETWORK
	FILEI NETI  = @ParentDir@@ADir@@Ao@@unloadednetprefix@_4pd.@AssignType@.net
 
	FILEO LINKO = @ParentDir@@TempDir@@ATmp@@unloadednetprefix@_4pd.@AssignType@_link.dbf
	FILEO NODEO = @ParentDir@@ADir@@Ao@@Ao_HwySum@@unloadednetprefix@_4pd.@AssignType@_node.dbf
 
 	ZONES = @UsedZones@	
 
 	PHASE=LINKMERGE
  		_LinkCount = _LinkCount + 1
 	ENDPHASE
 
 	PHASE=SUMMARY
  		LOG VAR=_LinkCount	  ;log Link Count value to VAR file			
 	ENDPHASE
ENDRUN


;Loop through model volumes & observed counts and calc calibration statistics
RUN PGM=MATRIX
	FILEI DBI[1] = @ParentDir@@TempDir@@ATmp@@unloadednetprefix@_4pd.@AssignType@_link.dbf,
	               SORT=AADT_ID, AUTOARRAY=ALLFIELDS
    
	FILEO PRINTO[1] = @ParentDir@@ADir@@Ao@@AO_HwySum@COMPARE_MODEL_OBS_VOL_BYAADT_ID.CSV
	FILEO RECO[1]   = @ParentDir@@TempDir@@ATmp@ASGNNET_LINKS_OBSV.DBF,
  					FIELDS=A(8.0), B(8.0),DIFF(10.2), PCT_ERR(8.2)

  	Zones= 1				
 
 	;Define arrays
  	ARRAY AADT_IDArray = @NETWORK._LinkCount@,     
          NumLinks     = @NETWORK._LinkCount@,
          Vol_DY       = @NETWORK._LinkCount@,
          Avg_Vol_DY   = @NETWORK._LinkCount@,
          ObsVolArray  = @NETWORK._LinkCount@,
          AWDTFactor   = @NETWORK._LinkCount@,
          OBSAWDT      = @NETWORK._LinkCount@,
          VolDiff      = @NETWORK._LinkCount@,
          PctError     = @NETWORK._LinkCount@,
          FTArray	   = @NETWORK._LinkCount@,
          ATArray	   = @NETWORK._LinkCount@,
          OnewayArray  = @NETWORK._LinkCount@,
          CountyArray  = @NETWORK._LinkCount@,
          LinkA        = @NETWORK._LinkCount@,
          LinkB        = @NETWORK._LinkCount@,
          AADT_ID      = @NETWORK._LinkCount@
 
	;loop through highway records, sumarize vol by AADT_ID, calc number of links, and identiy oneway, FT, & AT
	LOOP numrec=1, dbi.1.NUMRECORDS   			
	
		;assign A & B node arrays (used to link data back to hwy network)
   		LinkA[numrec]  = dba.1.A[numrec]
   		LinkB[numrec]  = dba.1.B[numrec]
   		AADT_ID[numrec] = dba.1.AADT_ID[numrec]
   		InAADT_IDArray  = 0 	
  
		;assign values to arrays for links where AADT_ID>0
   		if (dba.1.AADT_ID[numrec]>0)   
       		;loop through AADT_ID array to see if AADT_ID already exists
  			LOOP CheckInArray=1, NumAADT_ID    			
   				if (dba.1.AADT_ID[numrec]=AADT_IDArray[CheckInArray])
    				InAADT_IDArray = 1	
    				BREAK
   				endif
  			ENDLOOP
   
  			;set array index
  			if (InAADT_IDArray=1)			
   				Index = CheckInArray					
   				NumLinks[Index]= NumLinks[Index] + 1	
  			else
   				NumAADT_ID = NumAADT_ID + 1					
   				Index = NumAADT_ID				
   				AADT_IDArray[Index] = dba.1.AADT_ID[numrec]
   				NumLinks[Index] = 1						 
  			endif
   
  			Vol_DY[Index]      = Vol_DY[Index] + dba.1.DY_Vol[numrec] 
     		if(ObsVolArray[Index]<dba.1.AADT07[numrec])
   				ObsVolArray[Index] = dba.1.AADT07[numrec]
     			ObsAWDT[Index]= dba.1.AWDT07[numrec]  
				AWDTFactor[Index]  = dba.1.AWDTFACTOR[numrec]
			endif
			
   			;Assign ONEWAY, FT & AT
   			OnewayArray[Index] = dba.1.ONEWAY[numrec]
   			FTArray[Index]     = dba.1.FT[numrec]
   			ATArray[Index]     = dba.1.AREATYPE[numrec]
   			CountyArray[Index] = dba.1.County[numrec]
 
 		endif
	ENDLOOP
 
	;loop through AADT_ID's, calculate RMSE, & print output files
	LOOP numrec=1, NumAADT_ID
  
 		;calc statistics
 		if (ObsAWDT[numrec]>0)
  			VolDiff[numrec]    = Vol_DY[numrec] - ObsAWDT[numrec]
  			PctError[numrec]   = VolDiff[numrec] / ObsAWDT[numrec]
 
 	 		SumDyVol    = SumDyVol + Vol_DY[numrec]
  			SumDiffSq   = SumDiffSq + VolDiff[numrec]^2
  			ObsVolCount = ObsVolCount + 1
 		endif 
 
  		;Print model vs. opbserved vol file header
  		if (PrintObsVolHeader=0)
   			PRINT CSV=T, FILE = @ParentDir@@ADir@@Ao@@AO_HwySum@COMPARE_MODEL_OBS_VOL_BY_AADT_ID.CSV,
    		LIST='Index', 'AADT_ID', 'NumLink','Oneway','FT','AT', 'County','ModelAWDT', 'ObsAWDT', 'Diff', 'PctErr'
   
   		;toggle check variable
   		PrintObsVolHeader=1			;This means the file header has been set.
  		endif
  		
  		;Print actually numbers
  		PRINT CSV=T, FILE = @ParentDir@@ADir@@Ao@@AO_HwySum@COMPARE_MODEL_OBS_VOL_BY_AADT_ID.CSV,
   		LIST=numrec, AADT_IDArray[numrec](10.3),NumLinks[numrec],
   			 OnewayArray[numrec], FTArray[numrec], ATArray[numrec], CountyArray[numrec],
             Vol_DY[numrec], ObsAWDT[numrec](10.0), 
        	 VolDiff[numrec](10.0), PctError[numrec](8.4)
 	ENDLOOP
 
 	;calc RMSE & Pct RMSE
 	All_AvgModelVol = SumDyVol / ObsVolCount
 	All_RMSE        = (SumDiffSq / ObsVolCount)^0.5
 	All_PctRMSE     = All_RMSE / All_AvgModelVol * 100
 

 	;print RMSE to Summary file
 	PRINT FILE = @ParentDir@@ADir@@Ao@@AO_HwySum@Summary.TXT,
 	LIST=
  	';*********************************************************************',
  	'\n',
  	'\nRegional Calibration Summary',
  	'\n',
  	'\nAll Facilities',
  	'\n  Avg Model Volume         ', All_AvgModelVol(10.0),
  	'\n  RMSE                     ', All_RMSE(10.0),
  	'\n  %RMSE                    ', All_PctRMSE(10.1),
  	'\n  Sum of Suared Diff       ', SumDiffSq(10.0),
  	'\n  Number of Observations   ', ObsVolCount(10.0),
  	'\n'
  	
	;loop through highway records & caluculate output recordes
	LOOP numrec=1, dbi.1.NUMRECORDS
	    ;initialize output variables
	    RO.A = LinkA[numrec]
	    RO.B = LinkB[numrec]
	    RO.DIFF       = 0
	    RO.PCT_ERR    = 0
	  
	    ;assign values for AADTID>0
	    if (dba.1.AADT_ID[numrec]>0)
	    ;loop through AADTID array to find index that mathces AADTID value from net
	    ;and assing remaining values
	    LOOP Index=1, NumAADT_ID
	      if (dba.1.AADT_ID[numrec]=AADT_IDArray[Index])
	      RO.DIFF       = VolDiff[Index]
	      RO.PCT_ERR    = PctError[Index]
	      BREAK
	      endif
	    ENDLOOP
	    endif
	  
	    ;write output dbf
	    WRITE RECO=1
	ENDLOOP
ENDRUN

;put obsv data on model links
RUN PGM=NETWORK
	FILEI NETI[1]  = @ParentDir@@ADir@@Ao@@unloadednetprefix@_4pd.@AssignType@.net
	FILEI LINKI[2] = @ParentDir@@TempDir@@ATmp@ASGNNET_LINKS_OBSV.DBF
	 
	FILEO NETO = @ParentDir@@ADir@@Ao@@AO_HwySum@@unloadednetprefix@_4pd.@AssignType@_WITHOBSV.NET
	FILEO LINKO = @ParentDir@@ADir@@Ao@@AO_HwySum@@unloadednetprefix@_4pd.@AssignType@_WITHOBSV_Link.DBF
	  
	ZONES = @UsedZones@
	MERGE RECORD=F
	
ENDRUN

;Calculate Elapsed Time (options: /s=seconds, /n=minutes, /h=hours)
	*(..\..\_ElapsedTime\ElapsedTime.exe   _timchk2.txt /s  >> ..\..\_Log\_ElapsedTimeReport.txt)
	*(ECHO Above is time to 4HwySummary.s >> ..\..\_Log\_ElapsedTimeReport.txt)
	*(ECHO --------------------------------- >> ..\..\_Log\_ElapsedTimeReport.txt)
	
	*(..\..\_ElapsedTime\ElapsedTime.exe   _timchk1.txt /n  >> ..\..\_Log\_ElapsedTimeReport.txt)
	*(ECHO Above is time to run FINAL ASSIGNMENT >> @ParentDir@_Log\_ElapsedTimeReport.txt)
	*(ECHO ================================================== >> ..\..\_Log\_ElapsedTimeReport.txt)
	
	*(ECHO . >> ..\..\_Log\_ElapsedTimeReport.txt)
	*(ECHO . >> ..\..\_Log\_ElapsedTimeReport.txt)
	*(ECHO ************************************************** >> ..\..\_Log\_ElapsedTimeReport.txt)
	*(..\..\_ElapsedTime\ElapsedTime.exe   _IP_chk.txt /n  >> ..\..\_Log\_ElapsedTimeReport.txt)
	*(ECHO Above is time to run WFRC-MAG MODEL in MINUTES>> @ParentDir@_Log\_ElapsedTimeReport.txt)
	*(ECHO . >> ..\..\_Log\_ElapsedTimeReport.txt)
	*(ECHO or >> ..\..\_Log\_ElapsedTimeReport.txt)
	*(..\..\_ElapsedTime\ElapsedTime.exe   _IP_chk.txt /h  >> ..\..\_Log\_ElapsedTimeReport.txt)
	*(ECHO Above is time to run WFRC-MAG MODEL in WHOLE HOURS>> @ParentDir@_Log\_ElapsedTimeReport.txt)
	*(ECHO . >> ..\..\_Log\_ElapsedTimeReport.txt)
	*(ECHO ************************************************** >> ..\..\_Log\_ElapsedTimeReport.txt)




;System cleanup
	*(DEL 4HwySummarys.txt)
