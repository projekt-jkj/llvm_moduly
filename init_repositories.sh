#!/bin/bash
set -ue;

for a in "$@"
do
case $a in
	-target=*)
		TARGET="-target=${a#*=}";
		;;
	-log=*)
		LOG_FILE="${a#*=}";
		;;

	-llvm=*)
		LLVM_TAG="${a#*=}";
		;;
	-mingw=*)
		MINGW_TAG="${a#*=}";
		;;
	*)
		echo "Unknown argument '$a'";
		exit 1;
		;;
esac
done

source ./def.sh;

clone()
{
	log_begin "Cloning $2";
	if [ ! -d "$3" ]
	then
		git clone --depth 1 -q -b "$1" "$2" "$3" >>"$LOG_FILE";
	fi
	log_ok "Cloning $2";
}

clone "$LLVM_TAG" "https://github.com/llvm/llvm-project.git" "$LLVM_SOURCE";

if [ -v MINGW_TAG ]
then
	clone "$MINGW_TAG" "https://github.com/mingw-w64/mingw-w64.git" "$MINGW_SOURCE";
fi