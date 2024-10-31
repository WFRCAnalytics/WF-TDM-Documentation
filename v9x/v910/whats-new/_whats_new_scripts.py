import plotly as py
import plotly.graph_objects as go



def update_plot(lstIncludeInAll, dfTransitShareAll, tdmVersionsWithDate, scenarioGroups, modeGroups, trippurps, periods):

    data = []

    for v in tdmVersionsWithDate:
        for g in scenarioGroups:
            for m in modeGroups:

                # only do if data in dataframe since BY data is concatonated later
                if dfTransitShareAll[(dfTransitShareAll['tdmVersionWithDate']==v) & (dfTransitShareAll['scenarioGroup'].isin([g])) & (dfTransitShareAll['modeGroup']==m) & (dfTransitShareAll['TRIPPURP'].isin(trippurps)) & (dfTransitShareAll['PERIOD'].isin(periods))].shape[0]>1:

                    # data for plotting from filtered dataframe}
                    plotdata = dfTransitShareAll[(dfTransitShareAll['tdmVersionWithDate']==v) & (dfTransitShareAll['scenarioGroup'].isin(lstIncludeInAll + [g])) & (dfTransitShareAll['modeGroup']==m) & (dfTransitShareAll['TRIPPURP'].isin(trippurps)) & (dfTransitShareAll['PERIOD'].isin(periods))]

                    #display(plotdata)

                    plotdata = plotdata.groupby(['scenarioYear'], as_index=False).agg(TRIPS=('TRIPS','sum'))

                    # fill any NaN values with zeros
                    plotdata = plotdata.fillna(0)

                    #display(plotdata)

                    xplot = plotdata['scenarioYear']
                    yplot = plotdata['TRIPS'       ]

                    trace1 = go.Scatter(
                        x=xplot,
                        y=yplot,
                        mode='markers+lines',
                        name= v.split(' ')[2], # get version number by getting all characters before first space
                        marker=dict(size=12,
                                line=dict(width=2,
                                            color='DarkSlateGrey'))
                    )
                    data.append(trace1)


    layout = go.Layout(
        #title='Trips by Mode (' + '/'.join(trippurps) + ' ' + '/'.join(periods) + ')',
        yaxis=dict(
            title='Trips',
            rangemode = 'tozero'#,
            #range=(0,np.null)
        ),
        xaxis=dict(
            title='Year',
            range=(2018,2051)
        ),
        width=800,
        height=550
    )
    
    fig = go.Figure(data=data, layout=layout)
    fig.update_layout(legend=dict(
        yanchor="top",
        y=0.99,
        xanchor="left",
        x=0.01
    ))
    py.offline.iplot(fig)
py.offline.init_notebook_mode(connected=True)



#Transit Share Plotting Function
def update_plot_stackedarea(lstIncludeInAll, dfTransitShareAll, tdmVersionWithDate, scenarioGroup, modeGroups, trippurps, periods):

    data = []

    modeGroups = sorted(modeGroups)
    modeNames = ['Local Bus','Core Bus','Express Bus','Bus Rapid Transit','Light-Rail Transit','Commuter-Rail Transit']

    for m in modeGroups: 
        # only do if data in dataframe since BY data is concatonated later
        if dfTransitShareAll[(dfTransitShareAll['tdmVersionWithDate']==tdmVersionWithDate) &
                             (dfTransitShareAll['scenarioGroup'     ]==scenarioGroup     ) &
                             (dfTransitShareAll['modeGroup'         ]==m                 ) &
                             (dfTransitShareAll['TRIPPURP'          ].isin(trippurps)    ) &
                             (dfTransitShareAll['PERIOD'            ].isin(periods)      )].shape[0]>1:

            # data for plotting from filtered dataframe}
            plotdata = dfTransitShareAll[(dfTransitShareAll['tdmVersionWithDate']==tdmVersionWithDate                    ) &
                                         (dfTransitShareAll['scenarioGroup'     ].isin(lstIncludeInAll + [scenarioGroup])) &
                                         (dfTransitShareAll['modeGroup'         ]==m                                     ) &
                                         (dfTransitShareAll['TRIPPURP'          ].isin(trippurps)                        ) &
                                         (dfTransitShareAll['PERIOD'            ].isin(periods)                          )]

            #display(plotdata)

            plotdata = plotdata.groupby(['scenarioYear'], as_index=False).agg(TRIPS=('TRIPS','sum'))

            # fill any NaN values with zeros
            plotdata = plotdata.fillna(0)

            #display(plotdata)

            xplot = plotdata['scenarioYear']
            yplot = plotdata['TRIPS'       ]

            trace1 = go.Scatter(
                x=xplot,
                y=yplot,
                mode='lines',
                name= modeNames[modeGroups.index(m)],
                stackgroup='one',
                groupnorm='percent' # sets the normalization for the sum of the stackgroup
            )
            data.append(trace1)


    layout = go.Layout(
        #title=tdmVersionWithDate + ' Trips Mode Split (' + '/'.join(trippurps) + ' ' + '/'.join(periods) + ')',
        yaxis=dict(
            title='Percent of Total Trips'#,
            #rangemode = 'tozero',
            #ticksuffix='%',
            #range=(0,100)
        ),
        xaxis=dict(
            title='Year'#,
            #range=(2018,2051)
        ),
        width=840,
        height=400
    )
    
    fig2 = go.Figure(data=data, layout=layout)
    py.offline.iplot(fig2)
py.offline.init_notebook_mode(connected=True)



def update_plot_stackedarea_boardings(lstIncludeInAll, df, tdmVersionWithDate, scenarioGroup, BoardingsCol):

    data = []

    modes = [4.0,5.0,6.0,9.0,7.0,8.0] #put modes in sorted order
    #modes = sorted(df['MODE'].unique())
    modeNames = ['LCL','COR','EXP','BRT','LRT','CRT']

    for m in modes: 
        # only do if data in dataframe since BY data is concatonated later
        if df[(df['tdmVersionWithDate']==tdmVersionWithDate) &
                                          (df['scenarioGroup'     ]==scenarioGroup     ) &
                                          (df['Mode'              ]==m                 )].shape[0]>1:

            # data for plotting from filtered dataframe}
            plotdata = df[(df['tdmVersionWithDate']==tdmVersionWithDate                    ) &
                                                      (df['scenarioGroup'     ].isin(lstIncludeInAll + [scenarioGroup])) &
                                                      (df['Mode'              ]==m                                     )]

            #display(plotdata)

            plotdata = plotdata.groupby(['scenarioYear'], as_index=False).agg(BOARDINGS=(BoardingsCol,'sum'))

            # fill any NaN values with zeros
            plotdata = plotdata.fillna(0)

            #display(plotdata)

            xplot = plotdata['scenarioYear']
            yplot = plotdata['BOARDINGS'   ]

            trace1 = go.Scatter(
                x=xplot,
                y=yplot,
                mode='lines',
                name= modeNames[modes.index(m)],
                stackgroup='one',
                groupnorm='percent' # sets the normalization for the sum of the stackgroup
            )
            data.append(trace1)


    layout = go.Layout(
        #title=tdmVersionWithDate + ' Boardings by Mode',
        yaxis=dict(
            title='Percent of Total Boardings'#,
            #rangemode = 'tozero',
            #ticksuffix='%',
            #range=(0,100)
        ),
        xaxis=dict(
            title='Year'#,
            #range=(2018,2051)
        ),
        width=840,
        height=400
    )
    
    fig2 = go.Figure(data=data, layout=layout)
    py.offline.iplot(fig2)
py.offline.init_notebook_mode(connected=True)