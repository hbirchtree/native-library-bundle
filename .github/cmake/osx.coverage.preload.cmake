set ( GIT_DEP_BUILDVARIANT "osx.coverage" CACHE STRING "" )
set ( CMAKE_TOOLCHAIN_FILE "$ENV{SOURCE_DIR}/toolchain/cmake/Toolchains/osx-generic_osx.toolchain.cmake" CACHE STRING "" )
set ( OPENSSL_ROOT_DIR "/usr/local/opt/openssl" CACHE STRING "" )
set ( BUILD_COVERAGE "ON" CACHE STRING "" )
set ( BUILD_ASAN "ON" CACHE STRING "" )
set ( BUILD_EXAMPLES "OFF" CACHE STRING "" )
set ( SKIP_HIGHMEM_TESTS "ON" CACHE STRING "" )
set ( SKIP_LINKAGE_TEST "ON" CACHE STRING "" )
set ( SKIP_OPENVR_TEST "ON" CACHE STRING "" )
set ( CMAKE_BUILD_TYPE "$ENV{CONFIGURATION}" CACHE STRING "" )
set ( CMAKE_INSTALL_PREFIX "$ENV{BUILD_DIR}/build/osx.coverage" CACHE STRING "" )
set ( BUILD_BINARIES "$ENV{GENERATE_PROGRAMS}" CACHE STRING "" )
set ( SKIP_GRAPHIC_TESTS "$ENV{HEADLESS}" CACHE STRING "" )
set ( BUILD_ETC2COMP "ON" CACHE STRING "" )
set ( BUILD_ASSIMP "ON" CACHE STRING "" )
set ( BUILD_DISCORD_RPC "ON" CACHE STRING "" )
set ( CMAKE_INSTALL_PREFIX "$ENV{CMAKE_INSTALL_DIR}" CACHE STRING "" )
