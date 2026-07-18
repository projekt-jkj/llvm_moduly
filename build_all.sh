#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "argument_parser.sh";

if [ "$BUILD_TYPE" = release ]
then
	rm -rf "$INSTALL_BASE";
fi

./init_repositories.sh "$@";

./build_llvm.sh "$@";
./build_runtime.sh "$@";
./build_llvm_libraries.sh "$@";