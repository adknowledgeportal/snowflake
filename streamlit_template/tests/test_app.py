"""A suite of unit tests for the streamlit app in the base directory. We encourage
adding tests into this suite to ensure functionality within your streamlit app, particularly
for the components that allow users to interact with the app (buttons, dropdown menus, etc).

These tests were all written using Streamlit's AppTest class. See here for more details:
https://docs.streamlit.io/develop/api-reference/app-testing/st.testing.v1.apptest#run-an-apptest-script

A few considerations:

1. This suite is meant to be run from the base directory, not from the tests directory.
2. The streamlit app is meant to be run from the base directory.
3. The streamlit app is assumed to be called ``app.py``.
"""

import os
import sys

import pytest
from streamlit.testing.v1 import AppTest

# Ensure that the base directory is in PYTHONPATH so ``toolkit`` and other tools can be found
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

# The timeout limit to wait for the app to load before shutdown ( in seconds )
DEFAULT_TIMEOUT = 30


@pytest.fixture(scope="module")
def app():
    return AppTest.from_file(
        "adkp_app.py", default_timeout=DEFAULT_TIMEOUT
    ).run()


def test_monthly_overview(app):
    """
    Ensure that the Portal Summary section is being displayed
    with the appropriate labels in the right order.
    """

    # Access the Monthly Overview columns in Row 1
    total_files = app.columns[0].children[0]
    total_data_volume = app.columns[1].children[0]

    # Check that the labels are correct for each metric
    assert total_files.label == "Total Number of Files"
    assert total_data_volume.label == "Total Data Volume"


def test_plotly_charts(app):
    """Ensure both plotly charts are being displayed."""

    plotly_charts = app.get("plotly_chart")

    assert plotly_charts is not None
    assert len(plotly_charts) == 1


def test_dataframe(app):
    """Ensure that the dataframe is being displayed."""

    dataframe = app.dataframe
    assert dataframe is not None
    assert len(dataframe) == 1
