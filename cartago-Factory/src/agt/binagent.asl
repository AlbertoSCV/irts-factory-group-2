// ============================================================
//  binagent.asl — Jason 3.3 + CArtAgO
// ============================================================

// Configuration Constants
shift_period(80000).
quota(4).
repair_time(15000).
base_timer(25000).

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

// binfull(N) derived from CArtAgO observable properties bin_1..bin_6
binfull(1) :- bin_1(true).
binfull(2) :- bin_2(true).
binfull(3) :- bin_3(true).
binfull(4) :- bin_4(true).
binfull(5) :- bin_5(true).
binfull(6) :- bin_6(true).

!start.

// ── Startup & Focus ───────────────────────────────────────────

+!start : true
<- !focus_bin;
   .my_name(Me);
   ?binnumber(N, Me);
   +my_bin(N);
   +produced(0);
   .print("Agent ", Me, " (Bin ", N, ") started.");
   !start_shift;
   !work_loop.

+!start_shift : shift_period(P)
<- -+produced(0);
   .at("now + 80 s", { +!start_shift });
   .print("New shift started").

+!focus_bin : not factory_art_id(_)
<- lookupArtifact("bin_env", ArtId);
   focus(ArtId);
   +factory_art_id(ArtId).

-!focus_bin : true
<- .wait(500); !focus_bin.

// ── Main Work Loop ───────────────────────────────────────────

+!work_loop : true
<- !check_refill;
   .wait(500);
   !work_loop.

+!check_refill : my_bin(N) & not binfull(N)
<- !perform_refill.
+!check_refill.

// ── Human Refill Logic ───────────────────────────────────────

+!perform_refill : .my_name(Me) & human(Me, N)
<- ?base_timer(T);
   ?produced(Count);
   ?quota(Q);
   
   // Check if needing to speed up (compensation)
   // Simple heuristic: if we are behind quota, go faster
   if (Count < Q) {
       ActualWait = (math.random * T) * 0.5; // Faster
       .print("Working faster to meet quota...");
   } else {
       ActualWait = math.random * T;
   };
   
   // Potential distraction (20% chance)
   if (math.random < 0.2) {
       ChatTime = 400 + (math.random * 400);
       .print("Chatting with colleagues for ", ChatTime, "ms...");
       .wait(ChatTime);
   };
   
   .wait(ActualWait);
   refill_bin(N);
   -+produced(Count + 1);
   .print("Human ", Me, " refilled bin ", N, ". Total this shift: ", Count + 1).

// ── Robot Refill Logic ───────────────────────────────────────

+!perform_refill : .my_name(Me) & robot(Me)
<- ?base_timer(T);
   // Breakage probability 8%
   if (math.random < 0.08) {
       ?repair_time(RT);
       .print("Robot ", Me, " BROKEN! Repairing for ", RT, "ms...");
       .wait(RT);
   };
   
   .wait(T); // Robots always take the same time
   ?my_bin(N);
   refill_bin(N);
   .print("Robot ", Me, " refilled bin ", N).
