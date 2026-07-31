#!/bin/bash
# shellcheck source=/dev/null
set -ue;

CORES=4;

source "./argument_parser.sh";
source "./options/mingw.sh";
source "./helpers.sh";

export CC="$CLANG";
export CFLAGS="-resource-dir=${RESOURCE_DIR} --sysroot=${SYSROOT_DIR}";
export CXX="$CLANG_PP";
export CXXFLAGS="-resource-dir=${RESOURCE_DIR} --sysroot=${SYSROOT_DIR}";

log_begin "MinGW";

MINGW_HEADERS_DIR="${BUILD_BASE}/mingw_headers_${MINGW_TAG}";
mkdir -p "${MINGW_HEADERS_DIR}";
cd "${MINGW_HEADERS_DIR}";

"${MINGW_SOURCE}/mingw-w64-headers/configure" \
	"${MINGW_COMMON_OPTIONS[@]}" \
	"${MINGW_HEADERS_OPTIONS[@]}" \
>>"$LOG_FILE";

make install >>"$LOG_FILE";
log_ok "MinGW headers";

MINGW_BUILD_DIR="${BUILD_BASE}/mingw_crt_${MINGW_TAG}";
mkdir -p "${MINGW_BUILD_DIR}";
cd "${MINGW_BUILD_DIR}";

"${MINGW_SOURCE}/mingw-w64-crt/configure" \
	"${MINGW_COMMON_OPTIONS[@]}" \
	"${MINGW_CRT_OPTIONS[@]}" \
>>"$LOG_FILE";

make install "-j$CORES" >>"$LOG_FILE";

mkdir -p "$INSTALL_RUNTIME_BASE/licences";

cp -T \
	"${MINGW_SOURCE}/COPYING" \
	"$INSTALL_RUNTIME_BASE/licences/mingw_w64_root.txt";
cp -T \
	"${MINGW_SOURCE}/COPYING.MinGW-w64/COPYING.MinGW-w64.txt" \
	"$INSTALL_RUNTIME_BASE/licences/mingw_w64.txt";
cp -T \
	"${MINGW_SOURCE}/COPYING.MinGW-w64-runtime/COPYING.MinGW-w64-runtime.txt" \
	"$INSTALL_RUNTIME_BASE/licences/mingw_w64_runtime.txt";

log_ok "MinGW crt";