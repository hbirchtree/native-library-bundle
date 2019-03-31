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

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    set ( LINUX ON )
endif()

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
    set ( TOOLCHAIN_GENERATOR "Unix Makefiles" )

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
#                OR WIN32 # Not tested
                )
            )
        AND (
            "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86_64"
            )
        )
    set ( BUILD_PLATFORM ON )
endif()

#
# OpenAL-soft
# For now, OpenAL is not cross-compiler friendly >:(
#
if(OFF)
    ExternalProject_Add ( OpenALSoft

        PREFIX ${CMAKE_BINARY_DIR}/openal

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/openal
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/openal
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/openal

        GIT_REPOSITORY https://github.com/kcat/openal-soft.git
        GIT_TAG openal-soft-1.19.1

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
endif()

#
# SDL2
#
if(ANDROID)
    ExternalProject_Add ( SDL2

        PREFIX ${CMAKE_BINARY_DIR}/sdl2

        BINARY_DIR ${CMAKE_BINARY_DIR}/build/sdl2

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/sdl2
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/sdl2

        HG_REPOSITORY https://hg.libsdl.org/SDL
        HG_TAG release-2.0.9

        CMAKE_GENERATOR "${TOOLCHAIN_GENERATOR}"

        CMAKE_ARGS

            ${TOOLCHAIN_OPTIONS}

            -DSDL_ATOMIC=OFF
            -DSDL_AUDIO=OFF
            -DSDL_THREADS=OFF
            -DSDL_TIMERS=OFF
            -DSDL_FILE=OFF
            -DSDL_CPUINFO=OFF
            -DSDL_FILESYSTEM=OFF
            -DSDL_SENSOR=OFF
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
ExternalProject_Add ( Bullet

    PREFIX ${CMAKE_BINARY_DIR}/bullet

    SOURCE_DIR ${CMAKE_BINARY_DIR}/source/bullet
    BINARY_DIR ${CMAKE_BINARY_DIR}/build/bullet
    INSTALL_DIR ${CMAKE_BINARY_DIR}/install/bullet

    GIT_REPOSITORY https://github.com/bulletphysics/bullet3.git
    GIT_TAG 2.88

    CMAKE_GENERATOR "${TOOLCHAIN_GENERATOR}"

    CMAKE_ARGS

        ${TOOLCHAIN_OPTIONS}

        -DBUILD_BULLET2_DEMOS=OFF
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_CPU_DEMOS=OFF
        -DBUILD_EXTRAS=OFF
        -DUSE_GRAPHICAL_BENCHMARK=OFF
        -DINSTALL_LIBS=ON

        -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/bullet
    )

install (
    FILES       ${CMAKE_BINARY_DIR}/source/bullet/LICENSE.txt
    DESTINATION ${CMAKE_BINARY_DIR}/install/bullet/license
    )

#
# OpenSSL, a real bastard to compile
#

set ( OPENSSL_BUILT OFF )

set ( OPENSSL_VER "1_1_1b" )

if(ANDROID)
    # Android isn't compatible with every version?
    set ( OPENSSL_VER "1.0.2r" )

    ExternalProject_Add ( OpenSSL

        PREFIX ${CMAKE_BINARY_DIR}/openssl

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/openssl
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/openssl
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/openssl

        URL https://github.com/paulo-raca/android-openssl/archive/master.zip

        PATCH_COMMAND
            COMMAND patch
                -p0
                -i ${CMAKE_SOURCE_DIR}/patches/android-openssl.patch

        CONFIGURE_COMMAND true

        BUILD_COMMAND
            ${CMAKE_COMMAND} -E env

                ANDROID_NDK_ROOT=${ANDROID_NDK}

                ${CMAKE_BINARY_DIR}/source/openssl/build-all-arch.sh
                    ${OPENSSL_VER}
                    ${ANDROID_ABI}

        INSTALL_COMMAND true
        )
    install (
        FILES ${CMAKE_BINARY_DIR}/build/openssl/openssl-${OPENSSL_VER}/LICENSE
        DESTINATION ${CMAKE_BINARY_DIR}/install/openssl/license
        )

    install (
        FILES

        ${CMAKE_BINARY_DIR}/build/openssl/prebuilt/${ANDROID_ABI}/libcrypto.a
        ${CMAKE_BINARY_DIR}/build/openssl/prebuilt/${ANDROID_ABI}/libssl.a

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

    set ( OPENSSL_TOP "${OPENSSL_XCODE_PATH}/Platforms/${OPENSSL_SDK}.platform/Developer" )
    set ( OPENSSL_TOOLCHAIN "${OPENSSL_XCODE_PATH}/Toolchains/XcodeDefault.xctoolchain/usr/bin/" )

    ExternalProject_Add ( OpenSSL

        PREFIX ${CMAKE_BINARY_DIR}/openssl

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/openssl
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/openssl
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/openssl

        GIT_REPOSITORY https://github.com/openssl/openssl.git
        GIT_TAG OpenSSL_${OPENSSL_VER}

        PATCH_COMMAND ${GIT_EXECUTABLE} apply ${CMAKE_SOURCE_DIR}/patches/ios-openssl.patch

        CONFIGURE_COMMAND 
            ${CMAKE_COMMAND} -E env

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

            CROSS_COMPILE="${OPENSSL_XCODE_PATH}/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
            CROSS_SDK=${OPENSSL_SDK}.sdk
            CROSS_TOP=${OPENSSL_TOP}
       
            make

        INSTALL_COMMAND 
            ${CMAKE_COMMAND} -E env

            CROSS_COMPILE="${OPENSSL_XCODE_PATH}/Toolchains/XcodeDefault.xctoolchain/usr/bin/"
            CROSS_SDK=${OPENSSL_SDK}.sdk
            CROSS_TOP=${OPENSSL_TOP}

            make install_sw
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

#
# Building Assimp
#
ExternalProject_Add ( Assimp

    PREFIX ${CMAKE_BINARY_DIR}/assimp

    SOURCE_DIR ${CMAKE_BINARY_DIR}/source/assimp
    BINARY_DIR ${CMAKE_BINARY_DIR}/build/assimp
    INSTALL_DIR ${CMAKE_BINARY_DIR}/install/assimp

    GIT_REPOSITORY https://github.com/assimp/assimp.git
    GIT_TAG v4.1.0

    CMAKE_GENERATOR "${TOOLCHAIN_GENERATOR}"

    CMAKE_ARGS

        ${TOOLCHAIN_OPTIONS}

        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_TESTING=OFF
        -DASSIMP_BUILD_ASSIMP_TOOLS=OFF
        -DASSIMP_BUILD_TESTS=OFF

        -DASSIMP_BUILD_ZLIB=ON

        -DASSIMP_BUILD_ALL_IMPORTERS_BY_DEFAULT=OFF
        -DASSIMP_BUILD_ALL_EXPORTERS_BY_DEFAULT=OFF

        -DASSIMP_BUILD_BLEND_IMPORTER=ON
        -DASSIMP_BUILD_COLLADA_IMPORTER=ON
        -DASSIMP_BUILD_FBX_IMPORTER=ON

        -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/assimp
    )

install (
    FILES       ${CMAKE_BINARY_DIR}/source/assimp/LICENSE
    DESTINATION ${CMAKE_BINARY_DIR}/install/assimp/license
    )

#
# libsquish (doesn't cross-compile)
#
if(BUILD_PLATFORM)
    ExternalProject_Add ( squish

        PREFIX ${CMAKE_BINARY_DIR}/squish

        # libsquish doesn't support out-of-source compilation, bleh
        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/squish
        BINARY_DIR ${CMAKE_BINARY_DIR}/source/squish
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/squish

        GIT_REPOSITORY https://github.com/Cavewhere/squish.git

        CONFIGURE_COMMAND
            ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/install/squish/lib
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/install/squish/include

        BUILD_COMMAND
            COMMAND make
                -f ${CMAKE_BINARY_DIR}/source/squish/Makefile

                install
                -e INSTALL_DIR=${CMAKE_BINARY_DIR}/install/squish
            COMMAND make clean

        INSTALL_COMMAND make clean
        )

    install (
        FILES       ${CMAKE_BINARY_DIR}/source/squish/README
        DESTINATION ${CMAKE_BINARY_DIR}/install/squish/license
        )
endif()

#
# GLSLang
#
if(BUILD_PLATFORM)
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
if(BUILD_PLATFORM)
    ExternalProject_Add ( shaderc

        PREFIX ${CMAKE_BINARY_DIR}/shaderc

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/shaderc
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/shaderc
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/shaderc

        GIT_REPOSITORY https://github.com/hbirchtree/shaderc.git

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
if(BUILD_PLATFORM)
    ExternalProject_Add ( SPIRVCross

        PREFIX ${CMAKE_BINARY_DIR}/spirvcross

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/spirvcross
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/spirvcross
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/spirvcross

        GIT_REPOSITORY https://github.com/hbirchtree/SPIRV-Cross.git

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
if(BUILD_PLATFORM)
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

if(BUILD_PLATFORM)
    ExternalProject_Add ( FFMPEG

        PREFIX ${CMAKE_BINARY_DIR}/ffmpeg

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/ffmpeg
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/ffmpeg
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/ffmpeg

        GIT_REPOSITORY https://git.ffmpeg.org/ffmpeg.git
        GIT_TAG n4.1.2

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
        FILES       ${CMAKE_BINARY_DIR}/source/ffmpeg/LICENSE.md
        DESTINATION ${CMAKE_BINARY_DIR}/install/ffmpeg/license
        )
endif()

#
# Compressonator, for ASTC/ATC/BC{5,6,7}
#
if(BUILD_PLATFORM AND NOT "${CMAKE_INSTALL_PREFIX}" MATCHES "steam.amd64")
    ExternalProject_Add ( Compressonator

        PREFIX ${CMAKE_BINARY_DIR}/compressonator

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/compressonator
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/compressonator
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/compressonator

        GIT_REPOSITORY https://github.com/GPUOpen-Tools/Compressonator.git
        GIT_TAG v3.1.4064

        PATCH_COMMAND
            COMMAND ${GIT_EXECUTABLE} config user.email "a@b.c"
            COMMAND ${GIT_EXECUTABLE} config user.name "a@b.c"
            COMMAND ${GIT_EXECUTABLE} apply ${CMAKE_SOURCE_DIR}/patches/compressonator.patch

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

# Just trick CMake into making an install target
install (
    FILES ${CMAKE_BINARY_DIR}/CMakeCache.txt
    DESTINATION libs
    )
