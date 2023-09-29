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
#
#
#
#
#
#
#
#| label: tbl-hh-disagg
#| tbl-cap: Regional Median Income
import pandas as pd

table = pd.read_csv('tables/1-genparams.csv')
table = table.loc[table['Table'] == 'HHDisaggParams']
table = table[['Parameter', 'v9Value', 'v8Value']]
table['v9Value'] = table['v9Value'].astype(int).apply(lambda x: "${:,}".format((x)))
table['v8Value'] = table['v8Value'].astype(int).apply(lambda x: "${:,}".format((x)))
table.rename(columns = {'v9Value':'v9 Value', 'v8Value':'v8 Value'}, inplace=True)
display(table.style.hide_index())
```
#
#
#
#
#
#
#
#
#| label: tbl-exogen-income
#| tbl-cap: Income Break Points for Airport Exogenous Trip Table Generation
table = pd.read_csv('tables/1-genparams.csv')
table = table.loc[table['Table'] == 'ExogenousTrips']
table = table[['Parameter', 'v9Value', 'v8Value', 'Notes']]
table['v9Value'] = table['v9Value'].astype(int).apply(lambda x: "${:,}".format((x)))
table['v8Value'] = table['v8Value'].astype(int).apply(lambda x: "${:,}".format((x)))
table.rename(columns = {'v9Value':'v9 Value', 'v8Value':'v8 Value'}, inplace=True)
display(table.style.hide_index())  
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
#| label: tbl-vot1
#| tbl-cap: Value of Time Rates
#| tbl-colwidths: [24,8,24,8,36]
import pandas as pd
from tabulate import tabulate
from IPython.display import Markdown
import numpy as np

table = pd.read_csv('tables/1-genparams.csv')
table = table.loc[table['Table'] == 'VOT1']
table = table[['v9Parameter','v9Value', 'v8Parameter','v8Value','Notes']]
table = table.replace(np. nan,'',regex=True) 
table.rename(columns = {'v9Value':'v9 Value', 'v8Value':'v8 Value', 'v9Parameter':'v9 Parameter', 'v8Parameter':'v8 Parameter'}, inplace=True)
headers = ['v9 Parameter','v9 Value', 'v8 Parameter','v8 Value','Notes']
Markdown(tabulate(table, 
  headers=headers, 
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
#| label: tbl-relative-vot-ratios
#| tbl-cap: Relative Value of Time Ratios
# Define the data
data = [
    ['work trips'    ,	'1.00',	'1.00',	'0.0%' ],
    ['non-work trips',  '0.77', '0.78', '-0.6%'],
    ['external'      ,	'0.91',	'0.89',	'2.3%' ],
    ['light truck'   ,	'1.68',	'1.67',	'0.9%' ],
    ['medium truck'  ,	'2.27',	'2.22',	'2.3%' ],
    ['heavy truck'   ,	'2.86',	'2.78',	'3.1%' ]
]

# Create a pandas DataFrame
df = pd.DataFrame(data, columns=['Category', 'v9 Value Relative to Work Trips', 'v8 Value Relative to Work Trips', '% Difference'])

# Convert the DataFrame to a markdown table
headers = ['Category', 'v9 Value Relative to Work Trips', 'v8 Value Relative to Work Trips', '% Difference']
Markdown(tabulate(df, headers=headers, tablefmt="pipe", colalign=("left",)*len(headers), showindex=False)) 
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
#| label: tbl-auto-op
#| tbl-cap: Auto Operating Cost Parameters
import pandas as pd
table = pd.read_csv('tables/1-genparams.csv')
table = table.loc[table['Table'] == 'AutoOperatingCosts']
table = table[['Parameter','v9Value','v8Value','Notes']]
table.rename(columns = {'v9Value':'v9 Value', 'v8Value':'v8 Value'}, inplace=True)
display(table.style.hide_index())
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
#| label: tbl-auto-cost
#| tbl-cap: Relative Auto Operating Cost Ratios
# Define the data
data = [
    ["auto"        ,	"1.00",	"1.00",	"0.0%" ],
    ["light truck" ,	"1.26",	"1.34",	"-6.4%"],
    ["medium truck",	"2.56",	"2.61",	"-2.1%"],
    ["heavy truck" ,	"3.42",	"3.48",	"-1.6%"]
]

# Create a pandas DataFrame
df = pd.DataFrame(data, columns=['Category', 'v9 Value', 'v8 Value', '% Difference'])

# Convert the DataFrame to a markdown table
headers = ['Category', 'v9 Value', 'v8 Value', '% Difference']
Markdown(tabulate(df, headers=headers, tablefmt="pipe", colalign=("left",)*len(headers), showindex=False)) 
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
#| label: tbl-auto-vot
#| tbl-cap: Auto Operating Cost / Value of Time Ratios
# Define the data
data = [
    ['work trips'    ,	'0.986',	'1.017',	'-3.0%'],
    ['non-work trips',	'1.276',	'1.307',	'-2.3%'],
    ['external'      ,	'1.085',	'1.144',	'-5.1%'],
    ['light truck'   , '0.738' ,    '0.820',   '-10.0%'],
    ['medium truck'  ,	'1.110',	'1.195',	'-7.1%'],
    ['heavy truck'   ,	'1.179',	'1.274',	'-7.4%']

]

# Create a pandas DataFrame
df = pd.DataFrame(data, columns=['Category', 'v9 Value', 'v8 Value', '% Difference'])

# Convert the DataFrame to a markdown table
headers = ['Category', 'v9 Value', 'v8 Value', '% Difference']
Markdown(tabulate(df, headers=headers, tablefmt="pipe", colalign=("left",)*len(headers), showindex=False)) 
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
#| label: tbl-managed-lane
#| tbl-cap: Managed Lane Cost Rates
import pandas as pd
table = pd.read_csv('tables/1-genparams.csv')
table = table.loc[table['Table'] == 'ManagedLaneCosts']
table = table[['Parameter','v9Value','v8Value','Notes']]
table.rename(columns = {'v9Value':'v9 Value', 'v8Value':'v8 Value'}, inplace=True)
display(table.style.hide_index())
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
#| label: tbl-auto-occ1
#| tbl-cap: Vehicle Occupancy Rates
#| tbl-colwidths: [20,8,35,8,29]
import pandas as pd
table = pd.read_csv('tables/1-genparams.csv')
table = table.loc[table['Table'] == 'AutoOccupancy1']
table = table[['v9Parameter','v9Value', 'v8Parameter','v8Value','Notes']]
table['v9Value'] = table['v9Value'].astype('float').apply(lambda x: "{:,.2f}".format((x)))
table['v8Value'] = table['v8Value'].astype('float').apply(lambda x: "{:,.2f}".format((x)))
table = table.replace(np.nan,'',regex=True)
table = table.replace('nan','',regex=True) 
table.rename(columns = {'v9Value':'v9 Value', 'v8Value':'v8 Value', 'v9Parameter':'v9 Parameter', 'v8Parameter':'v8 Parameter'}, inplace=True)
headers = ['v9 Parameter','v9 Value', 'v8 Parameter','v8 Value','Notes']
Markdown(tabulate(table, 
  headers=headers, 
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
#| label: tbl-auto-occ2
#| tbl-cap: Vehicle Occupancy 3+ Rates
#| tbl-colwidths: [24,8,24,8,36]
import pandas as pd
table = pd.read_csv('tables/1-genparams.csv')
table = table.loc[table['Table'] == 'AutoOccupancy2']
table = table[['v9Parameter','v9Value', 'v8Parameter','v8Value','Notes']]
table['v9Value'] = table['v9Value'].astype('float').apply(lambda x: "{:,.2f}".format((x)))
table['v8Value'] = table['v8Value'].astype('float').apply(lambda x: "{:,.2f}".format((x)))
table = table.replace(np.nan,'',regex=True)
table = table.replace('nan','',regex=True) 
table.rename(columns = {'v9Value':'v9 Value', 'v8Value':'v8 Value', 'v9Parameter':'v9 Parameter', 'v8Parameter':'v8 Parameter'}, inplace=True)
headers = ['v9 Parameter','v9 Value', 'v8 Parameter','v8 Value','Notes']
Markdown(tabulate(table, 
  headers=headers, 
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
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
import pandas as pd
df_college_base = pd.read_csv('data/college-enrollment-forecast.csv')
df_college_long = pd.melt(df_college_base, id_vars=['Version','Year'], var_name='College', value_name = 'Enrollment')

```
#
ojs_define(dfcollege = df_college_long)
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#| label: tbl-college-enrollment-fcts
#| tbl-cap: College Enrollment Factors
# Define the data
data = [
    ['WFRC Colleges', 'Ensign'	        ,  0.101,	0.101,	1.179,	1.179,	0.930,	0.930, ''         ],
    [''             , 'Westminster'	    ,  0.012,	0.012,	1.098,	1.098,	0.930,	0.930, ''         ],
    [''             , 'UofU Main'	      ,  0.026,	0.026,	1.025,	1.210,	0.930,	0.930, ''         ],
    [''             , 'UofU Med'	      ,  0	  , 0.026,	1	 ,  1.210,	0	 ,  0.930, '(removed)'],
    [''             , 'WSU Main'	      ,  0.215,	0.215,	1.038,	1.588,	0.830,	0.830, ''         ],
    [''             , 'WSU Davis'	      ,  0.309,	0.309,	1.038,	1.588,	0.677,	0.677, ''         ],
    [''             , 'WSU West'	      ,  0	  , 0.309,	1	 ,  1.588,	0	 ,  0.677, '(removed)'],
    [''             , 'SLCC Main'	      ,  0.341,	0.341,	1.208,	2.005,	0.622,	0.622, ''         ],
    [''             , 'SLCC South City' ,  0.341,	0.341,	1.208,	2.005,	0.642,	0.642, ''         ],
    [''             , 'SLCC Jordan'	    ,  0.341,	0.341,	1.208,	2.005,	0.569,	0.569, ''         ],
    [''             , 'SLCC Meadowbrook',  0	  , 0.341,	1	 ,  2.005,	0	 ,  0.569, '(removed)'],
    [''             , 'SLCC Miller'	    ,  0.341,	0.341,	1.208,	2.005,	0.616,	0.616, ''         ],
    [''             , 'SLCC Library'    ,  0	  ,  0.341,	1	 ,  2.005,	0	 ,  0.616, '(removed)'],
    [''             , 'SLCC Highland'   ,  0	  ,  0.341,	1	 ,  2.005,	0	 ,  0.616, '(removed)'],
    [''             , 'SLCC Airport'    ,  0	  ,  0.341,	1	 ,  2.005,	0	 ,  0.616, '(removed)'],
    [''             , 'SLCC Westpointe' ,  0	  ,  0.341,	1	 ,  2.005,	0	 ,  0.616, '(removed)'],
    [''             , 'SLCC Herriman'   ,  0	  ,  0.341,	1	 ,  2.005,	0	 ,  0.616, '(removed)'],
    ['MAG Colleges' , 'BYU'             ,  0.026,	0.026,	1.025,	1.210,	0.930,	0.930, ''         ],
    [''             , 'UVU Main'	      ,  0.270,	0.270,	1.097,	1.400,	0.945,	0.945, ''         ],
    [''             , 'UVU Geneva'	    ,  0	  , 0.270,	1	 ,  1.400,	0	 ,  0.945, '(removed)'],
    [''             , 'UVU Lehi'	      ,  0.270,	0.270,	1.097,	1.400,	0.945,	0.945, ''         ],
    [''             ,' UVU Vineyard'    ,  0.270,	0.270,	1.097,	1.400,	0.945,	0.945, ''         ],
    [''             , 'UVU Payson'	    ,  0.270,	0.270,	1.097,	1.400,	0.945,	0.945, ''         ]
]

# Create a pandas DataFrame
df = pd.DataFrame(data, columns=['Areas', 'Campus', ' % Removed v9 Value', '% Removed v8 Value', 'FTE Rate v9 Value', 'FTE Rate v8 Value', 'HBC Trip Rate v9 Value', 'HBC Trip Rate v8 Value', 'Notes'])

# Convert the DataFrame to a markdown table
headers = ['Areas', 'Campus', ' % Removed <br> v9 Value', '% Removed <br> v8 Value', 'FTE Rate <br> v9 Value', 'FTE Rate <br> v8 Value', 'HBC Trip Rate <br> v9 Value', 'HBC Trip Rate <br> v8 Value', 'Notes']
Markdown(tabulate(df, headers=headers, tablefmt="pipe", colalign=("left",)*len(headers), showindex=False)) 
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
#| label: tbl-kfactors
#| tbl-cap: Reset K-Factors
#| tbl-colwidths: [37,23,11,18,11]
table = pd.read_csv('tables/1-genparams.csv')
table = table.loc[table['Table'] == 'KFactors']
table = table[['SubHeader','v9Parameter','v9Value', 'v8Parameter','v8Value']]
table = table.rename(columns={'SubHeader':'Area'})
table['v9Value'] = table['v9Value'].astype('float').apply(lambda x: "{:,.2f}".format((x)))
table['v8Value'] = table['v8Value'].astype('float').apply(lambda x: "{:,.2f}".format((x)))
table = table.replace(np.nan,'',regex=True)
table = table.replace('nan','',regex=True) 
table.rename(columns = {'v9Value':'v9 Value', 'v8Value':'v8 Value', 'v9Parameter':'v9 Parameter', 'v8Parameter':'v8 Parameter'}, inplace=True)
headers = ['Area', 'v9 Parameter','v9 Value', 'v8 Parameter','v8 Value']
Markdown(tabulate(table, 
  headers=headers, 
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
#
#
#
#| label: tbl-vot2
#| tbl-cap: Core Bus Constant Multiplier
#| tbl-colwidths: [30,8,30,8,20]
import pandas as pd
table = pd.read_csv('tables/1-genparams.csv')
table = table.loc[table['Table'] == 'VOT2']
table = table[['v9Parameter','v9Value', 'v8Parameter','v8Value','Notes']]
table.rename(columns = {'v9Value':'v9 Value', 'v8Value':'v8 Value', 'v9Parameter':'v9 Parameter', 'v8Parameter':'v8 Parameter'}, inplace=True)
headers = ['v9 Parameter','v9 Value', 'v8 Parameter','v8 Value','Notes']
Markdown(tabulate(table, 
  headers=headers, 
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
