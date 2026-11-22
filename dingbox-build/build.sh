#!/usr/bin/env bash
# DingBox cloud build: sing-box-for-apple client + jieluojun ding-capable core.
# All build logic lives here so it can be iterated without touching the workflow YAML.
set -x
WS="$GITHUB_WORKSPACE"
LOGDIR="$WS/dingbox-build"
FAILLOG="$LOGDIR/last-failure-log.md"

# shellcheck disable=SC1091
[ -f "$LOGDIR/config.env" ] && . "$LOGDIR/config.env"
CORE_REPO="${CORE_REPO:-jieluojun/sing-box}"
CORE_REF="${CORE_REF:-v1.15.0-alpha.13-d82b4e632}"
CLIENT_REPO="${CLIENT_REPO:-SagerNet/sing-box-for-apple}"
CLIENT_REF="${CLIENT_REF:-}"
GO_VERSION="${GO_VERSION:-1.25.5}"

on_failure() {
  local rc=$?
  if [ $rc -ne 0 ]; then
    {
      echo "# build failure log - run ${GITHUB_RUN_NUMBER:-?} - $(date -u)"
      echo "## build errors (grep)"; grep -E "undefined:|error:|failed: exit status|panic:" "$WS/libbox-build.log" 2>/dev/null | grep -v -E "^github\.com|^google\.golang|^golang\.org|^go\.uber" | head -40 || echo "(none)"
      echo "## libbox-build.log (tail)"; tail -300 "$WS/libbox-build.log" 2>/dev/null || echo "(none)"
      echo "## xcodebuild.log (tail)"; tail -200 "$WS/xcodebuild.log" 2>/dev/null || echo "(none)"
      echo "## build.sh trace (tail)"; tail -120 "$WS/build-trace.log" 2>/dev/null || echo "(none)"
    } > "$FAILLOG" 2>/dev/null || true
    cd "$WS" || exit 0
    git config user.email "actions@github.com" || true
    git config user.name "dingbox-build" || true
    git add dingbox-build/last-failure-log.md || true
    git commit -m "dingbox: failure log run ${GITHUB_RUN_NUMBER:-?}" || true
    git push origin HEAD:main || true
    # fallback: publish raw logs as a public release (fetchable without auth)
    if command -v gh >/dev/null 2>&1; then
      assets=""
      for f in "$WS/build-trace.log" "$WS/libbox-build.log" "$WS/xcodebuild.log"; do
        [ -f "$f" ] && assets="$assets $f"
      done
      if [ -n "$assets" ]; then
        # shellcheck disable=SC2086
        gh release create "dingbox-fail-${GITHUB_RUN_NUMBER:-manual}" $assets \
          --title "DingBox failure logs run ${GITHUB_RUN_NUMBER:-manual}" \
          --notes "Raw build logs for failed run ${GITHUB_RUN_NUMBER:-manual}." || true
      fi
    fi
  fi
  exit $rc
}
exec > >(tee -a "$WS/build-trace.log") 2>&1
trap on_failure EXIT
set -e

echo "=== toolchain ==="
xcodebuild -version
ls /Applications | grep -i xcode || true
sw_vers || true

echo "=== fetch sources ==="
if ! git clone --depth 1 --branch "$CORE_REF" "https://github.com/$CORE_REPO.git" "$WS/core"; then
  rm -rf "$WS/core"
  git clone "https://github.com/$CORE_REPO.git" "$WS/core"
  git -C "$WS/core" checkout "$CORE_REF"
fi
if [ -n "$CLIENT_REF" ]; then
  git clone --depth 1 --branch "$CLIENT_REF" "https://github.com/$CLIENT_REPO.git" "$WS/sing-box-for-apple"
else
  git clone --depth 1 "https://github.com/$CLIENT_REPO.git" "$WS/sing-box-for-apple"
fi
echo "client HEAD: $(git -C "$WS/sing-box-for-apple" rev-parse HEAD)"
echo "core describe: $(git -C "$WS/core" describe --tags 2>/dev/null || echo n/a)"

echo "=== init client submodules (Runestone) ==="
# Root cause of run 5: Frameworks/Runestone is a git submodule of
# sing-box-for-apple (nekohasekai/Runestone); a plain `git clone --depth 1`
# leaves it an empty directory, so xcodebuild died at Resolve Package
# Graph ("Package.swift doesn't exist in file system"). Initialise it
# and fail fast if the manifest is still missing.
git -C "$WS/sing-box-for-apple" submodule update --init --recursive --depth 1
[ -f "$WS/sing-box-for-apple/Frameworks/Runestone/Package.swift" ] || { echo "Runestone submodule still missing after init"; exit 1; }
echo "Runestone submodule present"

echo "=== patch core: upstream iOS/cgo build break (run 4) ==="
# Root cause of run 4: at upstream commit d82b4e63 (this fork's base),
# dns/transport/local/local.go uses localServerSet and
# Transport.exchangeAsync, but both live in local_shared.go guarded by
# `//go:build !darwin || (darwin && !cgo)` -- excluded when building for
# iOS (darwin+cgo), so `go build` died with `undefined: localServerSet`
# and `t.exchangeAsync undefined`. Upstream fixed it on `testing` by
# dropping that build tag (their local_darwin.go is byte-identical to the
# fork's, and no symbol in local_shared.go collides with it). Mirror it.
SHARED="$WS/core/dns/transport/local/local_shared.go"
grep -qF '//go:build !darwin || (darwin && !cgo)' "$SHARED" || { echo "unexpected: build tag line missing in local_shared.go (upstream may have fixed it)"; exit 1; }
grep -vF '//go:build !darwin || (darwin && !cgo)' "$SHARED" > "$SHARED.tmp" && mv "$SHARED.tmp" "$SHARED"
grep -q 'type localServerSet struct' "$SHARED" || { echo "patch broke local_shared.go"; exit 1; }
grep -q 'func (t \*Transport) exchangeAsync' "$SHARED" || { echo "patch broke local_shared.go"; exit 1; }
echo "patched local_shared.go (build tag removed)"

echo "=== install Go $GO_VERSION ==="
ARCH=$(uname -m)
case "$ARCH" in
  arm64) GO_ARCH=arm64 ;;
  x86_64) GO_ARCH=amd64 ;;
  *) GO_ARCH=arm64 ;;
esac
curl -fsL -o /tmp/go.tgz "https://go.dev/dl/go${GO_VERSION}.darwin-${GO_ARCH}.tar.gz"
ls -lh /tmp/go.tgz
mkdir -p "$HOME/go-sdk"
tar -C "$HOME/go-sdk" -xzf /tmp/go.tgz
export PATH="$HOME/go-sdk/go/bin:$PATH"
go version

echo "=== gomobile ==="
# Root cause of run 3 (and run 2): build_libbox calls build_shared.FindMobile(),
# which checks for $GOPATH/bin/gobind -- NOT for `gomobile` in PATH. `gobind`
# is produced by `gomobile init`; run 3's `gomobile init || true` hid its
# failure, so no gobind ever existed and the build died with FATAL
# 'missing gomobile installation'. Two further defects in run 3: upstream
# x/mobile@latest requires go >= 1.26 (toolchain switch) and its `version`
# self-check fails outside a module, so install the sagernet fork pinned to
# the version core's go.mod uses (v0.1.12) instead, into the default
# GOPATH/bin, and install gobind directly as well so FindMobile's check
# passes even if `gomobile init` cannot run.
export GOPATH="${GOPATH:-$HOME/go}"
export GOBIN="$GOPATH/bin"
mkdir -p "$GOBIN"
export PATH="$GOBIN:$PATH"
( cd /tmp && go install github.com/sagernet/gomobile/cmd/gomobile@v0.1.12 )
( cd /tmp && go install github.com/sagernet/gomobile/cmd/gobind@v0.1.12 )
command -v gomobile || { echo "gomobile install failed"; exit 1; }
command -v gobind || { echo "gobind install failed"; exit 1; }
cd "$WS/core"
gomobile version || true
gomobile init || echo "gomobile init failed (continuing, gobind preinstalled)"
[ -x "$GOPATH/bin/gobind" ] || { echo "gobind not in GOPATH/bin ($GOPATH/bin)"; exit 1; }

echo "=== build Libbox.xcframework (ios, ding core) ==="
go run ./cmd/internal/build_libbox -target apple -platform ios 2>&1 | tee "$WS/libbox-build.log"
echo "---- locate framework ----"
find "$WS" -maxdepth 3 -name "Libbox.xcframework" -print

echo "=== place framework into client ==="
SRC=""
for p in "$WS/sing-box-for-apple/Libbox.xcframework" "$WS/core/Libbox.xcframework"; do
  if [ -d "$p" ]; then SRC="$p"; break; fi
done
if [ -z "$SRC" ]; then echo "Libbox.xcframework not found"; exit 1; fi
echo "framework source: $SRC"
mkdir -p "$WS/sing-box-for-apple/Frameworks"
rm -rf "$WS/sing-box-for-apple/Frameworks/Libbox.xcframework"
cp -R "$SRC" "$WS/sing-box-for-apple/Frameworks/Libbox.xcframework"
if [ "$SRC" != "$WS/sing-box-for-apple/Libbox.xcframework" ]; then
  rm -rf "$WS/sing-box-for-apple/Libbox.xcframework"
  cp -R "$SRC" "$WS/sing-box-for-apple/Libbox.xcframework"
fi
ls "$WS/sing-box-for-apple/Frameworks/Libbox.xcframework"

echo "=== build SFI app (unsigned) ==="
cd "$WS/sing-box-for-apple"
set +e
xcodebuild build -skipPackagePluginValidation \
  -scheme SFI -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$WS/build-dd" \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" \
  > "$WS/xcodebuild.log" 2>&1
XRC=$?
set -e
tail -30 "$WS/xcodebuild.log"
if [ $XRC -ne 0 ]; then echo "xcodebuild failed rc=$XRC"; exit $XRC; fi

echo "=== package unsigned IPA ==="
APP=$(find "$WS/build-dd/Build/Products" -maxdepth 2 -name "*.app" | head -1)
echo "app bundle: $APP"
if [ -z "$APP" ]; then echo "no .app produced"; exit 1; fi
rm -rf "$WS/pkg" && mkdir -p "$WS/pkg/Payload"
cp -R "$APP" "$WS/pkg/Payload/"
cd "$WS/pkg" && zip -qr "$WS/DingBox-unsigned.ipa" Payload
ls -lh "$WS/DingBox-unsigned.ipa"
SHA=$(shasum -a 256 "$WS/DingBox-unsigned.ipa" | awk '{print $1}')
echo "IPA sha256: $SHA"

echo "=== publish release ==="
cd "$WS"
TAG="dingbox-build-${GITHUB_RUN_NUMBER:-manual}"
CORE_TAG=$(git -C "$WS/core" describe --tags 2>/dev/null || echo "$CORE_REF")
CLIENT_SHA=$(git -C "$WS/sing-box-for-apple" rev-parse HEAD)
gh release create "$TAG" "$WS/DingBox-unsigned.ipa" \
  --title "DingBox unsigned build ${GITHUB_RUN_NUMBER:-manual}" \
  --notes "Unsigned IPA: sing-box-for-apple client (commit $CLIENT_SHA) + $CORE_REPO core ($CORE_TAG, with-at/ding build). SHA256: $SHA. NOTE: unsigned - needs a paid Apple Developer account signature before the VPN tunnel can run."

echo "=== done ==="
trap - EXIT
