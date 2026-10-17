@echo off
setlocal
set "GAME_DIR=%~dp0gravity_flip_creator"
set "PORT=8000"

if not exist "%GAME_DIR%\index.html" (
  echo Could not find the game at "%GAME_DIR%\index.html".
  pause
  exit /b 1
)

where py >nul 2>&1
if not errorlevel 1 (
  start "Gravity Flip local server" py -3 -m http.server %PORT% --directory "%GAME_DIR%"
  goto open_game
)

where python >nul 2>&1
if not errorlevel 1 (
  start "Gravity Flip local server" python -m http.server %PORT% --directory "%GAME_DIR%"
  goto open_game
)

set "PYTHON_EXE=%LocalAppData%\Programs\Python\Python313\python.exe"
if exist "%PYTHON_EXE%" (
  start "Gravity Flip local server" "%PYTHON_EXE%" -m http.server %PORT% --directory "%GAME_DIR%"
  goto open_game
)

echo Python 3 was not found. Install Python 3, then run this file again.
pause
exit /b 1

:open_game
timeout /t 2 /nobreak >nul
start "" "http://127.0.0.1:%PORT%/"
echo The local game is open at http://127.0.0.1:%PORT%/
echo Keep the server window open while playing. Press Ctrl+C there to stop it.