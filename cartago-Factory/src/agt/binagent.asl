// ============================================================
//  binagent.asl — Jason 3.3 + CArtAgO
// ============================================================

// Configuration Constants
shift_period(80000).
off_period(160000).
repair_time(15000).
human_base_timer(40000). // Humans naturally slower
robot_timer(30000).      // Robots faster but constant

// Human specialization mapping (agent, bin_type, name)
human(binagent1, 1, "bob"). 
human(binagent2, 2, "alice").
human(binagent3, 3, "tom").
human(binagent4, 4, "mary").
robot(binagent5).
robot(binagent6).

// Different and fixed number of bins for each human (worst case)
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
   +on_shift;
   +produced(0);
   !!local_timer;
   !work_loop.

+!local_timer : shift_period(S) & off_period(O)
<- -+on_shift;
   -+produced(0);
   .wait(S);
   -on_shift;
   .wait(O);
   !!local_timer.

+!focus_bin : not factory_art_id(_)
<- lookupArtifact("bin_env", ArtId);
   focus(ArtId);
   +factory_art_id(ArtId).

-!focus_bin : true <- .wait(500); !focus_bin.

+!work_loop : true
<- !check_and_refill;
   .wait(1000); 
   !work_loop.

// ── HUMAN LOGIC ──────────────────────────────────────────────
+!check_and_refill : .my_name(Me) & human(Me, N, Name) & on_shift & not binfull(N)
<- ?human_base_timer(T);
   ?produced(Count);
   ?quota(Me, Q);
   
   if (math.random < 0.2) { 
       Chat = 400 + math.random(400);
       .print(Name, " chatting for ", Chat, " ms.");
       .wait(Chat); 
   };
   
   if (Count < Q) { 
       W = math.random * (T * 0.4); // Compensation speed
       .print(Name, " compensating (faster production).");
   } else { 
       W = (math.random * T) + 10000; // Normal slow pace
   };
   
   .wait(W);
   if (not binfull(N)) { 
       refill_bin(N); 
       -+produced(Count + 1); 
       .print(Name, " refilled bin ", N, ". Count: ", Count+1); 
   }.

// ── ROBOT LOGIC ──────────────────────────────────────────────
+!check_and_refill : .my_name(Me) & robot(Me)
<- ?robot_timer(T);
   if (math.random < 0.08) { 
       .print("Robot ", Me, " broken. Repairing.");
       .wait(repair_time); 
   };
   !robot_strategy(T).

+!check_and_refill.

+!robot_strategy(T) : .my_name(binagent5) & not binfull(5) <- !do_refill(5, T).
+!robot_strategy(T) : .my_name(binagent6) & not binfull(6) <- !do_refill(6, T).
+!robot_strategy(T) : not binfull(5) <- !do_refill(5, T).
+!robot_strategy(T) : not binfull(6) <- !do_refill(6, T).
+!robot_strategy(T) : not on_shift & not binfull(1) <- !do_refill(1, T).
+!robot_strategy(T) : not on_shift & not binfull(2) <- !do_refill(2, T).
+!robot_strategy(T) : not on_shift & not binfull(3) <- !do_refill(3, T).
+!robot_strategy(T) : not on_shift & not binfull(4) <- !do_refill(4, T).
+!robot_strategy(T).

+!do_refill(N, T) : true
<- .wait(T); 
   if (not binfull(N)) { 
       refill_bin(N); 
       .print("Robot ", .my_name, " refilled bin ", N); 
   }.
