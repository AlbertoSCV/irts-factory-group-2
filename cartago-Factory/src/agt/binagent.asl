// ============================================================
//  binagent.asl — Jason 3.3 + CArtAgO
// ============================================================

// Configuration Constants
shift_period(80000).
off_period(160000).
repair_time(15000).
base_timer(25000).

// Mappings
human(binagent1, 1, "bob"). 
human(binagent2, 2, "alice").
human(binagent3, 3, "tom").
human(binagent4, 4, "mary").
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

+!check_and_refill : .my_name(Me) & human(Me, N, Name) & on_shift & not binfull(N)
<- ?base_timer(T);
   ?produced(Count);
   ?quota(Me, Q);
   if (math.random < 0.2) { 
       Chat = 400 + math.random(400);
       .print(Name, " chatting for ", Chat, " ms.");
       .wait(Chat); 
   };
   if (Count < Q) { W = math.random * (T * 0.4); .print(Name, " compensating."); } 
   else { W = math.random * T; };
   .wait(W);
   if (not binfull(N)) { 
       refill_bin(N); 
       -+produced(Count + 1); 
       .print(Name, " refilled bin ", N); 
   }.

+!check_and_refill : .my_name(Me) & robot(Me)
<- ?base_timer(T);
   if (math.random < 0.08) { 
       .print("Robot ", Me, " broken.");
       .wait(repair_time); 
   };
   !select_bin_and_refill(T).

+!check_and_refill.

+!select_bin_and_refill(T) : not binfull(5) <- !do_refill(5, T).
+!select_bin_and_refill(T) : not binfull(6) <- !do_refill(6, T).
+!select_bin_and_refill(T) : not on_shift & not binfull(1) <- !do_refill(1, T).
+!select_bin_and_refill(T) : not on_shift & not binfull(2) <- !do_refill(2, T).
+!select_bin_and_refill(T) : not on_shift & not binfull(3) <- !do_refill(3, T).
+!select_bin_and_refill(T) : not on_shift & not binfull(4) <- !do_refill(4, T).
+!select_bin_and_refill(T).

+!do_refill(N, T) : true
<- .wait(T); 
   if (not binfull(N)) { 
       refill_bin(N); 
       .print("Robot ", .my_name, " refilled bin ", N); 
   }.
