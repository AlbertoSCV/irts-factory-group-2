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

// ── Startup & Focus ───────────────────────────────────────────

// Main startup: first request to focus on the environment
+!start : true
<- !focus_bin;
   .my_name(Agent);
   ?binnumber(N, Agent);
   +binnumber(N);
   .print("Bin agent ", N, " started.");
   !refill;
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

// ── Operations ────────────────────────────────────────────────

// Polling: constant retries with delay until the artifact is empty
+!check_empty : binnumber(N) & not binfull(N)
<- !refill; 
   .wait(500); 
   !check_empty.

+!check_empty : true
<- .wait(500); 
   !check_empty.

+!refill : binnumber(N) & timer(T)
<- // math.random used as arithmetic expression (not as action)
   // to avoid CArtAgO intercepting it as an artifact operation.
   WaitTime = math.random * T;
   .print("Bin agent ", N, " waiting ", WaitTime div 1000, " s for new parts...");
   .wait(WaitTime);
   .print("Bin agent ", N, " has received new parts.");
   refill_bin(N).        // CArtAgO operation on bin_env