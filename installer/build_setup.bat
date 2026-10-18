@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "PY=py -3.15"
set "SOURCE=%~dp0SpotiWoW-DevSetup.py"
set "MANIFEST=%~dp0release-manifest.json"
set "ICON=%~dp0SpotiWoW-Dev-Ruby.ico"
set "OUT=%~dp0dist"
set "WORK=%~dp0build_temp"

echo.
echo SpotiWoW-Dev Setup EXE builder
set /p "REPO=GitHub repository (owner/name), e.g. user/SpotiWoW-Dev: "
echo %REPO%| findstr /r /x "[A-Za-z0-9_.-][A-Za-z0-9_.-]*/[A-Za-z0-9_.-][A-Za-z0-9_.-]*" >nul
if errorlevel 1 (
  echo ERROR: Expected owner/name. This repository must have a public GitHub Release.
  pause
  exit /b 2
)
echo %REPO%>"%~dp0repo.txt"
if not exist "%SOURCE%" (
  echo ERROR: Missing %SOURCE%
  pause
  exit /b 2
)
if not exist "%ICON%" (
  echo ERROR: Missing %ICON%
  pause
  exit /b 2
)
if not exist "%MANIFEST%" (
  echo ERROR: Missing release-manifest.json. Build setup from a prepared release checkout.
  pause
  exit /b 2
)
%PY% --version >nul 2>nul
if errorlevel 1 (
  echo Python 3.15 was not found. Install Python 3.15 first.
  pause
  exit /b 1
)
%PY% -m pip install --upgrade "pyinstaller>=6.21"
if errorlevel 1 (
  echo PyInstaller install failed.
  pause
  exit /b 1
)
if not exist "%OUT%" mkdir "%OUT%"
%PY% -m PyInstaller --clean --noconfirm --onefile --windowed --name "SpotiWoW-Dev-Setup" --icon "%ICON%" --add-data "%~dp0repo.txt;." --add-data "%MANIFEST%;." --add-data "%ICON%;." --distpath "%OUT%" --workpath "%WORK%" --specpath "%WORK%" "%SOURCE%"
if errorlevel 1 (
  echo Setup EXE build failed. See the error output above.
  pause
  exit /b 1
)
echo.
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command "(Get-Content -Raw -LiteralPath '%MANIFEST%' | ConvertFrom-Json).tag"`) do set "TAG=%%V"
echo %TAG%| findstr /r /x "v[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*" >nul
if errorlevel 1 (
  echo ERROR: release-manifest.json must contain a vMAJOR.MINOR.PATCH tag.
  pause
  exit /b 2
)
set "VERSIONED_SETUP=%OUT%\SpotiWoW-Dev-Setup-%TAG%.exe"
move /y "%OUT%\SpotiWoW-Dev-Setup.exe" "%VERSIONED_SETUP%" >nul
if errorlevel 1 (
  echo ERROR: Could not rename the setup to its versioned filename.
  pause
  exit /b 1
)
echo SUCCESS: "%VERSIONED_SETUP%"
echo The setup downloads and verifies the portable package for its exact GitHub release tag and commit.
pause

