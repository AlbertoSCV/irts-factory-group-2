package factory;

import cartago.*;
import java.util.logging.Logger;

public class HolderArtifact extends Artifact {

    private FactoryModel model;
    private Logger log = Logger.getLogger(HolderArtifact.class.getName());

    void init() {
        model = FactoryModel.getInstance();
        log.info("HolderArtifact initialized.");
    }

    @OPERATION
    void hold_part(int partnum) {
        model.holdPart(partnum);
        // Throws a signal in CArtAgO instead of updating an observable property
        signal("part_held", partnum);
    }

    @OPERATION
    void unhold_part(int partnum) {
        model.unholdPart(partnum);
        signal("part_unhold", partnum);
    }
}