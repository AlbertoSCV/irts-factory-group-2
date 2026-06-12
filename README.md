# Practice Work - Group 2

### Universidade da Coruña
#### Master’s Degree in Artificial Intelligence
#### Intelligent Real Time System 2025–2026

Carlos Fernández Cabrero,
Emilio Augusto Somoza Cruz,
Alberto Emilio Somoza Cruz

## Assembly Factory

This repository contains an assembly-line simulation built with Jason 3.3 as the BDI runtime and CArtAgO as the environment and artifact layer.

## Project structure

```text
README.md
run.sh                         Linux and macOS launcher
run.bat                        Windows launcher
cartago-Factory/
  factory1.mas2j               Jason project entrypoint
  logging.properties
  bin/                         compiled classes
  lib/                         bundled libraries
  src/
    agt/
      assemblyareaagent.asl
      binagent.asl
      focus_factory.asl
      holdingagent.asl
      movingagent.asl
      roboticarmagent.asl
      weldingagent.asl
    env/
      factory/
        FactoryArtifact.java
jason/                         Jason runtime and dependencies
```

## Requirements

| Tool | Version |
|------|---------|
| Java | 17 or newer |
| Jason | 3.3 |
| CArtAgO | 3.x |

## Build and run

The preferred way to start the project is with the provided launcher script for your platform. The scripts recompile the Java artifact automatically and then start the MAS with the bundled Jason libraries.

### Run the project

Use one of the launchers from the repository root. They compile the Java artifact first, so this is the simplest way to run the project:

```bash
./run.sh
```

On Windows:

```cmd
run.bat
```

If you prefer to launch it manually, the project entrypoint is `cartago-Factory/factory1.mas2j`.

### Manual build

If you want to compile manually before running, use the commands below from the repository root.

```bash
mkdir -p cartago-Factory/bin
javac -cp "jason/*:cartago-Factory/lib/*" \
  cartago-Factory/src/env/factory/FactoryArtifact.java \
  -d cartago-Factory/bin
```

On Windows:

```cmd
mkdir cartago-Factory\bin
javac -cp "jason\*;cartago-Factory\lib\*" ^
  cartago-Factory\src\env\factory\FactoryArtifact.java ^
  -d cartago-Factory\bin
```

### Manual run

If you want to run it manually after compiling, use:

```bash
jason cartago-Factory/factory1.mas2j
```

If `jason` is not on your `PATH`, use the explicit Java command instead:

```bash
java -cp "jason/*:cartago-Factory/lib/*:cartago-Factory/bin" \
  jason.infra.local.RunLocalMAS cartago-Factory/factory1.mas2j
```

On Windows:

```cmd
java -cp "jason\*;cartago-Factory\lib\*;cartago-Factory\bin" ^
  jason.infra.local.RunLocalMAS cartago-Factory\factory1.mas2j
```

## Implementation notes

The robot agent creates the shared CArtAgO artifact at startup, and the rest of the agents resolve it through `lookupArtifact` before focusing on it. This keeps the Jason project self-contained without relying on a JaCaMo workspace declaration.

Observable properties are used instead of the older percept-based environment approach, which lets the agents receive updates directly after focusing on the artifact.

## Credits

This work was developed by Carlos Fernández Cabrero, Emilio Augusto Somoza Cruz, and Alberto Emilio Somoza Cruz for the Intelligent Real Time System course in the Master’s Degree in Artificial Intelligence at Universidade da Coruña.

The project also preserves and adapts material from the original factory simulation author where it remains useful and consistent with the current implementation.
