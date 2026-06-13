#!/bin/bash
# shellcheck source=/dev/null
set -ue;

COMMON_OPTIONS=();
INIT_OPTIONS=();
LLVM_OPTIONS=();
MINGW_OPTIONS=();

for a in "$@"
do
case $a in
	-target=*)
		TARGET="${a#*=}";
        ;;
	esac
done

source "./def.sh";

./init_repositories.sh "$@";
./build_llvm.sh "$@";

if [ "$SYSTEM" = "win" ]
then
	./build_mingw.sh "$@";
fi
./build_llvm_runtime.sh "$@";