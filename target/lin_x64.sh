#!/bin/bash
# shellcheck source=/dev/null

source "target/common.sh";

"${COMMAND}" \
	-architectures=X86 \
	-target=lin_x64 \
	-toolset=clang_gcc \
	-clang_tools \
	-lldb \
	-sanitizers \
	-clang_libraries \
	-llvm_libraries \
	"$@";