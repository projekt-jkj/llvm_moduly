#!/bin/bash
set -ue;

INIT_OPTIONS=();
LLVM_OPTIONS=();
COMMON_OPTIONS=();

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
	-install_prefix=*)
		LLVM_OPTIONS+=("-install_prefix=${a#*=}");
		;;
    -cores=*)
		LLVM_OPTIONS+=("-cores=${a#*=}");
        ;;
    -include_docs)
		LLVM_OPTIONS+=("-include_docs");
        ;;
	-build_only)
		LLVM_OPTIONS+=("-build_only");
        ;;

	-log=*)
		COMMON_OPTIONS+=("-log=${a#*=}");
		;;
	esac
done

./init_repositories.sh "${COMMON_OPTIONS[@]}" "${INIT_OPTIONS[@]}";
./build_llvm.sh        "${COMMON_OPTIONS[@]}" "${LLVM_OPTIONS[@]}";