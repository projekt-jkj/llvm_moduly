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

CLONE_ARGS=(--config core.autocrlf=false --config advice.detachedHead=false --depth 1 -q)
clone()
{
	local tag="$1";
	local url="$2";
	local path="$3";

	if [ ! -d "$path" ]
	then
		log_begin "Cloning $url";
		git clone "${CLONE_ARGS[@]}" -b "$tag" "$url" "$path" >>"$LOG_FILE";
		log_end "Cloning $url";
	fi
}
clone_sparse()
{
	local tag="$1";
	local url="$2";
	local path="$3";

	shift 3;

	log_begin "Cloning $url";

	if [ ! -d "$path" ]
	then
		git clone "${CLONE_ARGS[@]}" --sparse -b "$tag" "$url" "$path" >>"$LOG_FILE";
	fi

	cd "$path";
	git sparse-checkout add "$@";
	cd "-" >/dev/null;
	
	log_end "Cloning $url";
}

log_header "Initialize repositories"

clone_sparse "$LLVM_TAG" "https://github.com/llvm/llvm-project.git" "$LLVM_SOURCE" "${LLVM_SUBDIRECTORIES[@]}";

if [ "$SYSTEM" = "win" ]
then
	clone "$MINGW_TAG" "https://github.com/mingw-w64/mingw-w64.git" "$MINGW_SOURCE";
elif [ "$SYSTEM" = "lin" ]
then
	clone_sparse "$LINUX_TAG" "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git" "$LINUX_SOURCE" "include/uapi";
	clone "$MUSL_TAG" "https://git.musl-libc.org/git/musl" "$MUSL_SOURCE";
fi