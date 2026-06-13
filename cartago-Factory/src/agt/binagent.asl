// ============================================================
//  binagent.asl — Jason 3.3 + CArtAgO
// ============================================================

// Configuration Constants
shift_period(80000).
off_period(160000).
repair_time(15000).
base_timer(25000).

// Mappings
human(binagent1, 1, "Bob").
human(binagent2, 2, "Alice").
human(binagent3, 3, "Tom").
human(binagent4, 4, "Mary").
robot(binagent5).
robot(binagent6).

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
   .my_name(Me);
   if (human(Me, _, Name)) { .print("Human agent ", Name, " ready."); }
   else { .print("Robot agent ", Me, " online."); };
   !!local_timer;
   !work_loop.

+!local_timer : shift_period(S) & off_period(O)
<- .my_name(Me);
   -+on_shift;
   -+produced(0);
   if (human(Me, _, Name)) { .print(">>> ", Name, " is starting the work shift (Quota: ", quota(Me, _), ")"); }
   else { .print(">>> Robot ", Me, " entering peak-support mode."); };
   .wait(S);
   -on_shift;
   if (human(Me, _, Name)) { .print("<<< ", Name, " is going OFF-SHIFT to rest."); }
   else { .print("<<< Robot ", Me, " entering maintenance/solo mode."); };
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
<- ?base_timer(T);
   ?produced(Count);
   ?quota(Me, Q);
   
   // Chatting logic
   if (math.random < 0.2) { 
       Chat = 400 + math.random(400);
       .print(Name, " is distracted chatting for ", Chat, "ms...");
       .wait(Chat); 
   };
   
   // Speed logic
   if (Count < Q) { 
       W = math.random * (T * 0.4); 
       .print(Name, " is working FASTER to meet quota (", Count+1, "/", Q, ")");
   } else { 
       W = math.random * T; 
       .print(Name, " is working at normal pace...");
   };
   
   .wait(W);
   if (not binfull(N)) { 
       refill_bin(N); 
       -+produced(Count + 1); 
       .print(Name, " successfully refilled bin ", N, ". Total: ", Count+1); 
   }.

// ── ROBOT LOGIC ──────────────────────────────────────────────
+!check_and_refill : .my_name(binagent5) & not binfull(5) <- !do_refill(5).
+!check_and_refill : .my_name(binagent6) & not binfull(6) <- !do_refill(6).

+!check_and_refill : .my_name(binagent5) & not on_shift & not binfull(1) <- !do_refill(1).
+!check_and_refill : .my_name(binagent5) & not on_shift & not binfull(2) <- !do_refill(2).
+!check_and_refill : .my_name(binagent6) & not on_shift & not binfull(3) <- !do_refill(3).
+!check_and_refill : .my_name(binagent6) & not on_shift & not binfull(4) <- !do_refill(4).

+!check_and_refill.

+!do_refill(N) : true
<- .my_name(Me);
   ?base_timer(T);
   if (math.random < 0.08) { 
       .print("!!! Robot ", Me, " malfunction! Fixing for ", repair_time, "ms...");
       .wait(repair_time); 
   };
   .print("Robot ", Me, " is refilling bin ", N, "...");
   .wait(T); 
   if (not binfull(N)) { 
       refill_bin(N); 
       .print("Robot ", Me, " finished refilling bin ", N); 
   }.
