#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

VERSION="${VERSION:-1.0.0}"
APP_NAME="VsSonicEXEUnofficialLauncher"
DISPLAY_NAME="Vs Sonic.EXE Unofficial Launcher"
JFX_VERSION="${JFX_VERSION:-21.0.8}"
JFX_DIR="${JAVAFX_SDK:-$HOME/javafx-sdk-$JFX_VERSION}"
JDK="${JAVA_HOME:-$(/usr/libexec/java_home 2>/dev/null || true)}"
WORK="${WORK_DIR:-${TMPDIR:-/tmp}/vssonic-launcher-build-mac}"
ARCH="$(uname -m)"
ARCH_LABEL="$([ "$ARCH" = arm64 ] && echo silicon || echo "$ARCH")"

if [ ! -x "$JDK/bin/jpackage" ] || [ ! -x "$JDK/bin/javac" ]; then
    echo "JAVA_HOME must point to a full JDK 17+ that has javac and jpackage (got: $JDK)"
    exit 1
fi

if [ ! -d "$JFX_DIR/lib" ]; then
    echo "JavaFX macOS SDK not found at $JFX_DIR"
    echo "Download it from https://gluonhq.com/products/javafx/ (macOS aarch64 or x64 SDK, $JFX_VERSION),"
    echo "unzip it, then run: JAVAFX_SDK=/path/to/javafx-sdk-$JFX_VERSION $0"
    exit 1
fi

if ! file "$JFX_DIR/lib/libglass.dylib" | grep -q "$([ "$ARCH" = arm64 ] && echo arm64 || echo x86_64)"; then
    echo "JavaFX SDK at $JFX_DIR does not match this machine's architecture ($ARCH)"
    exit 1
fi

rm -rf "$WORK"
mkdir -p "$WORK/classes" "$WORK/input" "$WORK/icon.iconset"

"$JDK/bin/javac" --release 17 -d "$WORK/classes" \
    --module-path "$JFX_DIR/lib" --add-modules javafx.controls,javafx.media \
    src/*.java

"$JDK/bin/jar" --create --file "$WORK/input/$APP_NAME.jar" --main-class Main -C "$WORK/classes" .
cp -r media "$WORK/input/media"
mkdir -p "$WORK/input/icons"
cp icons/iconOG.png "$WORK/input/icons/"

for s in 16 32 128 256 512; do
    sips -z $s $s icons/iconOG.png --out "$WORK/icon.iconset/icon_${s}x${s}.png" >/dev/null
done
for s in 16 32 128 256; do
    sips -z $((s * 2)) $((s * 2)) icons/iconOG.png --out "$WORK/icon.iconset/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$WORK/icon.iconset" -o "$WORK/icon.icns"

"$JDK/bin/jlink" \
    --module-path "$JDK/jmods:$JFX_DIR/lib" \
    --add-modules javafx.controls,javafx.media,java.logging,java.desktop,jdk.unsupported,jdk.crypto.ec \
    --strip-debug --no-header-files --no-man-pages \
    --output "$WORK/runtime"
cp "$JFX_DIR"/lib/*.dylib "$WORK/runtime/lib/"

"$JDK/bin/jpackage" \
    --type app-image \
    --name "$DISPLAY_NAME" \
    --app-version "$VERSION" \
    --input "$WORK/input" \
    --main-jar "$APP_NAME.jar" \
    --main-class Main \
    --runtime-image "$WORK/runtime" \
    --icon "$WORK/icon.icns" \
    --mac-package-identifier "com.vssonicexe.unofficial.launcher" \
    --java-options "--add-modules=javafx.controls,javafx.media" \
    --dest "$WORK/dist"

APP="$WORK/dist/$DISPLAY_NAME.app"
chmod -R u+w "$APP"

cat > "$APP/Contents/MacOS/start" <<EOF
#!/bin/sh
HERE="\$(cd "\$(dirname "\$0")" && pwd)"
cd "\$HERE/../app"
exec "\$HERE/$DISPLAY_NAME" "\$@"
EOF
chmod +x "$APP/Contents/MacOS/start"
/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable start" "$APP/Contents/Info.plist"
codesign --force --deep -s - "$APP"

OUT="out/$APP_NAME-$VERSION-mac-$ARCH_LABEL"
mkdir -p out
rm -rf "$OUT.app" "$OUT.zip"
cp -R "$APP" "$OUT.app"
ditto -c -k --keepParent "$OUT.app" "$OUT.zip"
echo "Built: $PWD/$OUT.app"
echo "Zip:   $PWD/$OUT.zip"
