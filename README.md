# libcURL - the multiprotocol file transfer library

Project URL: [http://curl.haxx.se/libcurl/](http://curl.haxx.se/libcurl/)

# Building for PHP

## Available prebuilt libraries

All prebuilt libraries are available as part of the [PHP
SDK](http://windows.php.net/downloads/php-sdk/)

## Requirements

  * CURL sources, patched, available in [here](https://github.com/winlibs)

  * OpenSSL binaries and development files

  * Libssh2 binaries and development files

  * Zlib binaries and development files

  * Create a clean build tree without the classic php dependencies in ..\..\deps but only the required deps (ssl and zlib). Having curl headers in your include path is likely to break the build

## Configuration

See [https://github.com/pierrejoye/curl/blob/master/winbuild/BUILD.WINDOWS.txt
](https://github.com/pierrejoye/curl/blob/master/winbuild/BUILD.WINDOWS.txt)

Example release build command line:

for x86
    
    nmake /f Makefile.vc mode=static VC=9 WITH_DEVEL=D:\repo\curl_deps WITH_SSL=dll WITH_ZLIB=static WITH_SSH2=static ENABLE_WINSSL=no USE_IDN=no GEN_PDB=yes DEBUG=no

for x64

    nmake /f Makefile.vc mode=static VC=9 WITH_DEVEL=D:\repo\curl_deps WITH_SSL=dll WITH_ZLIB=static WITH_SSH2=static ENABLE_WINSSL=no USE_IDN=no GEN_PDB=yes DEBUG=no MACHINE=x64