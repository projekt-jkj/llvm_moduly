#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "./argument_parser.sh";
source "./helpers.sh";

LLVM_SUBDIRECTORIES=(
	clang
	cmake
	compiler-rt
	libc
	libcxx
	libcxxabi
	libunwind
	lld
	llvm
	runtimes
	third-party
);
if [ "$BUILD_CLANG_TOOLS" = "ON" ]
then
	LLVM_SUBDIRECTORIES+=(clang-tools-extra);
fi
if [ "$BUILD_LLDB" = "ON" ]
then
	LLVM_SUBDIRECTORIES+=(lldb);
fi

clone()
{
	log_begin "Cloning $2";

	if [ ! -d "$3" ]
	then
		git clone --config core.autocrlf=false --config advice.detachedHead=false --depth 1 -q -b "$@" >>"$LOG_FILE";
	fi
	log_ok "Cloning $2";
}

clone "$LLVM_TAG" "https://github.com/llvm/llvm-project.git" "$LLVM_SOURCE" "--sparse";

cd "$LLVM_SOURCE";
git sparse-checkout add "${LLVM_SUBDIRECTORIES[@]}";
cd "-";

if [ -v MINGW_TAG ]
then
	clone "$MINGW_TAG" "https://github.com/mingw-w64/mingw-w64.git" "$MINGW_SOURCE";
fi
