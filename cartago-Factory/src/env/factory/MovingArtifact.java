package factory;

import cartago.*;
import java.util.logging.Logger;

public class MovingArtifact extends Artifact {

    private FactoryModel model;
    private Logger log = Logger.getLogger(MovingArtifact.class.getName());

    // ─────────────────────────────────────────────────────────
    //  init() — called once by CArtAgO after makeArtifact
    // ─────────────────────────────────────────────────────────
    void init() {
        model = FactoryModel.getInstance();
        defineObsProperty("joints", FactoryModel.JOINTS);

        for (int i = 0; i < FactoryModel.PARTS; i++) {
            defineObsProperty("partPos", i + 1, FactoryModel.PART_POS[i][0], FactoryModel.PART_POS[i][1], FactoryModel.PART_POS[i][2]);
        }

        // we define an observable property for the mover's position (moverX, moverY)
        defineObsProperty("mover", model.moverPosition[0], model.moverPosition[1]);
        
        log.info("MovingArtifact initialized.");
    }

    // ─────────────────────────────────────────────────────────
    //  Exclusive MovingAgent operations
    // ─────────────────────────────────────────────────────────
    @OPERATION
    void pick_part(int partnum) {
        // Direct call to the model's mover switch, ignoring strings
        model.pickMover();
    }
    
    // Overload just in case the .asl agent calls it without parameters
    @OPERATION
    void pick_part() {
        model.pickMover();
    }

    @OPERATION
    void release_part() {
        // Direct call to the model's mover switch. 
        // This triggers the Arrays.fill(joint, false) to clear ghost joints.
        model.releaseMover();
    }

    @OPERATION
    void move_towards(int x, int y, int angle) {
        // Movement can still use getOpUserName() since FactoryModel uses .contains()
        model.moveTowards(getOpUserName(), x, y, angle);
        updateObsProperty("mover", model.moverPosition[0], model.moverPosition[1]);
    }

    @OPERATION
    void move_towards(int x, int y) {
        move_towards(x, y, 0);
    }
}