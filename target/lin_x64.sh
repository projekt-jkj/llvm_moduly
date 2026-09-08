#!/bin/bash

COMMAND="${1:-./build_all.sh}";
shift;

"${COMMAND}" \
	-architectures=X86 \
	-target=lin_x64 \
	-toolset=clang_gcc \
	-clang_tools \
	-lldb \
	"$@";