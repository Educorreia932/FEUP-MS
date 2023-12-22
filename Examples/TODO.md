DONE - Better path - (already maximally normalized)
    should instead try to be an agent moving, and can move with an aribtrary angle
    check collision with adjancent walls? cannot move through a corner. Otherwise can ignore the corner?
        let a 2 * n grid
            If [10] is a corner, agent cannot go [00] [11] -> [00] [01] [11]
            If [10] is a corner, agent can go [00] [12]. this would probably be translated by being in [00] [01] [12]
            Maybe check patch-ahead, patch-left-and-ahead, patch-right-and-ahead

    
DONE - pathfinding- change way to obtain pathable neighbors in p-pathfinding so diagonals are not adjancent if there is an obstacle in either side? meaning if not pathable diagonal 1 or not pathable diagonal 2 then not adjacent

DONE - meta-path-finding

TODO - for passengers, pathfinding from the head of the train will be very inneficient. will probably need to calculate from scratch. might be very slow at the very start? Otherwise, it will be better
Therefore, it is only useful to keep the static pathfinding in platforms where we do not have our final source or our final destination. 
    Given that the portal we might use is not defined. doing the meta-pathfinding will also need to be done at a passenger level
        for now do it just to have it

TODO - boarding zone per train?
TODO -  boarding zone min and max for each findable?



is-straight-from with two bounding boxes!
 GEt a bounding box of the path and its radius
    first get the set (no duplicates) of all of the neighbors while tracing the path (is this faster than just doing the operation with every patch?)
    then get only the pathables


    tracing the path and getting the neighbors is faster than just fetching all and seeing if they are pathable? and only then doing intersection?

    In any case, do the intersection of the bounding box with all of the closer non-patchables patches!


init-pathing:
    not from train head but from the boarding zone patches that we should make! we could therefore delete the train, just keep the train-cells?
        maybe just a few boarding patches? not the full train length? 1 or 2 according to train length?
    Maybe same thing for the portal-cells!
        will this complicate meta pathfinding too much?
    When initting, will try to go to a boarding if on a train, then will try to head for a random portal-cell or other boarding


Look into topology

Meta pathing seems to not be working at all (inside passenger pathing)


Pathfinding-better:
    It is reiniatiliing EVERY PATCH -> limit it to patches in the same platform?
Pathable might have to be turned into directional if stuff like escalators are added!

    

Bug when running everything (since it was updated to pathfind most likely! Path normalization is not very well it seems)

TODO    
 Change neighbors to neighbors 8 (we are already checking if it's straight so getting the diagonal is optimal)

First: see if the files were saved. Otherwise copy the ones in vsc
 Problem: Going on the diagonal for escalators is not working
 also, i think I am calling the straigthener too many times? Probably why it is so slow as a whole? and why there aer so many prints


A*? Are we using A* for pathfinding 


Pathing each tick
    Number of passengers in each turtle increases the cost


add file to metadata


DONE To speed up the setup run massively!
    Get a passenger
    Get their train
        Get the findable from the train to everyplace else
    Get an auxiliary turtle moving from the passenger to the 2nd checkpoint of the findable path. When the auxiliary turtle intersects with the original path, then we add that as the a checkpoint on the auxiliarty turle, keep the 2nd of the original and the first is the postiion of the turtle itself
    (check for the checkpoing and the intersect being or not the same)
    In the end we are left with
    original findable path [train, probably first bend, second bend, ..., last bend, destination]
    passenger path [passenger, intersection, probably first bend, second bend, ..., last bend, destination]


DONE To speed up the setup run
    meta pathfidning source and origin only do outgoing and incoming pathables. (the others will never be treaversed anyway)

To speed up and clean setup run
    Only kill goal and source findables. Keep the rest

