// ============================================================
//  roboticarmagent.asl — Jason 3.3 + CArtAgO
//
//  This agent creates the shared FactoryArtifact (makeArtifact)
//  so it must start before the others try to look it up.
//  All other agents use lookupArtifact + focus.
//
//  Once focused, every @OPERATION on the artifact is called
//  simply by its name (pick_part, move_towards, ...) just
//  like ordinary Jason external actions.
// ============================================================
binfull(1) :- bin_1(true).
binfull(2) :- bin_2(true).
binfull(3) :- bin_3(true).
binfull(4) :- bin_4(true).
binfull(5) :- bin_5(true).
binfull(6) :- bin_6(true).
// Soft-goal retry when gripper percept is not yet visible
+?gripper(X, Y, A) : true
  <- ?gripper(X, Y, A).

waitingposition(270, 613, 90).

!start.

// ── Startup: create the artifact and focus on it ──────────────
+!start : true
<- // Create the shared factory artifact in the "main" workspace.
   // All other agents will look it up by name.
   makeArtifact("assembly_env", "factory.AssemblyAreaArtifact", [], AssemblyArtId);

   makeArtifact("bin_env", "factory.BinArtifact", [], BinArtId);
   makeArtifact("robotic_arm_env", "factory.RoboticArmArtifact", [], ArmArtId);
   makeArtifact("welder_env", "factory.WelderArtifact", [], WelderArtId);
   makeArtifact("moving_env", "factory.MovingArtifact", [], MoverArtId);
   makeArtifact("holder_env", "factory.HolderArtifact", [], HolderArtId);


   focus(BinArtId);
   focus(ArmArtId);
   
   // We save the ID of the robotic arm artifact
   +factory_art_id(ArmArtId);
   
   .print("Robotic arm agent: artifacts bin_env and robotic_arm_env ready.");
   !positionParts.

// ── Guard: never call operations before focus is confirmed ───

+!positionParts : not factory_art_id(_)
<- .wait(200); !positionParts.

// ── Area lock requests ────────────────────────────────────────
// To place parts 1-5 (Area 1), request locks on both Area 1 and Area 2 to ensure exclusive access to the assembly area
+!positionParts : binfull(Part) & Part < 6 & not holding(Part)
                & (not lockedArea(2) | not lockedArea(1))
<- .print("Robotic arm agent: requesting areas 1 and 2.");
   .my_name(Agent);
   .send(assemblyareaagent, achieve, fullAreaLockFor(Agent));
   .wait(300);
   !positionParts.

// to place part 6 (Area 2), only request lock on Area 2
+!positionParts : binfull(6) & not holding(6) & not lockedArea(2)
<- .print("Robotic arm agent: requesting area 2.");
   .my_name(Agent);
   .send(assemblyareaagent, achieve, lockAreaFor(Agent, 2));
   .wait(300);
   !positionParts.

// Once it has all the pieces it needs to place, it can release the lock on Area 1
+!positionParts : not (binfull(Part) & Part < 6 & not holding(Part)) & lockedArea(1)
<- .print("Robotic arm agent: releasing area 1.");
   .my_name(Agent);
   .send(assemblyareaagent, achieve, unlockAreaFor(Agent, 1));
   .wait(300);
   !positionParts.

// ── Part sequencing ───────────────────────────────────────────

+!positionParts : binfull(1) & not holding(1) & lockedArea(1) & lockedArea(2)
<- !pickupAndpositionPart(1); !positionParts.

+!positionParts : binfull(2) & not holding(2) & lockedArea(1) & lockedArea(2)
<- !pickupAndpositionPart(2); !positionParts.

+!positionParts : binfull(3) & not holding(3) & lockedArea(1) & lockedArea(2)
<- !pickupAndpositionPart(3); !positionParts.

+!positionParts : binfull(4) & not holding(4) & lockedArea(1) & lockedArea(2)
<- !pickupAndpositionPart(4); !positionParts.

+!positionParts : binfull(5) & not holding(5) & lockedArea(1) & lockedArea(2)
<- !pickupAndpositionPart(5); !positionParts.

+!positionParts : binfull(6) & not holding(6) & lockedArea(2)
<- !pickupAndpositionPart(6); !positionParts.

// Still missing parts — retry
+!positionParts : not (holding(1) & holding(2) & holding(3) &
                       holding(4) & holding(5) & holding(6))
<- .wait(200); !positionParts.

// All parts placed — park and restart cycle
+!positionParts : true
<- !!parkArm; .wait(200); !positionParts.

// ── Movement ──────────────────────────────────────────────────

+!moveTo(X, Y, Angle) : not gripper(X, Y, Angle)
  <- move_towards(X,Y,Angle);
     !moveTo(X, Y, Angle).

+!moveTo(X, Y, Angle) : gripper(X, Y, Angle).

// ── Pick up and position a part ───────────────────────────────

+!pickupAndpositionPart(Part) : true
<- !pickupPart(Part);
   .print("Robotic arm agent: positioning part ", Part, ".");
   !positionPart(Part).

+!pickupPart(Part) : true
<- .drop_intention(parkArm);
   .print("Robotic arm agent: picking part ", Part, " from bin.");
   ?binPos(Part, X1, Y1);
   !moveTo(X1, Y1, 90);
   pick_part(Part).

+!positionPart(Part) : not holding(Part)
<- ?partPos(Part, X2, Y2, Angle);
   !moveTo(X2, Y2, Angle);
   .broadcast(tell, part_in_place(Part));
   .wait(200);
   !positionPart(Part).

+!positionPart(Part) : holding(Part)
<- .print("Robotic arm agent: releasing part ", Part, ".");
   .broadcast(untell, part_in_place(Part));
   release_part;
   !!parkArm.

// ── Park arm ─────────────────────────────────────────────────

+!parkArm : waitingposition(X, Y, Angle) & not gripper(X, Y, Angle)
<- ?waitingposition(X, Y, Angle);
   !moveTo(X, Y, Angle);
   !parkArm.

+!parkArm : lockedArea(Area)
<- .print("Robotic arm agent: releasing lock from area ", Area);
   .my_name(Agent);
   .send(assemblyareaagent, achieve, unlockAreaFor(Agent, Area));
   .wait(100);
   !parkArm.

+!parkArm.
