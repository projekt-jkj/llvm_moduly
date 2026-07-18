#!/bin/bash
# shellcheck source=/dev/null
set -ue;

CORES=4;
INSTALL_PATH="llvm_clang";

source "./argument_parser.sh";
source "./helpers.sh";

MINGW_INSTALL_DIR="${INSTALL_BASE}/${INSTALL_PATH}";

log_begin "MinGW";

MINGW_HEADERS_DIR="${BUILD_BASE}/mingw_headers_${MINGW_TAG}";
mkdir -p "${MINGW_HEADERS_DIR}";
cd "${MINGW_HEADERS_DIR}";

"${MINGW_SOURCE}/mingw-w64-headers/configure" \
	"--prefix=${MINGW_INSTALL_DIR}" \
	"--target=$MINGW_TARGET" \
	--enable-idl \
	--with-default-win32-winnt=0x601 \
	--with-default-msvcrt=ucrt \
	INSTALL=install -C \
	>>"$LOG_FILE";

make install >>"$LOG_FILE";
log_ok "MinGW headers";

MINGW_BUILD_DIR="${BUILD_BASE}/mingw_crt_${MINGW_TAG}";
mkdir -p "${MINGW_BUILD_DIR}";
cd "${MINGW_BUILD_DIR}";

"${MINGW_SOURCE}/mingw-w64-crt/configure" \
	"--with-sysroot=${MINGW_INSTALL_DIR}" \
	"--prefix=${MINGW_INSTALL_DIR}" \
	"--target=$MINGW_TARGET" \
	"${MINGW_PLATFORM_ARGS[@]}" \
	--with-default-msvcrt=ucrt \
	--enable-silent-rules \
	--disable-dependency-tracking \
	>>"$LOG_FILE";

make install "-j$CORES" >>"$LOG_FILE";


cp -T \
	"${MINGW_SOURCE}/COPYING" \
	"$MINGW_INSTALL_DIR/licences/mingw_w64.txt";
cp -T \
	"${MINGW_SOURCE}/COPYING.MinGW-w64/COPYING.MinGW-w64.txt" \
	"$MINGW_INSTALL_DIR/licences/COPYING.MinGW-w64.txt";
cp -T \
	"${MINGW_SOURCE}/COPYING.MinGW-w64-runtime/COPYING.MinGW-w64-runtime.txt" \
	"$MINGW_INSTALL_DIR/licences/COPYING.MinGW-w64-runtime.txt";

log_ok "MinGW crt";