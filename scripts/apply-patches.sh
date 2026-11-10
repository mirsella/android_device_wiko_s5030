#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
top="${ANDROID_BUILD_TOP:-$(cd "$root/../../.." && pwd)}"

apply() {
    local project="$1" patch="$2"
    local tree="$top/$project"
    local file="$root/patches/$patch"

    if git -C "$tree" apply --reverse --check "$file" >/dev/null 2>&1; then
        echo "already applied: $project"
    elif git -C "$tree" apply --check "$file"; then
        git -C "$tree" apply "$file"
        echo "applied: $project"
    else
        echo "cannot apply $patch to $project; check the LineageOS base revision" >&2
        exit 1
    fi
}

apply frameworks/av frameworks_av.patch
apply frameworks/base frameworks_base.patch
apply packages/apps/Snap packages_apps_Snap.patch
