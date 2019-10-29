# What is this?

A repository containing pre-compiled libraries and their respective headers for use in various projects. The libraries are as follows per platform:

| **Library** | **Linux** | **macOS** | **Windows** |
| **SDL2**    | 2.0.10    | 2.0.10    | 2.0.10      |

| **Library** | **Android** | **Linux** | **macOS + iOS** | **Windows** |
|:-----------:|:-----------:|:---------:|:---------------:|:-----------:|
| **OpenSSL** | 1.0.2t      | 1.1.1d    | 1.1.1d          | 1.1.1d      |

*(Assume Android to include armeabi-v7a, arm64-v8a, x86, x86_64 and mips architectures)*

*(Assume Windows to mean only 64-bit, because 32-bit is dead)*

*(Assume iOS to include 32-bit and 64-bit architectures)*

*(Assume OSX to include only 64-bit)*

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


| **Library**  | **Android**   | **Linux**                   || **Apple**                    || **Windows**                    ||
|:-------------|--------------:|-------------:|--------------:|--------------:|--------------:|---------------:|---------------:|
| **Variant**  |               | **SteamOS**  | **Linux**     | **OS X**      | **iOS**       | **Win32**      | **UWP**        |
| **SDL2**     |               | Inc., shared | 2.0.10, static| 2.0.10, shared|               | 2.0.4, static  | 2.0.4, static  |
| **OpenAL**   | 1.19, shared  | Inc., shared | master        | Inc., shared  | -             | 1.1, shared    | -              |
| **OpenSSL**  | 1.0.2t        | Inc., shared | master        | Inc., shared  | Inc., shared? | Latest, shared | -              |
| **assimp**   | master        | master       | master        | master        | master        | master         | -              |
| **ffmpeg**   | -             | Inc., shared | master        | master        | -             | master         | -              |

| **Library**  | **SDL2**      | **OpenAL**   | **OpenSSL**   | **assimp**    | **ffmpeg**    | **Bullet**   |
|:-------------|--------------:|-------------:|--------------:|--------------:|--------------:|-------------:|
|**Android**   | 2.0.4, static | 1.1, shared  | Not Yet ©     | master        | -             |              |
|**Apple OS X**| 2.0.4, shared | Inc., shared | Inc., shared  | master        | master        |              |
|**Apple iOS** | 2.0.4, static | -            | Inc., shared  | master        | -             |              |
|**Emscripten**| 2.0.4, static |              |               |               |               |              |
|**Linux**     |               |              |               |               |               |              |
|**NaCL**      | 2.0.4, static | -            | -             | -             | -             |              |
|**RaspPi**    | Inc., shared  | Inc., shared | Inc., shared  | -             |               |              |
|**Windows**   |               |              |               |               |               |              |
