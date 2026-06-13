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
        defineObsProperty("welder2", model.welder2Position[0], model.welder2Position[1]);
        defineObsProperty("holders", FactoryModel.HOLDERS);
        
        log.info("WelderArtifact initialized.");
    }

    // ─────────────────────────────────────────────────────────
    //  Exclusive WeldingAgent operations
    // ─────────────────────────────────────────────────────────
    @OPERATION
    void weld() {
        String user = getOpUserName();
        this.beginExternalSession();
        model.weld(user);
        this.endExternalSession();
        if (user.equals("weldingagent2")) {
            updateObsProperty("welder2", model.welder2Position[0], model.welder2Position[1]);
        } else {
            updateObsProperty("welder", model.welderPosition[0], model.welderPosition[1]);
        }
    }

    @OPERATION
    void move_towards(int x, int y, int angle) {
        String user = getOpUserName();
        model.moveTowards(user, x, y, angle);
        if (user.equals("weldingagent2")) {
            updateObsProperty("welder2", model.welder2Position[0], model.welder2Position[1]);
        } else {
            updateObsProperty("welder", model.welderPosition[0], model.welderPosition[1]);
        }
    }

    @OPERATION
    void move_towards(int x, int y) {
        move_towards(x, y, 0);
    }
}