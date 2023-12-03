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