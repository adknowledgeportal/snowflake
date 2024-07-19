import streamlit as st
from snowflake.snowpark import Session
import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta
import plotly.graph_objects as go
import plotly.express as px

from queries import query_entity_distribution, query_project_sizes, query_project_downloads

# Custom CSS for sage green filled containers and banners
with open('style.css') as f:
    st.markdown(f'<style>{f.read()}</style>', unsafe_allow_html=True)

@st.cache_resource
def connect_to_snowflake():
    session = Session.builder.configs(st.secrets.snowflake).create()
    return session

@st.cache_data
def get_data_from_snowflake(query=""):
    session = connect_to_snowflake()
    node_latest = session.sql(query).to_pandas()
    return node_latest

def plot_unique_users_trend(unique_users_data, width=2000, height=400):
    top_projects = sorted(unique_users_data, key=lambda k: sum(unique_users_data[k]), reverse=True)[:10]
    months = pd.date_range(start=datetime.now() - timedelta(days=365), periods=12, freq='M').strftime('%Y-%m').tolist()
    fig = go.Figure()
    for i, project in enumerate(top_projects):
        fig.add_trace(go.Scatter(
            x=months,
            y=unique_users_data[project],
            mode='lines+markers',
            name=project,
            line=dict(width=2),
            opacity=0.6,
            hoverinfo='x+y+name',
            hovertemplate='<b>Date</b>: %{x}<br><b>Users</b>: %{y}<extra></extra>',
            showlegend=True,
            visible='legendonly'
        ))
    median_values = np.median([unique_users_data[project] for project in top_projects], axis=0)
    fig.add_trace(go.Scatter(
        x=months,
        y=median_values,
        mode='lines+markers',
        name='Median',
        line=dict(color='black', width=4),
        hoverinfo='x+y+name',
        hovertemplate='<b>Date</b>: %{x}<br><b>Users</b>: %{y}<extra></extra>',
        visible=True
    ))
    fig.update_layout(
        xaxis_title="Month",
        yaxis_title="Unique Users",
        title="Monthly Unique Users Trend (Click a Project to see more trends)",
        width=width, height=height
    )
    return fig

def plot_download_sizes(download_sizes, project_sizes, width=2000):
    st.dataframe(download_sizes)
    download_sizes_df = download_sizes#pd.DataFrame(list(download_sizes.items()), columns=['project_id', 'total_downloads'])
    download_sizes_df['TOTAL_DOWNLOADS'] = download_sizes_df['PROJECT_ID'].map(project_sizes)
    download_sizes_df = download_sizes_df.sort_values(by='TOTAL_DOWNLOADS')
    st.dataframe(download_sizes_df)
    fig = go.Figure(data=[go.Bar(
        x=download_sizes_df['PROJECT_ID'],
        y=download_sizes_df['TOTAL_DOWNLOADS'],
        marker=dict(
            color=download_sizes_df['TOTAL_DOWNLOADS'],
            colorscale='Reds',
            colorbar=dict(title='Project Size (GB)')
        ),
        hovertemplate='<b>Project Name:</b> %{x}<br>' +
                      '<b>Download Size:</b> %{y} GB<br>' +
                      '<b>Project Size:</b> %{marker.color:.2f} GB<extra></extra>'
    )])
    fig.update_layout(
        xaxis_title="Project Name",
        yaxis_title="Download Size (GB)",
        title="Download Size from Unique User Downloads (Ordered)",
        width=width
    )
    return fig

def plot_popular_entities(popular_entities):
    popular_entities_df = pd.DataFrame(list(popular_entities.items()), columns=['Entity Type', 'Details'])
    popular_entities_df['Entity Name'] = popular_entities_df['Details'].apply(lambda x: x[0])
    popular_entities_df['Unique Users'] = popular_entities_df['Details'].apply(lambda x: x[1])
    popular_entities_df = popular_entities_df.drop(columns=['Details'])
    return popular_entities_df

def plot_entity_distribution(entity_distribution):
    entity_df = pd.DataFrame(list(entity_distribution.items()), columns=['Entity Type', 'Count'])
    fig = px.pie(entity_df, names='Entity Type', values='Count', title='Entity Distribution')
    fig.update_layout(
        margin=dict(t=0, b=0, l=0, r=0),
        title=dict(text='Entity Distribution', x=0.5)
    )
    return fig

def plot_user_downloads_map(locations, width=10000):
    locations_df = pd.DataFrame.from_dict(locations, orient='index')
    locations_df.reset_index(inplace=True)
    locations_df.columns = ['Region', 'Latitude', 'Longitude', 'Most Popular Project']
    fig = px.scatter_geo(
        locations_df,
        lat='Latitude',
        lon='Longitude',
        text='Region',
        hover_name='Region',
        hover_data={'Latitude': False, 'Longitude': False, 'Most Popular Project': True},
        size_max=10,
        color=locations_df['Most Popular Project'],
        color_continuous_scale=px.colors.sequential.Plasma
    )
    fig.update_geos(
        showland=True, landcolor="rgb(217, 217, 217)",
        showocean=True, oceancolor="LightBlue",
        showcountries=True, countrycolor="Black",
        showcoastlines=True, coastlinecolor="Black"
    )
    fig.update_layout(
        title='User Downloads by Region',
        geo=dict(
            scope='world',
            projection=go.layout.geo.Projection(type='natural earth')
        ),
        width=width,
        margin={"r":0,"t":0,"l":0,"b":0}
    )
    return fig

def main():

    
    # Retrieve and prepare the data

    entity_distribution_df = get_data_from_snowflake(query_entity_distribution)
    entity_distribution = dict(
        entity_type=list(entity_distribution_df['NODE_TYPE']),
        percent_of_total=list(entity_distribution_df['PERCENTAGE_OF_TOTAL'])
    )

    project_sizes_df = get_data_from_snowflake(query_project_sizes)
    project_sizes = dict(project_id=list(project_sizes_df['PROJECT_ID']), total_content_size=list(project_sizes_df['TOTAL_CONTENT_SIZE']))
    total_data_size = round(sum(project_sizes['total_content_size']) / (1024 * 1024 * 1024), 2)
    average_project_size = round(np.mean(project_sizes['total_content_size']) / (1024 * 1024 * 1024), 2)

    project_downloads_df = get_data_from_snowflake(query_project_downloads)
    #project_downloads = dict(project_id=list(project_downloads_df['PROJECT_ID']), total_downloads=list(project_downloads_df['TOTAL_DOWNLOADS']))

    # Row 1 -------------------------------------------------------------------
    st.markdown('### Monthly Overview :calendar:')
    col1, col2, col3 = st.columns([1, 1, 1])
    col1.metric("Total Storage Occupied", f"{total_data_size} GB", "7.2 GB")
    col2.metric("Avg. Project Size", f"{average_project_size} GB", "8.0 GB")
    col3.metric("Annual Cost", "102,000 USD", "10,000 USD")

    # # Row 2 -------------------------------------------------------------------
    st.markdown("### Unique Users Report :bar_chart:")
    # st.plotly_chart(plot_unique_users_trend(unique_users_data))

    # Row 3 -------------------------------------------------------------------
    st.plotly_chart(plot_download_sizes(project_downloads_df, project_sizes))

    # Row 4 -------------------------------------------------------------------
    st.markdown("### Entity Trends :pencil:")
    col1, col2 = st.columns(2)
    with col1:
        st.markdown('<div class="element-container">', unsafe_allow_html=True)
        #st.dataframe(plot_popular_entities(popular_entities))
    with col2:
        st.dataframe(entity_distribution)

    # # Row 5 -------------------------------------------------------------------
    # st.markdown("### Interactive Map of User Downloads :earth_africa:")
    # st.plotly_chart(plot_user_downloads_map(locations))

if __name__ == "__main__":
    main()