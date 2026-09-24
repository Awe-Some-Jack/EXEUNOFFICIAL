@echo off
setlocal enabledelayedexpansion

for /R %%F in (*.jxl) do (
    set "filepath=%%F"
    
    echo !filepath! | findstr /i "\\\.haxelib\\" >nul
    set skip_haxelib=!errorlevel!
    
    echo !filepath! | findstr /i "\\export\\" >nul
    set skip_export=!errorlevel!
    
    if !skip_haxelib! neq 0 (
        if !skip_export! neq 0 (
            echo Processing: %%F
            
            ffmpeg -y -i "%%F" -c:v libwebp -lossless 1 -compression_level 6 -quality 100 "%%~dpnF.webp"
            
            if !errorlevel! equ 0 (
                if exist "%%~dpnF.webp" (
                    del "%%F"
                )
            )
        )
    )
)

echo.
echo Done!
pause