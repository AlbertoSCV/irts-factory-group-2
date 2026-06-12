@echo off
:: Get the absolute path of the directory where this script is located
set "DIR=%~dp0"

:: Change directory to cartago-Factory
cd /d "%DIR%cartago-Factory"

:: Run using the system's Java. Note the semicolons (;) separating paths for Windows.
java -Djava.awt.headless=false -cp "%DIR%jason\jason-interpreter-3.3.2.jar;%DIR%jason\jade-4.3.jar;%DIR%jason\javax.json-api-1.1.4.jar;%DIR%jason\javax.json-1.1.4.jar;%DIR%cartago-Factory\lib\*;%DIR%cartago-Factory\bin" jason.infra.local.RunLocalMAS factory1.mas2j

pause
