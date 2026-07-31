# shellcheck shell=bash
# shellcheck disable=SC2034

MINGW_COMMON_OPTIONS=(
	"--prefix=${SYSROOT_DIR}"
	"--target=$MINGW_TARGET"
	--with-default-msvcrt=ucrt
);
MINGW_HEADERS_OPTIONS=(
	--enable-idl
	--with-default-win32-winnt=0x601
	INSTALL=install -C
);
MINGW_CRT_OPTIONS=(
	"--with-sysroot=${SYSROOT_DIR}"
	--enable-silent-rules
	--disable-dependency-tracking
	"${MINGW_PLATFORM_ARGS[@]}"
);