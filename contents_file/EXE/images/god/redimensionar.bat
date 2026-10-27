@echo off
setlocal enabledelayedexpansion

:: Preguntar si se quiere crear una subcarpeta o sobrescribir
echo ========================================================
echo   RESIZING DE IMAGENES AL 05%% (Incluyendo WEBP)
echo ========================================================
echo.
echo Creando carpeta de salida "redimensionadas"...
if not exist "redimensionadas" mkdir "redimensionadas"

echo Procesando imagenes (JPG, JPEG, PNG, WEBP)...

for %%f in (*.jpg *.jpeg *.png *.webp *.JPG *.JPEG *.PNG *.WEBP) do (
    echo Procesando: %%f
    magick "%%f" -resize 05%% "redimensionadas\%%f"
)

echo.
echo ========================================================
echo ¡Proceso terminado con exito!
echo Las imagenes reducidas estan en la carpeta "redimensionadas".
echo ========================================================
pause