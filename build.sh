#!/bin/bash
# This script is modified from https://github.com/ivan-hc/Chrome-appimage/raw/fe079615eb4a4960af6440fc5961a66c953b0e2d/chrome-builder.sh

APP=mailspring
VERSION="${VERSION:-1.13.3}"
ROOT="$(dirname "$(readlink -f "${0}")")"
VERSION_DIR="${ROOT:?}/$VERSION"
APPDIR="$VERSION_DIR/$APP.AppDir"

mkdir -p "$VERSION_DIR"
cd "$VERSION_DIR" || exit

# Download appimagetool
if [ ! -x "$ROOT/appimagetool" ]; then
    wget -O "$ROOT/appimagetool" "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$(uname -m).AppImage"
    chmod a+x "$ROOT/appimagetool"
fi

# Download deb
if [ ! -f "$ROOT/${APP}-${VERSION}-amd64.deb" ]; then
    wget -O "$ROOT/${APP}-${VERSION}-amd64.deb" "https://github.com/Foundry376/Mailspring/releases/download/${VERSION}/mailspring-${VERSION}-amd64.deb"
fi

# Extract deb
if [ ! -f "$VERSION_DIR/debian-binary" ]; then
    ar x "$ROOT/${APP}-${VERSION}-amd64.deb"
    tar xvf "$VERSION_DIR"/data.tar.*
fi

# Tarball
if [ ! -f "$ROOT/$APP-$VERSION-amd64.tar.xz" ]; then
    echo "Create tarball release"
    [ -d "$APPDIR" ] && rm -rf "${APPDIR}"
    mkdir -p "$APPDIR"
    cp -r "$VERSION_DIR"/usr/share/mailspring/* "$APPDIR/"
    cp -v "$VERSION_DIR"/usr/share/applications/*.desktop "$APPDIR/$APP.desktop"
    cp -v "$VERSION_DIR"/usr/share/icons/hicolor/256x256/apps/*.png "$APPDIR/$APP.png"
    cd "$APPDIR" || exit
    tar cJvf "$ROOT/$APP-$VERSION-amd64.tar.xz" .
fi

# AppImage
if [ ! -f "$ROOT/$APP-$VERSION-amd64.AppImage" ]; then
    echo "Create an AppImage"
    [ -d "$APPDIR" ] && rm -rf "${APPDIR}"
    mkdir -p "$APPDIR"
    cat >> "$APPDIR/AppRun" << 'EOF'
#!/bin/sh
APP=mailspring
HERE="$(dirname "$(readlink -f "${0}")")"
exec "${HERE}/$APP/$APP" "$@"
EOF
    chmod +x "$APPDIR/AppRun"
    cp -r "$VERSION_DIR"/usr/share/mailspring "$APPDIR/mailspring"
    cp -v "$VERSION_DIR"/usr/share/applications/*.desktop "$APPDIR/$APP.desktop"
    cp -v "$VERSION_DIR"/usr/share/icons/hicolor/256x256/apps/*.png "$APPDIR/$APP.png"
    cd "$VERSION_DIR" || exit
    ARCH=x86_64 "$ROOT/appimagetool" -n --verbose "$APPDIR" "$ROOT/$APP-$VERSION-amd64.AppImage"
fi
# rm -rf "$VERSION_DIR"
