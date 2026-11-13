#!/bin/bash
# shellcheck source=/dev/null
set -ue;

CORES=4;

source "./argument_parser.sh";
source "./options/mingw.sh";
source "./options/crt_tools_selection.sh";
source "./helpers.sh";

log_header "MinGW";

MINGW_PTHREADS_DIR="${BUILD_BASE}/mingw_pthreads_${MINGW_TAG}";
mkcd "${MINGW_PTHREADS_DIR}";

log_begin "MinGW WinPthreads";
{
	"${MINGW_SOURCE}/mingw-w64-libraries/winpthreads/configure" \
		"${MINGW_COMMON_OPTIONS[@]}" \
		"${MINGW_PTHREADS_OPTIONS[@]}";

	make "-j$CORES";
	make install;
} \
>>"$LOG_FILE";

log_end "MinGW WinPthreads";

mkdir -p "$INSTALL_RUNTIME_BASE/licences";

cp -T \
	"${EXTERNAL_SOURCE}/c11threads/threads.h" \
	"${SYSROOT_DIR}/include/threads.h"
cp -T \
	"${EXTERNAL_SOURCE}/c11threads/LICENCE" \
	"$INSTALL_RUNTIME_BASE/licences/c11threads.txt";
cp -T \
	"${MINGW_SOURCE}/mingw-w64-libraries/winpthreads/COPYING" \
	"$INSTALL_RUNTIME_BASE/licences/mingw_w64_winpthreads.txt";