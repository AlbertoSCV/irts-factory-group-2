// ============================================================
//  binagent.asl — Jason 3.3 + CArtAgO
// ============================================================

// Configuration Constants
shift_period(80000).
quota(2).           // Lower quota to ensure humans can definitely finish
repair_time(20000). 
base_timer(15000).  // Faster base timer to prevent UI desync

// Mappings
human(binagent1, 1). // Bob
human(binagent2, 2). // Alice
human(binagent3, 3). // Tom
human(binagent4, 4). // Mary
robot(binagent5).
robot(binagent6).

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
   !work_loop.

+!shift_timer : shift_period(P)
<- .wait(P);
   .print("--- NEW SHIFT STARTING ---");
   -+produced(0);
   !!shift_timer.

+!focus_bin : not factory_art_id(_)
<- lookupArtifact("bin_env", ArtId);
   focus(ArtId);
   +factory_art_id(ArtId).

-!focus_bin : true
<- .wait(500); !focus_bin.

// ── Main Work Loop ───────────────────────────────────────────

+!work_loop : true
<- !check_refill;
   .wait(2000); // Polling delay reduced to keep UI in sync
   !work_loop.

+!check_refill : my_bin(N) & not binfull(N)
<- !perform_refill.

+!check_refill.

// ── Human Refill Logic ───────────────────────────────────────

+!perform_refill : .my_name(Me) & human(Me, N)
<- ?base_timer(T);
   ?produced(Count);
   ?quota(Q);
   
   // Humans only work if they haven't met their quota
   if (Count < Q) {
       // Distraction (400-800ms)
       if (math.random < 0.2) {
           .wait(400 + math.random(400));
       };
       
       // Human speed (25s - 35s equivalent)
       .wait(T + math.random(T));
       
       refill_bin(N);
       -+produced(Count + 1);
       .print("Refilled bin ", N, ". Produced: ", Count + 1);
   } else {
       // Quota met, resting
       .wait(5000);
   }.

// ── Robot Refill Logic ───────────────────────────────────────

+!perform_refill : .my_name(Me) & robot(Me)
<- ?base_timer(T);
   if (math.random < 0.08) {
       ?repair_time(RT);
       .print("BROKEN! Repairing...");
       .wait(RT);
   };
   
   .wait(T); // Robots are consistent and match the "physical" animation speed
   ?my_bin(N);
   refill_bin(N);
   .print("Robot refilled bin ", N).
