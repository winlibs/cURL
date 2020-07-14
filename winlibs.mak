!IFNDEF VERSION
VERSION=unknown
!ENDIF

!IF "$(PHP_SDK_VS_NUM)" >= "14"
NGHTTP2_PREFIX=-nghttp2-dll
NGHTTP2_NMAKE=WITH_NGHTTP2=dll
!ENDIF

PREFIX=..\builds\libcurl-vc$(PHP_SDK_VS_NUM)-$(PHP_SDK_ARCH)-release-static-ssl-dll-zlib-static-ssh2-dll-ipv6-sspi$(NGHTTP2_PREFIX)

OUTPUT=$(MAKEDIR)\..\libcurl-$(VERSION)-$(PHP_SDK_VS)-$(PHP_SDK_ARCH)
ARCHIVE=$(OUTPUT).zip

all:
	git checkout -- .
	git clean -fdx

	cd winbuild
	nmake /f Makefile.vc mode=static VC=$(PHP_SDK_VS_NUM) WITH_DEVEL=..\..\deps WITH_SSL=dll WITH_ZLIB=static $(NGHTTP2_NMAKE) WITH_SSH2=dll ENABLE_WINSSL=no USE_IDN=yes ENABLE_IPV6=yes GEN_PDB=yes DEBUG=no MACHINE=$(PHP_SDK_ARCH)

	-rmdir /s /q $(OUTPUT)
	xcopy /e $(PREFIX)\* $(OUTPUT)\*

	del $(ARCHIVE)
	7za a $(ARCHIVE) $(OUTPUT)\*
