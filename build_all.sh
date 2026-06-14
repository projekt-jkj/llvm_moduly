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

if [ "$SYSTEM" = "win" ]
then
	./build_mingw.sh "$@";
fi
./build_llvm_runtime.sh "$@";