// ============================================================
//  binagent.asl — Jason 3.3 + CArtAgO
// ============================================================

// Configuration Constants
shift_period(80000).
off_period(40000).  // Reduced for better simulation flow
repair_time(15000).
base_timer(25000).

// Mappings
human(binagent1, 1). // Bob
human(binagent2, 2). // Alice
human(binagent3, 3). // Tom
human(binagent4, 4). // Mary
robot(binagent5).
robot(binagent6).

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

// Perception
binfull(1) :- bin_1(true).
binfull(2) :- bin_2(true).
binfull(3) :- bin_3(true).
binfull(4) :- bin_4(true).
binfull(5) :- bin_5(true).
binfull(6) :- bin_6(true).

!start.

+!start : true
<- !focus_bin;
   +on_shift;
   +produced(0);
   !!local_timer; // Each agent runs its own timer to avoid cross-agent belief pollution
   !work_loop.

+!local_timer : shift_period(S) & off_period(O)
<- .my_name(Me);
   -+on_shift;
   -+produced(0);
   .print("Shift started");
   .wait(S);
   -on_shift;
   .print("Shift ended (Resting)");
   .wait(O);
   !!local_timer.

+!focus_bin : not factory_art_id(_)
<- lookupArtifact("bin_env", ArtId);
   focus(ArtId);
   +factory_art_id(ArtId).

-!focus_bin : true
<- .wait(500); !focus_bin.

+!work_loop : true
<- !check_and_refill;
   .wait(3000); // UI breathing room
   !work_loop.

// ── HUMAN LOGIC ──
// Human only works IF on_shift AND their specific bin is empty
+!check_and_refill : .my_name(Me) & human(Me, N) & on_shift & not binfull(N)
<- ?base_timer(T);
   ?produced(Count);
   ?quota(Me, Q);
   
   if (math.random < 0.2) { .wait(400 + math.random(400)); };
   
   if (Count < Q) { Wait = math.random * (T * 0.4); } 
   else { Wait = math.random * T; };
   
   .wait(Wait);
   if (not binfull(N)) {
       refill_bin(N);
       -+produced(Count + 1);
       .print("Refilled bin ", N);
   }.

// ── ROBOT LOGIC ──
// Robot works regardless of shift, can refill any bin 1-6
+!check_and_refill : .my_name(Me) & robot(Me)
<- ?base_timer(T);
   if (math.random < 0.08) { .wait(repair_time); .print("Broken/Repaired"); };
   
   // Robot picks first available empty bin
   if (not binfull(1)) { !do_robot_refill(1, T) }
   else { if (not binfull(2)) { !do_robot_refill(2, T) }
   else { if (not binfull(3)) { !do_robot_refill(3, T) }
   else { if (not binfull(4)) { !do_robot_refill(4, T) }
   else { if (not binfull(5)) { !do_robot_refill(5, T) }
   else { if (not binfull(6)) { !do_robot_refill(6, T) } } } } } }.

+!check_and_refill.

+!do_robot_refill(N, T) : true
<- .wait(T);
   if (not binfull(N)) {
       refill_bin(N);
       .print("Robot refilled bin ", N);
   }.
