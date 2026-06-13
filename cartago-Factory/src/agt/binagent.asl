// ============================================================
//  binagent.asl — Jason 3.3 + CArtAgO
// ============================================================

// Configuration Constants
shift_period(80000).
repair_time(15000).
base_timer(25000).

// Mappings
human(binagent1, 1). // Bob
human(binagent2, 2). // Alice
human(binagent3, 3). // Tom
human(binagent4, 4). // Mary
robot(binagent5).
robot(binagent6).

// Each human has a different and fixed number of bins in each period
quota(binagent1, 2).
quota(binagent2, 1).
quota(binagent3, 3).
quota(binagent4, 1).

binnumber(1, binagent1).
binnumber(2, binagent2).
binnumber(3, binagent3).
binnumber(4, binagent4).
binnumber(5, binagent5).
binnumber(6, binagent6).

binfull(1) :- bin_1(true).
binfull(2) :- bin_2(true).
binfull(3) :- bin_3(true).
binfull(4) :- bin_4(true).
binfull(5) :- bin_5(true).
binfull(6) :- bin_6(true).

!start.

+!start : true
<- !focus_bin;
   .my_name(Me);
   ?binnumber(N, Me);
   +my_bin(N);
   +produced(0);
   .print("Agent ", Me, " started.");
   !!shift_timer;
   !check_empty. // Reverting to original polling name for stability

+!shift_timer : shift_period(P)
<- .wait(P);
   -+produced(0);
   .print("--- NEW SHIFT ---");
   !!shift_timer.

+!focus_bin : not factory_art_id(_)
<- lookupArtifact("bin_env", ArtId);
   focus(ArtId);
   +factory_art_id(ArtId).

-!focus_bin : true
<- .wait(500); !focus_bin.

// Reverting to the very simple polling logic from the original file
+!check_empty : my_bin(N) & not binfull(N)
<- !perform_refill;
   .wait(2000); 
   !check_empty.

+!check_empty : true
<- .wait(2000); 
   !check_empty.

// ── Human Refill Logic ───────────────────────────────────────

+!perform_refill : .my_name(Me) & human(Me, N)
<- ?base_timer(T);
   ?produced(Count);
   ?quota(Me, Q);
   
   // Distraction
   if (math.random < 0.2) {
       .wait(400 + math.random(400));
   };
   
   // Compensation
   if (Count < Q) {
       ActualWait = math.random * (T * 0.5); 
   } else {
       ActualWait = math.random * T;
   };
   
   .wait(ActualWait);
   
   // Final check to handle race conditions with the arm
   if (not binfull(N)) {
      refill_bin(N);
      -+produced(Count + 1);
      .print("Refilled bin ", N, ". Produced: ", Count + 1);
   }.

// ── Robot Refill Logic ───────────────────────────────────────

+!perform_refill : .my_name(Me) & robot(Me)
<- ?base_timer(T);
   if (math.random < 0.08) {
       .wait(repair_time);
       .print("Robot repaired.");
   };
   
   .wait(T); 
   
   ?my_bin(N);
   if (not binfull(N)) {
      refill_bin(N);
      .print("Robot refilled bin ", N);
   }.
