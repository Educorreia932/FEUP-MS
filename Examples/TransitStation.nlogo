__includes ["vector_utils.nls" "setup_static.nls" "pathing.nls" "breeds.nls" "intersects.nls" "setup_run.nls"]

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

; patch
to-report p-index
  report pxcor * world-height + pycor
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
  let non-instantiated-platform min-one-of patches with [member? pcolor PCS-PLATFORM and not member? PT-PLATFORM pts] [p-index]
  while [non-instantiated-platform != nobody][
    ask non-instantiated-platform [
      set pts lput PT-PLATFORM pts
      set pts-ids lput platform-id pts-ids
      flood-multizone PT-PLATFORM platform-id PCS-PLATFORM
    ]

    let platform-patches patches with [member? PT-PLATFORM PTS and p-platform = platform-id]
    let centroid get-centroid platform-patches
    ask centroid [
      sprout-platformers 1 [
        set p-p-id platform-id
        set color [ 0 255 0 ]
      ]

    ]

    set non-instantiated-platform min-one-of patches with [member? pcolor PCS-PLATFORM and not member? PT-PLATFORM pts][p-index]
    set platform-id platform-id + 1
  ]
  set PLATFORMS platform-id + 1
end

to init-grounds
  ask patches with [pcolor = COLOR-GROUND][
    set pts lput PT-GROUND PTS
    set pts-ids lput 0 pts-ids
  ]
end

; patch
to-report p-platform
  let platform-index position PT-PLATFORM pts
  let platform-id item platform-index pts-ids
  report platform-id
end

; turtle
to-report t-platform
  report [p-platform] of patch-here
end

; patch
to-report p-portal-id
  let portal-index position PT-PORTAL pts
  let portal-id-to-report item portal-index pts-ids
  report portal-id-to-report
end

to-report sprout-portal
  let sprouted-portal 0
  sprout-portals 1 [
    ; portal
    set portal-id p-portal-id
    set portal-connect-ids []

    ; turtle
    set tfloor-id pfloor-id
    set tfloor-x pfloor-x
    set tfloor-y pfloor-y
    set tt TT-PORTAL
    set poi-paths []
    set init-poi-paths false
    set shape "arrow"


    set sprouted-portal self
  ]
  report sprouted-portal
end

; patch
to-report sprout-portal-cell
  let sprouted-portal-cell 0
  let pportal-index p-portal-id
  sprout-portal-cells 1 [
    ; portal
    set portal-id pportal-index
    set belong-to-portal min-one-of portals with [portal-id = p-portal-id][[p-index] of patch-here]

    ; turtle
    set color [80 0 80]
    set tfloor-id pfloor-id
    set tfloor-x pfloor-x
    set tfloor-y pfloor-y
    set poi-paths []
    set init-poi-paths false
    set shape "star"
    set sprouted-portal-cell self
  ]
  report sprouted-portal-cell
end

; observer
to-report get-centroid [patches-set]

 let x-sum 0
 let y-sum 0

  ask patches-set [
    set x-sum x-sum + pxcor
    set y-sum y-sum + pycor
  ]

  let num-patches count patches-set
  let centroid-x x-sum / num-patches
  let centroid-y y-sum / num-patches
  let centroid min-one-of patches-set [distance patch centroid-x centroid-y]
  report centroid
end

; observer
to init-portal [portal-id-to-init]
  let portal-patches patches with [member? PT-PORTAL pts and p-portal-id = portal-id-to-init]
  let centroid-portal get-centroid portal-patches

  ask centroid-portal [
    let main-portal sprout-portal
    ask portal-patches [
      let _ sprout-portal-cell
    ]
  ]

end

; observer
to init-portals
  let pportal-id 0
  let non-instantiated-portal min-one-of patches with [pcolor = COLOR-PORTAL and not member? PT-PORTAL pts][p-index]
  while [non-instantiated-portal != nobody] [
    ask non-instantiated-portal [
      set pts lput PT-PORTAL pts
      set pts-ids lput pportal-id pts-ids
      flood-zone PT-PORTAL pportal-id COLOR-PORTAL
    ]
    init-portal pportal-id
    set  non-instantiated-portal min-one-of patches with [pcolor = COLOR-PORTAL and not member? PT-PORTAL pts][p-index]
    set pportal-id pportal-id + 1
  ]
end

; observer
to init-lines
  let train-line-id 0
  let non-instantiated-train-line min-one-of patches with [pcolor = COLOR-TRAIN-LINE and not member? PT-TRAIN-LINE pts][p-index]
  while [non-instantiated-train-line != nobody] [
    ask non-instantiated-train-line [
      set pts lput PT-TRAIN-LINE pts
      set pts-ids lput train-line-id pts-ids
      flood-zone PT-TRAIN-LINE train-line-id COLOR-TRAIN-LINE
      init-rail
    ]
    set non-instantiated-train-line min-one-of patches with [pcolor = COLOR-TRAIN-LINE and not member? PT-TRAIN-LINE pts ][p-index]
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

;patch
to-report is-train-line-pt?
  report member? PT-TRAIN-LINE pts
end

; patch
to-report sprout-train [heading-vector]
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


to setup-data
  init-basics
  init-floors
  init-platforms
  init-grounds
  init-portals
  init-lines
  init-path-finding

end


to setup
  ca
  setup-static
  setup-data
  setup-run
end


to go
  print "tick"
  spawn-passengers
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
310
34
1483
439
-1
-1
12.433333333333334
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
93
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
68
498
131
531
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
121
114
184
147
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
79
356
156
389
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
25
461
111
494
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
54
74
151
107
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
80
392
199
425
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
48
149
141
182
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
78
218
161
251
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
77
253
181
286
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
81
185
177
218
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
76
323
166
356
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

BUTTON
77
288
174
321
NIL
init-grounds\n
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
