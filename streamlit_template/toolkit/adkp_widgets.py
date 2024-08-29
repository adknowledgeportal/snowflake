import pandas as pd
import plotly.graph_objects as go
from datetime import date


def plot_unique_users(unique_users_df, width=1800, height=600):

    # group by STUDY and MONTH, sum NUMBER OF UNIQUE USERS
    grouped_df = (
    unique_users_df.groupby(["STUDY", "MONTH"])["NUMBER_OF_UNIQUE_USERS"]
    .sum()
    .reset_index()
    )

    grouped_df["MONTH"] = pd.to_datetime(grouped_df["MONTH"])

    # Sort studies by most unique users for current month
    current_month = date.today().strftime(f"%Y-%m-01")
    recent_top_studies = (
        grouped_df.loc[grouped_df["MONTH"] == current_month]
        .sort_values(by="NUMBER_OF_UNIQUE_USERS", ascending=False)
        .head(20)
        )

    # Construct the plotly object
    fig = go.Figure()
    for study in recent_top_studies["STUDY"]:
    
        # Extract data for current study
        filtered_df = unique_users_df[unique_users_df["STUDY"] == study]
        months = pd.to_datetime(filtered_df["MONTH"])
        counts = filtered_df["NUMBER_OF_UNIQUE_USERS"]

        # Scatter plot for the current project
        fig.add_trace(
            go.Scatter(
                x=months,
                y=list(counts),
                mode="lines+markers",
                name=study,
                line=dict(width=2),
                opacity=0.6,
                hoverinfo="x+y+name",
                hovertemplate= "<b>Date</b>: %{x}<br>" + "<b>Users</b>: %{y}<extra></extra>",
                showlegend=True,
                visible="legendonly"
            )
        )

    # Calculate monthly total for all studies
    total_monthly_counts = (
        unique_users_df.groupby("MONTH")["NUMBER_OF_UNIQUE_USERS"]
        .sum()
        .reset_index()
        )

    total_monthly_counts["MONTH"] = pd.to_datetime(total_monthly_counts["MONTH"])

    # Add monthly totals to plot as default
    fig.add_trace(
        go.Scatter(
            x=total_monthly_counts["MONTH"],
            y=total_monthly_counts["NUMBER_OF_UNIQUE_USERS"],
            mode="lines+markers",
            name="All Studies",
            line=dict(color="purple", width=4),
            hoverinfo="x+y+name",
            hovertemplate="<b>Date</b>: %{x}<br><b>Users</b>: %{y}<extra></extra>",
            visible=True,
            showlegend=True
        )
    )

    fig.update_layout(
        xaxis_title="Month",
        yaxis_title="Unique Users",
        title="Monthly Unique AD Portal Users (Click a Study to see details)",
        legend=dict(title="Studies", orientation="v"),
        width=width,
        height=height
    )
    return fig