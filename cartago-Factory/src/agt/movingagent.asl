// ============================================================
//  movingagent.asl — Jason 3.3 + CArtAgO
// ============================================================


waitingposition(500, 70).
framestockposition(-400, 300).

// Soft-goal retry for mover percept
+?mover(X, Y) : true
  <- ?mover(X, Y).

holdersReleased(N) :- not holding(N) & (N = 1 | holdersReleased(N-1)).
holdersReleased    :- holdersReleased(6).

jointDone(N)       :- joint(N) & (N = 1 | jointDone(N-1)).
weldingCompleted   :- joints(N) & jointDone(N).

!start.

+!start : true
<- !focus_moving;
   .print("Moving robot: waiting for finished frame");
   !removeFrame.

+!focus_moving : not factory_art_id(_)
<- .print("[", .my_name, "] Searching for moving_env...");
   lookupArtifact("moving_env", ArtId);
   focus(ArtId);
   +factory_art_id(ArtId);
   .print("[", .my_name, "] Focus on moving_env.").

// if moving_env is not yet available, wait and retry
-!focus_moving : true
<- .print("[", .my_name, "] moving_env not ready, retrying...");
   .wait(500);
   !focus_moving.

+!removeFrame : weldingCompleted & not (lockedArea(1) & lockedArea(2))
<- .print("Moving robot: requesting areas 1 and 2.");
   .my_name(Agent);
   .send(assemblyareaagent, achieve, fullAreaLockFor(Agent));
   .wait(200);
   !removeFrame.

+!removeFrame : weldingCompleted & lockedArea(1) & lockedArea(2)
<- .print("Moving robot: moving finished frame away.");
   !pickFrame;
   !moveAway;
   !removeFrame.

+!removeFrame : not weldingCompleted
<- .wait(200); !removeFrame.

+!pickFrame : true
<- ?partPos(4, X, Y, _);
   !moveTo(X, Y);
   pick_part(4);
   .broadcast(tell, mover(hold)).

+!moveAway : holdersReleased
<- ?framestockposition(X2, Y2);
   !moveTo(X2, Y2);
   release_part;
   .broadcast(untell, mover(hold));
   !awaitUnlockArea;
   !parkArm.

+!moveAway : true
<- .wait(200); !moveAway.

+!moveTo(X, Y) : not mover(X, Y)
  <- move_towards(X,Y,0);
     !moveTo(X, Y).

+!moveTo(X, Y) : mover(X, Y).

+!parkArm : true
<- ?waitingposition(X, Y);
   !moveTo(X, Y).

+!awaitUnlockArea : lockedArea(_)
<- .print("Moving robot: giving way to others.");
   .my_name(Agent);
   .send(assemblyareaagent, achieve, fullAreaUnlockFor(Agent));
   .wait(200);
   !awaitUnlockArea.

+!awaitUnlockArea.
