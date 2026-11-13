#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "argument_parser.sh";

./install_resource_headers.sh "$@";

if [ "$SYSTEM" = "win" ]
then
	./build_mingw.sh "$@";
elif [ "$SYSTEM" = "lin" ]
then
	./build_musl.sh "$@";
fi

./build_llvm_runtime.sh "$@";

if [ "$SYSTEM" = "win" ] && [ "$ENABLE_WIN_THREADS" = "ON" ]
then
	./build_win_threads.sh "$@";
fi