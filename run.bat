@echo off
:: Get the absolute path of the directory where this script is located
set "DIR=%~dp0"

:: Compile all Java artifacts before running the MAS
if not exist "%DIR%cartago-Factory\bin" mkdir "%DIR%cartago-Factory\bin"
javac -cp "%DIR%cartago-Factory\lib\*" ^
	"%DIR%cartago-Factory\src\env\factory\AssemblyAreaArtifact.java" ^
	"%DIR%cartago-Factory\src\env\factory\BinArtifact.java" ^
	"%DIR%cartago-Factory\src\env\factory\FactoryArtifact.java" ^
	"%DIR%cartago-Factory\src\env\factory\FactoryModel.java" ^
	"%DIR%cartago-Factory\src\env\factory\FactoryView.java" ^
	"%DIR%cartago-Factory\src\env\factory\HolderArtifact.java" ^
	"%DIR%cartago-Factory\src\env\factory\MovingArtifact.java" ^
	"%DIR%cartago-Factory\src\env\factory\RoboticArmArtifact.java" ^
	"%DIR%cartago-Factory\src\env\factory\WelderArtifact.java" ^
	-d "%DIR%cartago-Factory\bin"

:: Change directory to cartago-Factory
cd /d "%DIR%cartago-Factory"

:: Run using the system's Java. Note the semicolons (;) separating paths for Windows.
java -Djava.awt.headless=false -cp "%DIR%jason\jason-interpreter-3.3.2.jar;%DIR%jason\jade-4.3.jar;%DIR%jason\javax.json-api-1.1.4.jar;%DIR%jason\javax.json-1.1.4.jar;%DIR%cartago-Factory\lib\*;%DIR%cartago-Factory\bin" jason.infra.local.RunLocalMAS factory1.mas2j

pause
