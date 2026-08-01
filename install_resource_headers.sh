#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "./argument_parser.sh";
source "./helpers.sh";
source "./options/llvm_runtime.sh";

mkcd "$LLVM_RESOURCE_HEADERS_DIR";

cmake -G Ninja \
	"-DCMAKE_INSTALL_PREFIX=$INSTALL_RUNTIME_BASE" \
	-DLLVM_ENABLE_PROJECTS="clang" \
	-DCLANG_RESOURCE_DIR=../resource \
	"${LLVM_SOURCE}/llvm" \
>>"$LOG_FILE";

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

install_ninja "${HEADERS[@]}";