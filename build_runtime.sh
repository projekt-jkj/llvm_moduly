#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "argument_parser.sh";

if [ "$SYSTEM" = "win" ]
then
	./build_mingw.sh "$@";
fi
./build_llvm_runtime.sh "$@";