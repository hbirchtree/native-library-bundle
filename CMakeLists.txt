project ( native-libs )
cmake_minimum_required(VERSION 3.1)

include ( ExternalProject )

set ( TOOLCHAIN_OPTIONS
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
    -DCMAKE_BUILD_TYPE=Release
    )

set ( TOOLCHAIN_GENERATOR "CodeBlocks - Ninja" )

set ( BUILD_PIC "ON" )

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
                "${CMAKE_SYSTEM_NAME}" STREQUAL "Linux"
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

#
# Building Assimp
#
if(BUILD_PLATFORM)
    ExternalProject_Add ( Assimp

        PREFIX ${CMAKE_BINARY_DIR}/assimp

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/assimp
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/assimp
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/assimp

        GIT_REPOSITORY https://github.com/assimp/assimp.git

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
endif()

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
            make
                -f ${CMAKE_BINARY_DIR}/source/squish/Makefile

                install
                -e INSTALL_DIR=${CMAKE_BINARY_DIR}/install/squish

        INSTALL_COMMAND true
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
endif()

install (
    FILES ${CMAKE_BINARY_DIR}/CMakeCache.txt
    DESTINATION libs
    )
