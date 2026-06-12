package factory;

import cartago.*;
import javax.swing.SwingUtilities;
import java.util.logging.Logger;

public class AssemblyAreaArtifact extends Artifact {

    private FactoryModel model;
    private Logger log = Logger.getLogger(AssemblyAreaArtifact.class.getName());

    // ─────────────────────────────────────────────────────────
    //  init() — called once by CArtAgO after makeArtifact
    // ─────────────────────────────────────────────────────────
    void init() {
        model = FactoryModel.getInstance();

        defineObsProperty("area_locked_1", false);
        defineObsProperty("area_locked_2", false);

        // Centralized GUI initialization
        SwingUtilities.invokeLater(() -> new FactoryView(model));
        
        log.info("AssemblyAreaArtifact starting and GUI running.");
    }

    // ─────────────────────────────────────────────────────────
    //  Exclusive AssemblyAreaAgent operations
    // ─────────────────────────────────────────────────────────
    @OPERATION
    void lock_area(int area) {
        model.lockArea(area);
        updateObsProperty("area_locked_" + area, true);
    }

    @OPERATION
    void unlock_area(int area) {
        model.unlockArea(area);
        updateObsProperty("area_locked_" + area, false);
    }
}