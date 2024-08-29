import streamlit as st
from toolkit.adkp_queries import (
    query_project_summary,
    query_monthly_downloads_per_study
)
from toolkit.utils import get_data_from_snowflake
from toolkit.adkp_widgets import plot_unique_users

# Configure the layout of the Streamlit app page
st.set_page_config(
    layout="wide",
    page_title="AD Knowledge Portal Data Usage Report",
    page_icon=":brain:"
    #initial_sidebar_state="expanded"
    )

# Custom CSS for styling
with open("style.css") as f:
    st.markdown(f"<style>{f.read()}</style>", unsafe_allow_html=True)


def main():

    # 1. Retrieve the data using queries in adkp_queries.py
    project_summary_df = get_data_from_snowflake(query_project_summary())
    unique_users_df = get_data_from_snowflake(query_monthly_downloads_per_study)


    # 2. Transform the data as needed
    total_files = project_summary_df.loc[0,'TOTAL_FILES']
    total_data_volume = project_summary_df.loc[0, 'TOTAL_SIZE_IN_TB']

    # 3. Format the app, and visualize the data with your widgets in widgets.py
    # -------------------------------------------------------------------------
    # Row 1 -------------------------------------------------------------------
    st.markdown("## AD Knowledge Portal Data Usage Report :brain: :barchart:")
    st.markdown("### Portal Summary")
    col1, col2 = st.columns([1, 1])
    col1.metric("Total Number of Files", f"{total_files}")
    col2.metric("Total Data Volume", f"{total_data_volume} TB")

    # Row 2 -----------------------------------------------------------------
    st.markdown("### Monthly Unique Users")
    st.markdown("Use the figure below to see the total monthly unique users who have downloaded data from the AD Knowledge Portal. You can select a study from the plot legend to see unique monthly users for that study.")
    st.plotly_chart(plot_unique_users(unique_users_df))


if __name__ == "__main__":
    main()