#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "./argument_parser.sh";
source "./helpers.sh";
source "./options/llvm.sh";

mkdir -p "$LLVM_BUILD_DIR";
cd "$LLVM_BUILD_DIR";

log_begin "LLVM";

cmake -G Ninja \
	"${CMAKE_OPTIONS[@]}" \
	"${LLVM_OPTIONS[@]}" \
	"${CLANG_OPTIONS[@]}" \
	"${LLD_OPTIONS[@]}" \
    "${LLVM_SOURCE}/llvm" >>"$LOG_FILE";

log_ok "LLVM configure";

for dist in "${DISTRIBUTIONS[@]}"
do
	build "$dist";
	log_ok "LLVM build $dist";
done

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
	for dist in "${DISTRIBUTIONS[@]}"
	do
		install "$dist";
	done

	log_ok "LLVM install";
fi