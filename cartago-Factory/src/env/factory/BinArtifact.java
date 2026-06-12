package factory;

import cartago.*;
import java.util.logging.Logger;

public class BinArtifact extends Artifact {

    private FactoryModel model;
    private Logger log = Logger.getLogger(BinArtifact.class.getName());

    // ─────────────────────────────────────────────────────────
    //  init() — called once by CArtAgO after makeArtifact
    // ─────────────────────────────────────────────────────────
    void init() {

        model = FactoryModel.getInstance();
        model.registerBinArtifact(this);

        // Observable properties for each bin (bin_1, bin_2, ..., bin_6)
        for (int i = 1; i <= FactoryModel.BINS; i++) {
            // All bins start empty (binfull = false)
            defineObsProperty("bin_" + i, false);
        }
        
        log.info("BinArtifact initialized. Properties bin_1 to bin_6 created.");
    }

    // ─────────────────────────────────────────────────────────
    // Exclusive binAgent operations
    // ─────────────────────────────────────────────────────────
    @OPERATION
    void refill_bin(int binnum) {
        model.refillBin(binnum);
        
        updateObsProperty("bin_" + binnum, true);
        
        log.info("Bin " + binnum + " refilled.");
    }

    public void updatePropertyFromModel(int binnum, boolean state) {
        log.info("Syncing bin_" + binnum + " to " + state);
        updateObsProperty("bin_" + binnum, state);
    }
}