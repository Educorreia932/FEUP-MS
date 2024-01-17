Experiment file \<date>.txt
\<pos> is either the position of a turtle or of a patch. It has the information [\<abs x> \<abs y> <floor number> <platform number> <floor x> <floor y>]

```
[<number of floors> <floor-width> <floor-height> <number of platforms> <number of passengers> <number of trains> <number of portals>]
[]
[]
```
\<number of passengers> lines
p-init-data:   
```
[<passenger pos> <source turtle> <pos of patch of source turtle> <destination turtle> <pos of patch of destination turtle> <pos of destination patch>]
```  
p-tick-data:  
```
[ [<turtle pos> <optional: turtle pos after portal>] heading [<passengers in radius for each radii in LOG-CROWDNESS-RADII]]
```  
p-end-data: 
```
[]
```
\<number of accesses (connections between platforms) lines>
```
[<type of access (STAIR or ESCALATOR)> <cost of access> <pos of end 1 of access> <pos of end 2 of access>]
```
\<number of spawners lines>
```
[<spawner name: <type> <id>> <turtle type: POI> <spawner radius>]
```



Experimen file \<date>_metadata.txt
init data:
```
[<number of floors> <floor-width> <floor-height> <number of platforms> <number of passengers> <number of trains> <number of portals>]
```
tick data:
```
[]
```

end data:
```
[]
```
\number of passengers lines
p-init-data:

```

```

p-end-data:
```
[<starting pos> <source name: (<type> <id>)> <source pos> <destination name: (<type> <id>)> <destination pos> <destination patch pos> <passenger meta path (path of paths)>]
```

Experiment file \<date>_tickdata.txt
See header