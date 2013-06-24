@echo off

cd winbuild

if "%1"=="" goto HELP
if "%2"=="" goto HELP
if "%3"=="" goto HELP

set WL_CRT=%1
set WL_MODE=%2
set WL_ARCH=%3

if NOT "debug"=="%WL_MODE%" (
	if NOT "release"=="%WL_MODE%" (
		echo Invalid env
		goto HELP
	)
)

rem set debug option
set WL_DEBUG=no
if "debug"=="%WL_MODE%" (
	set WL_DEBUG=yes
)

if NOT "x86"=="%WL_ARCH%" (
	if NOT "x64"=="%WL_ARCH%" (
		echo Invalid platform
		goto HELP
	)
)

if "vc9"=="%WL_CRT%" (
	if "x86"=="%WL_ARCH%" (
		call "%ProgramFiles%\Microsoft Visual Studio 9.0\VC\bin\vcvars32.bat" 
		setenv /%WL_MODE% /%WL_ARCH% /xp
		set WL_IDN=no
		set WL_WC_NUM=9
	) else (
		rem call "%ProgramFiles%\Microsoft Visual Studio 9.0\VC\bin\vcvarsx86_amd64.bat" 
		echo only x86 build for vc9 are supported
		goto EXIT_BAD 
	)
) else if "vc11"=="%WL_CRT%" (
	call "%ProgramFiles%\Microsoft Visual Studio 11.0\VC\vcvarsall.bat" %WL_ARCH%
	set WL_IDN=yes
	set WL_WC_NUM=11
) else (
	echo Unsupported Visual C++ version
	goto EXIT_BAD 
)


if ""=="%WL_DEPS_PREFIX%" set WL_DEPS_PREFIX=C:\php-lib-deps
set WL_DEPS="%WL_DEPS_PREFIX%\%WL_CRT%\%WL_ARCH%\curl"
if NOT EXIST %WL_DEPS% (
        echo "Dependencies not found!"
        echo "To fix this, please"
        echo " - set WL_DEPS_PREFIX=<some_full_path> or use C:\php-lib-deps as a fallback"
        echo " - put the dependencies into WL_DEPS_PREFIX\%WL_CRT%\%WL_ARCH%\curl"
        echo " - rerun the script"
        goto EXIT_BAD
)


rem all checks are ok, do build
nmake /f Makefile.vc mode=static VC=%WL_WC_NUM% WITH_DEVEL=%WL_DEPS% WITH_SSL=dll WITH_ZLIB=static WITH_SSH2=static ENABLE_WINSSL=no USE_IDN=%WL_IDN% ENABLE_IPV6=yes GEN_PDB=yes DEBUG=no MACHINE=%WL_ARCH%
goto EXIT_GOOD

:EXIT_GOOD
	cd ..
	exit /b 0

:EXIT_BAD
	cd ..
	exit /b 3

:HELP
	cd ..
	echo Builds a winlibs project
	echo Usage: build.bat ^<CRT^> ^<mode^> ^<arch^>
	echo     CRT         vc9 or vc11
	echo     mode        release or debug
	echo     arch        x86 or x64
