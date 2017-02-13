# sdl2 cmake project-config input for ./configure scripts

set(prefix "/buildbot/slave/SDL/sdl-nacl/src/nacl-buildbot/nacl-sdl2-installed") 
set(exec_prefix "${prefix}")
set(libdir "${exec_prefix}/lib")
set(SDL2_PREFIX "/buildbot/slave/SDL/sdl-nacl/src/nacl-buildbot/nacl-sdl2-installed")
set(SDL2_EXEC_PREFIX "/buildbot/slave/SDL/sdl-nacl/src/nacl-buildbot/nacl-sdl2-installed")
set(SDL2_LIBDIR "${exec_prefix}/lib")
set(SDL2_INCLUDE_DIRS "${prefix}/include/SDL2")
set(SDL2_LIBRARIES "-L${SDL2_LIBDIR}  -lppapi_simple -lppapi_gles2 -lSDL2 ")
string(STRIP "${SDL2_LIBRARIES}" SDL2_LIBRARIES)
