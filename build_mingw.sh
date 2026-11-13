#!/bin/bash
# shellcheck source=/dev/null
set -ue;

CORES=4;

source "./argument_parser.sh";
source "./options/mingw.sh";
source "./options/crt_tools_selection.sh";
source "./helpers.sh";

log_header "MinGW";

MINGW_HEADERS_DIR="${BUILD_BASE}/mingw_headers_${MINGW_TAG}";
mkcd "${MINGW_HEADERS_DIR}";

log_begin "MinGW headers";

{
	"${MINGW_SOURCE}/mingw-w64-headers/configure" \
		"${MINGW_COMMON_OPTIONS[@]}" \
		"${MINGW_HEADERS_OPTIONS[@]}";

	make "-j$CORES";
	make install;
} \
>>"$LOG_FILE";

log_end "MinGW headers";

log_begin "MinGW crt";

MINGW_BUILD_DIR="${BUILD_BASE}/mingw_crt_${MINGW_TAG}";
mkcd "${MINGW_BUILD_DIR}";

{
	"${MINGW_SOURCE}/mingw-w64-crt/configure" \
		"${MINGW_COMMON_OPTIONS[@]}" \
		"${MINGW_CRT_OPTIONS[@]}";

	make "-j$CORES";
	make install;
} \
>>"$LOG_FILE";

log_end "MinGW crt";

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