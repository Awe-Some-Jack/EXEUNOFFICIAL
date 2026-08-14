@echo off
setlocal enabledelayedexpansion

REM If an argument (folder path) is provided, use it; otherwise use current folder
if "%~1"=="" (
    set "target_dir=%cd%"
) else (
    set "target_dir=%~1"
)

echo Optimizing PNG files in: %target_dir%
echo.

REM Check if oxipng is in PATH
where oxipng >nul 2>nul
if errorlevel 1 (
    echo ERROR: oxipng not found.
    echo Please install oxipng and add it to PATH, or place oxipng.exe next to this batch file.
    pause
    exit /b 1
)

REM Recursively process all .png files
for /r "%target_dir%" %%i in (*.png) do (
    oxipng -o max --strip safe --alpha "%%i"
    if errorlevel 1 (
        echo Warning: Failed to process %%i
    )
)

echo.
echo Done!
pause