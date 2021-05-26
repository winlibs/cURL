param (
    [Parameter(Mandatory)] $vs,
    [Parameter(Mandatory)] $arch,
    [Parameter(Mandatory)] $libssh2,
    [Parameter(Mandatory)] $openssl,
    [Parameter(Mandatory)] $zlib,
    [Parameter(Mandatory)] $nghttp2
)

$ErrorActionPreference = "Stop"

New-Item "winlib_deps" -ItemType "directory"

$temp = New-TemporaryFile | Rename-Item -NewName {$_.Name + ".zip"} -PassThru
Invoke-WebRequest "https://windows.php.net/downloads/php-sdk/deps/$vs/$arch/libssh2-$libssh2-$vs-$arch.zip" -OutFile $temp
Expand-Archive $temp -DestinationPath "winlib_deps"

$temp = New-TemporaryFile | Rename-Item -NewName {$_.Name + ".zip"} -PassThru
Invoke-WebRequest "https://windows.php.net/downloads/php-sdk/deps/$vs/$arch/openssl-$openssl-$vs-$arch.zip" -OutFile $temp
Expand-Archive $temp -DestinationPath "winlib_deps"

$temp = New-TemporaryFile | Rename-Item -NewName {$_.Name + ".zip"} -PassThru
Invoke-WebRequest "https://windows.php.net/downloads/php-sdk/deps/$vs/$arch/zlib-$zlib-$vs-$arch.zip" -OutFile $temp
Expand-Archive $temp -DestinationPath "winlib_deps"

$temp = New-TemporaryFile | Rename-Item -NewName {$_.Name + ".zip"} -PassThru
Invoke-WebRequest "https://windows.php.net/downloads/php-sdk/deps/$vs/$arch/nghttp2-$nghttp2-$vs-$arch.zip" -OutFile $temp
Expand-Archive $temp -DestinationPath "winlib_deps"

Set-Location "winbuild"
nmake "/f" "Makefile.vc" "mode=static" "VC=$($vs.substring(2))" "WITH_DEVEL=..\winlib_deps" "WITH_SSL=dll" "WITH_ZLIB=static" "WITH_NGHTTP2=dll" "WITH_SSH2=dll" "ENABLE_WINSSL=no" "USE_IDN=yes" "ENABLE_IPV6=yes" "GEN_PDB=yes" "DEBUG=no" "MACHINE=$arch" "CURL_DISABLE_MQTT=1"

Set-Location ".."
xcopy "/e" "builds\libcurl-vc$($vs.substring(2))-$arch-release-static-ssl-dll-zlib-static-ssh2-dll-ipv6-sspi-nghttp2-dll\*" "winlib_build\*"
