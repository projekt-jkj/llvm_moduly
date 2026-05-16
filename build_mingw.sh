#!/bin/bash

set -ue;

CORES=4;

for a in "$@"
do
case $a in
    -mingw)
		INCLUDE_MINGW="ON";
        ;;
    -mingw=*)
        MINGW_TAG="${a#*=}";
		INCLUDE_MINGW="ON";
        ;;
    -install_prefix=*)
        INSTALL_PREFIX="${a#*=}";
        ;;
    -cores=*)
        CORES="${a#*=}";
        ;;
	-log=*)
		LOG_FILE="${a#*=}";
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
	"--prefix=${INSTALL_BASE}/mingw_headers" \
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
	"--prefix=${INSTALL_BASE}/mingw_crt" \
	--disable-lib32 \
	--enable-lib64 \
	--with-default-msvcrt=ucrt \
	--enable-silent-rules \
	--enable-cfguard \
	--disable-dependency-tracking \
	>>"$LOG_FILE";

make install "-j$CORES" >>"$LOG_FILE";
log_ok "MinGW crt";