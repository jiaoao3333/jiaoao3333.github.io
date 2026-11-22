# dingbox-build

Cloud build of an iOS sing-box client whose core is jieluojun's ding-capable
fork (the BoxProxy core). A thin workflow (`.github/workflows/dingbox-build.yml`,
a thin wrapper that must be created once via the GitHub web UI) runs
`build.sh` from this directory on a macOS runner. `build.sh` builds
Libbox.xcframework from the fork, compiles the official sing-box-for-apple
client around it, and publishes an **unsigned** IPA to this repo's Releases
(`dingbox-build-<n>`). Knobs live in `config.env`.

The IPA cannot run its VPN tunnel until it is signed with a paid Apple
Developer account (Network Extension entitlement). Build/verification only.

`last-failure-log.md` (when present) holds the tail of the latest failed run.
