# Dalvik heap limits for the 1 GB Lenny 2. The generic xhdpi 1 GB file uses a
# 192 MB growth limit; 128 MB leaves more headroom for the rest of the system.
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapstartsize=8m \
    dalvik.vm.heapgrowthlimit=128m \
    dalvik.vm.heapsize=256m \
    dalvik.vm.heaptargetutilization=0.75 \
    dalvik.vm.heapminfree=2m \
    dalvik.vm.heapmaxfree=8m
