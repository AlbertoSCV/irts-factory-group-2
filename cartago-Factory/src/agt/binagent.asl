// ============================================================
//  binagent.asl — Jason 3.3 + CArtAgO
// ============================================================

// Configuration Constants
shift_period(80000).  // 8 hours
off_period(160000).   // 16 hours off
repair_time(15000).
base_timer(25000).

// Mappings
human(binagent1, 1). // Bob
human(binagent2, 2). // Alice
human(binagent3, 3). // Tom
human(binagent4, 4). // Mary
robot(binagent5).
robot(binagent6).

// Worst Case Quota per shift
quota(binagent1, 2).
quota(binagent2, 1).
quota(binagent3, 2).
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
   +on_shift;
   +produced(0);
   !!global_timer;
   !check_empty.

// Global cycle: 80s work, 160s rest for humans
+!global_timer : shift_period(S) & off_period(O)
<- .print("--- HUMANS STARTING SHIFT ---");
   -+on_shift;
   -+produced(0);
   .wait(S);
   .print("--- HUMANS ENDING SHIFT (Resting) ---");
   -on_shift;
   .wait(O);
   !!global_timer.

+!focus_bin : not factory_art_id(_)
<- lookupArtifact("bin_env", ArtId);
   focus(ArtId);
   +factory_art_id(ArtId).

-!focus_bin : true
<- .wait(500); !focus_bin.

// Polling loop
+!check_empty : true
<- !try_refill_any;
   .wait(3000); 
   !check_empty.

// Robots can refill ANY empty bin (1-6)
+!try_refill_any : robot(Me)
<- if (not binfull(1)) { !perform_refill(1) }
   else { if (not binfull(2)) { !perform_refill(2) }
   else { if (not binfull(3)) { !perform_refill(3) }
   else { if (not binfull(4)) { !perform_refill(4) }
   else { if (not binfull(5)) { !perform_refill(5) }
   else { if (not binfull(6)) { !perform_refill(6) } } } } } }.

// Humans specialized: only refill their specific bin, only if on shift
+!try_refill_any : human(Me, N) & on_shift & not binfull(N)
<- !perform_refill(N).

+!try_refill_any.

// ── Human Refill Logic ───────────────────────────────────────
+!perform_refill(N) : human(Me, N)
<- ?base_timer(T);
   ?produced(Count);
   ?quota(Me, Q);
   
   if (math.random < 0.25) { .wait(400 + math.random(400)); .print("Chatting..."); };
   
   if (Count < Q) { ActualWait = math.random * (T * 0.4); .print("Compensating..."); }
   else { ActualWait = math.random * T; };
   
   .wait(ActualWait);
   if (not binfull(N)) {
       refill_bin(N);
       -+produced(Count + 1);
       .print("Human refilled bin ", N);
   }.

// ── Robot Refill Logic ───────────────────────────────────────
+!perform_refill(N) : robot(Me)
<- ?base_timer(T);
   if (math.random < 0.08) {
       .print("Robot BROKEN. Repairing...");
       .wait(repair_time);
   };
   
   .wait(T);
   if (not binfull(N)) {
       refill_bin(N);
       .print("Robot refilled bin ", N);
   }.
