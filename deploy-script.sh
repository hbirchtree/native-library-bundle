ASSETS=(openal bullet assimp squish glslang shaderc spirvcross)

INSTALL_BASE_DIR=$BUILD_DIR/$BUILDVARIANT/install

for a in ${ASSETS[@]}; do
    ASSET="${a}_${BUILDVARIANT}.tar.gz"

    if [[ ! -d "$INSTALL_BASE_DIR/$a" ]]; then
        continue
    fi

    tar -zcvf "$ASSET" -C $INSTALL_BASE_DIR/$a \
        $INSTALL_BASE_DIR/$a

    deploy_asset "${ASSET}" ${TARGET_SLUG}
done
