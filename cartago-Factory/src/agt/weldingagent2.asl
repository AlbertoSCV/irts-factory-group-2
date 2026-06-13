// ============================================================
//  weldingagent2.asl — Jason 3.3 + CArtAgO (Welder 2)
// ============================================================

waitingposition(200, 470).

// Soft-goal retry for welder2 percept
+?welder2(X, Y) : true
  <- ?welder2(X, Y).

// Which parts must be in place for each joint
jointPartsInPlace(3) :- holding(3) & holding(4) & holding(6).
jointPartsInPlace(5) :- holding(5) & holding(6).

holdersReleased(N) :- not holding(N) & (N = 1 | holdersReleased(N-1)).
holdersReleased    :- holders(N) & holdersReleased(N).

!main.

+!main : true
<- !focus_welder;
   .print("Welding robot 2 (Area 2): waiting for new parts");
   !weldParts.

+!focus_welder : not factory_art_id(_)
<- lookupArtifact("welder_env", ArtId);
   focus(ArtId);
   +factory_art_id(ArtId).

-!focus_welder : true
<- .wait(500); !focus_welder.

+!weldParts : joint(3) & joint(5) & holdersReleased
<- !forgetJoints; !weldParts.

// Welder 2 only works on joints 3 and 5 in Area 2
+!weldParts : (Joint = 3 | Joint = 5) & jointPartsInPlace(Joint) & not joint(Joint) & not lockedArea(2)
<- .print("Welding robot 2: requesting area 2.");
   .my_name(Agent);
   .send(assemblyareaagent, achieve, lockAreaFor(Agent, 2));
   .wait(200);
   !weldParts.


+!weldParts : (Joint = 3 | Joint = 5) & jointPartsInPlace(Joint) & not joint(Joint) & lockedArea(2)
<- .print("Welding robot 2: welding joint ", Joint);
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

+!forgetJoints : (Joint = 3 | Joint = 5) & joint(Joint)
<- -joint(Joint);
   .broadcast(untell, joint(Joint));
   !forgetJoints.
+!forgetJoints.

+!moveTo(X, Y) : not welder2(X, Y)
  <- move_towards(X,Y,0);
     !moveTo(X, Y).
+!moveTo(X, Y) : welder2(X, Y).

+!parkArm : waitingposition(X, Y) & not welder2(X, Y)
<- !moveTo(X, Y); !parkArm.

+!parkArm : lockedArea(Area)
<- ?waitingposition(X, Y);
   !moveTo(X, Y);
   .print("Welding arm 2: releasing lock from area ", Area);
   .my_name(Agent);
   .send(assemblyareaagent, achieve, unlockAreaFor(Agent, Area));
   .wait(200);
   !parkArm.
+!parkArm.
