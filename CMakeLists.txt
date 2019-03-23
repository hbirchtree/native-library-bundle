project ( native-libs )
cmake_minimum_required(VERSION 3.1)

include ( ExternalProject )

set ( TOOLCHAIN_OPTIONS
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    )

#
# For libraries that are not going to be cross-compiled
#
set ( BUILD_PLATFORM OFF )

if(
        (
            (
                ${CMAKE_SYSTEM_NAME} STREQUAL "Linux" OR
                (APPLE AND NOT IOS) OR
                WIN32
                )
            )
        AND (
            ${CMAKE_SYSTEM} STREQUAL "x86_64"
            )
        )
    set ( BUILD_PLATFORM ON )
endif()

#
# OpenAL-soft
#
if(NOT EMSCRIPTEN)
    ExternalProject_Add ( OpenALSoft

        PREFIX ${CMAKE_BINARY_DIR}/openal

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/openal
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/openal
        INSTALL_DIR ${CMAKE_BINARY_DIR}/install/openal

        GIT_REPOSITORY https://github.com/kcat/openal-soft.git
        GIT_TAG openal-soft-1.19.1

        CMAKE_GENERATOR "Ninja"

        CMAKE_ARGS

            ${TOOLCHAIN_OPTIONS}

            -DALSOFT_UTILS=OFF
            -DALSOFT_EXAMPLES=OFF
            -DALSOFT_TESTS=OFF
            -DALSOFT_NO_CONFIG_UTIL=ON

            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/openal
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

    CMAKE_GENERATOR "Ninja"

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

        CMAKE_GENERATOR "Ninja"

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
    ExternalProject_Add ( GLSLang

        PREFIX ${CMAKE_BINARY_DIR}/glslang

        SOURCE_DIR ${CMAKE_BINARY_DIR}/source/squish
        BINARY_DIR ${CMAKE_BINARY_DIR}/build/squish

        GIT_REPOSITORY https://github.com/Cavewhere/squish.git

        CONFIGURE_COMMAND true

        BUILD_COMMAND make -f ${CMAKE_BINARY_DIR}/source/squish/Makefile install
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

        CMAKE_GENERATOR "Ninja"

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

        CMAKE_GENERATOR "Ninja"

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

        CMAKE_GENERATOR "Ninja"

        CMAKE_ARGS

            ${TOOLCHAIN_OPTIONS}

            -DCMAKE_CXX_FLAGS="-fPIC"

            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/install/spirvcross
        )
endif()

install (
    DIRECTORY ${CMAKE_BINARY_DIR}/install
    DESTINATION libs
    )
