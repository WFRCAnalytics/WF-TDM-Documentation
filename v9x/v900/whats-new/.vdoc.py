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
#|echo: false
# model folder
tdmOld = r"A:\1 - TDM\3 - Model Dev\1 - WF\1 - Official Release\v8x\v8.3.2\WF TDM v8.3.2 - 2022-02-04a"
tdmNew = r"A:\1 - TDM\3 - Model Dev\1 - WF\1 - Official Release\v9x\v9.0\WF TDM v9.0 - official"
#
#
#
#|echo: false
# PREPROCESS GEOSPATIAL DATA
import os
import pandas as pd
import geopandas as gpd
import topojson as tp

fnTazOldIn    = tdmOld + r"\1_Inputs\1_TAZ\TAZ.shp"
fnTazNewIn    = tdmNew + r"\1_Inputs\1_TAZ\TAZ.shp"
fnK12EnrollIn = tdmNew + r"\1_Inputs\2_SEData\_ source - HBSch Enroll & Med Inc\K-12 Enrollment\k12_schools_enrollment\k12_schools_enrollment.shp"
fnCity        = tdmNew + r"\1_Inputs\1_TAZ\Districts\City_Name.dbf"
fnSDst        = tdmNew + r"\1_Inputs\1_TAZ\Districts\Dist_Small.dbf"
fnMDst        = tdmNew + r"\1_Inputs\1_TAZ\Districts\Dist_Medium.dbf"
fnLDst        = tdmNew + r"\1_Inputs\1_TAZ\Districts\Dist_Large.dbf"

fnDistrictsOld    = tdmNew + r"\1_Inputs\1_TAZ\TAZ.shp"

def writeGeoJson(in_path,out_path,fields):
  if not os.path.isfile(out_path):
    gdf = gpd.read_file(in_path)
    gdf = gdf[fields]
    gdf = gdf.to_crs({'init': 'epsg:4326'}) 
    topo = tp.Topology(gdf, prequantize=False)
    gdf_simplified = topo.toposimplify(.0001).to_gdf()
    gdf_simplified.to_file(out_path, driver='GeoJSON')
    return;

writeGeoJson(fnTazOldIn   , "data/tazOld.geojson"   , ['TAZID','CO_TAZID','geometry'])
writeGeoJson(fnTazNewIn   , "data/tazNew.geojson"   , ['TAZID','CO_TAZID','REMM','geometry'])
writeGeoJson(fnK12EnrollIn, "data/k12enroll.geojson", ['SchoolName','Enrol_Elem','Enrol_Midl','Enrol_High','PublicElem','PublicMidl','PublicHigh','PriChaElem','PriChaMidl','PriChaHigh','geometry'])
writeGeoJson(fnCity       , "data/city.geojson"     , ['CITY_NAME','geometry'])
writeGeoJson(fnSDst       , "data/sdst.geojson"     , ['DISTSML','DSML_NAME','geometry'])
writeGeoJson(fnMDst       , "data/mdst.geojson"     , ['DISTMED','DMED_NAME','geometry'])
writeGeoJson(fnLDst       , "data/ldst.geojson"     , ['DISTLRG','DLRG_NAME','geometry'])

# add median income to taz file
if not os.path.isfile('data/tazmedincome.geojson'):
  gdfTazNew = gpd.read_file("data/tazNew.geojson")
  dfMedIncome = pd.read_csv(tdmNew + r"\1_Inputs\2_SEData\_ source - HBSch Enroll & Med Inc\Median Income & VOT\for SE file -- TAZ Median Income - 2022-03-17.csv")
  gdfTazMedIncome = pd.DataFrame.merge(gdfTazNew,dfMedIncome,on='CO_TAZID',how='left')
  gdfTazMedIncome.to_file('data/tazmedincome.geojson', driver='GeoJSON')
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
# Convert bus speeds input into long format
import pandas as pd

# add name data to expand model CSV
dfAreaTypes = pd.DataFrame([
  ['Rur','Rural'     ],
  ['Trn','Transition'],
  ['Sub','Suburban'  ],
  ['Urb','Urban'     ],
  ['CBD','CBD-Like'  ]
], columns=('AreaType','AreaTypeName'))

dfTimePeriods = pd.DataFrame([
  ['Pk','Peak'    ],
  ['Ok','Off-Peak'],
  ['DY','Daily'   ]
], columns=('TimePeriod','TimePeriodName'))

dfFunctionalClasses = pd.DataFrame([
  [1, 'Col', 'Collectors & Locals'],
  [2, 'Min', 'Minor Arterials'    ],
  [3, 'Maj', 'Major Arterials'    ],
  [4, 'Exp', 'Expressways'        ],
  [5, 'Fwy', 'Freeways & Ramps'   ]
], columns=('FC','FunctionalClass','FunctionalClassName'))

# read in bus speed ratios
dfBusSpeedRatios = pd.read_csv(r"\\modelace\ModelAce-E\1 - TDM\2 - Sandbox\v9_Development\WF TDM v9.0 - 2023-04-28\1_Inputs\0_GlobalData\4_ModeChoice\bus_speed_ratios.csv").rename(columns={';FC':'FC'})

# create a list of column names to use as variable names
varCols = dfBusSpeedRatios.columns.to_list()

# remove the ID columns from variable columns list
varCols.remove('Functional Class')

# melt table to get long format using FC and FC Name as ids
dfBusSpeedRatios_long = pd.melt(dfBusSpeedRatios, id_vars=['FC'], value_vars=varCols, var_name='TimePeriod_AreaType', value_name='BusSpeedRatio')

# get Time Period and Area Type from TimePeriod_AreaType field
dfBusSpeedRatios_long['TimePeriod'] = dfBusSpeedRatios_long['TimePeriod_AreaType'].str.split('_').str[0]
dfBusSpeedRatios_long['AreaType'  ] = dfBusSpeedRatios_long['TimePeriod_AreaType'].str.split('_').str[1]

dfBusSpeedRatios_long = dfBusSpeedRatios_long.merge(dfFunctionalClasses,on='FC'        )
dfBusSpeedRatios_long = dfBusSpeedRatios_long.merge(dfTimePeriods      ,on='TimePeriod')
dfBusSpeedRatios_long = dfBusSpeedRatios_long.merge(dfAreaTypes        ,on='AreaType'  )

# limit columns and export csv
dfBusSpeedRatios_long = dfBusSpeedRatios_long[['FunctionalClass','FunctionalClassName','TimePeriod','TimePeriodName','AreaType','AreaTypeName','BusSpeedRatio']]

## create objects for observable js
#ojs_define(busdata = dfBusSpeedRatios_long, typed=True)
#ojs_define(fcnames = dfBusSpeedRatios_long[['FunctionalClassName']].drop_duplicates())
#ojs_define(tpnames = dfBusSpeedRatios_long[['TimePeriodName'     ]].drop_duplicates())
#ojs_define(atnames = dfBusSpeedRatios_long[['AreaTypeName'       ]].drop_duplicates())

dfBusSpeedRatios_long.to_csv(r'data\bus_speed_ratios_long.csv', index=False)

# export function class list csv
dfBusSpeedRatios_long[['FunctionalClass','FunctionalClassName']].drop_duplicates().to_csv('data\\functionalclass.csv', index=False)
dfBusSpeedRatios_long[['TimePeriod'     ,'TimePeriodName'     ]].drop_duplicates().to_csv('data\\timeperiod.csv'     , index=False)
dfBusSpeedRatios_long[['AreaType'       ,'AreaTypeName'       ]].drop_duplicates().to_csv('data\\areatype.csv'       , index=False)

dfBusSpeedRatios_Previous = pd.DataFrame([
   ['Collectors'                        , 0.60],
   ['Minor Arterials\n(Urb/CBD)'        , 0.65],
   ['Minor Arterials\n(Sub/Rur)'        , 0.65],
   ['Principal Arterials\n& Expressways', 0.55],
   ['Freeway Ramps'                     , 0.75],
   ['Freeways'                          , 0.95]
], columns=('FunctionalClass','BusSpeedRatio'))

dfBusSpeedRatios_Previous.to_csv(r'data\bus_speed_ratios_previous.csv', index=False)
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
#
#
#
#| label: tbl-taz-count-internal
#| tbl-cap: Internal TAZ Count Comparison
#| tbl-colwidths: [40,15,15,25]
import pandas as pd
from IPython.display import Markdown
from tabulate import tabulate
table = {
    'County': ['Box Elder', 'Weber', 'Davis', 'Salt Lake', 'Utah', 'Total'],
    'v9': [153, 428, 324, 1311, 1330, 3546],
    'v832': [135, 280, 231, 1127, 1085, 2858],
    'Change': [18, 148, 93, 184, 245, 688]
}
headers = ['County','v9','v832','Change']
Markdown(tabulate(table, 
  headers = headers,
  tablefmt="pipe", 
  colalign=("left",)*len(headers), 
  showindex=False)
)
```
#
#| label: tbl-taz-count-external
#| tbl-cap: External TAZ Count Comparison
#| tbl-colwidths: [40,15,15,25]
import pandas as pd
from IPython.display import Markdown
from tabulate import tabulate
table = {
    'County': ['Box Elder', 'Weber', 'Davis', 'Salt Lake', 'Utah', 'Total'],
    'v9': [6, 3, 0, 6, 14, 29],
    'v832': [5, 3, 0, 7, 8, 23],
    'Change': [1, 0, 0, -1, 6, 6]
}
headers = ['County','v9','v832','Change']
Markdown(tabulate(table, 
  headers = headers,
  tablefmt="pipe", 
  colalign=("left",)*len(headers), 
  showindex=False)
)
```
#
#
#
#
#
#
import matplotlib.pyplot as plt
import geopandas as gpd
# Define a function to generate CO_FIPS attribute based on CO_TAZID
def assign_fips(co_tazid):
    co_tazid_str = str(co_tazid)
    if co_tazid_str.startswith('30'):
        return '3'
    elif co_tazid_str.startswith('11'):
        return '11'
    elif co_tazid_str.startswith('35'):
        return '35'
    elif co_tazid_str.startswith('57'):
        return '57'
    elif co_tazid_str.startswith('49'):
        return '49'
    else:
        return None  # Handle other cases if needed

def plot_geo_data_by_fips(data_taz_new, data_taz_old, co_fips_value, line_color_new, line_color_old, line_width):    
    # Create the figure and axes
    fig, ax = plt.subplots(figsize=(15, 15))
    
    # Filter GeoDataFrames based on CO_FIPS value
    data_taz_new_filtered = data_taz_new.loc[data_taz_new['CO_FIPS'] == co_fips_value]
    data_taz_old_filtered = data_taz_old.loc[data_taz_old['CO_FIPS'] == co_fips_value]
    
    # Plot the filtered GeoDataFrames with different line colors and line width
    data_taz_new_filtered.plot(ax=ax, facecolor='none', edgecolor=line_color_new, linewidth=line_width)
    data_taz_old_filtered.plot(ax=ax, facecolor='none', edgecolor=line_color_old, linewidth=line_width)
    
    legend_ax = fig.add_axes([0.85, 0.5, 0.1, 0.1])
    legend_elements = [
        plt.Line2D([0], [0], color=line_color_new, linewidth=line_width, label='v9.0.0'),
        plt.Line2D([0], [0], color=line_color_old, linewidth=line_width, label='v8.3.2')
    ]
    legend_ax.legend(handles=legend_elements, loc='center')
    legend_ax.axis('off')
    
    # Display the plot
    plt.show()
#
#
#
import geopandas as gpd
import matplotlib.pyplot as plt

# Read the GeoJSON files
data_taz_new = gpd.read_file(r'D:\GitHub\TDM-Documentation\v9x\v900\whats-new\data\tazNew.geojson')
data_taz_old = gpd.read_file(r'D:\GitHub\TDM-Documentation\v9x\v900\whats-new\data\tazOld.geojson')

# Apply the function to create the CO_FIPS attribute
data_taz_new['CO_FIPS'] = data_taz_new['CO_TAZID'].apply(assign_fips)
data_taz_old['CO_FIPS'] = data_taz_old['CO_TAZID'].apply(assign_fips)

# Set the line colors and line width
line_color_new = '#0B2842'
line_color_old = '#789d4b'
line_width = 0.5
#
#
#
#| label: fig-taz-compare-weber-pdf
#| fig-cap: TAZ Geography Comparison Map -- Weber County
plot_geo_data_by_fips(data_taz_new, data_taz_old, '57', line_color_new, line_color_old, line_width)
#
#
#
#| label: fig-taz-compare-davis-pdf
#| fig-cap: TAZ Geography Comparison Map -- Davis County
plot_geo_data_by_fips(data_taz_new, data_taz_old, '11', line_color_new, line_color_old, line_width)
#
#
#
#| label: fig-taz-compare-sl-pdf
#| fig-cap: TAZ Geography Comparison Map -- Salt Lake County
plot_geo_data_by_fips(data_taz_new, data_taz_old, '35', line_color_new, line_color_old, line_width)
#
#
#
#| label: fig-taz-compare-utah-pdf
#| fig-cap: TAZ Geography Comparison Map -- Utah County
plot_geo_data_by_fips(data_taz_new, data_taz_old, '49', line_color_new, line_color_old, line_width)
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
#| label: tbl-taz-ranges-internal
#| tbl-cap: Internal TAZ Ranges
#| tbl-colwidths: [30,33,33]
import pandas as pd
from IPython.display import Markdown
from tabulate import tabulate
table = {
    'County': ['Box Elder', 'Weber', 'Davis', 'Salt Lake', 'Utah', 'Total'],
    'v9': ['1-153','154-581','582-905','906-2216','2217-3546', '1-3546'],
    'v832': ['1-135','141-420','424-654','655-1781','1789-2873', '1-2873']
}
headers = ['County','v9','v832']
Markdown(tabulate(table, 
  headers = headers,
  tablefmt="pipe", 
  colalign=("left",)*len(headers), 
  showindex=False)
)
```
#
#| label: tbl-taz-ranges-external
#| tbl-cap: External TAZ Ranges
#| tbl-colwidths: [30,33,33]
import pandas as pd
from IPython.display import Markdown
from tabulate import tabulate
table = {
    'County': ['Box Elder', 'Weber', 'Davis', 'Salt Lake', 'Utah', 'Total'],
    'v9': ['3601-3606','3607-3609','N/A','3610-3615','3616-3629', '3601-3629'],
    'v832': [  '136-140','421-423','N/A','1782-1788','2874-2881', '137-140, 421-423, 1782-1788, 2874-2881']
}
headers = ['County','v9','v832']
Markdown(tabulate(table, 
  headers = headers,
  tablefmt="pipe", 
  colalign=("left",)*len(headers), 
  showindex=False)
)
```
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
#|label: fig-taz-remm-space-pdf
#|fig-cap: TAZ REMM Space
# Read the GeoJSON files
import matplotlib.colors as colors
data_taz_new = gpd.read_file(r'D:\GitHub\TDM-Documentation\v9x\v900\whats-new\data\tazNew.geojson')
remm_values = data_taz_new['REMM'].astype(int)
cmap = 'Accent_r'

fig, ax = plt.subplots(figsize=(10, 10))
data_taz_new.plot(column=remm_values, cmap=cmap, linewidth=0.5, ax=ax)

legend_ax = fig.add_axes([0.85, 0.5, 0.1, 0.1]) 
legend_elements = [
    plt.Line2D([0], [0], color='green', linewidth=line_width, label='REMM Space'),
    plt.Line2D([0], [0], color='gray', linewidth=line_width, label='Non-REMM Space')
]
legend_ax.legend(handles=legend_elements, loc='center')
legend_ax.axis('off')

# Display the plot
plt.show()

```
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
#| echo: false
import pandas as pd

# County Control Totals
fnConTotOld = tdmOld + r"\1_Inputs\2_SEData\_ControlTotals\ControlTotal_SE_WF.csv"
fnConTotNew = tdmNew + r"\1_Inputs\2_SEData\_ControlTotals\ControlTotal_SE_AllCounties.csv"

dfConTotOld = pd.read_csv(fnConTotOld)
dfConTotOld = dfConTotOld.rename(columns={'CoName':'CO_NAME'})
dfConTotOld['CO_NAME'] = dfConTotOld['CO_NAME'].str.replace(' County','')
dfConTotOld['ModelVersion'] = 'v8.3.2'

dfConTotNew = pd.read_csv(fnConTotNew)
dfConTotNew = dfConTotNew[dfConTotNew['Subarea']=='1 - Wasatch Front'] # only WF area
dfConTotNew['ModelVersion'] = 'v9.0.0'

dfConTot = pd.concat([dfConTotOld,dfConTotNew])

#display(dfConTot)
dfConTot_melt = pd.melt(dfConTot, id_vars=('CO_NAME','YEAR','ModelVersion'), value_name='ControlTotal', var_name='Category', value_vars=('TOTPOP','GQ_Pop','HH_Pop','HH','HH_Size','POP_00_17','POP_18_64','POP_65P','ALLEMP','RETL','FOOD','MANU','WSLE','OFFI','GVED','HLTH','OTHR','AGRI','MING','CONS','HBJ','Job_HH','WrkPop_Job'))

dfConTot_melt.to_csv('data/controltotal.csv',index=False)
dfConTot_melt.groupby(['CO_NAME'],as_index=False).agg(COUNT=('YEAR','size')).to_csv('data/counties.csv',index=False)

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
#| label: tbl-master-network-node-numbering-schema
#| tbl-cap: Master Network Node Numbering Schema
#| echo: False
from IPython.display import Markdown
from tabulate import tabulate
table = [['WFRC'   , '10,000 - 19,999', '20,000 - 49,999', '90,000 - 94,999'],
         ['MAG'    , '50,000 - 59,999', '60,000 - 89,999', '95,000 - 99,999']]
Markdown(tabulate(
  table, 
  headers=["MPO","Transit Nodes", "Highway Nodes", "v9 Expansion Areas"]
))
```
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
#|echo: false
# get externals mapping layers

import os
import pandas as pd
import geopandas as gpd
import topojson as tp

if not os.path.isfile('data/masternetlink.geojson'):
  gdfMasterNetLink = gpd.read_file(r"A:\1 - TDM\1 - Input Dev\5 - External\_GIS_Layers\Master Net\MasterNet - 2022-07-29_Link.shp")
  gdfMasterNetLink = gdfMasterNetLink.to_crs({'init': 'epsg:4326'}) 
  gdfMasterNetLink = gdfMasterNetLink[gdfMasterNetLink['FT_2019']>1]
  gdfMasterNetLink = gdfMasterNetLink[['LINKID','FLG_NEWNET','geometry']]
  topo = tp.Topology(gdfMasterNetLink, prequantize=False)
  gdfMasterNetLink = topo.toposimplify(.0001).to_gdf()
  gdfMasterNetLink.to_file('data/masternetlink.geojson', driver='GeoJSON')

if not os.path.isfile('data/masternetnode.geojson'):
  gdfMasterNetNode = gpd.read_file(r"A:\1 - TDM\1 - Input Dev\5 - External\_GIS_Layers\Master Net\MasterNet - 2022-07-29_Node.shp")
  gdfMasterNetNode = gdfMasterNetNode.to_crs({'init': 'epsg:4326'}) 
  gdfMasterNetNode = gdfMasterNetNode[['N','EXTERNAL','EXT_V9','geometry']]
  topo = tp.Topology(gdfMasterNetNode, prequantize=False)
  gdfMasterNetNode = topo.toposimplify(.0001).to_gdf()
  gdfMasterNetNode.to_file('data/masternetnode.geojson', driver='GeoJSON')

if not os.path.isfile('data/externalold.geojson'):
  gdfMasterNetNode = gpd.read_file('data/masternetnode.geojson')
  gdfExtNew = gdfMasterNetNode[gdfMasterNetNode['EXTERNAL']==1]
  gdfExtNew.to_file('data/externalold.geojson', driver='GeoJSON')

if not os.path.isfile('data/externalnew.geojson'):
  gdfMasterNetNode = gpd.read_file('data/masternetnode.geojson')
  gdfExtNew = gdfMasterNetNode[gdfMasterNetNode['EXT_V9']==1]
  gdfExtNew.to_file('data/externalnew.geojson', driver='GeoJSON')

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
#
#
#
#
#
#
#
