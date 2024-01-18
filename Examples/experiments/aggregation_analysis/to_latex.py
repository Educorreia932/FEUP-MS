import pandas as pd
import os

files = os.listdir("./")
files = [file for file in files if file.endswith(".csv")]

for file in files:
    df = pd.read_csv(file, index_col=0)
    df = df.style.format("{:.2f}")
    basename = os.path.splitext(file)[0]
    df.to_latex(f"{basename}.tex", encoding="utf-8")


    
