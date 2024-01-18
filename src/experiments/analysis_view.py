import os
import pandas as pd
AGGREGATION_ANALYSIS_FOLDER = "aggregation_analysis"
AGGREGATION_ANALYSIS_PREFIX = "analysis"

analyses = os.listdir(AGGREGATION_ANALYSIS_FOLDER)
analyses = [analysis for analysis in analyses if analysis.startswith(AGGREGATION_ANALYSIS_PREFIX) and analysis.endswith(".csv")]


# Load all analyses
for analysis in analyses:
    analysis_name = os.path.splitext(analysis)[0]

    analysis_df = pd.read_csv(f"{AGGREGATION_ANALYSIS_FOLDER}/{analysis}", index_col=0)

    print(analysis_name)
    print(analysis_df)
    print()
