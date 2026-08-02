#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "./argument_parser.sh";
source "./helpers.sh";

export CC="$CLANG";
export CFLAGS="-resource-dir=${RESOURCE_DIR} --sysroot=${SYSROOT_DIR}";
export CROSS_COMPILE=llvm-;

log_header "Musl";

MUSL_OPTIONS=(
	"--prefix=${SYSROOT_DIR}"
	"--target=${MUSL_TARGET}"
	--disable-shared
);
MUSl_DIR="${BUILD_BASE}/musl_${MUSL_TAG}";
mkcd "${MUSl_DIR}";

log_begin "Musl";

"${MUSL_SOURCE}/configure" \
	"${MUSL_OPTIONS[@]}" \
>>"$LOG_FILE";

make install "-j$CORES" >>"$LOG_FILE";

mkdir -p "$INSTALL_RUNTIME_BASE/licences";

cp -T \
	"${MUSL_SOURCE}/COPYRIGHT" \
	"$INSTALL_RUNTIME_BASE/licences/musl.txt";

log_end "Musl";

log_header "Linux kernel headers";
log_begin "Linux kernel headers";

make LLVM=1 \
	"ARCH=${LINUX_ARCH}" \
	"INSTALL_HDR_PATH=$SYSROOT_DIR" \
	-C "${LINUX_SOURCE}" \
	headers_install \
>>"$LOG_FILE";

log_end "Linux kernel headers";