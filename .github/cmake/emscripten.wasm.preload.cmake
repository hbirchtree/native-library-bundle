set ( GIT_DEP_BUILDVARIANT "emscripten.wasm" CACHE STRING "" )
set ( CMAKE_TOOLCHAIN_FILE "$ENV{EMSCRIPTEN}/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake" CACHE STRING "" )
set ( BUILD_AUDIO "OFF" CACHE STRING "" )
set ( BUILD_GLES "ON" CACHE STRING "" )
set ( BUILD_GLES_20 "ON" CACHE STRING "" )
set ( BUILD_OPENSSL "OFF" CACHE STRING "" )
set ( BUILD_ASSIMP "OFF" CACHE STRING "" )
set ( GENERATE_HTML "ON" CACHE STRING "" )
set ( CMAKE_BUILD_TYPE "$ENV{CONFIGURATION}" CACHE STRING "" )
set ( CMAKE_INSTALL_PREFIX "$ENV{CMAKE_INSTALL_DIR}/emscripten.wasm" CACHE STRING "" )
set ( BUILD_BINARIES "$ENV{GENERATE_PROGRAMS}" CACHE STRING "" )
set ( SKIP_GRAPHIC_TESTS "$ENV{HEADLESS}" CACHE STRING "" )
set ( BUILD_SDL2 "ON" CACHE STRING "" )
set ( BUILD_OPENSSL "OFF" CACHE STRING "" )
set ( BUILD_AUDIO "OFF" CACHE STRING "" )
set ( BUILD_GLES "ON" CACHE STRING "" )
set ( BUILD_GLES_20 "ON" CACHE STRING "" )
set ( GENERATE_HTML "ON" CACHE STRING "" )
set ( CMAKE_INSTALL_PREFIX "$ENV{CMAKE_INSTALL_DIR}" CACHE STRING "" )
