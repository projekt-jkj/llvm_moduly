#!/bin/bash

COMMAND="${1:-./build_all.sh}";

"${COMMAND}" \
	-architectures=X86 \
	-target=win_x64 \
	-clang_tools \
	-lldb