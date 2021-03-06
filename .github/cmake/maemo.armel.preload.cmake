set ( GIT_DEP_BUILDVARIANT "maemo.armel" CACHE STRING "" )
set ( CMAKE_TOOLCHAIN_FILE "$ENV{CMAKE_SOURCE_DIR}/toolchain/cmake/Toolchains/linux-maemo-armv7_linux.toolchain.cmake" CACHE STRING "" )
set ( BUILD_ASIO "OFF" CACHE STRING "" )
set ( BUILD_GLES "ON" CACHE STRING "" )
set ( BUILD_GLES_20 "ON" CACHE STRING "" )
set ( BUILD_SDL2 "OFF" CACHE STRING "" )
set ( CMAKE_BUILD_TYPE "Release" CACHE STRING "" )
set ( CMAKE_INSTALL_PREFIX "$ENV{CMAKE_INSTALL_DIR}/maemo.armel" CACHE STRING "" )
set ( BUILD_BINARIES "$ENV{GENERATE_PROGRAMS}" CACHE STRING "" )
set ( SKIP_GRAPHIC_TESTS "$ENV{HEADLESS}" CACHE STRING "" )
set ( BUILD_SDL2 "OFF" CACHE STRING "" )
set ( BUILD_X11 "ON" CACHE STRING "" )
set ( BUILD_EGL "ON" CACHE STRING "" )
set ( CMAKE_INSTALL_PREFIX "$ENV{CMAKE_INSTALL_DIR}" CACHE STRING "" )
