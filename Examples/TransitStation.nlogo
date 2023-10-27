extensions [bitmap]

globals [
  FLOORS
  floor-width floor-height
  number-passengers number-pois left-to-spawn
  ; trains variables
  train-width train-height train-gap train-length

  ;patch colors
  COLOR-TRAIN-LINE COLOR-GROUND COLOR-WALL COLOR-BOUNDARY COLOR-PORTAL
  PCS-PLATFORM
  ;patch type pt
  PT-TRAIN-LINE PT-TRAIN PT-PLATFORM PT-WALL PT-BOUNDARY PT-PORTAL
  PTS-PATHABLE
  ;turtle type tt
  TT-POI TT-PORTAL
  TTS-PATHABLE

  ;pathing
  pathing INFINITY
]

;; breeds
breed [passengers passenger]
breed [pois poi]
breed [portals portal]
breed [trains train]
breed [train-cells train-cell]
breed [debugers debuger]

passengers-own [source destination spawned]
pois-own [to-spawn to-despawn empty ]
trains-own [is-a-poi direction-vector]
portals-own [portal-id portal-connect-ids]
train-cells-own [belong-to-train]
turtles-own [
  tfloor-id tfloor-x tfloor-y
  tt poi-paths init-poi-paths
]
patches-own [
 pfloor-id pfloor-x pfloor-y
 pts pts-ids number-pt
 g-score h-score f-score parent ;a-star
]

;; links
undirected-link-breed [findables findable]
undirected-link-breed [accesses access]

links-own [link-type]

to load
  let img bitmap:import "3_platforms_2_floors_station.png"
  resize-world 0 (bitmap:width img - 1) 0 (bitmap:height img - 1)
  set floor-width (world-width - FLOORS - 1 ) / FLOORS
  set floor-height world-height - 2 ; top and bottom edges
  print (list "height" floor-height "width" floor-width)
  bitmap:copy-to-pcolors img false
end

to init-basics
  ask patches [
    set pts []
    set pts-ids []
    set number-pt 0
  ]

  ct
  ask turtles [die]

  clear-links
end

to init-floors
  let floor-index 0
  let height-index 0
  let width-index 0
  let floor-x-index 0
  let floor-y-index 0
  repeat FLOORS [
    set height-index 1
    set floor-y-index 0
    repeat floor-height [
      set width-index 1 + (1 + floor-width) * floor-index
      set floor-x-index 0
      repeat floor-width [
         ask patch width-index height-index [
         set pfloor-id floor-index
          set pfloor-x floor-x-index
          set pfloor-y floor-y-index
        ]
        set width-index width-index + 1
        set floor-x-index floor-x-index + 1
      ]
      set height-index height-index + 1
      set floor-y-index floor-y-index + 1
    ]
   set floor-index floor-index + 1
  ]
end

to init-platforms
  let platform-id 0
  let non-instantiated-platform one-of patches with [member? pcolor PCS-PLATFORM and not member? PT-PLATFORM pts]
  while [non-instantiated-platform != nobody][
   print "new-platform"
   ask non-instantiated-platform [
      set pts lput PT-PLATFORM pts
      set pts-ids lput platform-id pts-ids
      flood-multizone PT-PLATFORM platform-id PCS-PLATFORM
    ]
   set non-instantiated-platform one-of patches with [member? pcolor PCS-PLATFORM and not member? PT-PLATFORM pts]
   set platform-id platform-id + 1
  ]
end

; patch
to-report sprout-portal
  let sprouted-portal 0
  let portal-pt-index position PT-PORTAL pts
  let pportal-index item portal-pt-index pts-ids
  sprout-portals 1 [
    ; portal
    set portal-id pportal-index
    set portal-connect-ids []

    ; turtle
    set color [80 0 80]
    set tfloor-id pfloor-id
    set tfloor-x pfloor-x
    set tfloor-y pfloor-y
    set poi-paths []
    set init-poi-paths false
    set shape "star"
   set sprouted-portal self
  ]
  report sprouted-portal
end

; turtle
to-report t-platform
  let platform-index position PT-PLATFORM [pts] of patch-here
  let platform-id item platform-index [pts-ids] of patch-here
  report platform-id
end


; observer
to init-portals
  let pportal-id 0
  let non-instantiated-portal one-of patches with [pcolor = COLOR-PORTAL and not member? PT-PORTAL pts]
  while [non-instantiated-portal != nobody] [
    print "portal"
    ask non-instantiated-portal [
      set pts lput PT-PORTAL pts
      set pts-ids lput pportal-id pts-ids
      flood-zone PT-PORTAL pportal-id COLOR-PORTAL
    ]
    set  non-instantiated-portal one-of patches with [pcolor = COLOR-PORTAL and not member? PT-PORTAL pts]
    set pportal-id pportal-id + 1
  ]

  ask patches with [member? PT-PORTAL pts][
      let sprouted-portal sprout-portal
  ]

  ask portals [
    create-accesses-with other portals with [

      tfloor-x = [tfloor-x] of myself
      and
      tfloor-y = [tfloor-y] of myself
    ]

    create-findables-with other portals with [
      t-platform = [t-platform] of myself
    ]
  ]


end

; observer
to init-lines
  let train-line-id 0
  let non-instantiated-train-line one-of patches with [pcolor = COLOR-TRAIN-LINE and not member? PT-TRAIN-LINE pts]
  while [non-instantiated-train-line != nobody] [
    ask non-instantiated-train-line [
      set pts lput PT-TRAIN-LINE pts
      set pts-ids lput train-line-id pts-ids
      flood-zone PT-TRAIN-LINE train-line-id COLOR-TRAIN-LINE
      init-rail
      ]
    set non-instantiated-train-line one-of patches with [pcolor = COLOR-TRAIN-LINE and not member? PT-TRAIN-LINE pts ]
    set train-line-id train-line-id + 1
  ]
end

; patch
to flood-multizone [flood-pt flood-pt-id flood-list-colors]
  let to-flood []
  set to-flood fput self to-flood
  while [length to-flood > 0] [
    let patch-to-flood first to-flood
    set to-flood remove-item 0 to-flood
    ask patch-to-flood [
      set number-pt number-pt + 1
      let new-to-flood other neighbors4 with [member? pcolor flood-list-colors and not member? flood-pt pts]
      ask new-to-flood [
        set pts lput flood-pt pts
        set pts-ids lput flood-pt-id pts-ids
        set to-flood fput self to-flood
        ]
      ]
    ]
end

; patch
to flood-zone [flood-pt flood-pt-id flood-color]
  let to-flood []
  set to-flood fput self to-flood
  while [length to-flood > 0] [
    let patch-to-flood first to-flood
    set to-flood remove-item 0 to-flood
    ask patch-to-flood [
      set number-pt number-pt + 1
      let new-to-flood other neighbors4 with [pcolor = flood-color and not member? flood-pt pts]
      ask new-to-flood [
        set pts lput flood-pt pts
        set pts-ids lput flood-pt-id pts-ids
        set to-flood fput self to-flood
        ]
      ]
    ]
end

to-report get-last [a-patch patch-pt direction]
  let vec_x item 0 direction
  let vec_y item 1 direction
  let x 0
  let y 0


  let checking-ground patch-at x y
  while [is-patch? checking-ground and (member? patch-pt [pts] of checking-ground)] [
    set x x + vec_x
    set y y + vec_y
    set checking-ground patch-at x y

  ]

   set x x - vec_x
   set y y - vec_y
   set checking-ground patch-at x y
   report checking-ground
end

to-report get-last-before-ground [a-patch patch-pt direction]
  let vec_x item 0 direction
  let vec_y item 1 direction
  let x 0
  let y 0


  let checking-ground patch-at x y
  while [is-patch? checking-ground and member? patch-pt [pts] of checking-ground] [
    set x x + vec_x
    set y y + vec_y
    set checking-ground patch-at x y

  ]

  if is-patch? checking-ground [
    if [pcolor] of checking-ground = COLOR-GROUND [
     set x x - vec_x
     set y y - vec_y
     set checking-ground patch-at x y
    report checking-ground

    ]
  ]
  report nobody
end

to init-rail
  let directions [[0 1] [0 -1] [1 0] [-1 0]]
  foreach directions [
    let direction first directions
    set directions remove-item 0 directions
    let checking-ground get-last-before-ground self PT-TRAIN-LINE direction
    if checking-ground != nobody[
    ask checking-ground [
     let carriage-direction-vector rotate-vector-clock direction
     let carriage-head get-last checking-ground PT-TRAIN-LINE carriage-direction-vector
      ask carriage-head [
       set pcolor pink
        init-train carriage-direction-vector
      ]
      ]
    stop
    ]
  ]

end

to-report rotate-vector-clock [vector]
  let new-x item 1 vector * 1
  let new-y item 0 vector * -1
  report list new-x new-y
end

to-report rotate-vector-counterclock [vector]
  let new-x item 1 vector * -1
  let new-y item 0 vector * 1
  report list new-x new-y
end

to-report symmetric-vector [vector]
  let new-x -1 * item 0 vector
  let new-y -1 * item 1 vector
  report list new-x new-y
end

;observer
to-report from-to-vector [p1 p2]
  let x [pxcor] of p2 - [pxcor] of p1
  let y [pycor] of p2 - [pycor] of p1
  report list x y
end

to-report vector-direction [vector]
  report atan item 1 vector item 0 vector

end
;patch
to-report is-train-line-pt?
 report member? PT-TRAIN-LINE pts
 end

; patch
to-report sprout-train [heading-vector]
  show "SProuting"
  let sprouted-train ""
  sprout-trains 1 [
    ; train
    set direction-vector heading-vector
    set is-a-poi true

    ; turtle
    set color [133 133 133]
    facexy xcor + item 0 heading-vector ycor + item 1 heading-vector
    set tfloor-id pfloor-id
    set tfloor-x pfloor-x
    set tfloor-y pfloor-y
    set tt TT-POI
    set poi-paths []
    set init-poi-paths false
    set sprouted-train self
  ]
  report sprouted-train
end

to init-train [heading-vector]
  let inited-train sprout-train heading-vector

  let heading_x item 0 heading-vector
  let heading_y item 1 heading-vector
  let outward-vector rotate-vector-clock heading-vector
  let outward_x item 0 outward-vector
  let outward_y item 1 outward-vector
  let inward-vector symmetric-vector outward-vector
  let length-index 0
  let height-index 0
  let width-index 0
  let x 0
  let y 0
  while [length-index < train-length] [
    set height-index 0
    while [height-index < train-height][
      set width-index 0
      while [width-index < train-width] [
        let train-patch patch-at x y
        ask train-patch [
          if is-train-line-pt? [
            sprout-train-cells 1 [
              set color red
              set shape "circle"
              set belong-to-train inited-train
            ]
            set pts lput PT-TRAIN pts
            set pts-ids lput 0 pts-ids
          ]
        ]
        set x x + outward_x
        set y y + outward_y
        set width-index width-index + 1
      ]
      set x x - width-index * outward_x
      set y y - width-index * outward_y

      set x x - heading_x
      set y y - heading_y
      set height-index height-index + 1
    ]
    set x x - heading_x * train-gap
    set y y - heading_y * train-gap
    set length-index length-index + 1
  ]
end


to init-path-finding
  let path-found-turtles []
  let poi-turtles turtles with [tt = TT-POI]
  let poi-turtles-with-no-paths poi-turtles with [init-poi-paths = false]

  while [count poi-turtles-with-no-paths > 0 ][
     ask one-of poi-turtles-with-no-paths[
      let left-to-pathfind-to [self] of other poi-turtles-with-no-paths
      let index 0
      foreach left-to-pathfind-to [
       let path pathfind item index left-to-pathfind-to
       set poi-paths lput path poi-paths
       set index index + 1
      ]
      set init-poi-paths true
    ]
      set poi-turtles-with-no-paths poi-turtles with [init-poi-paths = false]
  ]

end

to-report adjacent [p1 p2]
  let p1-neighbors []
  ask p1 [
    set p1-neighbors neighbors
  ]
  report member? p2 p1-neighbors
end

; patch
to-report h-distance [destination-patch]
  report distance destination-patch
end

;patch
to-report is-pathable
  report not empty? filter [i -> member? i PTS-PATHABLE] pts
end

;patch
to-report backtrace-path [goal-vertex]
  let path []
  let current-vertex goal-vertex
  while [current-vertex != 0] [
    set path fput current-vertex path
    set current-vertex [parent] of current-vertex
  ]
  report path
end

; turtle
to-report pathfind [pathfind-to]
  ask debugers [die]
  let start-vertex patch-here
  let goal-vertex [patch-here] of pathfind-to
  ask patches with [is-pathable] [
    set g-score infinity
    set h-score h-distance goal-vertex
    set f-score (g-score + h-score)
    set parent 0
  ]

  let open-set (list start-vertex)
  let closed-set []
  ask start-vertex [
    set g-score 0
    set f-score h-score
  ]

  while [length open-set > 0 ] [
    let current-vertex first sort-by[[t1 t2] -> [f-score] of t1 < [f-score] of t2] open-set

    ask current-vertex [sprout-debugers 1 [set color black]]
    if current-vertex = goal-vertex [ ; Goal reached
      let path backtrace-path goal-vertex
      report path
    ]

    set open-set (remove current-vertex open-set)
    set closed-set lput current-vertex closed-set

    ask current-vertex [

      let pathable-neighbors neighbors with [
        is-pathable
      ]
      ask pathable-neighbors[
        if not member? self closed-set [
          let tentative-g [g-score] of current-vertex + distance current-vertex
          if not member? self open-set or tentative-g < g-score [
            set g-score tentative-g
            set f-score h-score + g-score
            set parent current-vertex
            if not member? self open-set [
              set open-set lput self open-set
            ]
          ]
        ]
      ]
    ]
  ]
  report []
end


; observer
to init-normalized-paths
  let poi-turtles turtles with [tt = TT-POI]
  ask poi-turtles [
    show ""
    let new-poi-paths []
    foreach poi-paths [
      poi-path ->
      let new-path normalize-path poi-path
      set new-poi-paths lput new-path new-poi-paths
    ]
    set poi-paths new-poi-paths
  ]
end

; observer
to-report normalize-path [path]
  if length path < 3 [
   report path
  ]
  let prev-patch item 0 path
  let new-path (list prev-patch)
  let cur-patch item 1 path
  let prev-vector from-to-vector prev-patch cur-patch
  let prev-direction vector-direction prev-vector

  let next-vector []
  let next-patch nobody

  let useful-path sublist path 2 length path
  let index-useful-path 0
  foreach useful-path[
    set next-patch item index-useful-path useful-path
    set next-vector from-to-vector cur-patch next-patch
    let is-adjacent adjacent cur-patch next-patch
    let next-direction vector-direction next-vector
    let is-same-direction prev-direction = next-direction
    ifelse is-adjacent and is-same-direction [
        ; Normalize the path
        set  next-vector from-to-vector prev-patch cur-patch
      ]
    [
      ; Add to path
      set new-path lput cur-patch new-path
      set prev-direction from-to-vector cur-patch next-patch
    ]


    set index-useful-path index-useful-path + 1
    set cur-patch next-patch

  ]
  set new-path lput last useful-path new-path
  report new-path

end

to setup-configs
 set FLOORS 2
end

to setup-constants


  ;instantiate globals
  set number-passengers 5
  set number-pois 2

  set train-width 3
  set train-height 5
  set train-gap 2
  set train-length 2
  set COLOR-TRAIN-LINE [0 0 255]
;  set COLOR-TRAIN-LINE [0 255 0]
  set COLOR-GROUND [255 255 255]
  set COLOR-WALL [0 0 0]
  set COLOR-BOUNDARY [245 0 255]
  set COLOR-PORTAL [255 255 0]

  set PCS-PLATFORM (list COLOR-GROUND COLOR-PORTAL)

  set PT-TRAIN-LINE "TRAIN_LINE"
  set PT-TRAIN "TRAIN"
  set PT-PLATFORM "GROUND"
  set PT-WALL "WALL"
  set PT-BOUNDARY "BOUNDARY"
  set PT-PORTAL "PORTAL"

  set PTS-PATHABLE (list PT-PLATFORM PT-TRAIN PT-PORTAL)

  set TT-POI "POI"
  set TT-PORTAL "PORTAL"

  set TTS-PATHABLE (list "POI" "PORTAL")

  set INFINITY 999999
end

to setup-static
  setup-configs
  setup-constants
  load
end


to setup-data
  init-basics
  init-floors
  init-platforms
  init-portals
  init-lines
  init-path-finding
  init-normalized-paths
end

to setup-run
;  set left-to-spawn number-passengers
;  init-pois
;  init-passengers
  reset-ticks
end

to setup
  ca
  setup-static
  setup-data
  setup-run
end

to init-pois
  let poi-index 0
  repeat number-pois [
    print poi-index
    let side poi-index mod 2
    create-a-poi-in-side side
    set poi-index poi-index + 1
  ]
end

to create-a-poi-in-side [side]
  let x min-pxcor ; default left side
  if side = 1
  [
   set x max-pxcor
  ]
  create-a-poi x random-ycor
end
to create-a-poi [x y]
  create-pois 1 [
  set empty true
    set to-spawn []
    set to-despawn []
   setxy x y
   set shape "square"
   set color red
  ]
end

to init-passengers

  repeat number-passengers [
    let to-be-source one-of pois
    let to-be-destination one-of pois with [self != to-be-source]

    create-passengers 1 [
     set source to-be-source
     set destination to-be-destination
     set spawned false
     set color pink
     setxy [xcor] of source  [ycor] of source
    ]

  ]
    ask pois [
      set to-spawn passengers with [source = myself]
      set to-despawn passengers with [destination = myself]
    ]
end


to spawn-passenger
  set spawned true
  show "spawned"
end

to spawn-passengers
  if left-to-spawn = 0 [
    stop
  ]

  ask pois [
    ; TODO
    show list "passengers here:" passengers-here
    ifelse any? passengers-here with [spawned = true] [
      print list "self" self

    ]
    [
      if any? to-spawn with [spawned = false][
        print list "to be spanwed" passengers-here with [spawned = false]
        ask one-of to-spawn [
          spawn-passenger
        ]
        print "exiting pois"
      ]
    ]

  ]
  ;let passengers-to-spawn passengers with [spawned = false]
  ;print list "length" count passengers-to-spawn
  ;ask passengers-to-spawn [
  ;  ask source [
  ;   ifelse empty [
  ;       show "is empty"
  ;       set empty false
  ;     ]
  ;     [
  ;       show "is full"
  ;    ]
  ;  ]
  ; ]
end


to go
  print "tick"
  spawn-passengers
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
299
15
954
352
-1
-1
10.27
1
10
1
1
1
0
0
0
1
0
62
0
31
0
0
1
ticks
30.0

BUTTON
11
34
74
67
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
72
492
135
525
tick
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
126
129
189
162
load
load
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
83
350
160
383
init-lines
init-lines
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
29
455
115
488
NIL
setup-run
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
59
89
156
122
NIL
setup-static
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
84
386
203
419
NIL
init-path-finding\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
53
164
146
197
NIL
setup-data\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
82
422
229
455
NIL
init-normalized-paths
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
83
240
166
273
NIL
init-floors
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
81
279
185
312
NIL
init-platforms\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
86
200
182
233
NIL
init-basics\n\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
80
317
170
350
NIL
init-portals\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
