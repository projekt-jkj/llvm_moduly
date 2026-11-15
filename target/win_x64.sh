#!/bin/bash
# shellcheck source=/dev/null

COMMAND="${1:-./build_all.sh}";
shift;

"${COMMAND}" \
	-architectures=X86 \
	-target=win_x64 \
	-toolset=clang \
	-clang_tools \
	-lldb \
	-sanitizers \
	-clang_libraries \
	-llvm_libraries \
	"$@";