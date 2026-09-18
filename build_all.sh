#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "argument_parser.sh";

if [ "$BUILD_TYPE" = release ]
then
	rm -rf "$INSTALL_PREFIX";
fi

./init_repositories.sh "$@";

./build_llvm.sh "$@";
./build_runtime.sh "$@";

if [ "$BUILD_CLANG_LIBRARIES" = ON ] || [ "$BUILD_LLVM_LIBRARIES" = ON ]
then
	./build_llvm_libraries.sh "$@";
fi