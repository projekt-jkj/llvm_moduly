#!/bin/bash
set -ue;

INIT_OPTIONS=();
LLVM_OPTIONS=();

for a in "$@"
do
case $a in
	-llvm=*)
		INIT_OPTIONS+=("-llvm=${a#*=}");
		LLVM_OPTIONS+=("-llvm=${a#*=}");
		;;
	-mingw)
		INIT_OPTIONS+=("-mingw");
		;;
	-mingw=*)
		INIT_OPTIONS+=("-mingw=${a#*=}");
		;;

	-build_type=*)
		LLVM_OPTIONS+=("-build_type=${a#*=}");
		;;
	-architectures=*)
		LLVM_OPTIONS+=("-architectures=${a#*=}");
		;;
	-install_folder=*)
		LLVM_OPTIONS+=("-install_folder=${a#*=}");
		;;
	esac
done

./init_repositories.sh "${INIT_OPTIONS[@]}";
./build_llvm.sh "${LLVM_OPTIONS[@]}";