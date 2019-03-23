ASSETS=(openal bullet assimp squish glslang shaderc spirvcross)

INSTALL_BASE_DIR=$BUILD_DIR/$BUILDVARIANT/install

for a in ${ASSETS[@]}; do
    ASSET="$a_$BUILDVARIANT.tar.gz"

    tar -zcvf "$ASSET" -c $INSTALL_BASE_DIR/$a \
        $INSTALL_BASE_DIR/$a

    deploy_asset "${ASSET}" ${TARGET_SLUG}
done
