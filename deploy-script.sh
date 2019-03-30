ASSETS=(openal bullet assimp squish glslang shaderc spirvcross sdl2 openssl ffmpeg compressonator)

INSTALL_BASE_DIR=$BUILD_DIR/$BUILDVARIANT/install

for a in ${ASSETS[@]}; do
    ASSET="${PWD}/${a}_${BUILDVARIANT}.tar.gz"

    if [[ ! -d "$INSTALL_BASE_DIR/$a" ]]; then
        continue
    fi

    pushd $INSTALL_BASE_DIR/$a
    tar -zcvf "$ASSET" *
    popd

    deploy_asset "$(basename ${ASSET})" ${TARGET_SLUG}
done
