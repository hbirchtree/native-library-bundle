#
# Download a downgraded Android build image, uses NDK 14 instead of 16
#
if [[ "$BUILDVARIANT" == "android.*" ]]; then
    docker pull hbirch/android:r14b
    docker tag hbirch/android:r14b hbirch/coffeecutie:android
fi
