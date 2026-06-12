package factory;

import cartago.*;
import java.util.logging.Logger;

public class WelderArtifact extends Artifact {

    private FactoryModel model;
    private Logger log = Logger.getLogger(WelderArtifact.class.getName());

    // ─────────────────────────────────────────────────────────
    //  init() — called once by CArtAgO after makeArtifact
    // ─────────────────────────────────────────────────────────
    void init() {
        model = FactoryModel.getInstance();

        for (int i = 0; i < FactoryModel.JOINTS; i++) {
            defineObsProperty("jointPos", i + 1, FactoryModel.JOINT_POS[i][0], FactoryModel.JOINT_POS[i][1]);
        }

        // initial position of the welder (observable property)
        defineObsProperty("welder", model.welderPosition[0], model.welderPosition[1]);
        defineObsProperty("holders", FactoryModel.HOLDERS);
        
        log.info("WelderArtifact initialized.");
    }

    // ─────────────────────────────────────────────────────────
    //  Exclusive WeldingAgent operations
    // ─────────────────────────────────────────────────────────
    @OPERATION
    void weld() {
        model.weld();
        updateObsProperty("welder", model.welderPosition[0], model.welderPosition[1]);
    }

    @OPERATION
    void move_towards(int x, int y, int angle) {
        model.moveTowards(getOpUserName(), x, y, angle);
        updateObsProperty("welder", model.welderPosition[0], model.welderPosition[1]);
    }

    @OPERATION
    void move_towards(int x, int y) {
        move_towards(x, y, 0);
    }
}