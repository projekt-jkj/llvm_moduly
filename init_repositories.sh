#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "./argument_parser.sh";
source "./helpers.sh";

clone()
{
	log_begin "Cloning $2";
	if [ ! -d "$3" ]
	then
		git clone --config core.autocrlf=false --config advice.detachedHead=false --depth 1 -q -b "$1" "$2" "$3" >>"$LOG_FILE";
	fi
	log_ok "Cloning $2";
}

clone "$LLVM_TAG" "https://github.com/llvm/llvm-project.git" "$LLVM_SOURCE";

if [ -v MINGW_TAG ]
then
	clone "$MINGW_TAG" "https://github.com/mingw-w64/mingw-w64.git" "$MINGW_SOURCE";
fi