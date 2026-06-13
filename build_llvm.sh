#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "./argument_parser.sh";
source "./helpers.sh";
source "./options/llvm.sh";

if [ "$BUILD_TYPE" = "release" ] || [ "$BUILD_TYPE" = "llvm_build" ] \
	|| [ "$BUILD_TYPE" = "runtime_test" ]
then
	LLVM_BUILD="$BUILD_BASE/llvm_${LLVM_TAG}";
    mkdir -p "$LLVM_BUILD";
    cd "$LLVM_BUILD";
elif [ "$BUILD_TYPE" = "llvm_test" ]
then
	LLVM_BUILD="$BUILD_BASE/llvm_test_${LLVM_TAG}";
    mkdir -p "${LLVM_BUILD}";
    cd "${LLVM_BUILD}";
else
    echo "Unknown build type.";
    exit 1;
fi

log_begin "LLVM";

cmake -G Ninja \
	"${CMAKE_OPTIONS[@]}" \
	"${LLVM_OPTIONS[@]}" \
	"${CLANG_OPTIONS[@]}" \
	"${LLD_OPTIONS[@]}" \
    "${LLVM_SOURCE}/llvm" >>"$LOG_FILE";

log_ok "LLVM configure";

cmake --build . "-j$CORES" >>"$LOG_FILE";
log_ok "LLVM build";

if [ "$BUILD_TYPE" = "llvm_build" ]
then
	exit 1;
elif [ "$BUILD_TYPE" = "test" ]
then
	log_begin "LLVM tests";
	cmake --build . --target check "-j$CORES" >>"$LOG_FILE";
	log_ok "LLVM tests";
	exit 1;
else
	for c in "${LLVM_CLANG[@]}"
	do
		install "$c" llvm_clang;
	done

	reset_dir "${INSTALL_BASE}/lib";
	install_resource_headers clang llvm_clang;
	rm -rf "${INSTALL_BASE:?}/lib";

	log_ok "LLVM install";
fi