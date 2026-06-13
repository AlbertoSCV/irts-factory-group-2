package factory;

import java.util.Arrays;

public class FactoryModel {

    // ── Singleton Instance ───────────────────────────────
    private static FactoryModel instance;
    private BinArtifact binArtifact;
    
    public static synchronized FactoryModel getInstance() {
        if (instance == null) {
            instance = new FactoryModel();
        }
        return instance;
    }

    // ── FactoryModel Constants ──────────────────────
    public static final int BINS    = 6;
    public static final int PARTS   = 6;
    public static final int HOLDERS = 6;
    public static final int JOINTS  = 5;
    public static final int AREAS   = 2;

    public static final int[]   PART_LENGTHS = { 55, 410, 452, 256, 275, 167 };
    public static final int[][] HOLDER_POS   = { {910,210},{757,183},{785,270},{500,309},{422,309},{449,448} };
    public static final int[]   ARM_BASE     = { 600,  613 };
    public static final int[]   WELDER_BASE  = { 1000,  70 };
    public static final int[]   WELDER2_BASE = { 200, 70 };
    public static final int[]   MOVER_BASE   = {  300,  70 };
    public static final int[][] BIN_POS      = { {270,538},{270,568},{270,598},{270,628},{270,658},{270,688} };
    public static final int[][] JOINT_POS    = { {914,194},{501,197},{534,460},{501,215},{358,459} };
    public static final int[][] PART_POS     = { {917,198,344},{705,194,90},{727,328,55}, {515,327,352},{428,335,30},{445,458,90} };


    // ── Internal state with dynamic values ───────────────────
    public boolean[] binfull  = new boolean[BINS];
    public int       gripperPart  = -1;
    public int       gripperAngle = 90;
    public boolean   welding    = false;
    public boolean   welding2   = false;
    public boolean   moving     = false;
    public boolean[] holding  = new boolean[HOLDERS];
    public boolean[] joint    = new boolean[JOINTS];
    public boolean[] lockArea = new boolean[AREAS];

    public int[] gripperPosition = { 270, 613 };
    public int[] welderPosition  = { 1000, 470 };
    public int[] welder2Position = { 200, 470 };
    public int[] moverPosition   = { 500, 70 };

    // ── Constructor ───────────────────────────────────────────
    public FactoryModel() {
        Arrays.fill(binfull,  false);
        Arrays.fill(holding,  false);
        Arrays.fill(joint,    false);
        Arrays.fill(lockArea, false);
    }

    // ── Negotiation Logic and Operations ───────────────────────
    public boolean anyHolding() {
        for (boolean h : holding) if (h) return true;
        return false;
    }


    public synchronized void pickArm(int p) {
        gripperPart = p;
        binfull[p-1] = false;
    }

    public synchronized void releaseArm() {
        gripperPart = -1;
    }

    public synchronized void pickMover() {
        moving = true;
    }

    public synchronized void releaseMover() {
        moving = false;
        Arrays.fill(joint, false);
    }

    public void weld(String ag) {
        int[] pos = ag.equals("weldingagent2") ? welder2Position : welderPosition;
        for (int i = 0; i < JOINTS; i++) {
            if (pos[0] == JOINT_POS[i][0] && pos[1] == JOINT_POS[i][1]) {
                if (ag.equals("weldingagent2")) {
                    welding2 = true;
                } else {
                    welding = true;
                }
                
                try { 
                    Thread.sleep(5000); 
                } catch (InterruptedException e) { 
                    Thread.currentThread().interrupt(); 
                }
                
                synchronized(this) {
                    joint[i] = true;
                }

                if (ag.equals("weldingagent2")) {
                    welding2 = false;
                } else {
                    welding = false;
                }
            }
        }
    }

    public synchronized void moveTowards(String ag, int tx, int ty, int ta) {
        if (ag.equals("roboticarmagent")) {
            gripperPosition[0] = step(gripperPosition[0], tx);
            gripperPosition[1] = step(gripperPosition[1], ty);
            gripperAngle       = stepAngle(gripperAngle, ta);
        } else if (ag.equals("weldingagent")) {
            welderPosition[0] = step(welderPosition[0], tx);
            welderPosition[1] = step(welderPosition[1], ty);
        } else if (ag.equals("weldingagent2")) {
            welder2Position[0] = step(welder2Position[0], tx);
            welder2Position[1] = step(welder2Position[1], ty);
        } else if (ag.equals("movingagent")) {
            moverPosition[0] = step(moverPosition[0], tx);
            moverPosition[1] = step(moverPosition[1], ty);
        }
        try { Thread.sleep(10); }
        catch (InterruptedException e) { Thread.currentThread().interrupt(); }
    }

    public void refillBin(int x)    { binfull[x-1]    = true;  }
    public void lockArea(int a)      { lockArea[a-1]   = true;  }
    public void unlockArea(int a)    { lockArea[a-1]   = false; }
    public void holdPart(int n)      { holding[n-1]    = true;  }
    public void unholdPart(int n)    { holding[n-1]    = false; }

    // ── Auxiliary Movement Functions ────────────────────
    private int step(int cur, int t) {
        return cur < t ? Math.min(t, cur+5) : cur > t ? Math.max(t, cur-5) : cur;
    }
    
    private int stepAngle(int cur, int t) {
        int d = ((t - cur) % 360 + 360) % 360;
        if (d == 0) return cur;
        return d <= 180 ? (cur+1)%360 : (cur-1+360)%360;
    }

    public void registerBinArtifact(BinArtifact binArtifact) {
        this.binArtifact = binArtifact;
    }

    public void notifyBinUpdate(int binnum, boolean state) {
        if (this.binArtifact != null) {
            this.binArtifact.updatePropertyFromModel(binnum, state);
        }
    }
}