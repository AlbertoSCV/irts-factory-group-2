// ============================================================
//  weldingagent.asl — Jason 3.3 + CArtAgO (Welder 1)
// ============================================================

waitingposition(1000, 470).

// Soft-goal retry for welder percept
+?welder(X, Y) : true
  <- ?welder(X, Y).

// Which parts must be in place for each joint
jointPartsInPlace(1) :- holding(1) & holding(2) & holding(3).
jointPartsInPlace(2) :- holding(2) & holding(4).
jointPartsInPlace(4) :- holding(4) & holding(5).

holdersReleased(N) :- not holding(N) & (N = 1 | holdersReleased(N-1)).
holdersReleased    :- holders(N) & holdersReleased(N).

!main.

+!main : true
<- !focus_welder;
   .print("Welding robot 1 (Area 1): waiting for new parts");
   !weldParts.

+!focus_welder : not factory_art_id(_)
<- lookupArtifact("welder_env", ArtId);
   focus(ArtId);
   +factory_art_id(ArtId).

-!focus_welder : true
<- .wait(500); !focus_welder.

+!weldParts : joint(1) & joint(2) & joint(4) & holdersReleased
<- !forgetJoints; !weldParts.

// Welder 1 only works on joints 1, 2, 4 in Area 1
+!weldParts : (Joint = 1 | Joint = 2 | Joint = 4) & jointPartsInPlace(Joint) & not joint(Joint) & not lockedArea(1)
<- .print("Welding robot 1: requesting area 1.");
   .my_name(Agent);
   .send(assemblyareaagent, achieve, lockAreaFor(Agent, 1));
   .wait(200);
   !weldParts.


+!weldParts : (Joint = 1 | Joint = 2 | Joint = 4) & jointPartsInPlace(Joint) & not joint(Joint) & lockedArea(1)
<- .print("Welding robot 1: welding joint ", Joint);
   .drop_intention(parkArm);
   ?jointPos(Joint, X, Y);
   !moveTo(X, Y);
   weld;                          
   +joint(Joint);
   .broadcast(tell, joint(Joint));
   !!parkArm;
   !weldParts.

+!weldParts : true
<- .wait(200); 
   !weldParts.

+!forgetJoints : (Joint = 1 | Joint = 2 | Joint = 4) & joint(Joint)
<- -joint(Joint);
   .broadcast(untell, joint(Joint));
   !forgetJoints.
+!forgetJoints.

+!moveTo(X, Y) : not welder(X, Y)
  <- move_towards(X,Y,0);
     !moveTo(X, Y).
+!moveTo(X, Y) : welder(X, Y).

+!parkArm : waitingposition(X, Y) & not welder(X, Y)
<- !moveTo(X, Y); !parkArm.

+!parkArm : lockedArea(Area)
<- ?waitingposition(X, Y);
   !moveTo(X, Y);
   .print("Welding arm 1: releasing lock from area ", Area);
   .my_name(Agent);
   .send(assemblyareaagent, achieve, unlockAreaFor(Agent, Area));
   .wait(200);
   !parkArm.
+!parkArm.
