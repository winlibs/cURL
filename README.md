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

  * Nghttp2 binaries and development files

  * Create a clean build tree without the classic php dependencies in ..\..\deps but only the required deps (ssl, ssh2, zlib and nghttp2). Having curl headers in your include path is likely to break the build

## Configuration

See [https://github.com/pierrejoye/curl/blob/master/winbuild/BUILD.WINDOWS.txt
](https://github.com/pierrejoye/curl/blob/master/winbuild/BUILD.WINDOWS.txt)

### Release build command lines:

#### PHP 5.5 x86

	nmake /f Makefile.vc mode=static VC=11 WITH_DEVEL=D:\repo\curl_deps.x86 WITH_SSL=dll WITH_ZLIB=static WITH_SSH2=dll ENABLE_WINSSL=no USE_IDN=yes ENABLE_IPV6=yes GEN_PDB=yes DEBUG=no MACHINE=x86

#### PHP 5.5 x64

	nmake /f Makefile.vc mode=static VC=11 WITH_DEVEL=D:\repo\curl_deps.x64 WITH_SSL=dll WITH_ZLIB=static WITH_SSH2=dll ENABLE_WINSSL=no USE_IDN=yes ENABLE_IPV6=yes GEN_PDB=yes DEBUG=no MACHINE=x64

#### PHP 7.x x86

	nmake /f Makefile.vc mode=static VC=14 WITH_DEVEL=E:\repo\deps_curl\vc14\x86 WITH_SSL=dll WITH_ZLIB=static WITH_NGHTTP2=dll WITH_SSH2=dll ENABLE_WINSSL=no USE_IDN=yes ENABLE_IPV6=yes GEN_PDB=yes DEBUG=no MACHINE=x86 

#### PHP 7.x x64

	nmake /f Makefile.vc mode=static VC=14 WITH_DEVEL=E:\repo\deps_curl\vc14\x64 WITH_SSL=dll WITH_ZLIB=static WITH_NGHTTP2=dll WITH_SSH2=dll ENABLE_WINSSL=no USE_IDN=yes ENABLE_IPV6=yes GEN_PDB=yes DEBUG=no MACHINE=x64 

