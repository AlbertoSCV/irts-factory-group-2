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

// Worst Case Quota
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

// Correct perception: only refill if the bin is truly perceived as empty
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
   .print("--- NEW SHIFT ---");
   -+produced(0);
   !!shift_timer.

+!focus_bin : not factory_art_id(_)
<- lookupArtifact("bin_env", ArtId);
   focus(ArtId);
   +factory_art_id(ArtId).

-!focus_bin : true
<- .wait(500); !focus_bin.

+!work_loop : true
<- !check_refill;
   .wait(3000); // Polling delay increased to ensure artifact state syncs
   !work_loop.

+!check_refill : my_bin(N) & not binfull(N)
<- !perform_refill.
+!check_refill.

// ── Human Refill Logic ───────────────────────────────────────

+!perform_refill : .my_name(Me) & human(Me, N) & my_bin(N) & not binfull(N)
<- ?base_timer(T);
   ?produced(Count);
   ?quota(Me, Q);
   
   if (math.random < 0.2) {
       .wait(400 + math.random(400));
       .print("Chatting...");
   };
   
   if (Count < Q) {
       ActualWait = math.random * (T * 0.4); 
       .print("Compensating...");
   } else {
       ActualWait = math.random * T;
   };
   
   .wait(ActualWait);
   
   // Double check state before calling artifact operation to prevent ghost refills
   if (not binfull(N)) {
       refill_bin(N);
       -+produced(Count + 1);
       .print("Refilled bin ", N, ". Produced: ", Count + 1);
   }.

// ── Robot Refill Logic ───────────────────────────────────────

+!perform_refill : .my_name(Me) & robot(Me) & my_bin(N) & not binfull(N)
<- ?base_timer(T);
   if (math.random < 0.08) {
       ?repair_time(RT);
       .print("Robot BROKEN. Repairing...");
       .wait(RT);
   };
   
   .wait(T); 
   
   if (not binfull(N)) {
       refill_bin(N);
       .print("Robot refilled bin ", N);
   }.
