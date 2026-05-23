#!/bin/bash
set -ue;

COMMON_OPTIONS=();
INIT_OPTIONS=();
LLVM_OPTIONS=();
MINGW_OPTIONS=();

for a in "$@"
do
case $a in
	-target=*)
		TARGET="-target=${a#*=}";
		COMMON_OPTIONS+=("$TARGET");
		;;
	-log=*)
		COMMON_OPTIONS+=("-log=${a#*=}");
		;;
		
	-llvm=*)
		INIT_OPTIONS+=("-llvm=${a#*=}");
		LLVM_OPTIONS+=("-llvm=${a#*=}");
		;;
	-mingw=*)
		INIT_OPTIONS+=("-mingw=${a#*=}");
		LLVM_OPTIONS+=("-mingw=${a#*=}");
		MINGW_OPTIONS+=("-mingw=${a#*=}");
		;;

	-build_type=*)
		LLVM_OPTIONS+=("-build_type=${a#*=}");
		;;
	-install_prefix=*)
		LLVM_OPTIONS+=("-install_prefix=${a#*=}");
		MINGW_OPTIONS+=("-install_prefix=${a#*=}");
		;;
	-architectures=*)
		LLVM_OPTIONS+=("-architectures=${a#*=}");
		;;
    -cores=*)
		LLVM_OPTIONS+=("-cores=${a#*=}");
		MINGW_OPTIONS+=("-cores=${a#*=}");
        ;;
    -include_docs)
		LLVM_OPTIONS+=("-include_docs");
        ;;
    *)
        echo "Unknown argument '$a'";
        exit 1;
        ;;
	esac
done

source "./def.sh";

./init_repositories.sh "${COMMON_OPTIONS[@]}" "${INIT_OPTIONS[@]}";

if [ -n "${INCLUDE_MINGW:-}" ]
then
	./build_mingw.sh "${COMMON_OPTIONS[@]}" "${MINGW_OPTIONS[@]}";
fi

./build_llvm.sh "${COMMON_OPTIONS[@]}" "${LLVM_OPTIONS[@]}";