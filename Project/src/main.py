import jupedsim as jps
import shapely
import pandas
import pathlib
import shapely.plotting
import matplotlib.pyplot as plt

geometry = shapely.Polygon( 
    # complete area
    [
        (3.5, -2),
        (3.5, 8),
        (-3.5, 8),
        (-3.5, -2),
    ],
    holes=[
        # left barrier
        [
            (-0.7, -1.1),
            (-0.25, -1.1),
            (-0.25, -0.15),
            (-0.4, 0.0),
            (-2.8, 0.0),
            (-2.8, 6.7),
            (-3.05, 6.7),
            (-3.05, -0.3),
            (-0.7, -0.3),
            (-0.7, -1.0),
        ],
        # right barrier
        [
            (0.25, -1.1),
            (0.7, -1.1),
            (0.7, -0.3),
            (3.05, -0.3),
            (3.05, 6.7),
            (2.8, 6.7),
            (2.8, 0.0),
            (0.4, 0.0),
            (0.25, -0.15),
            (0.25, -1.1),
        ],
    ],
)

exit_polygon = shapely.Polygon(
    [(-0.2, -1.9), (0.2, -1.9), (0.2, -1.7), (-0.2, -1.7)]
)

experiment_data = pandas.read_csv(
    "data/bottleneck/040_c_56_h-.txt",
    comment="#",
    sep="\t",
    header=None,
    names=["id", "frame", "x", "y", "z"],
)
start_positions = experiment_data[experiment_data.frame == 0][
    ["x", "y"]
].values

trajectory_file = "bottleneck_cfsm.sqlite"
simulation_cfsm = jps.Simulation(
    model=jps.CollisionFreeSpeedModel(),
    geometry=geometry,
    trajectory_writer=jps.SqliteTrajectoryWriter(
        output_file=pathlib.Path(trajectory_file)
    ),
)

shapely.plotting.plot_polygon(geometry)
shapely.plotting.plot_polygon(exit_polygon)

plt.show()