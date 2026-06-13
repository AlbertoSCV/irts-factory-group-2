// ============================================================
//  binagent.asl — Jason 3.3 + CArtAgO
//
//  Changes from Jason 2.x:
//   1. !focus_bin (lookupArtifact + focus with retry) to prevent
//      ArtifactNotAvailableException race conditions.
//   2. binfull(N) derived from obs. property bin_N(true).
//   3. math.random(X) instead of .random(X).
//   4. refill_bin(N) is a CArtAgO operation (no extra annotation).
// ============================================================
timer(25000).

// Mappings for Human and Robot roles
human(binagent1, 1, "bob").
human(binagent2, 2, "alice").
human(binagent3, 3, "tom").
human(binagent4, 4, "mary").
robot(binagent5).
robot(binagent6).

binnumber(1, binagent1).
binnumber(2, binagent2).
binnumber(3, binagent3).
binnumber(4, binagent4).
binnumber(5, binagent5).
binnumber(6, binagent6).

// binfull(N) derived from CArtAgO observable properties bin_1..bin_6
binfull(1) :- bin_1(true).
binfull(2) :- bin_2(true).
binfull(3) :- bin_3(true).
binfull(4) :- bin_4(true).
binfull(5) :- bin_5(true).
binfull(6) :- bin_6(true).

!start.

// ── Shift Management ──────────────────────────────────────────
+!shift_timer : true
<- -+on_shift;
   -+produced(0);
   .wait(80000); // 80s period
   -on_shift;
   .wait(160000); // Off period
   !!shift_timer.

// ── Startup & Focus ───────────────────────────────────────────

// Main startup: first request to focus on the environment
+!start : true
<- !focus_bin;
   .my_name(Me);
   ?binnumber(N, Me);
   +binnumber(N);
   +produced(0);
   +on_shift;
   !!shift_timer; // Start the local cycle
   .print("Bin agent ", N, " started.");
   !check_empty.

// Search and focus on ITS specific artifact
+!focus_bin : not factory_art_id(_)
<- .print("[", .my_name, "] Looking for bin_env...");
   lookupArtifact("bin_env", ArtId);
   focus(ArtId);
   +factory_art_id(ArtId); // Save the belief
   .print("[", .my_name, "] Focused on bin_env OK.").

// Fallback plan: If bin_env does not exist yet, wait and retry
-!focus_bin : true
<- .print("[", .my_name, "] bin_env not ready, retrying...");
   .wait(500);
   !focus_bin.
// Base timers for rebalancing speed
human_timer(40000).  // Humans are slower (40s base)
robot_timer(30000).   // Robots are faster but constant (30s base)
repair_time(15000).

// Worst-case fixed quotas for humans
quota(binagent1, 2).
quota(binagent2, 1).
quota(binagent3, 2).
quota(binagent4, 1).

// ── Operations ────────────────────────────────────────────────

// Polling: humans only check if on shift
+!check_empty : .my_name(Me) & human(Me, N, Name) & on_shift & not binfull(N)
<- !refill; 
   .wait(2500); // Polling delay to slow down environment checks
   !check_empty.

// Robots check any bin as needed
+!check_empty : .my_name(Me) & robot(Me)
<- !robot_check;
   .wait(2500);
   !check_empty.

+!check_empty : true
<- .wait(2500); 
   !check_empty.

// Robot versatility: search for empty bins with static priority to avoid collision
+!robot_check : .my_name(binagent5)
<- if (not binfull(5)) { !refill_target(5) }
   else { if (not binfull(1)) { !refill_target(1) }
   else { if (not binfull(2)) { !refill_target(2) }
   else { if (not on_shift) { // Help with 3,4 only if humans are off and 5,1,2 are full
        if (not binfull(3)) { !refill_target(3) }
        else { if (not binfull(4)) { !refill_target(4) } }
   } } } }.

+!robot_check : .my_name(binagent6)
<- if (not binfull(6)) { !refill_target(6) }
   else { if (not binfull(3)) { !refill_target(3) }
   else { if (not binfull(4)) { !refill_target(4) }
   else { if (not on_shift) { // Help with 1,2 only if humans are off and 6,3,4 are full
        if (not binfull(1)) { !refill_target(1) }
        else { if (not binfull(2)) { !refill_target(2) } }
   } } } }.

+!robot_check.

+!refill_target(N) : true
<- +target(N);
   !refill;
   -target(N).

// Specialized refill for Humans
+!refill : .my_name(Me) & human(Me, N, Name) & human_timer(T)
<- ?produced(Count);
   ?quota(Me, Q);
   // Bored distraction
   if (math.random < 0.2) {
       .wait(400 + math.random(400));
       .print(Name, " is chatting...");
   };
   // Speed compensation
   if (Count < Q) {
       ActualWait = math.random * (T * 0.4);
       .print(Name, " working faster to meet quota.");
   } else {
       ActualWait = (math.random * T) + 10000;
   };
   .wait(ActualWait);
   if (not binfull(N)) {
       refill_bin(N);
       -+produced(Count + 1);
       .print(Name, " refilled bin ", N);
   }.

// Specialized refill for Robots
+!refill : .my_name(Me) & robot(Me) & robot_timer(T)
<- // Breakage chance 8%
   if (math.random < 0.08) {
       .print("Robot ", Me, " broken.");
       .wait(repair_time);
   };
   .wait(T); // Always makes the same number of parts (fixed time)
   if (target(N) & not binfull(N)) {
       refill_bin(N);
       .print("Robot ", Me, " refilled bin ", N);
   }.

+!refill.
