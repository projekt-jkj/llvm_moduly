# shellcheck shell=bash
# shellcheck disable=SC2034

LLVM_CLANG=(
	clang
	clang-scan-deps
	lld

	llvm-ar
	llvm-cov
	llvm-cxxfilt
	llvm-dlltool
	llvm-dwp
	llvm-lib
	llvm-mca
	llvm-ml
	llvm-nm
	llvm-objcopy
	llvm-objdump
	llvm-pdbutil
	llvm-profdata
	llvm-profgen
	llvm-ranlib
	llvm-rc
	llvm-readobj
	llvm-size
	llvm-strings
	llvm-strip
	llvm-symbolizer

	bash-autocomplete
	clang-resource-headers
);
CLANG_TOOLS=(
	clangd
	clang-format
	clang-tidy
);
LLDB=(
	lldb
);