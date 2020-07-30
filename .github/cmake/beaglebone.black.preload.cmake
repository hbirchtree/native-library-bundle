set ( GIT_DEP_BUILDVARIANT "beaglebone.black" CACHE STRING "" )
set ( CMAKE_TOOLCHAIN_FILE "$ENV{CMAKE_SOURCE_DIR}/toolchain/cmake/Toolchains/linux-beagle-armv7hf_linux.toolchain.cmake" CACHE STRING "" )
set ( CMAKE_BUILD_TYPE "$ENV{CONFIGURATION}" CACHE STRING "" )
set ( CMAKE_INSTALL_PREFIX "$ENV{CMAKE_INSTALL_DIR}/beaglebone.black" CACHE STRING "" )
set ( BUILD_BINARIES "$ENV{GENERATE_PROGRAMS}" CACHE STRING "" )
set ( SKIP_GRAPHIC_TESTS "$ENV{HEADLESS}" CACHE STRING "" )
set ( BUILD_GLES "ON" CACHE STRING "" )
set ( BUILD_GLES_20 "ON" CACHE STRING "" )
set ( BUILD_OPENAL "OFF" CACHE STRING "" )
set ( BUILD_OPENSSL "OFF" CACHE STRING "" )
set ( BUILD_SDL2 "OFF" CACHE STRING "" )
