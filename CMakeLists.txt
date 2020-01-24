project ( native-libs C CXX ASM )
cmake_minimum_required(VERSION 3.1)

include ( ExternalProject )

set ( TOOLCHAIN_OPTIONS
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_SHARED_LIBS=OFF
    )

set ( TOOLCHAIN_GENERATOR "CodeBlocks - Ninja" )

set ( BUILD_PIC "ON" )

set ( LINUX OFF )

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux" AND NOT ANDROID)
    set ( LINUX ON )
endif()

if(WIN32)
    set ( TOOLCHAIN_GENERATOR "${CMAKE_GENERATOR}" )
    list ( APPEND TOOLCHAIN_OPTIONS "-G${TOOLCHAIN_GENERATOR}" )
endif()

set ( GITCOMMAND "git" )

#
# We set up some toolchain-specific options
#
if(ANDROID)
    add_custom_target ( AndroidPackage ) # Dummy package to make CI happy

    set ( TOOLCHAIN_OPTIONS
        ${TOOLCHAIN_OPTIONS}

        -DANDROID_SDK=${ANDROID_SDK}
        -DANDROID_NDK=${ANDROID_NDK}

        -DANDROID_ARM_NEON=${ANDROID_ARM_NEON}
        -DANDROID_PLATFORM=${ANDROID_PLATFORM}
        -DANDROID_CPP_FEATURES=${ANDROID_CPP_FEATURES}
        -DANDROID_ABI=${ANDROID_ABI}
        -DANDROID_STL=${ANDROID_STL}
        -DANDROID_TOOLCHAIN=${ANDROID_TOOLCHAIN}
        )
endif()

if(EMSCRIPTEN)
    set ( TOOLCHAIN_GENERATOR "Ninja" )

    set ( TOOLCHAIN_OPTIONS
        ${TOOLCHAIN_OPTIONS}

        -DEMSCRIPTEN_ROOT_PATH=${EMSCRIPTEN_ROOT_PATH}
        -DGENERATE_WASM=${GENERATE_WASM}
        )
endif()

if(APPLE)
    set ( TOOLCHAIN_GENERATOR "Unix Makefiles" )

    if(IOS)
        set ( TOOLCHAIN_OPTIONS
            ${TOOLCHAIN_OPTIONS}

            -DIOS_PLATFORM=${IOS_PLATFORM}
            )
    endif()
endif()

#
# For libraries that are not going to be cross-compiled
# This applies to texture compressors, shader compilers and preprocessing models
#
set ( BUILD_PLATFORM OFF )

if(
        (
            (
                LINUX
                OR (APPLE AND NOT IOS)
                #OR WIN32
                )
            )
        AND (
            "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86_64"
            OR "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "AMD64"
            )
        )
    set ( BUILD_PLATFORM ON )
endif()

#
# Top-level options for enabling/disabling builds
#

# Application libraries, for most platforms

set ( SDL2_BUILD            OFF )
set ( OPENAL_BUILD          OFF )
set ( BULLET_BUILD          ON  )
set ( OPENSSL_BUILD         ON  )
set ( ZLIB_BUILD            ON  )
set ( ZSTD_BUILD            ON  )
set ( LZ4_BUILD             ON  )
set ( DISCORD_BUILD         OFF )

set ( OPENSSL_VER "1_1_1d" )
set ( SDL2_VER    "2.0.10" )
set ( ASSIMP_VER  "5.0.0"  )
set ( BULLET_VER  "2.89"   )
set ( ZLIB_VER    "1.2.11" )
set ( OPENAL_VER  "1.19.1" )
set ( ZSTD_VERSION "1.4.4" )
set ( LZ4_VERSION "1.9.2"  )
set ( DISCORD_VERSION "3.4.0" )

# Build libraries, only for desktop (x86/amd64)

set ( ASSIMP_BUILD          OFF )
set ( SQUISH_BUILD          OFF )
set ( FFMPEG_BUILD          OFF )
set ( COMPRESSONATOR_BUILD  OFF )
set ( SPIRVCROSS_BUILD      OFF )
set ( GLSLANG_BUILD         OFF )
set ( SHADERC_BUILD         OFF )

set ( FFMPEG_VER  "4.1.2"  )

# Turning builds on/off

if(BUILD_PLATFORM)
    set ( ZLIB_BUILD            OFF ) # There are problems with shared libs and static zlib
    set ( ASSIMP_BUILD          ON )
    set ( SQUISH_BUILD          ON )
    set ( FFMPEG_BUILD          ON )
    set ( COMPRESSONATOR_BUILD  ON )
    set ( SPIRVCROSS_BUILD      ON )
    set ( GLSLANG_BUILD         ON )
    set ( SHADERC_BUILD         ON )

    set ( DISCORD_BUILD         ON )
endif()

# Only used on desktop platforms, Android and iOS use custom backends
if(LINUX OR (APPLE AND NOT IOS))
    set ( SDL2_BUILD ON )
endif()

# steam.amd64 is not used for building, and also does not support C++14
if("${CMAKE_INSTALL_PREFIX}" MATCHES "steam.amd64")
    set ( COMPRESSONATOR_BUILD OFF )
endif()

if(ANDROID OR LINUX)
    set ( OPENAL_BUILD ON )
endif()

# Android's OpenSSL build is just impossible to understand
# It currently uses a custom process for building
if(ANDROID)
    set ( OPENSSL_VER "1.0.2t" )
endif()

if(EMSCRIPTEN)
    set ( ZLIB_BUILD OFF )
endif()

#
#
#

#
# OpenAL-soft
# For now, OpenAL is not cross-compiler friendly >:(
#
if(OPENAL_BUILD)
    ExternalProject_Add ( OpenALSoft

        PREFIX ${CMAKE_BINARY_DIR}/openal

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/openal
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/openal
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/openal

        GIT_REPOSITORY https://github.com/kcat/openal-soft.git
        GIT_TAG openal-soft-${OPENAL_VER}

        CMAKE_GENERATOR "${TOOLCHAIN_GENERATOR}"

        CMAKE_ARGS

            ${TOOLCHAIN_OPTIONS}

            -DALSOFT_UTILS=OFF
            -DALSOFT_EXAMPLES=OFF
            -DALSOFT_TESTS=OFF
            -DALSOFT_NO_CONFIG_UTIL=ON

            -DALSOFT_HRTF_DEFS=OFF
            -DALSOFT_AMBDEC_PRESETS=OFF
            -DALSOFT_CONFIG=OFF
            -DALSOFT_EMBED_HRTF_DATA=OFF

            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/openal
        )
    install (
        FILES       ${CMAKE_BINARY_DIR}/source/openal/COPYING
        DESTINATION ${CMAKE_BINARY_DIR}/install/openal/license
        )
endif()

#
# SDL2
#
if(SDL2_BUILD)
    ExternalProject_Add ( SDL2

        PREFIX ${CMAKE_BINARY_DIR}/sdl2

        BINARY_DIR ${CMAKE_BINARY_DIR}/build/sdl2

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/sdl2
        INSTALL_DIR ${CMAKE_BINARY_DIR}/${INSTALL_PREFIX}/sdl2

        URL https://www.libsdl.org/release/SDL2-${SDL2_VER}.tar.gz

        PATCH_COMMAND
            COMMAND patch
                -p0
                -i ${CMAKE_SOURCE_DIR}/patches/sdl-osx-frameworks.patch

        CMAKE_GENERATOR "${TOOLCHAIN_GENERATOR}"

        CMAKE_ARGS

            ${TOOLCHAIN_OPTIONS}

            -DSDL_AUDIO=OFF
            -DSDL_SHARED=OFF
            -DSDL_STATIC_PIC=${BUILD_PIC}

            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/sdl2
        )

    install (
        FILES       ${CMAKE_BINARY_DIR}/source/sdl2/COPYING.txt
        DESTINATION ${CMAKE_BINARY_DIR}/install/sdl2/license
        )
endif()

#
# Bullet
#
if(BULLET_BUILD)
    ExternalProject_Add ( Bullet

        PREFIX ${CMAKE_BINARY_DIR}/bullet

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/bullet
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/bullet
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/bullet

        GIT_REPOSITORY https://github.com/bulletphysics/bullet3.git
        GIT_TAG ${BULLET_VER}

        PATCH_COMMAND
            COMMAND ${GITCOMMAND} config user.email "a@b.c"
            COMMAND ${GITCOMMAND} config user.name "a@b.c"
            COMMAND ${GITCOMMAND} apply --ignore-space-change --ignore-whitespace ${CMAKE_SOURCE_DIR}/patches/bullet-cmake.patch

        CMAKE_GENERATOR "${TOOLCHAIN_GENERATOR}"

        CMAKE_ARGS

            ${TOOLCHAIN_OPTIONS}

            -DBUILD_BULLET2_DEMOS=OFF
            -DBUILD_UNIT_TESTS=OFF
            -DBUILD_CPU_DEMOS=OFF
            -DBUILD_EXTRAS=ON
            -DUSE_GRAPHICAL_BENCHMARK=OFF
            -DINSTALL_LIBS=ON

            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/bullet
        )

    install (
        FILES       ${CMAKE_BINARY_DIR}/source/bullet/LICENSE.txt
        DESTINATION ${CMAKE_BINARY_DIR}/install/bullet/license
        )
endif()

#
# OpenSSL, a real bastard to compile
#

if(OPENSSL_BUILD)
    set ( OPENSSL_BUILT OFF )

    if(ANDROID)
        # Android isn't compatible with every version?
        set ( OPENSSL_TARGET_PATH
            ${CMAKE_BINARY_DIR}/build/openssl/prebuilt/${ANDROID_ABI}
            )

        ExternalProject_Add ( OpenSSL

            PREFIX ${CMAKE_BINARY_DIR}/openssl

            SOURCE_DIR ${CMAKE_BINARY_DIR}/source/openssl
            BINARY_DIR ${CMAKE_BINARY_DIR}/build/openssl
            INSTALL_DIR ${CMAKE_BINARY_DIR}/install/openssl

            URL https://github.com/paulo-raca/android-openssl/archive/master.zip

            PATCH_COMMAND
                COMMAND patch
                    -p0
                    -i ${CMAKE_SOURCE_DIR}/patches/openssl-android.patch

            CONFIGURE_COMMAND true

            BUILD_COMMAND
                ${CMAKE_COMMAND} -E env

                ANDROID_NDK_ROOT=${ANDROID_NDK}
                ANDROID_API=${ANDROID_PLATFORM}

                ${CMAKE_BINARY_DIR}/source/openssl/build-all-arch.sh
                    ${OPENSSL_VER}
                    ${ANDROID_ABI}

            INSTALL_COMMAND true
            )
        install (
            FILES
            ${CMAKE_BINARY_DIR}/build/openssl/openssl-${OPENSSL_VER}/LICENSE

            DESTINATION
            ${CMAKE_BINARY_DIR}/install/openssl/license
            )

        install (
            FILES
            ${OPENSSL_TARGET_PATH}/libcrypto.a
            ${OPENSSL_TARGET_PATH}/libssl.a

            DESTINATION ${CMAKE_BINARY_DIR}/install/openssl/lib
            )

        install (
            DIRECTORY ${CMAKE_BINARY_DIR}/build/openssl/prebuilt/include/openssl
            DESTINATION ${CMAKE_BINARY_DIR}/install/openssl/include
            )

    elseif(APPLE AND IOS) # Just in case
        set ( OPENSSL_BUILT ON )
        # Just in case, and because Travis CI is a dick
        unset ( ENV{CC} )
        unset ( ENV{CXX} )

        set ( OPENSSL_PLATFORM ios64-cross )
        set ( OPENSSL_ARCH arm64 )
        set ( OPENSSL_SDK iPhoneOS )

        if("${IOS_PLATFORM}" STREQUAL "SIMULATOR64")
            set ( OPENSSL_PLATFORM ios64sim-cross )
            set ( OPENSSL_ARCH x86_64 )
            set ( OPENSSL_SDK iPhoneSimulator )
        endif()

        execute_process (
            COMMAND xcode-select --print-path
            OUTPUT_VARIABLE OPENSSL_XCODE_PATH
            )

        string ( REPLACE "\n" "" OPENSSL_XCODE_PATH "${OPENSSL_XCODE_PATH}" )

        set ( OPENSSL_TOP
            "${OPENSSL_XCODE_PATH}/Platforms/${OPENSSL_SDK}.platform/Developer"
            )
        set ( OPENSSL_TOOLCHAIN
            "${OPENSSL_XCODE_PATH}/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
            )

        set ( OPENSSL_TOOLCHAIN_BIN
            "${OPENSSL_XCODE_PATH}/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
            )

        ExternalProject_Add ( OpenSSL

            PREFIX ${CMAKE_BINARY_DIR}/openssl

            SOURCE_DIR ${CMAKE_BINARY_DIR}/source/openssl
            BINARY_DIR ${CMAKE_BINARY_DIR}/build/openssl
            INSTALL_DIR ${CMAKE_BINARY_DIR}/install/openssl

            GIT_REPOSITORY https://github.com/openssl/openssl.git
            GIT_TAG OpenSSL_${OPENSSL_VER}

            PATCH_COMMAND
                ${GITCOMMAND}
                    apply --ignore-space-change --ignore-whitespace ${CMAKE_SOURCE_DIR}/patches/openssl-ios.patch

            CONFIGURE_COMMAND
                ${CMAKE_COMMAND} -E env

                CC="clang"
                CROSS_COMPILE="${OPENSSL_TOOLCHAIN}"
                CROSS_SDK=${OPENSSL_SDK}.sdk
                CROSS_TOP=${OPENSSL_TOP}

                ${CMAKE_BINARY_DIR}/source/openssl/Configure

                    ${OPENSSL_PLATFORM}
                    "-arch ${OPENSSL_ARCH} -fembed-bitcode"
                    no-asm
                    no-ssl3
                    no-comp
                    no-hw
                    no-engine
                    no-async

                    --prefix=${CMAKE_BINARY_DIR}/install/openssl
                    no-shared

            BUILD_COMMAND
                ${CMAKE_COMMAND} -E env

                CROSS_COMPILE="${OPENSSL_TOOLCHAIN_BIN}"
                CROSS_SDK=${OPENSSL_SDK}.sdk
                CROSS_TOP=${OPENSSL_TOP}

                make

            INSTALL_COMMAND
                ${CMAKE_COMMAND} -E env

                CROSS_COMPILE="${OPENSSL_TOOLCHAIN_BIN}"
                CROSS_SDK=${OPENSSL_SDK}.sdk
                CROSS_TOP=${OPENSSL_TOP}

                make install_sw
            )
    elseif(EMSCRIPTEN)

        # We don't support this.

    elseif(CMAKE_CROSSCOMPILING)
        set ( OPENSSL_BUILT ON  )
        set ( USE_CROSS_OPT OFF )

        if("${CMAKE_LIBRARY_ARCHITECTURE}" STREQUAL "arm-none-linux-gnueabihf")
            set ( OPENSSL_PLATFORM "linux-armv4" )
            set ( OPENSSL_ARCH "armv6" )
            set ( USE_CROSS_OPT ON )
        elseif(MINGW64)
            set ( OPENSSL_PLATFORM "mingw64" )
            set ( USE_CROSS_OPT ON )
        endif()

        if(DEFINED OPENSSL_ARCH)
            list ( APPEND EXTRA_OPTS -march=${OPENSSL_ARCH} )
        endif()

        if(USE_CROSS_OPT)
            list ( APPEND EXTRA_OPTS
                --cross-compile-prefix=${CMAKE_LIBRARY_ARCHITECTURE}-
                )
        endif()

        ExternalProject_Add ( OpenSSL

            PREFIX ${CMAKE_BINARY_DIR}/openssl

            SOURCE_DIR ${CMAKE_BINARY_DIR}/source/openssl
            BINARY_DIR ${CMAKE_BINARY_DIR}/build/openssl
            INSTALL_DIR ${CMAKE_BINARY_DIR}/install/openssl

            GIT_REPOSITORY https://github.com/openssl/openssl.git
            GIT_TAG OpenSSL_${OPENSSL_VER}

            CONFIGURE_COMMAND
                ${CMAKE_COMMAND} -E env

                ${CMAKE_BINARY_DIR}/source/openssl/Configure

                    ${OPENSSL_PLATFORM}
                    ${EXTRA_OPTS}
                    no-asm
                    no-ssl3
                    no-comp
                    no-hw
                    no-engine
                    no-async

                    --prefix=${CMAKE_BINARY_DIR}/install/openssl
                    --openssldir=${CMAKE_BINARY_DIR}/install/openssl/data
                    no-shared

            BUILD_COMMAND make

            INSTALL_COMMAND make install
            )
    elseif(LINUX OR APPLE)
        set ( OPENSSL_BUILT ON )
        ExternalProject_Add ( OpenSSL

            PREFIX ${CMAKE_BINARY_DIR}/openssl

            SOURCE_DIR ${CMAKE_BINARY_DIR}/source/openssl
            BINARY_DIR ${CMAKE_BINARY_DIR}/build/openssl
            INSTALL_DIR ${CMAKE_BINARY_DIR}/install/openssl

            GIT_REPOSITORY https://github.com/openssl/openssl.git
            GIT_TAG OpenSSL_${OPENSSL_VER}

            CONFIGURE_COMMAND ${CMAKE_BINARY_DIR}/source/openssl/config
                --prefix=${CMAKE_BINARY_DIR}/install/openssl
                no-shared

            BUILD_COMMAND make

            INSTALL_COMMAND make install
            )
    elseif(WIN32)

    endif()

    if(OPENSSL_BUILT)
        install (
            FILES       ${CMAKE_BINARY_DIR}/source/openssl/LICENSE
            DESTINATION ${CMAKE_BINARY_DIR}/install/openssl/license
            )
    endif()
endif()

#
# zlib, for platforms that don't have it
#
if(ZLIB_BUILD)
    ExternalProject_Add ( Zlib

        PREFIX ${CMAKE_BINARY_DIR}/zlib

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/zlib
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/zlib
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/zlib

        GIT_REPOSITORY https://github.com/madler/zlib.git
        GIT_TAG v${ZLIB_VER}

        PATCH_COMMAND
            COMMAND ${GITCOMMAND} config user.email "a@b.c"
            COMMAND ${GITCOMMAND} config user.name "a@b.c"
            COMMAND ${GITCOMMAND} apply --ignore-space-change --ignore-whitespace ${CMAKE_SOURCE_DIR}/patches/zlib-export.patch

        CMAKE_GENERATOR "${TOOLCHAIN_GENERATOR}"

        CMAKE_ARGS

            ${TOOLCHAIN_OPTIONS}

            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/zlib
        )
    install (
        FILES       ${CMAKE_BINARY_DIR}/source/zlib/README
        DESTINATION ${CMAKE_BINARY_DIR}/install/zlib/license
        )
endif()

#
# Building Assimp
#
if(ASSIMP_BUILD)
    set ( ASSIMP_DEPS )
    set ( ASSIMP_BUILD_ZLIB ON )
    set ( ASSIMP_CXX_FLAGS )
    if(ZLIB_BUILD)
        set ( ASSIMP_DEPS Zlib )
        set ( ASSIMP_BUILD_ZLIB OFF )
    endif()
    if(EMSCRIPTEN)
        set ( ASSIMP_BUILD_ZLIB OFF )
    endif()
    ExternalProject_Add ( Assimp

        DEPENDS ${ASSIMP_DEPS}

        PREFIX ${CMAKE_BINARY_DIR}/assimp

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/assimp
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/assimp
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/assimp

        GIT_REPOSITORY https://github.com/assimp/assimp.git
        GIT_TAG v${ASSIMP_VER}

        PATCH_COMMAND
            COMMAND ${GITCOMMAND} config user.email "a@b.c"
            COMMAND ${GITCOMMAND} config user.name "a@b.c"
            COMMAND ${GITCOMMAND} apply --ignore-space-change --ignore-whitespace ${CMAKE_SOURCE_DIR}/patches/assimp-zlib-find.patch

        CMAKE_GENERATOR "${TOOLCHAIN_GENERATOR}"

        CMAKE_ARGS

            ${TOOLCHAIN_OPTIONS}

            -DBUILD_SHARED_LIBS=OFF
            -DBUILD_TESTING=OFF
            -DASSIMP_BUILD_ASSIMP_TOOLS=OFF
            -DASSIMP_BUILD_TESTS=OFF

            -DASSIMP_BUILD_ZLIB=${ASSIMP_BUILD_ZLIB}

            -DASSIMP_BUILD_ALL_IMPORTERS_BY_DEFAULT=OFF
            -DASSIMP_BUILD_ALL_EXPORTERS_BY_DEFAULT=OFF

            -DASSIMP_BUILD_BLEND_IMPORTER=ON
            -DASSIMP_BUILD_COLLADA_IMPORTER=ON
            -DASSIMP_BUILD_FBX_IMPORTER=ON

            -Dzlib_DIR=${CMAKE_BINARY_DIR}/install/zlib/lib/cmake/zlib
            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/assimp
        )

    install (
        FILES       ${CMAKE_BINARY_DIR}/source/assimp/LICENSE
        DESTINATION ${CMAKE_BINARY_DIR}/install/assimp/license
        )
endif()

if(ZSTD_BUILD)
    ExternalProject_Add( Zstd

        PREFIX "${CMAKE_BINARY_DIR}/zstd"

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/zstd
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/zstd
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/zstd
        
        GIT_REPOSITORY https://github.com/facebook/zstd.git
        GIT_TAG "v${ZSTD_VERSION}"

        CMAKE_GENERATOR "${TOOLCHAIN_GENERATOR}"

        PATCH_COMMAND
            COMMAND ${GITCOMMAND} config user.email "a@b.c"
            COMMAND ${GITCOMMAND} config user.name "a@b.c"
            COMMAND ${GITCOMMAND} apply --ignore-space-change --ignore-whitespace ${CMAKE_SOURCE_DIR}/patches/zstd-export.patch

        CONFIGURE_COMMAND ${CMAKE_COMMAND}

            ${TOOLCHAIN_OPTIONS}

            -G${TOOLCHAIN_GENERATOR}
            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/zstd
            -DCMAKE_POSITION_INDEPENDENT_CODE=ON

            -DZSTD_MULTITHREAD_SUPPORT=OFF
            -DZSTD_BUILD_PROGRAMS=OFF
            -DZSTD_BUILD_SHARED=OFF

            ${CMAKE_BINARY_DIR}/source/zstd/build/cmake
        )

    install (
        FILES       ${CMAKE_BINARY_DIR}/source/zstd/LICENSE
        DESTINATION ${CMAKE_BINARY_DIR}/install/zstd/license
        )
endif()

if(LZ4_BUILD)
    ExternalProject_Add( LZ4

        PREFIX "${CMAKE_BINARY_DIR}/lz4"

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/lz4
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/lz4
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/lz4

        GIT_REPOSITORY https://github.com/lz4/lz4.git
        GIT_TAG "v${LZ4_VERSION}"

        PATCH_COMMAND
            COMMAND ${GITCOMMAND} config user.email "a@b.c"
            COMMAND ${GITCOMMAND} config user.name "a@b.c"
            COMMAND ${GITCOMMAND} apply --ignore-space-change --ignore-whitespace ${CMAKE_SOURCE_DIR}/patches/lz4-cmake.patch

        CONFIGURE_COMMAND ${CMAKE_COMMAND}

            ${TOOLCHAIN_OPTIONS}

            -G${TOOLCHAIN_GENERATOR}
            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/lz4
            -DCMAKE_POSITION_INDEPENDENT_CODE=ON

            ${CMAKE_BINARY_DIR}/source/lz4/lib
        )

    install (
        FILES       ${CMAKE_BINARY_DIR}/source/zstd/LICENSE
        DESTINATION ${CMAKE_BINARY_DIR}/install/zstd/license
        )
endif()

#
# Discord-RPC
# Only for desktop platforms
#
if(DISCORD_BUILD)
    ExternalProject_Add( Discord

        PREFIX "${CMAKE_BINARY_DIR}/discord-rpc"

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/discord-rpc
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/discord-rpc
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/discord-rpc

        GIT_REPOSITORY https://github.com/discordapp/discord-rpc.git
        GIT_TAG "v${DISCORD_VERSION}"

        PATCH_COMMAND
            COMMAND ${GITCOMMAND} config user.email "a@b.c"
            COMMAND ${GITCOMMAND} config user.name "a@b.c"
            COMMAND ${GITCOMMAND} apply --ignore-space-change --ignore-whitespace ${CMAKE_SOURCE_DIR}/patches/discord-cmake.patch

        CMAKE_GENERATOR "${TOOLCHAIN_GENERATOR}"

        CMAKE_ARGS

            ${TOOLCHAIN_OPTIONS}
            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/discord-rpc

            -DBUILD_EXAMPLES=OFF
            -DENABLE_IO_THREAD=OFF
        )

    install (
        FILES ${CMAKE_BINARY_DIR}/source/discord-rpc/LICENSE
        DESTINATION ${CMAKE_BINARY_DIR}/install/discord-rpc/license
        )
endif()

#
# libsquish
#
if(SQUISH_BUILD)
    ExternalProject_Add ( squish

        PREFIX ${CMAKE_BINARY_DIR}/squish

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/squish
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/squish
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/squish

        GIT_REPOSITORY https://github.com/Cavewhere/squish.git

        PATCH_COMMAND
            COMMAND ${GITCOMMAND} config user.email "a@b.c"
            COMMAND ${GITCOMMAND} config user.name "a@b.c"
            COMMAND ${GITCOMMAND} apply --ignore-space-change --ignore-whitespace ${CMAKE_SOURCE_DIR}/patches/squish-cmake.patch

        CMAKE_GENERATOR "${TOOLCHAIN_GENERATOR}"

        CMAKE_ARGS

            ${TOOLCHAIN_OPTIONS}
            -DCMAKE_POSITION_INDEPENDENT_CODE=ON
            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/squish
        )

    install (
        FILES       ${CMAKE_BINARY_DIR}/source/squish/README
        DESTINATION ${CMAKE_BINARY_DIR}/install/squish/license
        )
endif()

#
# GLSLang
#
if(GLSLANG_BUILD)
    ExternalProject_Add ( GLSLang

        PREFIX ${CMAKE_BINARY_DIR}/glslang

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/glslang
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/glslang
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/glslang

        GIT_REPOSITORY https://github.com/KhronosGroup/glslang.git

        CMAKE_GENERATOR "${TOOLCHAIN_GENERATOR}"

        CMAKE_ARGS

            ${TOOLCHAIN_OPTIONS}

            -DBUILD_TESTING=OFF

            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/glslang
        )

    install (
        FILES       ${CMAKE_BINARY_DIR}/source/glslang/LICENSE.txt
        DESTINATION ${CMAKE_BINARY_DIR}/install/glslang/license
        )
endif()

#
# Shaderc
#
if(SHADERC_BUILD)
    ExternalProject_Add ( shaderc

        PREFIX ${CMAKE_BINARY_DIR}/shaderc

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/shaderc
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/shaderc
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/shaderc

        GIT_REPOSITORY https://github.com/hbirchtree/shaderc.git

        PATCH_COMMAND
            COMMAND ${GITCOMMAND} config user.email "a@b.c"
            COMMAND ${GITCOMMAND} config user.name "a@b.c"
            COMMAND ${GITCOMMAND} apply --ignore-space-change --ignore-whitespace ${CMAKE_SOURCE_DIR}/patches/shaderc-cmake.patch

        CMAKE_GENERATOR "${TOOLCHAIN_GENERATOR}"

        CMAKE_ARGS

            ${TOOLCHAIN_OPTIONS}

            -DSHADERC_SKIP_TESTS=ON
            -DENABLE_HLSL=OFF

            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/shaderc
        )

    install (
        FILES       ${CMAKE_BINARY_DIR}/source/shaderc/LICENSE
        DESTINATION ${CMAKE_BINARY_DIR}/install/shaderc/license
        )
endif()

#
# SPIRV-Cross
#
if(SPIRVCROSS_BUILD)
    ExternalProject_Add ( SPIRVCross

        PREFIX ${CMAKE_BINARY_DIR}/spirvcross

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/spirvcross
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/spirvcross
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/spirvcross

        GIT_REPOSITORY https://github.com/hbirchtree/SPIRV-Cross.git

        PATCH_COMMAND
            COMMAND ${GITCOMMAND} config user.email "a@b.c"
            COMMAND ${GITCOMMAND} config user.name "a@b.c"
            COMMAND ${GITCOMMAND} apply --ignore-space-change --ignore-whitespace ${CMAKE_SOURCE_DIR}/patches/spirvcross-werror.patch

        CMAKE_GENERATOR "${TOOLCHAIN_GENERATOR}"

        CMAKE_ARGS

            ${TOOLCHAIN_OPTIONS}
            -DCMAKE_C_COMPILER=gcc
            -DCMAKE_CXX_COMPILER=g++

            -DCMAKE_CXX_FLAGS="-fPIC"

            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/spirvcross
        )

    install (
        FILES       ${CMAKE_BINARY_DIR}/source/spirvcross/LICENSE
        DESTINATION ${CMAKE_BINARY_DIR}/install/spirvcross/license
        )
endif()

#
# FFMPEG
# Doesn't support cross-compiling for now
#
if(FFMPEG_BUILD)
    set ( FFMPEG_OPTS
        --disable-x86asm
        )
else()
    set ( FFMPEG_OPTS
        --enable-cross-compile

        --cc=${CMAKE_C_COMPILER}
        --cxx=${CMAKE_CXX_COMPILER}
        --nm=${CMAKE_NM}
        --ar=${CMAKE_AR}
        --as=${CMAKE_ASM_COMPILER}
        --ld=${CMAKE_LINKER}
        --ranlib=${CMAKE_RANLIB}
        --strip=${CMAKE_STRIP}
        )
endif()

if(FFMPEG_BUILD)
    ExternalProject_Add ( FFMPEG

        PREFIX ${CMAKE_BINARY_DIR}/ffmpeg

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/ffmpeg
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/ffmpeg
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/ffmpeg

        GIT_REPOSITORY https://git.ffmpeg.org/ffmpeg.git
        GIT_TAG n${FFMPEG_VER}

        CONFIGURE_COMMAND
            ${CMAKE_BINARY_DIR}/source/ffmpeg/configure

                --disable-protocols
                --disable-devices
                --disable-outdevs
                --disable-bsfs
                --disable-filters
                --disable-network

                --disable-programs
                --disable-doc

                ${FFMPEG_OPTS}

                --enable-pic
                --prefix=${CMAKE_BINARY_DIR}/install/ffmpeg

        BUILD_COMMAND
            make -j8 install

        INSTALL_COMMAND true
        )

    install (
        FILES
            ${CMAKE_BINARY_DIR}/source/ffmpeg/LICENSE.md
            ${CMAKE_BINARY_DIR}/source/ffmpeg/COPYING.GPLv3
            ${CMAKE_BINARY_DIR}/source/ffmpeg/COPYING.LGPLv2.1
        DESTINATION ${CMAKE_BINARY_DIR}/install/ffmpeg/license
        )
endif()

#
# Compressonator, for ASTC/ATC/BC{5,6,7}
#
if(COMPRESSONATOR_BUILD)
    ExternalProject_Add ( Compressonator

        PREFIX ${CMAKE_BINARY_DIR}/compressonator

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/compressonator
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/compressonator
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/compressonator

        GIT_REPOSITORY https://github.com/GPUOpen-Tools/Compressonator.git
        GIT_TAG v3.1.4064

        PATCH_COMMAND
            COMMAND ${GITCOMMAND} config user.email "a@b.c"
            COMMAND ${GITCOMMAND} config user.name "a@b.c"
            COMMAND ${GITCOMMAND} apply --ignore-space-change --ignore-whitespace ${CMAKE_SOURCE_DIR}/patches/compressonator-linux-mac.patch

        CONFIGURE_COMMAND ${CMAKE_COMMAND}

            ${TOOLCHAIN_OPTIONS}

            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/compressonator

            ${CMAKE_BINARY_DIR}/source/compressonator/Compressonator/Make
        )

    install (
        FILES       ${CMAKE_BINARY_DIR}/source/compressonator/LICENSE
        DESTINATION ${CMAKE_BINARY_DIR}/install/compressonator/license
        )
endif()

#
# AppImage runtime
# This is only used for Ubuntu and Fedora
#
#if(LINUX)
#    ExternalProject_Add ( AppImageRuntime

#        PREFIX ${CMAKE_BINARY_DIR}/compressonator

#        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/appimage
##        BINARY_DIR ${CMAKE_BINARY_DIR}/build/appimage
#        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/appimage

#        GIT_REPOSITORY https://github.com/AppImage/AppImageKit.git
#        GIT_TAG 11

#        BUILD_IN_SOURCE ON

#        CMAKE_ARGS
#            ${TOOLCHAIN_OPTIONS}

#            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/appimage
#        )

#    install (
#        FILES       ${CMAKE_BINARY_DIR}/source/appimage/LICENSE
#        DESTINATION ${CMAKE_BINARY_DIR}/install/appimage/license
#        )
#endif()

# Just trick CMake into making an install target
install (
    FILES ${CMAKE_BINARY_DIR}/CMakeCache.txt
    DESTINATION libs
    )
