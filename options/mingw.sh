# shellcheck shell=bash
# shellcheck disable=SC2034

MINGW_COMMON_OPTIONS=(
	"--prefix=${SYSROOT_DIR}"
	"--target=${MINGW_TARGET}"
	--enable-silent-rules
);
MINGW_HEADERS_OPTIONS=(
	--enable-idl
	--with-default-msvcrt=ucrt
	--with-default-win32-winnt=0x601
	INSTALL=install -C
);
MINGW_CRT_OPTIONS=(
	"--with-sysroot=${SYSROOT_DIR}"
	--with-default-msvcrt=ucrt
	--disable-dependency-tracking
	"${MINGW_PLATFORM_ARGS[@]}"
);
MINGW_PTHREADS_OPTIONS=(
	"--with-sysroot=${SYSROOT_DIR}"
	--disable-dependency-tracking
);