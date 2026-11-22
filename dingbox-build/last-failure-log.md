# build failure log - run 2 - Sun Nov 22 13:16:57 UTC 2026
## libbox-build.log (tail)
go: downloading github.com/sagernet/gomobile v0.1.12
go: downloading github.com/reF1nd/sing v0.9.7-0.20261025115535-d4dda9140332
go: downloading howett.net/plist v1.0.1
go: downloading github.com/logrusorgru/aurora v2.0.3+incompatible
go: downloading golang.org/x/mod v0.40.0
go: downloading github.com/miekg/dns v1.1.72
go: downloading golang.org/x/crypto v0.55.0
go: downloading golang.org/x/sys v0.47.0
go: downloading go4.org/netipx v0.0.0-20260823151212-3075585bcbeb
[31mFATAL[0m[0000] missing gomobile installation
exit status 1
## xcodebuild.log (tail)
(none)
## build.sh trace (tail)
+ trap on_failure EXIT
+ set -e
+ echo '=== toolchain ==='
=== toolchain ===
+ xcodebuild -version
Xcode 26.6
Build version 17F113
+ ls /Applications
+ grep -i xcode
Xcode_26.0.1.app
Xcode_26.0.app
Xcode_26.1.1.app
Xcode_26.1.app
Xcode_26.2.0.app
Xcode_26.2.app
Xcode_26.3.0.app
Xcode_26.3.app
Xcode_26.4.1.app
Xcode_26.4.app
Xcode_26.5.0.app
Xcode_26.5.app
Xcode_26.6.0.app
Xcode_26.6.app
Xcode.app
+ sw_vers
ProductName:		macOS
ProductVersion:		26.7.2
BuildVersion:		25G332
+ echo '=== fetch sources ==='
=== fetch sources ===
+ git clone --depth 1 --branch v1.15.0-alpha.13-d82b4e632 https://github.com/jieluojun/sing-box.git /Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/core
Cloning into '/Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/core'...
+ '[' -n '' ']'
+ git clone --depth 1 https://github.com/SagerNet/sing-box-for-apple.git /Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/sing-box-for-apple
Cloning into '/Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/sing-box-for-apple'...
++ git -C /Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/sing-box-for-apple rev-parse HEAD
+ echo 'client HEAD: 768b3de2baf2461dd06405cba1b2ca4e39da5ea4'
client HEAD: 768b3de2baf2461dd06405cba1b2ca4e39da5ea4
++ git -C /Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/core describe --tags
+ echo 'core describe: v1.15.0-alpha.13-d82b4e632'
core describe: v1.15.0-alpha.13-d82b4e632
+ echo '=== install Go 1.25.5 ==='
=== install Go 1.25.5 ===
++ uname -m
+ ARCH=arm64
+ case "$ARCH" in
+ GO_ARCH=arm64
+ curl -fsL -o /tmp/go.tgz https://go.dev/dl/go1.25.5.darwin-arm64.tar.gz
+ ls -lh /tmp/go.tgz
-rw-r--r--  1 runner  wheel    55M Nov 22 13:16 /tmp/go.tgz
+ mkdir -p /Users/runner/go-sdk
+ tar -C /Users/runner/go-sdk -xzf /tmp/go.tgz
+ export PATH=/Users/runner/go-sdk/go/bin:/opt/homebrew/opt/rustup/bin:/opt/homebrew/lib/ruby/gems/3.4.0/bin:/opt/homebrew/opt/ruby@3.4/bin:/Users/runner/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Users/runner/.cargo/bin:/usr/local/opt/curl/bin:/usr/local/bin:/usr/local/sbin:/Users/runner/bin:/Users/runner/.yarn/bin:/Users/runner/Library/Android/sdk/tools:/Users/runner/Library/Android/sdk/platform-tools:/Library/Frameworks/Python.framework/Versions/Current/bin:/Library/Frameworks/Mono.framework/Versions/Current/Commands:/usr/bin:/bin:/usr/sbin:/sbin:/Users/runner/.dotnet/tools
+ PATH=/Users/runner/go-sdk/go/bin:/opt/homebrew/opt/rustup/bin:/opt/homebrew/lib/ruby/gems/3.4.0/bin:/opt/homebrew/opt/ruby@3.4/bin:/Users/runner/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Users/runner/.cargo/bin:/usr/local/opt/curl/bin:/usr/local/bin:/usr/local/sbin:/Users/runner/bin:/Users/runner/.yarn/bin:/Users/runner/Library/Android/sdk/tools:/Users/runner/Library/Android/sdk/platform-tools:/Library/Frameworks/Python.framework/Versions/Current/bin:/Library/Frameworks/Mono.framework/Versions/Current/Commands:/usr/bin:/bin:/usr/sbin:/sbin:/Users/runner/.dotnet/tools
+ go version
go version go1.25.5 darwin/arm64
+ echo '=== gomobile (best effort) ==='
=== gomobile (best effort) ===
+ cd /Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/core
+ export GOBIN=/Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/core/bin
+ GOBIN=/Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/core/bin
+ go install golang.org/x/mobile/cmd/gomobile
no required module provides package golang.org/x/mobile/cmd/gomobile; to add it:
	go get golang.org/x/mobile/cmd/gomobile
+ true
+ ls /Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/core/bin
ls: /Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/core/bin: No such file or directory
+ true
+ export PATH=/Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/core/bin:/Users/runner/go-sdk/go/bin:/opt/homebrew/opt/rustup/bin:/opt/homebrew/lib/ruby/gems/3.4.0/bin:/opt/homebrew/opt/ruby@3.4/bin:/Users/runner/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Users/runner/.cargo/bin:/usr/local/opt/curl/bin:/usr/local/bin:/usr/local/sbin:/Users/runner/bin:/Users/runner/.yarn/bin:/Users/runner/Library/Android/sdk/tools:/Users/runner/Library/Android/sdk/platform-tools:/Library/Frameworks/Python.framework/Versions/Current/bin:/Library/Frameworks/Mono.framework/Versions/Current/Commands:/usr/bin:/bin:/usr/sbin:/sbin:/Users/runner/.dotnet/tools
+ PATH=/Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/core/bin:/Users/runner/go-sdk/go/bin:/opt/homebrew/opt/rustup/bin:/opt/homebrew/lib/ruby/gems/3.4.0/bin:/opt/homebrew/opt/ruby@3.4/bin:/Users/runner/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/Users/runner/.cargo/bin:/usr/local/opt/curl/bin:/usr/local/bin:/usr/local/sbin:/Users/runner/bin:/Users/runner/.yarn/bin:/Users/runner/Library/Android/sdk/tools:/Users/runner/Library/Android/sdk/platform-tools:/Library/Frameworks/Python.framework/Versions/Current/bin:/Library/Frameworks/Mono.framework/Versions/Current/Commands:/usr/bin:/bin:/usr/sbin:/sbin:/Users/runner/.dotnet/tools
+ echo '=== build Libbox.xcframework (ios, ding core) ==='
=== build Libbox.xcframework (ios, ding core) ===
+ go run ./cmd/internal/build_libbox -target apple -platform ios
+ tee /Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/libbox-build.log
go: downloading github.com/sagernet/gomobile v0.1.12
go: downloading github.com/reF1nd/sing v0.9.7-0.20261025115535-d4dda9140332
go: downloading howett.net/plist v1.0.1
go: downloading github.com/logrusorgru/aurora v2.0.3+incompatible
go: downloading golang.org/x/mod v0.40.0
go: downloading github.com/miekg/dns v1.1.72
go: downloading golang.org/x/crypto v0.55.0
go: downloading golang.org/x/sys v0.47.0
go: downloading go4.org/netipx v0.0.0-20260823151212-3075585bcbeb
[31mFATAL[0m[0000] missing gomobile installation
exit status 1
+ echo '---- locate framework ----'
---- locate framework ----
+ find /Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io -maxdepth 3 -name Libbox.xcframework -print
+ echo '=== place framework into client ==='
=== place framework into client ===
+ SRC=
+ for p in '"$WS/sing-box-for-apple/Libbox.xcframework"' '"$WS/core/Libbox.xcframework"'
+ '[' -d /Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/sing-box-for-apple/Libbox.xcframework ']'
+ for p in '"$WS/sing-box-for-apple/Libbox.xcframework"' '"$WS/core/Libbox.xcframework"'
+ '[' -d /Users/runner/work/jiaoao3333.github.io/jiaoao3333.github.io/core/Libbox.xcframework ']'
+ '[' -z '' ']'
+ echo 'Libbox.xcframework not found'
Libbox.xcframework not found
+ exit 1
+ on_failure
+ local rc=1
+ '[' 1 -ne 0 ']'
