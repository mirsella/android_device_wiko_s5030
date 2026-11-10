#!/system/bin/sh
# 384 MiB zram swap for the 1 GB Lenny 2.  CONFIG_ZRAM=y in the kernel.
# The stock tiny_mkswap/tiny_swapon helpers are absent from Lineage, so use
# toybox's mkswap/swapon instead.
PATH=/system/bin:/system/xbin
export PATH

# class core can start before ueventd has created the zram node.  Wait for it
# instead of silently leaving the device without swap.
i=0
while [ ! -e /dev/block/zram0 ] && [ "$i" -lt 10 ]; do
    /system/bin/sleep 1
    i=$((i + 1))
done
if [ ! -e /dev/block/zram0 ]; then
    echo "zram: /dev/block/zram0 did not appear" >&2
    exit 1
fi

/system/bin/swapoff /dev/block/zram0 2>/dev/null

echo 402653184 > /sys/block/zram0/disksize
/system/bin/mkswap /dev/block/zram0 || exit 1
/system/bin/swapon /dev/block/zram0 || exit 1

echo 100 > /proc/sys/vm/swappiness
