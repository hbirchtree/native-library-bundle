# What is this?

A repository containing pre-compiled libraries and their respective headers for use in various projects. The libraries are as follows per platform:

## Client dependencies

The platforms included are:
 - Android (ARMv7-A, ARMv8, x86, x86-64) (flavors of Kitkat, Lollipop, Nougat)
 - Linux (including Ubuntu, Fedora, SteamOS, Raspberry Pi)
 - macOS
 - iOS
 - MinGW-W64

Listed beneath are versions for the libraries across the board

| **Library** | **Version** |
|:-----------:|:-----------:|
| **Assimp**  | 5.0.1       |
| **Bullet**  | 2.88        |
| **OpenSSL** | 1.1.1g<sup>2</sup>  |
| **OpenAL**  | 1.20.1<sup>1</sup>    |
| **zlib**    | 1.2.11<sup>2</sup>    |

<sup>1</sup> Only for Android and Linux

<sup>2</sup> All platforms except Emscripten, `emscripten-ports` provides it

SDL2 is only built for desktop platforms, with `emscripten-ports` providing SDL2 already.

| **Library** | **Linux** | **macOS** | **Windows** |
|:-----------:|:---------:|:---------:|:-----------:|
| **SDL2**    | 2.0.12    | 2.0.12    | 2.0.12      |

## Build dependencies

Desktop-only dependencies, not intended for client binaries. These are available for `ubuntu.amd64`, `fedora.amd64` and `osx`.

| **Library**        | **Version**        |
|:------------------:|:------------------:|
| **Squish**         | Latest             |
| **FFMPEG**         | 4.1.5              |
| **glslang**        | Patched version<sup>1</sup>  |
| **shaderc**        | Patched version<sup>1</sup>  |
| **spirv-cross**    | Patched version<sup>2</sup> |
| **compressonator** | 3.1.4064<sup>3</sup>       |

<sup>1</sup> Patches for CMake configuration

<sup>2</sup> Patches for some GLESv2 features

<sup>3</sup> Patches for compiling on Linux

# How is this strucutred?

Built dependencies are published to releases for this repository.
Each dependency may be downloaded piecewise. The structure of each package is as such:

 - bin/
    - *executable files, not common*
 - lib/
    - cmake
        - $name
            - *CMake files*
    - *library files*
 - license/
    - *license files, eg. COPYING.txt, LICENSE etc.*
 - share/
    - *application data*
