# What is this?

A repository containing pre-compiled libraries and their respective headers for use in various projects. The libraries are as follows per platform:

| **Library**     | **Android**   | **Linux**                   || **Apple**                    || **Windows**                    ||
|:----------------|--------------:|-------------:|--------------:|--------------:|--------------:|---------------:|---------------:|
| **Variant**     |               | **SteamOS**  | **Linux**     | **OS X**      | **iOS**       | **Win32**      | **UWP**        |
| **SDL2**        | 2.0.4, static | Inc., shared | 2.0.4, static | 2.0.4, shared | 2.0.4, static | 2.0.4, static  | 2.0.4, static  |
| **OpenAL-soft** | 1.1, shared   | Inc., shared | master        | Inc., shared  | -             | 1.1, shared    | 1.1, shared    |
| **OpenSSL**     | Not yet ©     | Inc., shared | master        | Inc., shared  | Inc., shared? | Latest, shared | Latest, shared |
| **glbinding**   | -             | master       | master        | master        | -             | master         | master         |
| **assimp**      | master        | master       | master        | master        | master        | master         | master         |
| **ffmpeg**      | -             | Inc., shared | master        | master        | -             | master         | master         |

*(Assume Android to include armeabi-v7a, arm64-v8a, x86, x86_64 and mips architectures)*

*(Assume Windows to mean only 64-bit, because 32-bit is dead)*

*(Assume iOS to include 32-bit and 64-bit architectures)*

*(Assume OSX to include only 64-bit)*

# How is this structured?
For most systems:

 - $SYSTEM_NAME (eg. SteamOS)
   - common
     - (header directory)
     - header.h
   - amd64
     - libLibrary.a
     - libLibrary.so
   - i686
     - libLibrary.a
     - libLibrary.so
   - util
     - SomeNecessarySmallProgram2

*(Variations are found with Windows (32 and 64) and OSX/iOS)*

*(Data meant for /usr/share is ignored)*
