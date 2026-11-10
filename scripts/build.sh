#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
top="${ANDROID_BUILD_TOP:-$(cd "$root/../../.." && pwd)}"

"$root/scripts/apply-patches.sh"

cd "$top"
source build/envsetup.sh
lunch "${TARGET:-lineage_s5030-userdebug}"
mka bacon
