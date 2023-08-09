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
#
#| echo: False
import pandas as pd
mdist_age = pd.read_csv(r'data/1-hhdisag-autoown/TAZ_AgePct_Lookup-2022-06-07_v9.0-2023-06-30.csv')
mdist_age['MediumDistrict'] = mdist_age['MEDDIST'].astype(str).str.cat(mdist_age['MEDDIST2'], sep="-")
mdist_age_sum = mdist_age.groupby(['MediumDistrict','MEDDIST']).sum().reset_index()
mdist_age_sum['Total'] = mdist_age_sum['TotPop_0-17'] + mdist_age_sum['TotPop_18-64'] + mdist_age_sum['TotPop_65Plus']
mdist_age_sum['Percent_0-17'] = mdist_age_sum['TotPop_0-17'] / mdist_age_sum['Total']
mdist_age_sum['Percent_18-64'] = mdist_age_sum['TotPop_18-64'] / mdist_age_sum['Total']
mdist_age_sum['Percent_65Plus'] = mdist_age_sum['TotPop_65Plus'] / mdist_age_sum['Total']
mdist_age_sum = mdist_age_sum.fillna(0)
mdist_age_sum = mdist_age_sum.sort_values(by='MEDDIST')
#
#
#
#| echo: False
mdist_age_long = mdist_age_sum.melt(id_vars=['MediumDistrict'], value_vars=['Percent_0-17', 'Percent_18-64', 'Percent_65Plus'], var_name='AgeGroup', value_name='Percent')
#
#
#
gpi_age = pd.read_csv(r'data/1-hhdisag-autoown/ControlTotal_SE-2022-08-31_v9.0-2023-06-30.csv')
gpi_age_long = gpi_age.melt(id_vars=['AgeGroup','Region'], value_vars=['1990','2000','2010','2020','2030','2040','2050','2060'], var_name='Year',value_name='Percent')
gpi_age_long['Percent'] = gpi_age_long['Percent']
#
#
#
#| include: False
import plotly.express as px
colors = {'Age 0 - 17': 'steelblue', 'Age 18 - 64': 'peru', 'Age 65+': 'darkgrey'}
fig2 = px.bar(gpi_age_long, x = "Year", y = "Percent", color = "AgeGroup", facet_row = "Region", height = 1000, color_discrete_map=colors,
text=[f'{val:.00%}' for val in gpi_age_long['Percent']], 
             template='simple_white')
fig2.update_xaxes(title=None, tickangle=0, showticklabels=True, ticks='inside', ticklen=10)
fig2.update_traces(textposition='inside', textangle = 0, textfont=dict(color='white'))
#
#
#
#
#
#
#
#
#
co_age_sum = mdist_age.groupby(['CountyID']).sum().reset_index()
#
#
#
#
co_age_sum['Total'] = co_age_sum['TotPop_0-17'] + co_age_sum['TotPop_18-64'] + co_age_sum['TotPop_65Plus']
co_age_sum['Percent_0-17'] = co_age_sum['TotPop_0-17'] / co_age_sum['Total']
co_age_sum['Percent_18-64'] = co_age_sum['TotPop_18-64'] / co_age_sum['Total']
co_age_sum['Percent_65Plus'] = co_age_sum['TotPop_65Plus'] / co_age_sum['Total']
co_age_sum = co_age_sum.fillna(0)
#
#
#
#
county_map = {3: 'Box Elder', 11: 'Davis', 35: 'Salt Lake', 49: 'Utah', 57: 'Weber'}
def get_county_name(county_id):
    return county_map[county_id]
co_age_sum['Region'] = co_age_sum['CountyID'].apply(get_county_name)

co_age_long = co_age_sum.melt(id_vars=['Region'], value_vars=['Percent_0-17','Percent_18-64','Percent_65Plus'], var_name='AgeGroup', value_name='Percent')
#
#
#
#
import numpy as np
conditions = [
    (co_age_long['AgeGroup'] == 'Percent_0-17'),
    (co_age_long['AgeGroup'] == 'Percent_18-64'),
    (co_age_long['AgeGroup'] == 'Percent_65Plus')
]
values = ['Age 0 - 17', 'Age 18 - 64', 'Age 65+']
co_age_long['AgeGroup'] = np.select(conditions,values)
co_age_long['Year'] = 2020
#
#
#
#
gpi_age_long_c = gpi_age_long
gpi_age_long_c['Source'] = 'Observed'
gpi_age_long_c = gpi_age_long_c[gpi_age_long_c['Year']=='2020']
co_age_long_c = co_age_long
co_age_long_c['Source'] = 'Modeled'
life_compare = pd.concat([gpi_age_long_c, co_age_long_c], axis=0)
life_compare = life_compare[life_compare['Region'].isin(['Utah','Weber','Salt Lake','Davis'])]
#
#
#
#
#| include: False
colors2 = {'Observed':'steelblue','Modeled':'forestgreen'}
fig3 = px.bar(life_compare, 
    x="Region", 
    y="Percent",
    text_auto='.2s',    
    color='Source', 
    barmode='group', 
    height=800, 
    facet_row = 'AgeGroup',
    color_discrete_map=colors2, 
    text=[f'{round(val2*100,1)}' for val2 in life_compare['Percent']], template='simple_white')
fig3.update_yaxes(title='Percent')
fig3.update_xaxes(title=None, tickangle=0, showticklabels=True, ticks='inside', ticklen=10)
fig3.update_traces(textposition='inside', textangle = 0, texttemplate='%{text}%', textfont=dict(color='white'))
#
#
#
#
#| label: fig-age-comp
#| fig-cap: "2020 Model vs. 2020 GPI – % Population by Age Group and County."
#| cap-location: margin
fig3.show()
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
#| include: False
hhts = pd.read_csv(r'data/1-hhdisag-autoown/2012_HHSurvey-HHData_2022-09-29.csv')[['record_ID','h_CO_FIPS_v30','h_CO_NAME_v30','weight','hhsize','life_cycle']]
hhts_lf_pop = hhts
hhts_lf_pop['number'] = hhts_lf_pop['weight'] * hhts_lf_pop['hhsize']
hhts_lf_pop = (hhts_lf_pop
    .drop(columns={'record_ID','weight','hhsize'})
    .groupby(['h_CO_FIPS_v30','h_CO_NAME_v30','life_cycle'])
    .sum()
    .reset_index())
hhts_lf_pop = hhts_lf_pop[hhts_lf_pop['h_CO_FIPS_v30'].isin([3,11,35,49,57])]
hhts_lf_pop = hhts_lf_pop.rename(columns={'h_CO_FIPS_v30':'CO_FIPS','h_CO_NAME_v30':'Region','life_cycle':"LifeCycle"})
hhts_lf_pop_tot = hhts_lf_pop.groupby(['CO_FIPS','Region']).sum().reset_index().drop(columns={'LifeCycle'}).rename(columns={'number':'total'})

hhts_lf_pop_full = pd.merge(hhts_lf_pop, hhts_lf_pop_tot,how = 'left', on = ('CO_FIPS','Region'))
hhts_lf_pop_full['Percent'] = hhts_lf_pop_full['number'] / hhts_lf_pop_full['total']

lf_control_pop = hhts_lf_pop_full[['Region','LifeCycle','Percent']]
lf_control_pop['Source'] = 'Observed'
#
#
#
#| include: False
from dbfread import DBF
lc_dbf = pd.DataFrame(DBF(r'data/1-hhdisag-autoown/LifeCycle_Households_Population_v9.0-2023-06-30-BY_2019.dbf', load=True))
lc_dbf = lc_dbf[lc_dbf['CO_FIPS'].isin([3,11,35,49,57])]
lc_dbf['Region'] = lc_dbf['CO_FIPS'].apply(get_county_name).str.upper()
lc_wf = lc_dbf[['Region','POP_LC1','POP_LC2','POP_LC3']]

lc_model_pop = lc_wf.melt(id_vars=['Region'], value_vars=['POP_LC1','POP_LC2','POP_LC3'], var_name='LifeCycle',value_name='number')
conditions2 = [
    (lc_model_pop['LifeCycle'] == 'POP_LC1'),
    (lc_model_pop['LifeCycle'] == 'POP_LC2'),
    (lc_model_pop['LifeCycle'] == 'POP_LC3')
]
values2 = [1, 2, 3]
lc_model_pop['LifeCycle'] = np.select(conditions2,values2)

lf_model_group = lc_model_pop.groupby(['Region','LifeCycle']).sum().reset_index()
lf_model_total = lc_model_pop.groupby(['Region']).sum().reset_index().rename(columns={'number':'total'}).drop(columns={'LifeCycle'})
lf_model_groupsum = pd.merge(lf_model_group,lf_model_total,how='left', on = ('Region'))

lf_model_groupsum['Percent'] = lf_model_groupsum['number'] / lf_model_groupsum['total']
lf_model_pop = lf_model_groupsum[['Region','LifeCycle','Percent']]
lf_model_pop['Source'] = 'Modeled'
#
#
#
#
#| include: False
lf_pop_both = pd.concat([lf_control_pop,lf_model_pop],axis=0)
#
#
#
#
#| include: False
fig4 = px.bar(lf_pop_both, 
    x="Region", 
    y="Percent",
    text_auto='.2s',    
    color='Source', 
    barmode='group', 
    height=800, 
    facet_row = 'LifeCycle',
    color_discrete_map=colors2, 
    text=[f'{round(val2*100,1)}' for val2 in lf_pop_both['Percent']], template='simple_white')
fig4.update_yaxes(title='Percent')
fig4.update_xaxes(title=None, tickangle=0, showticklabels=True, ticks='inside', ticklen=10)
fig4.update_traces(textposition='inside', textangle = 0, texttemplate='%{text}%', textfont=dict(color='white'))
```
#
#| label: fig-lc-pop
#| fig-cap: "2019 Model vs. 2012 Household Survey – % Population by Life Cycle and County."
#| cap-location: margin
fig4.show()
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
#| include: False
hhts = pd.read_csv(r'data/1-hhdisag-autoown/2012_HHSurvey-HHData_2022-09-29.csv')[['record_ID','h_CO_FIPS_v30','h_CO_NAME_v30','weight','hhsize','life_cycle']]
hhts_lf_hh = hhts
hhts_lf_hh['number'] = hhts_lf_hh['weight']
hhts_lf_hh = (hhts_lf_hh
    .drop(columns={'record_ID','weight','hhsize'})
    .groupby(['h_CO_FIPS_v30','h_CO_NAME_v30','life_cycle'])
    .sum()
    .reset_index())
hhts_lf_hh = hhts_lf_hh[hhts_lf_hh['h_CO_FIPS_v30'].isin([3,11,35,49,57])]
hhts_lf_hh = hhts_lf_hh.rename(columns={'h_CO_FIPS_v30':'CO_FIPS','h_CO_NAME_v30':'Region','life_cycle':"LifeCycle"})
hhts_lf_hh_tot = hhts_lf_hh.groupby(['CO_FIPS','Region']).sum().reset_index().drop(columns={'LifeCycle'}).rename(columns={'number':'total'})

hhts_lf_hh_full = pd.merge(hhts_lf_hh, hhts_lf_hh_tot,how = 'left', on = ('CO_FIPS','Region'))
hhts_lf_hh_full['Percent'] = hhts_lf_hh_full['number'] / hhts_lf_hh_full['total']

lf_control_hh = hhts_lf_hh_full[['Region','LifeCycle','Percent']]
lf_control_hh['Source'] = 'Observed'
display(lf_control_hh)
#
#
#
#| include: False
lc_wf_hh = lc_dbf[['Region','HH_LC1','HH_LC2','HH_LC3']]

lc_model_hh = lc_wf_hh.melt(id_vars=['Region'], value_vars=['HH_LC1','HH_LC2','HH_LC3'], var_name='LifeCycle',value_name='number')
conditions3 = [
    (lc_model_hh['LifeCycle'] == 'HH_LC1'),
    (lc_model_hh['LifeCycle'] == 'HH_LC2'),
    (lc_model_hh['LifeCycle'] == 'HH_LC3')
]
values3 = [1, 2, 3]
lc_model_hh['LifeCycle'] = np.select(conditions3,values3)

lf_model_group_hh = lc_model_hh.groupby(['Region','LifeCycle']).sum().reset_index()
lf_model_total_hh = lc_model_hh.groupby(['Region']).sum().reset_index().rename(columns={'number':'total'}).drop(columns={'LifeCycle'})
lf_model_groupsum_hh = pd.merge(lf_model_group_hh,lf_model_total_hh,how='left', on = ('Region'))

lf_model_groupsum_hh['Percent'] = lf_model_groupsum_hh['number'] / lf_model_groupsum_hh['total']
lf_model_hh = lf_model_groupsum_hh[['Region','LifeCycle','Percent']]
lf_model_hh['Source'] = 'Modeled'
lf_hh_both = pd.concat([lf_control_hh,lf_model_hh],axis=0)
display(lf_hh_both)
#
#
#
#| include: False
fig5 = px.bar(lf_hh_both, 
    x="Region", 
    y="Percent",
    text_auto='.2s',    
    color='Source', 
    barmode='group', 
    height=800, 
    facet_row = 'LifeCycle',
    color_discrete_map=colors2, 
    text=[f'{round(val2*100,1)}' for val2 in lf_hh_both['Percent']], template='simple_white')
fig5.update_yaxes(title='Percent')
fig5.update_xaxes(title=None, tickangle=0, showticklabels=True, ticks='inside', ticklen=10)
fig5.update_traces(textposition='inside', textangle = 0, texttemplate='%{text}%', textfont=dict(color='white'))
#
#
#
#| label: fig-lc-hh
#| fig-cap: "2019 Model vs. 2012 Household Survey – % Households by Life Cycle and County."
#| cap-location: margin
fig5.show()
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
import pandas as pd
hhsizevalid_csv = pd.read_csv('data/1-hhdisag-autoown/HHSizeValidation.csv')

hhsizevalid = hhsizevalid_csv.replace('%','', regex=True)
hhsizevalid = hhsizevalid.drop(columns={'CO_FIPS','Total'})
hhsizevalid = pd.melt(hhsizevalid, id_vars = ['Data','COUNTY'], var_name = 'Household Type', value_name = 'Percent')

hhsizevalid = hhsizevalid[hhsizevalid['COUNTY'].isin(['BOX ELDER', 'WEBER', 'DAVIS', 'SALT LAKE', 'UTAH'])]
hhsizevalid[['Percent']] = hhsizevalid[['Percent']].apply(pd.to_numeric)
#
#
#
#| label: fig-hh-modobs
#| fig-cap: "2015 Model vs. 2010 Census & 2016 ACS – % Households by Household Size"
#| cap-location: margin
colors2 = {'2015 Model':'royalblue','2010 Census':'forestgreen', '2016 5Yr ACS': 'mediumseagreen'}
import plotly.express as px
fig3 = px.bar(hhsizevalid, 
    x="Household Type", 
    y="Percent",
    text_auto='.2s',    
    color='Data', 
    barmode='group', 
    height=1600,
    facet_row = 'COUNTY',
    color_discrete_map=colors2, 
    text=[f'{round(val2*100,1)}' for val2 in hhsizevalid['Percent']], template='simple_white')
fig3.update_xaxes(title=None, tickangle=0, showticklabels=True, ticks='inside', ticklen=10)
fig3.show()
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
