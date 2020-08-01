ASSETS=(openal bullet assimp squish glslang shaderc spirvcross sdl2 openssl ffmpeg compressonator zlib lz4 zstd discord-rpc)

for a in ${ASSETS[@]}; do
    ASSET="${PWD}/${a}_${BUILDVARIANT}.tar.bz2"

    if [[ ! -d "$INSTALL_DIR/$a" ]]; then
        continue
    fi

    echo "-- Packaging ${a} => ${ASSET}"

    pushd $INSTALL_DIR/$a
    tar -cvf "$ASSET" *
    popd
done
