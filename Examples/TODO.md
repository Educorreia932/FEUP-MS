Better path - (already maximally normalized)
    should instead try to be an agent moving, and can move with an aribtrary angle
    check collision with adjancent walls? cannot move through a corner. Otherwise can ignore the corner?
        let a 2 * n grid
            If [10] is a corner, agent cannot go [00] [11] -> [00] [01] [11]
            If [10] is a corner, agent can go [00] [12]. this would probably be translated by being in [00] [01] [12]
            Maybe check patch-ahead, patch-left-and-ahead, patch-right-and-ahead

    
pathfinding- change way to obtain pathable neighbors in p-pathfinding so diagonals are not adjancent if there is an obstacle in either side? meaning if not pathable diagonal 1 or not pathable diagonal 2 then not adjacent

meta-path-finding

for passengers, pathfinding from the head of the train will be very inneficient. will probably need to calculate from scratch. might be very slow at the very start? Otherwise, it will be better
Therefore, it is only useful to keep the static pathfinding in platforms where we do not have our final source or our final destination. 
    Given that the portal we might use is not defined. doing the meta-pathfinding will also need to be done at a passenger level
        for now do it just to have it

boarding zone per train?
boarding zone min and max for each findable?



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