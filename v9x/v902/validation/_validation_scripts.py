import os
import pandas as pd
import geopandas as gpd
import numpy as np
import matplotlib.pyplot as plt
import contextily as ctx


def plot_volume_diff(segSum, varOption, segShp):
    scenario1 = 'Modeled'
    scenario2 = 'Observed'

    lstScenario = list(set(segSum.data.tolist()))
    segSum = segSum[['SEGID', 'FTCLASS', 'data', varOption]]
    dfSegSum1 = segSum.query('data == @scenario1')
    dfSegSum2 = segSum.query('data == @scenario2')

    dfSegSum2[varOption] *= -1
    dfSegSumDiff = pd.merge(dfSegSum1, dfSegSum2, on= ['SEGID'], how='left')
    dfSegSumDiff['diff'] = dfSegSumDiff[varOption + '_x'] + dfSegSumDiff[varOption + '_y']
    dfSegSumDiff['FTCLASS'] = dfSegSumDiff['FTCLASS_x']

    sdfSegSumDiff = segShp.merge(dfSegSumDiff, on = 'SEGID')

    conditions = [
        (sdfSegSumDiff['diff'].lt(-10000)),
        (sdfSegSumDiff['diff'].ge(-10000) & sdfSegSumDiff['diff'].lt(-3000)),
        (sdfSegSumDiff['diff'].ge(-3000) & sdfSegSumDiff['diff'].lt(-1000)),
        (sdfSegSumDiff['diff'].ge(-1000) & sdfSegSumDiff['diff'].lt(1000)),
        (sdfSegSumDiff['diff'].ge(1000) & sdfSegSumDiff['diff'].lt(3000)),
        (sdfSegSumDiff['diff'].ge(3000) & sdfSegSumDiff['diff'].le(10000)),
        (sdfSegSumDiff['diff'].gt(10000)),
    ]
    choices = [2.4,2,1.7,1.7,1.7,2,2.4]
    sdfSegSumDiff["lw"] = np.select(conditions, choices)
    sdfSegSumDiff['lwf'] = np.where(sdfSegSumDiff['FTCLASS'] == 'Freeway', sdfSegSumDiff['lw'], sdfSegSumDiff['lw'] - 1.6)

    # Create the figure and axis
    fig, ax = plt.subplots()

    # Check and set CRS if necessary
    if sdfSegSumDiff.crs is None:
        # Assuming your original data is in EPSG:4326 (WGS84)
        sdfSegSumDiff.set_crs(epsg=26912, inplace=True)

    # Check if we need to reproject to Web Mercator
    if sdfSegSumDiff.crs.to_string() != 'EPSG:3857':
        sdfSegSumDiff = sdfSegSumDiff.to_crs(epsg=3857)
    
    bin1 = [-15000, -7500, -2500, 0, 2500, 7500, 15000]
    bin2 = [-5000, -1500, -500, 0, 500, 1500, 5000]
    
    if varOption=='Total':
        bin = bin1
    else:
        bin = bin2
    
    # Plot your geospatial data
    sdfSegSumDiff.plot(
        column='diff', 
        cmap='RdBu', 
        scheme="userdefined", 
        legend=True, 
        classification_kwds=dict(bins=bin),
        linewidth=sdfSegSumDiff['lwf'], 
        ax=ax,
        antialiased=False
    )

    # Add basemap using contextily with OpenStreetMap
    ctx.add_basemap(ax, source=ctx.providers.CartoDB.PositronNoLabels, alpha=1)

    # Adjust the margins and axis
    ax.margins(0.1)
    ax.axis('off')

    # Adjust the x-axis limits to cut off the right side of the map
    xlim = ax.get_xlim()  # Get current x-axis limits
    cutoff_value = xlim[1] - 65000  # Define how much you want to cut off (adjust value as needed)
    ax.set_xlim(xlim[0], cutoff_value)  # Set new x-axis limits


    # Adjust legend size
    leg = ax.get_legend()  # Get the current legend
    leg.set_bbox_to_anchor((1, 1))  # Move the legend outside the plot area if necessary
    leg.set_title('Difference Scale', prop={'size': 8})  # Adjust the title size
    for text in leg.get_texts():
        text.set_fontsize(8)  # Adjust the size of the legend text


    # Show the plot
    plt.rcParams["figure.figsize"]=6,12
    plt.tight_layout()
    plt.savefig(f'_pictures/vol-diff-{varOption}.png', bbox_inches='tight', dp=12000)
    plt.close(fig)
