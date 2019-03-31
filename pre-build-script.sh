#
# Download a downgraded Android build image, uses NDK 14 instead of 16
#
if [[ "$BUILDVARIANT" == "android."* ]]; then
    docker pull hbirch/android:r15c
    docker tag hbirch/android:r15c hbirch/coffeecutie:android
fi
