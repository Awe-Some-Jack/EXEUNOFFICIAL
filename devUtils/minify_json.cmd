@echo off
setlocal

echo JSON Minifier
echo Drag a JSON file or folder onto this CMD.
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dpn0.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo Done. Press any key to close.
) else (
    echo An error occurred. Check the message above. Press any key to close.
)
pause >nul
exit /b %EXIT_CODE%
