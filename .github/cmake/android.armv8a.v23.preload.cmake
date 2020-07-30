set ( GIT_DEP_BUILDVARIANT "android.armv8a.v23" CACHE STRING "" )
set ( ANDROID_NDK "$ENV{ANDROID_NDK}" CACHE STRING "" )
set ( ANDROID_SDK "$ENV{ANDROID_SDK}" CACHE STRING "" )
set ( ANDROID_TOOLCHAIN "clang" CACHE STRING "" )
set ( ANDROID_STL "c++_static" CACHE STRING "" )
set ( ANDROID_PLATFORM "android-23" CACHE STRING "" )
set ( ANDROID_ABI "arm64-v8a" CACHE STRING "" )
set ( ANDROID_CPP_FEATURES "rtti;exceptions" CACHE STRING "" )
set ( ANDROID_ARM_NEON "OFF" CACHE STRING "" )
set ( CMAKE_TOOLCHAIN_FILE "$ENV{ANDROID_NDK}/build/cmake/android.toolchain.cmake" CACHE STRING "" )
set ( CMAKE_BUILD_TYPE "$ENV{CONFIGURATION}" CACHE STRING "" )
set ( CMAKE_INSTALL_PREFIX "$ENV{CMAKE_INSTALL_DIR}/android.armv8a.v23" CACHE STRING "" )
set ( BUILD_BINARIES "$ENV{GENERATE_PROGRAMS}" CACHE STRING "" )
set ( SKIP_GRAPHIC_TESTS "$ENV{HEADLESS}" CACHE STRING "" )
set ( BUILD_EGL "ON" CACHE STRING "" )
set ( BUILD_GLES "ON" CACHE STRING "" )
set ( BUILD_ANATIVE "ON" CACHE STRING "" )
set ( BUILD_TESTS "OFF" CACHE STRING "" )
set ( BUILD_SDL2 "OFF" CACHE STRING "" )
