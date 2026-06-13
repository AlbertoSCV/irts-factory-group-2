#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$DIR/cartago-Factory/bin"
javac -cp "$DIR/cartago-Factory/lib/*" \
	"$DIR/cartago-Factory/src/env/factory/AssemblyAreaArtifact.java" \
	"$DIR/cartago-Factory/src/env/factory/BinArtifact.java" \
	"$DIR/cartago-Factory/src/env/factory/FactoryModel.java" \
	"$DIR/cartago-Factory/src/env/factory/FactoryView.java" \
	"$DIR/cartago-Factory/src/env/factory/HolderArtifact.java" \
	"$DIR/cartago-Factory/src/env/factory/MovingArtifact.java" \
	"$DIR/cartago-Factory/src/env/factory/RoboticArmArtifact.java" \
	"$DIR/cartago-Factory/src/env/factory/WelderArtifact.java" \
	-d "$DIR/cartago-Factory/bin"

cd "$DIR/cartago-Factory"

# Using the machine's system Java instead of the local runtime
java -Djava.awt.headless=false -cp "$DIR/jason/jason-interpreter-3.3.2.jar:$DIR/jason/jade-4.3.jar:$DIR/jason/javax.json-api-1.1.4.jar:$DIR/jason/javax.json-1.1.4.jar:$DIR/cartago-Factory/lib/*:$DIR/cartago-Factory/bin" jason.infra.local.RunLocalMAS factory1.mas2j
