// ============================================================
//  weldingagent.asl — Jason 3.3 + CArtAgO
//
//  Changes from Jason 2.x:
//   1. !focus_factory (lookupArtifact + focus with retry).
//   2. move_towards and weld are CArtAgO operations.
//   3. Bug fixed: ?waitingposition(X,Y) added before !moveTo
//      in the lockedArea(Area) variant of +!parkArm.
// ============================================================

waitingposition(1000, 470).

// Soft-goal retry for welder percept
+?welder(X, Y) : true
  <- ?welder(X, Y).

// Which parts must be in place for each joint
jointPartsInPlace(1) :- holding(1) & holding(2) & holding(3).
jointPartsInPlace(2) :- holding(2) & holding(4).
jointPartsInPlace(3) :- holding(3) & holding(4) & holding(6).
jointPartsInPlace(4) :- holding(4) & holding(5).
jointPartsInPlace(5) :- holding(5) & holding(6).

holdersReleased(N) :- not holding(N) & (N = 1 | holdersReleased(N-1)).
holdersReleased    :- holders(N) & holdersReleased(N).

!main.

+!main : true
<- !focus_welder;
   .print("Welding robot: waiting for new parts");
   !weldParts.

// search and focus on the welder_env artifact, with retry if not found
+!focus_welder : not factory_art_id(_)
<- .print("[", .my_name, "] Buscando welder_env...");
   lookupArtifact("welder_env", ArtId);
   focus(ArtId);
   +factory_art_id(ArtId); 
   .print("[", .my_name, "] focused in welder_env.").

// if welder_env is not yet available (not instantiated), wait and retry
-!focus_welder : true
<- .print("[", .my_name, "] welder_env not ready, retrying...");
   .wait(500);
   !focus_welder.


+!weldParts : joint(_) & holdersReleased
<- !forgetJoints; !weldParts.

// The joints 1, 2 and 4 (Area 1) only need that area locked
+!weldParts : (Joint = 1 | Joint = 2 | Joint = 4) & jointPartsInPlace(Joint) & not joint(Joint) & not lockedArea(1)
<- .print("Welding robot: requesting area 1.");
   .my_name(Agent);
   .send(assemblyareaagent, achieve, lockAreaFor(Agent, 1));
   .send(assemblyareaagent, achieve, unlockAreaFor(Agent, 2)); // Libera la 2 si la tenía
   .wait(200);
   !weldParts.

// The Joints 3 and 5 (Area 2) need both areas locked (the welder is below) 
+!weldParts : (Joint = 3 | Joint = 5) & jointPartsInPlace(Joint) & not joint(Joint) & (not lockedArea(1) | not lockedArea(2))
<- .print("Welding robot: requesting areas 1 and 2.");
   .my_name(Agent);
   .send(assemblyareaagent, achieve, fullAreaLockFor(Agent));
   .wait(200);
   !weldParts.

// Welding in progress — wait for completion
+!weldParts : ((Joint = 1 | Joint = 2 | Joint = 4) & jointPartsInPlace(Joint) & not joint(Joint) & lockedArea(1)) |
              ((Joint = 3 | Joint = 5) & jointPartsInPlace(Joint) & not joint(Joint) & lockedArea(1) & lockedArea(2))
<- .print("Welding robot: welding joint ", Joint);
   .drop_intention(parkArm);
   ?jointPos(Joint, X, Y);
   !moveTo(X, Y);
   weld;                           // CArtAgO operation
   +joint(Joint);
   .broadcast(tell, joint(Joint));
   !!parkArm;
   !weldParts.

// With pause between retries to avoid busy-waiting
+!weldParts : true
<- .wait(200); 
   !weldParts.

+!forgetJoints : joint(N)
<- -joint(N);
   .broadcast(untell, joint(N));
   !forgetJoints.

+!forgetJoints.

// Movement
+!moveTo(X, Y) : not welder(X, Y)
  <- move_towards(X,Y,0);
     !moveTo(X, Y).

+!moveTo(X, Y) : welder(X, Y).

// Park arm
+!parkArm : waitingposition(X, Y) & not welder(X, Y)
<- !moveTo(X, Y); !parkArm.

// Bug fix: bind X,Y before moveTo (were unbound in Jason 2.x version)
+!parkArm : lockedArea(Area)
<- ?waitingposition(X, Y);
   !moveTo(X, Y);
   .print("Welding arm: releasing lock from area ", Area);
   .my_name(Agent);
   .send(assemblyareaagent, achieve, unlockAreaFor(Agent, Area));
   .wait(200);
   !parkArm.

+!parkArm.
