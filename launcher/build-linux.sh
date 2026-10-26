#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

VERSION="${VERSION:-1.0.0}"
APP_NAME="VsSonicEXEUnofficialLauncher"
PKG_NAME="vssonicexe-unofficial-launcher"
JFX_VERSION="17.0.17"
JFX_DIR="${JAVAFX_SDK:-$PWD/out/javafx-sdk-$JFX_VERSION}"
JDK="${JAVA_HOME:-/usr/lib/jvm/jdk-21.0.10-oracle-x64}"
TOOL="${APPIMAGETOOL:-$PWD/out/appimagetool-x86_64.AppImage}"
WORK="${WORK_DIR:-${TMPDIR:-/tmp}/vssonic-launcher-build}"

if [ ! -x "$JDK/bin/jpackage" ] || [ ! -x "$JDK/bin/javac" ]; then
    echo "JAVA_HOME must point to a full JDK 17+ that has javac and jpackage (got: $JDK)"
    exit 1
fi

if [ ! -d "$JFX_DIR/lib" ]; then
    echo "JavaFX Linux SDK not found at $JFX_DIR"
    echo "Download it from https://gluonhq.com/products/javafx/ (Linux x64 SDK, $JFX_VERSION),"
    echo "unzip it, then run: JAVAFX_SDK=/path/to/javafx-sdk-$JFX_VERSION $0"
    exit 1
fi

if [ ! -x "$TOOL" ]; then
    echo "appimagetool not found at $TOOL"
    echo "Get appimagetool-x86_64.AppImage from https://github.com/AppImage/appimagetool/releases,"
    echo "chmod +x it, then run: APPIMAGETOOL=/path/to/appimagetool-x86_64.AppImage $0"
    exit 1
fi

if ! command -v ffmpeg >/dev/null; then
    echo "ffmpeg is required to convert launcher sounds to WAV (JavaFX cannot decode MP3 on Linux)"
    exit 1
fi

rm -rf "$WORK"
mkdir -p "$WORK/classes" "$WORK/input"

"$JDK/bin/javac" --release 17 -d "$WORK/classes" \
    --module-path "$JFX_DIR/lib" --add-modules javafx.controls,javafx.media \
    src/*.java

"$JDK/bin/jar" --create --file "$WORK/input/$APP_NAME.jar" --main-class Main -C "$WORK/classes" .
cp -r media "$WORK/input/media"

for f in "$WORK"/input/media/sounds/*.mp3; do
    [ -e "$f" ] || continue
    ffmpeg -loglevel error -y -i "$f" "${f%.mp3}.wav"
    rm "$f"
done

"$JDK/bin/jlink" \
    --module-path "$JDK/jmods:$JFX_DIR/lib" \
    --add-modules javafx.controls,javafx.media,java.logging,java.desktop,jdk.unsupported,jdk.crypto.ec \
    --strip-debug --no-header-files --no-man-pages \
    --output "$WORK/runtime"
cp "$JFX_DIR"/lib/*.so "$WORK/runtime/lib/"

"$JDK/bin/jpackage" \
    --type app-image \
    --name "$PKG_NAME" \
    --app-version "$VERSION" \
    --input "$WORK/input" \
    --main-jar "$APP_NAME.jar" \
    --main-class Main \
    --runtime-image "$WORK/runtime" \
    --icon icons/iconOG.png \
    --java-options "--add-modules=javafx.controls,javafx.media" \
    --dest "$WORK/dist"

APPDIR="$WORK/AppDir"
cp -r "$WORK/dist/$PKG_NAME" "$APPDIR"
cp icons/iconOG.png "$APPDIR/$PKG_NAME.png"
cp icons/iconOG.png "$APPDIR/.DirIcon"

cat > "$APPDIR/$PKG_NAME.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Vs Sonic.EXE Unofficial Launcher
Exec=$PKG_NAME
Icon=$PKG_NAME
Categories=Game;
Terminal=false
EOF

cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
cd "$HERE/lib/app"
exec "$HERE/bin/vssonicexe-unofficial-launcher" "$@"
EOF
chmod +x "$APPDIR/AppRun"

OUT="$WORK/$APP_NAME-$VERSION-x86_64.AppImage"
ARCH=x86_64 "$TOOL" --appimage-extract-and-run "$APPDIR" "$OUT"

mkdir -p out
cp "$OUT" out/
echo "Built: $PWD/out/$(basename "$OUT")"
