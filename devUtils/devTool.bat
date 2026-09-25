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
        goto :CHOOSE_FORMAT
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

:CHOOSE_FORMAT
echo ==========================================
echo SELECT TARGET FORMAT FOR CONVERSION:
echo [1] Convert to JXL
echo [2] Convert to WEBP
echo [3] Skip conversion
echo ==========================================
choice /C 123 /N /M "Enter your choice (1, 2, or 3): "

if errorlevel 3 goto :SORT_FILES
if errorlevel 2 goto :CONVERT_WEBP
if errorlevel 1 goto :CONVERT_JXL

:CONVERT_JXL
echo.
echo IMAGES CONVERTER to JXL
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
goto :SORT_FILES

:CONVERT_WEBP
echo.
echo IMAGES CONVERTER to WEBP
echo.
echo PNG to WEBP
echo.
echo Processing "assets/"...
for /R "assets" %%i in (*.png) do (
    echo Processing: "%%i"
    ffmpeg -y -i "%%i" -c:v libwebp -lossless 1 -compression_level 6 -quality 100 "%%~dpi%%~ni.webp" && del "%%i"
)
echo Done!
echo Processing "contents_file/"...
for /R "contents_file" %%i in (*.png) do (
    echo Processing: "%%i"
    ffmpeg -y -i "%%i" -c:v libwebp -lossless 1 -compression_level 6 -quality 100 "%%~dpi%%~ni.webp" && del "%%i"
)
echo Done!
goto :SORT_FILES

:SORT_FILES
echo.
echo Sorting files from "contents_file/" to "embedded_contents_file/"...
python "devUtils\sortContentFolder.py"
echo.
pause