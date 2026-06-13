// ============================================================
//  weldingagent2.asl — Jason 3.3 + CArtAgO (Welder 2)
// ============================================================

waitingposition(200, 470).

// Soft-goal retry for welder2 percept
+?welder2(X, Y) : true
  <- ?welder2(X, Y).

// Joint 3, 5 (Area 2)
jointPartsInPlace(3) :- holding(3) & holding(4) & holding(6).
jointPartsInPlace(5) :- holding(5) & holding(6).

holdersReleased(N) :- not holding(N) & (N = 1 | holdersReleased(N-1)).
holdersReleased    :- holders(N) & holdersReleased(N).

!main.

+!main : true
<- !focus_welder;
   .print("Welding robot 2 (Area 2): online.");
   !weldParts.

+!focus_welder : not factory_art_id(_)
<- createArtifact("welder_env2", "factory.WelderArtifact", [], ArtId);
   focus(ArtId);
   +factory_art_id(ArtId).

-!focus_welder : true <- .wait(500); !focus_welder.

// Reset cycle
+!weldParts : joint(3) & joint(5) & holdersReleased
<- !forgetJoints; !weldParts.

// Priority: Lock Area 2 for Joints 3, 5
+!weldParts : (Joint = 3 | Joint = 5) & jointPartsInPlace(Joint) & not joint(Joint) & not lockedArea(2)
<- .print("Welding robot 2: requesting area 2.");
   .my_name(Agent);
   .send(assemblyareaagent, achieve, lockAreaFor(Agent, 2));
   .wait(500);
   !weldParts.

// Weld logic
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
<- .wait(500); 
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
   .my_name(Agent);
   .print("Welder 2 releasing area ", Area);
   .send(assemblyareaagent, achieve, unlockAreaFor(Agent, Area));
   .wait(200);
   !parkArm.
+!parkArm.
