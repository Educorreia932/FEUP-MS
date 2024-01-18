import pandas as pd
import math
import numpy as np
import re
import argparse
import os

AGGREGATION_ANALYSIS_FOLDER = "aggregation_analysis"
AGGREGATION_ANALYSIS_PREFIX = "analysis"
def parse_arguments():
    parser = argparse.ArgumentParser(description='Analyse experiment data')
    parser.add_argument("--overwrite", action="store_true", help="Overwrite existing files")
    args = parser.parse_args()
    return args.overwrite

def main(overwrite: bool):
    
    filenames = ["trindade", "trindade-no-elevators", "trindade-long-trains", "trindade-single-stairs", "trindade-300", "trindade-no-elevators-300", "trindade-long-trains-300", "trindade-single-stairs-300", "trindade-escalators", "trindade-escalators-300"]
    for filename in filenames:

        stats =  analyse_experiment(filename, overwrite)

def distance_calc(x_init_pos, y_init_pos, x_final_pos, y_final_pos):
    distance = math.sqrt(((x_init_pos-x_final_pos)**2)+((y_init_pos-y_final_pos)**2))
    return distance

def analyse_experiment(experiment_name, overwrite):
    data_file = experiment_name + '_tickdata.txt'
    metadata_file = experiment_name + '_metadata.txt'
    analysis_filename = experiment_name + '_analysis.txt'

    if os.path.exists(analysis_filename) and not overwrite:
        print("Analysis already exists, skipping: " + experiment_name)
        return
    
    ###### Read meta
    with open(metadata_file) as f:
        content = f.readlines()
    world_init_metadata_line = content[0]
    # Regex numbers separated by spaces inside of [ ]
    world_init_metadata = re.findall(r'\[(.*?)\]', world_init_metadata_line)
    world_init_metadata_numbers = [float(x) for x in world_init_metadata[0].split(' ')]
    floors, floor_width, floor_height, platforms, passengers, trains, portals = world_init_metadata_numbers

    passengers_start_line_index = 3
    passengers_end_line_index = passengers_start_line_index + int(passengers)*2
    passengers_init_data = content[passengers_start_line_index:passengers_end_line_index:2]
    passengers_end_data = content[passengers_start_line_index+1:passengers_end_line_index:2]

    # Get the data from the following line
    # Define regular expressions to extract information
    pos_pattern = r'\[([\d.]+) ([\d.]+) (\d+) (\d+) (\d+) (\d+)\]'
    source_dest_pattern = r'\((\w+) (\d+)\)'
    path_pattern = r'\[([^\]]+)\]'

    # Extract position information
    for line in passengers_init_data:
        positions = re.findall(pos_pattern, line)

        # Extract source and destination information
        source_match = re.search(source_dest_pattern, line)
        destination_match = re.search(source_dest_pattern, line[source_match.end():])
        source = (source_match.group(1), int(source_match.group(2)))
        destination = (destination_match.group(1), int(destination_match.group(2)))

        # Extract destination patch positions
        patch_match = re.search(path_pattern, line[destination_match.end():])
        destination_patch_pos = re.findall(pos_pattern, patch_match.group(1))

    ######
        
    ###### Read tickdata
    df = pd.read_csv(data_file)   
    # Filter df
    # df = df[df['who'] == df['who'].min()]

    df['distance'] = np.nan
    turtles_df = df.groupby('who')

    one_turtle = list(turtles_df.groups.keys())[0]
    one_turtle_df = turtles_df.get_group(one_turtle)
    one_turtle_df

    for turtle, turtle_df in turtles_df:
        # Ensure sort by tick
        turtle_df = turtle_df.sort_values('tick', ascending=True)
        prev_x = None
        prev_y = None
        prev_distance = None
        first = True
        prev_transition = False
        for i, row in turtle_df.iterrows():
            if first:
                
                distance = 0
                tick_distance = 0
                first = False
                x2 = row['xcor-init-pos']
                y2 = row['ycor-init-pos']
            else:
                x1 = prev_x
                y1 = prev_y
                d1 = prev_distance
                x2 = row['xcor-init-pos']
                y2 = row['ycor-init-pos']
                
                            
                delta_d = distance_calc(x1, y1, x2, y2)
                distance = d1 + delta_d
                tick_distance = delta_d
                if row['floor-transition'] != "none":
                    x2 = row['xcor-final-pos']
                    y2 = row['ycor-final-pos']
                
                
            prev_x = x2
            prev_y = y2
            prev_distance = distance
            # turtles_df.loc[turtle].loc[i, 'distance'] = distance
            df.loc[i, 'distance'] = distance
            df.loc[i, 'tick_distance'] = tick_distance


    maximum_distances = df.loc[df.groupby('who')['tick'].idxmax()][['who', 'distance', 'tick']]
    print(type(maximum_distances))
    print(maximum_distances.head(10))

    distance_stats = maximum_distances['distance'].describe()
    print("Distance Stats")
    print(distance_stats)
    tick_stats = maximum_distances['tick'].describe()
    print("Tick Stats")
    print(tick_stats)

    # Get rows sorted descending tick distance
    sorted_tick_distance = df.sort_values('tick_distance', ascending=False)
    print(sorted_tick_distance.head(102))

    # Get all tick distance but for rows where the tick is 0
    tick_distances = df.loc[df['tick'] > 0]['tick_distance']
    tick_distance_stats = tick_distances.describe()
    print("Tick Distance Stats")
    print(tick_distance_stats)

    # Crowdness stats
    crowdness_columns = [column for column in df.columns if 'crowdness' in column]
    # Describe crowdness columns
    crowdness_stats = df[crowdness_columns].describe()
    print("Crowdness Stats")
    print(crowdness_stats)
    print(crowdness_stats.to_json(indent=4))

    # Aggregate all stats
    df_stats = pd.DataFrame()
    df_stats['distance'] = distance_stats
    df_stats['tick'] = tick_stats
    df_stats['tick_distance'] = tick_distance_stats
    for column in crowdness_columns:
        df_stats[column] = crowdness_stats[column]

    df_stats = df_stats.transpose()
    with open(analysis_filename, 'w') as f:
        f.write(df_stats.to_csv())

    aggregate_analysis(experiment_name, df_stats)


def aggregate_analysis(experiment_name, stats):
    os.makedirs(AGGREGATION_ANALYSIS_FOLDER, exist_ok=True)
    for row_name in stats.index:
        stats_filename = f"{AGGREGATION_ANALYSIS_FOLDER}/{AGGREGATION_ANALYSIS_PREFIX}_{row_name}.csv"

        if os.path.exists(stats_filename):
            # Load existing stats
            aggregate_stats = pd.read_csv(stats_filename, index_col=0)
        else:
            aggregate_stats = pd.DataFrame(columns=stats.columns)
        
        # Add new stats row
        stats_row = stats.loc[row_name]
        aggregate_stats.loc[experiment_name] = stats_row
        
        
        

        # Save stats
        aggregate_stats.to_csv(stats_filename)

if __name__ == "__main__":
    
    overwrite = parse_arguments()
    overwrite = True
    main(overwrite)