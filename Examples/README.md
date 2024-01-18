# Tickdata
Experiment file \<date>.txt
\<pos> is either the position of a turtle or of a patch. It has the information [\<abs x> \<abs y> <floor number> <platform number> <floor x> <floor y>]

Header
```
who,tick,xcor-init-pos,ycor-init-pos,floor-id-init-pos,platform-init-pos,floor-x-init-pos,floor-y-init-pos,floor-transition,xcor-final-pos,ycor-final-pos,floor-id-final-pos,platform--final-pos,floor-x-final-pos,floor-y-final-pos,heading,crowdness-0.8,crowdness-1,crowdness-1.2,crowdness-1.4
```
\<number of passengers> lines
p-tick-data following header format:   

# Metadata
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
[<starting pos> <source name: (<type> <id>)> <source pos> <destination name: (<type> <id>)> <destination pos> <destination patch pos> <passenger meta path (path of paths)>]
```

p-end-data:
```
```

Experiment file \<date>_tickdata.txt
See header