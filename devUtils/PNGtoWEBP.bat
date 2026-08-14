@echo off
setlocal

for /R %%i in (*.png) do (
    echo "%%~dpi" | findstr /I "\\export\\" >nul
    if errorlevel 1 (
        echo Processing: "%%i"
        ffmpeg -y -i "%%i" -c:v libwebp -lossless 1 -compression_level 6 -quality 100 "%%~dpi%%~ni.webp" && del "%%i"
    )
)

echo.
echo Done!
pause