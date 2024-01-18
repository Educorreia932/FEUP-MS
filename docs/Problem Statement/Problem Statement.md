The simulation project will attempt to draw conclusions out of the simulation of different boarding and disembarking scenarios in a multimodal transit station.

# Brief description of the problem to be modelled

Rush hour embarking and debarkings at a transit platform can cause the intersection of large masses of people, making it harder for ease movement and arriving at the destination.
A good design of a multimodal transit station might help to attenuate this problem, bringing improvements in metrics such as mean average time to changing lines, and, more subjectively, stress induced in passengers.

# Goals of the simulation project

Explore design alternatives of an idealized or specific multimodal transit station that affect passenger movement. For a specific real life station, alternatives should focus on minimal changes (to minimize alterations costs) that still bring improvements.

# Main entities of the system:

Passengers are the main entities.
Multiple type of passengers can be idealized. 
Optionally, there could be passengers that have limited information of where they need to go.
Passengers have determined origins and destinations. The location of these points of interest might vary in the same scenario, or not, to account for transports arrival at the stop not always being the same

# Variables of the system

**Points of interest:** Generate and receive passengers and act as origins and destinations. 
**Signaling (optional):** Indications of where points of interest are.

# Operation policies to be tested (scenarios):

Restricted access to some routes between points of interest
Place of points of interest (represent different transports arriving at a different place, which is possible to implement and might still draw benefits)
Points of interest having a slight variation, to account for some random behavior of transports.
Agents with partial of full information
	Information on the location point of interest to go to
	Information on points of interest "crowdedness"

# Key performance indicators and decision criteria:

Obtain mean and squared error:
	- Per route and globally:
		- Time of travel
		- Time debark to embark
		- Distance traveled

# Data requirements:

- Start and end time for each passenger 
- Points of interest location, input and output of passengers
- Possible time for hitting a checkpoint in the route (e.g. a central place in the station)

# Simulation tools, environments, languages:

- Netlogo

# Related projects:

- [Plaça de Catalunya Pedestrian Simulation Project](https://blog.virtuosity.com/catalunya-station-gets-legion-pedestrian-simulation)
- [Predicting Pedestrian Flow: A Methodology and a Proof of Concept Based on Real-Life Data](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0083355)