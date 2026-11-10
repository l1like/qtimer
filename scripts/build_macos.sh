#!/usr/bin/env bash
# ============================================================
# 在 macOS 上打包 QTimer：生成 QTimer.app / .zip / .dmg
#
# 用法：
#   bash scripts/build_macos.sh                             # 按当前机器架构打包
#   TARGET_ARCH=universal2 bash scripts/build_macos.sh      # 通用二进制（需 universal2 Python）
#   CODESIGN_IDENTITY="Developer ID Application: xxx" bash scripts/build_macos.sh
#
# 说明：
#   * PyInstaller 不支持交叉编译，本脚本只能在 macOS 上执行；
#   * PySide6 6.12 的 macOS wheel 为 universal2，最低要求 macOS 14（Qt 官方要求 14.4+）；
#   * 未提供 CODESIGN_IDENTITY 时使用 ad-hoc 签名：本机可运行，
#     但分发给他人后会被 Gatekeeper 拦截，需用户手动放行（见脚本末尾提示）。
# ============================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

info() { printf '\033[36m==> %s\033[0m\n' "$*"; }
fail() { printf '\033[31m[错误] %s\033[0m\n' "$*" >&2; exit 1; }

if [[ "$(uname -s)" != "Darwin" ]]; then
    fail "只能在 macOS 上打包 .app（PyInstaller 不支持交叉编译）。"
fi

PYTHON="${PYTHON:-}"
if [[ -z "$PYTHON" ]]; then
    if [[ -x ".venv/bin/python" ]]; then
        PYTHON=".venv/bin/python"
    else
        PYTHON="$(command -v python3 || true)"
    fi
fi
if [[ -z "$PYTHON" || ! -x "$PYTHON" ]]; then
    fail "未找到 Python 3.10+。请先执行：python3 -m venv .venv && .venv/bin/pip install -r requirements-dev.txt"
fi

"$PYTHON" -c "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('PyInstaller') else 1)" \
    || fail "缺少 PyInstaller，请执行：$PYTHON -m pip install -r requirements-dev.txt"
"$PYTHON" -c "import importlib.util, sys; sys.exit(0 if importlib.util.find_spec('PySide6') else 1)" \
    || fail "缺少 PySide6，请执行：$PYTHON -m pip install -r requirements-dev.txt"

VER="$("$PYTHON" scripts/gen_version_info.py --print-version)"
ARCH_TAG="${TARGET_ARCH:-$(uname -m)}"
info "QTimer v${VER} / 目标架构：${ARCH_TAG}"

PYI_ARGS=(--noconfirm --clean --windowed --onedir --name QTimer)
PYI_ARGS+=(--osx-bundle-identifier "com.qwejay.qtimer")
if [[ -f "icon.icns" ]]; then
    PYI_ARGS+=(--icon=icon.icns)
else
    info "未找到 icon.icns，将使用 PyInstaller 默认图标"
fi
if [[ -n "${TARGET_ARCH:-}" ]]; then
    PYI_ARGS+=(--target-arch "${TARGET_ARCH}")
fi
if [[ -n "${CODESIGN_IDENTITY:-}" ]]; then
    PYI_ARGS+=(--codesign-identity "${CODESIGN_IDENTITY}")
fi

info "PyInstaller ${PYI_ARGS[*]} main.py"
"$PYTHON" -m PyInstaller "${PYI_ARGS[@]}" main.py

APP="dist/QTimer.app"
if [[ ! -d "$APP" ]]; then
    fail "打包结束但未找到 $APP"
fi

# ---- 写入版本号（PyInstaller 命令行不暴露 BUNDLE version，默认是 0.0.0）----
PLIST="$APP/Contents/Info.plist"
if [[ -f "$PLIST" ]]; then
    plutil -replace CFBundleShortVersionString -string "$VER" "$PLIST" 2>/dev/null \
        || plutil -insert CFBundleShortVersionString -string "$VER" "$PLIST"
    plutil -replace CFBundleVersion -string "$VER" "$PLIST" 2>/dev/null \
        || plutil -insert CFBundleVersion -string "$VER" "$PLIST"
fi

# ---- 修改 Info.plist 会使签名失效，重新签名 ----
if [[ -n "${CODESIGN_IDENTITY:-}" ]]; then
    info "使用 Developer ID 签名（hardened runtime）"
    codesign --force --deep --options runtime --timestamp --sign "$CODESIGN_IDENTITY" "$APP"
else
    info "使用 ad-hoc 签名（本机可运行；分发给他人需用户手动放行）"
    codesign --force --deep --sign - "$APP"
fi
codesign --verify --deep --strict "$APP" || fail "签名校验失败"

# ---- 打包 ZIP（保留符号链接/权限，等价于 Finder 压缩）----
mkdir -p dist
SUFFIX="v${VER}_${ARCH_TAG}"
ZIP="dist/QTimer_${SUFFIX}.zip"
DMG="dist/QTimer_${SUFFIX}.dmg"

info "生成 ZIP：$ZIP"
rm -f "$ZIP"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"

# ---- 打包 DMG（带 Applications 快捷方式，方便拖拽安装）----
info "生成 DMG：$DMG"
STAGE="build/dmg_stage"
rm -rf "$STAGE"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
rm -f "$DMG"
hdiutil create -volname "QTimer ${VER}" -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null

info "打包完成"
for f in "$DMG" "$ZIP"; do
    printf '  %-52s %s\n' "$f" "$(du -h "$f" | cut -f1)"
done
printf '\n提示：未公证（notarized）的 App 首次打开会被提示“无法验证开发者”，\n'
printf '      可在「系统设置 → 隐私与安全性」点“仍要打开”，或执行：\n'
printf '      xattr -dr com.apple.quarantine /Applications/QTimer.app\n'
