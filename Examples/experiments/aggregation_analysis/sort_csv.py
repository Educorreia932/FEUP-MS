import pandas as pd
import os

files = os.listdir("./")
files = [file for file in files if file.endswith(".csv")]

for file in files:
    df = pd.read_csv(file, index_col=0)
    basename = os.path.splitext(file)[0]

    # Sort index alphabetically
    df = df.sort_index()
    # to csv
    df.to_csv(f"{basename}.csv")
    # to latex
    df.to_latex(f"{basename}.tex")


    
