# dingbox-build

Cloud build of an iOS sing-box client whose core is jieluojun's ding-capable
fork (the BoxProxy core). The workflow in `.github/workflows/dingbox-build.yml`
builds Libbox.xcframework from the fork, compiles the official
sing-box-for-apple client around it on a macOS runner, and publishes an
**unsigned** IPA to this repo's Releases (`dingbox-build-<n>`).

The IPA cannot run its VPN tunnel until it is signed with a paid Apple
Developer account (Network Extension entitlement). Build/verification only.

`last-failure-log.md` (when present) holds the tail of the latest failed run.
