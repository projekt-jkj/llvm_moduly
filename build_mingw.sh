#!/bin/bash

set -ue;

CORES=4;
INSTALL_PATH="llvm_clang";

for a in "$@"
do
case $a in
	-target=*)
		TARGET="${a#*=}";
		;;
	-log=*)
		LOG_FILE="${a#*=}";
		;;

    -mingw=*)
        MINGW_TAG="${a#*=}";
        ;;
    -install_prefix=*)
        INSTALL_PREFIX="${a#*=}";
        ;;
	-install_path=*)
		INSTALL_PATH="${a#*=}";
		;;
    -cores=*)
        CORES="${a#*=}";
        ;;
    *)
        echo "Unknown argument '$a'";
        exit 1;
        ;;
esac
done

source ./def.sh;

log_begin "MinGW";

mkdir -p "${MINGW_BUILD}_headers";
cd "${MINGW_BUILD}_headers";

"${MINGW_SOURCE}/mingw-w64-headers/configure" \
	"--prefix=${INSTALL_BASE}/${INSTALL_PATH}" \
	"--target=$MINGW_TARGET" \
	--enable-idl \
	--with-default-win32-winnt=0x601 \
	--with-default-msvcrt=ucrt \
	INSTALL=install -C \
	>>"$LOG_FILE";

make install >>"$LOG_FILE";
log_ok "MinGW headers";

mkdir -p "${MINGW_BUILD}_crt";
cd "${MINGW_BUILD}_crt";

"${MINGW_SOURCE}/mingw-w64-crt/configure" \
	"--with-sysroot=${INSTALL_BASE}/${INSTALL_PATH}" \
	"--prefix=${INSTALL_BASE}/${INSTALL_PATH}" \
	"--target=$MINGW_TARGET" \
	"${MINGW_PLATFORM_ARGS[@]}" \
	--with-default-msvcrt=ucrt \
	--enable-silent-rules \
	--disable-dependency-tracking \
	>>"$LOG_FILE";

make install "-j$CORES" >>"$LOG_FILE";
log_ok "MinGW crt";