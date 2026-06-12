package factory;

import cartago.*;
import java.util.logging.Logger;

public class RoboticArmArtifact extends Artifact {

    private FactoryModel model;
    private Logger log = Logger.getLogger(RoboticArmArtifact.class.getName());

    // ─────────────────────────────────────────────────────────
    //  init() — called once by CArtAgO after makeArtifact
    // ─────────────────────────────────────────────────────────
    void init() {
        model = FactoryModel.getInstance();

        // pos ini
        defineObsProperty("gripper", model.gripperPosition[0], model.gripperPosition[1], model.gripperAngle);

        // constants for dimensions and positions (observable properties)
        defineObsProperty("bins",    FactoryModel.BINS);
        defineObsProperty("parts",   FactoryModel.PARTS);
        defineObsProperty("holders", FactoryModel.HOLDERS);
        defineObsProperty("joints",  FactoryModel.JOINTS);

        // dim and coord mapping
        for (int i = 0; i < FactoryModel.PARTS; i++) {
            defineObsProperty("partLength", i+1, FactoryModel.PART_LENGTHS[i]);
            defineObsProperty("holderPos",  i+1, FactoryModel.HOLDER_POS[i][0], FactoryModel.HOLDER_POS[i][1]);
            defineObsProperty("partPos",    i+1, FactoryModel.PART_POS[i][0], FactoryModel.PART_POS[i][1], FactoryModel.PART_POS[i][2]);
            defineObsProperty("binPos",     i+1, FactoryModel.BIN_POS[i][0], FactoryModel.BIN_POS[i][1]);
        }
        
        log.info("RoboticArmArtifact initialized with positioning constants.");
    }

    // ─────────────────────────────────────────────────────────
    //  Exclusive RoboticArmAgent operations
    // ─────────────────────────────────────────────────────────
    @OPERATION
    void pick_part(int partnum) {
        model.pickArm(partnum);
        model.notifyBinUpdate(partnum, false);
        pushPositions();
    }

    @OPERATION
    void release_part() {
        model.releaseArm();
        pushPositions();
    }

    @OPERATION
    void move_towards(int x, int y, int angle) {
        model.moveTowards(getOpUserName(), x, y, angle);
        pushPositions();
    }

    @OPERATION
    void move_towards(int x, int y) {
        move_towards(x, y, 0);
    }

    private void pushPositions() {
        updateObsProperty("gripper",
            model.gripperPosition[0],
            model.gripperPosition[1],
            model.gripperAngle);
    }
}