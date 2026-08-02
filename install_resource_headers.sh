#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "./argument_parser.sh";
source "./helpers.sh";
source "./options/llvm_runtime.sh";

log_header "Clang resource headers";
mkcd "$LLVM_RESOURCE_HEADERS_DIR";

log_begin "Clang resource headers configure";

cmake -G Ninja \
	-Wno-dev \
	"-DCMAKE_INSTALL_PREFIX=$INSTALL_RUNTIME_BASE" \
	-DLLVM_ENABLE_PROJECTS=clang \
	-DCLANG_RESOURCE_DIR=../resource \
	"${LLVM_SOURCE}/llvm" \
>>"$LOG_FILE";

log_end "Clang resource headers configure";

HEADERS=(core-resource-headers utility-resource-headers);
case "$PLATFORM" in
	x64)
		HEADERS+=(x86-resource-headers);
		;;
esac

if [ "$SYSTEM" = "win" ]
then
	HEADERS+=(windows-resource-headers);
fi

log_begin "Clang resource headers install";
install_ninja "${HEADERS[@]}";
log_end "Clang resource headers install";