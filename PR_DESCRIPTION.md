# IRTS 2025–2026: Factory Automation Group 2 Project Updates

### Project Context
This pull request documents the technical refinements and logic implementations performed by **Group 2** (Carlos Fernández Cabrero, Emilio Augusto Somoza Cruz, and Alberto Emilio Somoza Cruz) for the **Intelligent Real Time Systems** final assignment. 

The following updates transition our initial prototype into a stable Multi-Agent System (MAS) capable of handling realistic industrial scenarios and resource synchronization.

## 🛠 Technical Implementations & Problem Solving

### 1. Synchronization and Resource Locking (Welding Subsystem)
We identified a critical bottleneck where the two welding agents (`weldingagent` and `weldingagent2`) would deadlock or fail during initialization due to concurrent artifact creation.
* **The Fix:** We decoupled the environment setup. The `roboticarmagent` now handles the initial creation of shared resources, while the welders use a `lookupArtifact` and `focus` strategy with a retry mechanism. 
* **Outcome:** This ensures that both welding arms can operate in parallel without "artifact already exists" errors or race conditions during the startup phase.

### 2. Behavioral Modeling: Human vs. Robotic Workflows
To meet the "Intelligent" requirement of the assignment, we replaced the generic bin refill logic with a differentiated behavioral model for humans and robots.
* **Human Logic:** Agents like "Bob" or "Alice" now have variable production speeds. We implemented a **quota-compensation heuristic**: if a human agent falls behind their shift target, they automatically increase their working speed. We also added stochastic "distractions" (like chatting) to simulate real-world variance.
* **Robot Logic:** Robots are faster and consistent, but we introduced a **failure/repair cycle** (8% breakage probability). This forces the other agents in our MAS to adapt to temporary resource unavailability.

### 3. Spatial Calibration (Area 2 Corrections)
During testing, we noticed the agents were attempting to weld in incorrect coordinates in the second assembly area.
* **The Fix:** Recalibrated the `FactoryView` graphics and the `FactoryModel` mount points. 
* **Outcome:** The visual simulation now accurately represents the physical bounding boxes of Area 2, ensuring that the agents' beliefs about "joint positions" match the environment's state.

### 4. Shift Management and System Resilience
We implemented a localized "Shift System" using Jason's `.at` internal action. 
* **Shift Logic:** Every 80 seconds, the system triggers a new shift, resetting production quotas.
* **Cross-Role Support:** We refactored the robot agents to proactively monitor and refill human-assigned bins if a human is off-shift, demonstrating agent collaboration and autonomy.

## 📊 Summary of Contributions
* **Stability:** Resolved "welders lock" race conditions.
* **Realism:** Replaced static timers with dynamic, role-based behaviors.
* **Accuracy:** Updated Area 2 coordinates for precise agent-environment interaction.
* **Infrastructure:** Standardized on Java 21 and cleaned up the `.mas2j` configuration for consistent execution.

---
**Group 2 - UDC Master’s in Artificial Intelligence**
*Carlos, Emilio, and Alberto*
