@echo off

cd winbuild

if "%1"=="" goto HELP
if "%2"=="" goto HELP
if "%3"=="" goto HELP
if "%4"=="" goto HELP

set WL_VC=%1
set WL_ENV=%2
set WL_PLATFORM=%3
set WL_DEPS=%4

if NOT "debug"=="%WL_ENV%" (
	if NOT "release"=="%WL_ENV%" (
		echo Invalid env
		goto HELP
	)
)

rem set debug option
set WL_DEBUG=no
if "debug"=="%WL_ENV%" (
	set WL_DEBUG=yes
)

if NOT "x86"=="%WL_PLATFORM%" (
	if NOT "x64"=="%WL_PLATFORM%" (
		echo Invalid platform
		goto HELP
	)
)

if "vc9"=="%WL_VC%" (
	if "x86"=="%WL_PLATFORM%" (
		call "%ProgramFiles%\Microsoft Visual Studio 9.0\VC\bin\vcvars32.bat" 
		setenv /%WL_ENV% /%WL_PLATFORM% /xp
		set WL_IDN=no
		set WL_WC_NUM=9
	) else (
		rem call "%ProgramFiles%\Microsoft Visual Studio 9.0\VC\bin\vcvarsx86_amd64.bat" 
		echo only x86 build for vc9 are supported
		goto EXIT_BAD 
	)
) else if "vc11"=="%WL_VC%" (
	call "%ProgramFiles%\Microsoft Visual Studio 11.0\VC\vcvarsall.bat" %WL_PLATFORM%
	set WL_IDN=yes
	set WL_WC_NUM=11
) else (
	echo Unsupported Visual Studio version
	goto EXIT_BAD 
)

rem all checks are ok, do build
nmake /f Makefile.vc mode=static VC=%WL_WC_NUM% WITH_DEVEL=%WL_DEPS% WITH_SSL=dll WITH_ZLIB=static WITH_SSH2=static ENABLE_WINSSL=no USE_IDN=%wL_IDN% ENABLE_IPV6=yes GEN_PDB=yes DEBUG=no MACHINE=%WL_PLATFORM%
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
	echo Usage: build.bat vc env platform path
	echo     vc         vc9 or vc11
	echo     env        release or debug
	echo     platform   x86 or x64
	echo     path       path to the deps
