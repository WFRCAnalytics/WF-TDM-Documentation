# type: ignore
# flake8: noqa
#
#
#
#
#
#
#
#
#
#
#
#
#
#
debug = False

import pandas as pd
import os
import numpy as np
from scipy import special
import time
import math as ms

filenameTLFObs  = 'data/3-distribute/dfTLF_Obs_wSmoothed_20221209-075253.csv'
observedStage = 'v9 Final Smoothing'

folderTDMTLFLoc = 'data/3-distribute'

binsize = 2

# remove these, since they are not really observed curves
removeObservedPurp = ['MD','HV','IX_HV','IX_MD','XI_HV','XI_MD']
removeModelPurp = ['IXXI']

# a set of column renaming to be used to put all columns in consistent naming
colRenames ={'HBOTH':'HBOth',
             'HBSHP':'HBShp',
             'HBSCHPR' :'HBSchPr',
             'HBSCHSC' :'HBSchSc',
             'HBSCH_PR':'HBSchPr',
             'HBSCH_SC':'HBSchSc',
             'HBSch_Pr':'HBSchPr',
             'HBSch_Sc':'HBSchSc'}

# some trip purposes are added together for information purposes
dfTripPurpSubtotals = pd.DataFrame([
    ['HBOth','HBO' ],
    ['HBShp','HBO' ],
    ['NHBW' ,'NHB' ],
    ['NHBNW','NHB' ],
    ['IX'   ,'IXXI'],
    ['XI'   ,'IXXI']
],columns=(['TRIPPURP','TRIPPURP_SUB']))
if debug: display(dfTripPurpSubtotals)
#
#
#
# read in observed TLF data to be used
dfTLF_Obs = pd.read_csv(filenameTLFObs)

#filter by the STAGE for 
dfTLF_Obs = dfTLF_Obs[dfTLF_Obs['STAGE']==observedStage].copy()
dfTLF_Obs = dfTLF_Obs.drop(columns=('STAGE'))

# remove unreport purposes
dfTLF_Obs = dfTLF_Obs[~dfTLF_Obs['TRIPPURP'].isin(removeObservedPurp)]

dfTLF_Obs.rename(columns={'FREQ':'freqObs'}, inplace=True)

if debug: display(dfTLF_Obs)
#
#
#
#
# show max bin size for TLF type to use in updating TDM TLF code
if debug: display(dfTLF_Obs[dfTLF_Obs['freqObs']>0].groupby(['TLFTYPE'],as_index=False).agg(MAXBIN=('BIN','max')))
#
#
#
#
# Check TLF Observed. freqObs should all sum to 1! Also show average trip length
# add one to BIN to get bin midpoint
dfTLF_Obs['BINMIDxfreqObs'] = (dfTLF_Obs['BIN'] + 1) * dfTLF_Obs['freqObs']
dfTLF_Obs_Stats = dfTLF_Obs.groupby(['TRIPPURP','TLFTYPE'],as_index=False).agg(freqObs_SUM=('freqObs','sum'),AVG_TRIP_LEN=('BINMIDxfreqObs','sum'))
dfTLF_Obs.drop(columns=('BINMIDxfreqObs'), inplace=True)
if debug: display(dfTLF_Obs_Stats)
#
#
#

tlfs=['Cost','Dist','Time']

dfTLFTDMTrips = pd.DataFrame()

for tlf in tlfs:
    
    # read in csv for tlf
    dfRead = pd.read_csv(folderTDMTLFLoc + '/TLF_' + tlf + '.csv')

    # make sure id column is always same: BIN
    dfRead.rename(columns={';BIN':'BIN',';MINUTE':'BIN','Mile':'BIN','Mil':'BIN','Min':'BIN','Bin':'BIN'}, inplace=True)
    # rename columns
    dfRead.rename(columns=colRenames,inplace=True)

    dfRead = pd.melt(dfRead, id_vars=['BIN'], value_vars=dfRead.columns[1:].tolist(), ignore_index=False, var_name='TRIPPURP', value_name='TRIPS')

    # set TLF value, rename Cost to GC
    if tlf=='Cost':
        dfRead['TLFTYPE'] = 'GC'
    else:
        dfRead['TLFTYPE'] = tlf

    # reorder columns
    dfRead = dfRead[['TLFTYPE','TRIPPURP','BIN','TRIPS']]

    # concat data into single dataframe
    dfTLFTDMTrips = pd.concat([dfTLFTDMTrips, dfRead], ignore_index=True)

if debug: display(dfTLFTDMTrips)

# create subtotals
dfTLFTDMTripsForSubtotals = pd.DataFrame.merge(dfTLFTDMTrips, dfTripPurpSubtotals, on=('TRIPPURP'))
dfTLFTDMTripsForSubtotals = dfTLFTDMTripsForSubtotals.groupby(['TLFTYPE','TRIPPURP_SUB','BIN'],as_index=False).agg(TRIPS=('TRIPS','sum'),COUNT=('TRIPS','size'))
dfTLFTDMTripsForSubtotals = dfTLFTDMTripsForSubtotals[['TLFTYPE','TRIPPURP_SUB','BIN','TRIPS']]
dfTLFTDMTripsForSubtotals = dfTLFTDMTripsForSubtotals.rename(columns={'TRIPPURP_SUB':'TRIPPURP'})
if debug: display (dfTLFTDMTripsForSubtotals)

# concat subtotals
dfTLFTDMTrips = pd.concat([dfTLFTDMTrips,dfTLFTDMTripsForSubtotals], ignore_index=True)
if debug: display(dfTLFTDMTrips)

# calculated collapsed bins
from math import floor
def round_to_binsize(x):
    return int(binsize * floor(float(x)/binsize))
dfTLFTDMTrips['BIN_COLLAPSE'] = dfTLFTDMTrips['BIN'].apply(lambda x: round_to_binsize(x))
if debug: display(dfTLFTDMTrips)

# aggregate to collapsed bins
dfTLFTDMTrips = dfTLFTDMTrips.groupby(['TLFTYPE','TRIPPURP','BIN_COLLAPSE'], as_index=False).agg(TRIPS=('TRIPS','sum'))
dfTLFTDMTrips = dfTLFTDMTrips.rename(columns={'BIN_COLLAPSE':'BIN'})
if debug: display(dfTLFTDMTrips)

# calculate percent distribution
dfTLFTDMTripTotals = dfTLFTDMTrips.groupby(['TLFTYPE','TRIPPURP'], as_index=False).agg(TRIP_TOTAL=('TRIPS','sum'))
if debug: display(dfTLFTDMTripTotals)

# join to toals
dfTLFTDMTripDist = pd.DataFrame.merge(dfTLFTDMTrips, dfTLFTDMTripTotals, on=('TLFTYPE','TRIPPURP'))
dfTLFTDMTripDist['freqMod'] = dfTLFTDMTripDist['TRIPS'] / dfTLFTDMTripDist['TRIP_TOTAL']
if debug: display(dfTLFTDMTripDist)

dfTLF_TDM = dfTLFTDMTripDist[['TLFTYPE','TRIPPURP','BIN','freqMod']]
if debug: display(dfTLF_TDM)

# check to see if add up to 1.0
dfCheck = dfTLF_TDM.groupby(['TLFTYPE','TRIPPURP'], as_index=False).agg(freqMod_SUM=('freqMod','sum'))
# only display results out of range
if debug: display('Not adding to 1 (if empty dataset, YAY!!!):')
if debug: display(dfCheck[(dfCheck['freqMod_SUM']<0.9999999) | (dfCheck['freqMod_SUM']>1.0000001)])

#dfTLF_TDM.to_csv(filename, index=False)

#
#
#
#Merge together all Modeled data and Observed data
dfObsModelMerge = pd.DataFrame.merge(dfTLF_Obs, dfTLF_TDM, on=('BIN','TRIPPURP','TLFTYPE'),how='outer')
dfObsModelMerge.fillna(0, inplace=True)

dfObsModelMerge = dfObsModelMerge.melt(id_vars=('TRIPPURP','TLFTYPE','BIN'), value_vars=('freqObs','freqMod'), var_name='freqSource', value_name='freq')

dfObsModelMerge = dfObsModelMerge[~dfObsModelMerge['TRIPPURP'].isin(removeModelPurp)]

if debug: display(dfObsModelMerge)
#
#
#
#
#
#
#
#
#
#CALCUATE TRIP LENGTH AVERAGES AS TABLE
gcdtime = dfObsModelMerge.rename(columns={'freqSource':'DataSource','TRIPPURP':'Purpose','freq':'FREQ','TLFTYPE':'Variable'})
gcdtime.loc[gcdtime['DataSource']=='freqMod', 'DataSource'] = 'Model'
gcdtime.loc[gcdtime['DataSource']=='freqObs', 'DataSource'] = 'Observed'
gcdtime['BINMIDxFREQ'] = (gcdtime['BIN'] + 1) * gcdtime['FREQ']
if debug: display(gcdtime)
gcdtime_Stats = (gcdtime.groupby(['DataSource','Variable','Purpose'],as_index=False).agg(FREQ_SUM=('FREQ','sum'),AVG_TRIP_LEN=('BINMIDxFREQ','sum'))) # ADDING BINMIDxFREQ to get Avg Trip Length only works if FREQ sum = 1
if debug: display(gcdtime_Stats)
#
#
#
import numpy as np

mainPurposes = ['HBW','HBShp','HBOth','HBSchPr','HBSchSc','NHBW','NHBNW','LT','MD','HV']
externals = ['IX','XI','IX_MD','IX_HV','XI_MD','XI_HV','IXXI','IXXI_MD','IXXI_HV']

gcdtime_Stats.loc[gcdtime_Stats['Purpose'].isin(mainPurposes), 'PurpType'] = 'MainPurposes'

gcdtime_Stats.loc[gcdtime_Stats['Purpose'].isin(externals), 'PurpType'] = 'Externals'

# Assuming you have a dataframe called df and a column named 'Purpose'
order = ['HBW','HBShp','HBOth','HBSchPr','HBSchSc','NHBW','NHBNW','LT','MD','HV','IX','XI','IX_MD','XI_MD','IX_HV','XI_HV']

# Convert the 'Purpose' column to a categorical type with the desired order
gcdtime_Stats['Purpose'] = pd.Categorical(gcdtime_Stats['Purpose'], categories=order, ordered=True)

# Sort by 'Purpose'
gcdtime_Stats = gcdtime_Stats.sort_values('Purpose')

#
#
#
#
#
ojs_define(dataStats = gcdtime_Stats)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
ojs_define(freq = dfObsModelMerge)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
