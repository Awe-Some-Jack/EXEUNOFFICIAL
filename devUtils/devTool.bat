@echo off

setlocal

cd /d "%~dp0.."

echo === DEV TOOL ===
echo.
echo IMAGE OPTIMIZER (PNGs, WEBPs and JXLs)
echo.
where oxipng >nul 2>nul
if errorlevel 1 (
    if exist "%~dp0oxipng.exe" (
        set "OXIPNG=%~dp0oxipng.exe"
        echo OxiPNG found next to this batch file.
    ) else (
        echo WARNING: oxipng not found.
        echo Skipping image optimization...
        echo.
        goto :CONVERT_PNG
    )
) else (
    set "OXIPNG=oxipng"
    echo OxiPNG found in PATH.
)
echo.
echo Optimizing PNGs in "assets/"...
for /R "assets" %%i in (*.png) do (
    echo Optimizing: "%%i"
    "%OXIPNG%" -o max --strip safe --alpha "%%i"
    if errorlevel 1 (
        echo Warning: Failed to optimize "%%i"
    )
)
echo Done!
echo.
echo Optimizing PNGs in "contents_file/"...
for /R "contents_file" %%i in (*.png) do (
    echo Optimizing: "%%i"
    "%OXIPNG%" -o max --strip safe --alpha "%%i"
    if errorlevel 1 (
        echo Warning: Failed to optimize "%%i"
    )
)
echo Done!
echo.
:CONVERT_PNG
echo IMAGES CONVERTER (PNGs and WEBPs) to JXL
echo.
echo PNG to JXL
echo.
echo Processing "assets/"...
for /R "assets" %%i in (*.png) do (
    echo Processing: "%%i"
    ffmpeg -y -i "%%i" -c:v libjxl -distance 0 -effort 9 -update 1 "%%~dpi%%~ni.jxl" && del "%%i"
)
echo Done!
echo Processing "contents_file/"...
for /R "contents_file" %%i in (*.png) do (
    echo Processing: "%%i"
    ffmpeg -y -i "%%i" -c:v libjxl -distance 0 -effort 9 -update 1 "%%~dpi%%~ni.jxl" && del "%%i"
)
echo Done!
echo.
echo WEBP to JXL
echo.
echo Processing "assets/"...
for /R "assets" %%i in (*.webp) do (
    echo Processing: "%%i"
    ffmpeg -y -i "%%i" -c:v libjxl -distance 0 -effort 9 -update 1 "%%~dpi%%~ni.jxl" && del "%%i"
)
echo Done!
echo Processing "contents_file/"...
for /R "contents_file" %%i in (*.webp) do (
    echo Processing: "%%i"
    ffmpeg -y -i "%%i" -c:v libjxl -distance 0 -effort 9 -update 1 "%%~dpi%%~ni.jxl" && del "%%i"
)
echo Done!
echo.
echo Sorting files from "contents_file/" to "embedded_contents_file/"...
python "devUtils\sortContentFolder.py"
echo.
pause