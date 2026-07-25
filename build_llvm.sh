#!/bin/bash
# shellcheck source=/dev/null
set -ue;

source "./argument_parser.sh";
source "./helpers.sh";
source "./options/llvm.sh";

log_begin "LLVM";
mkcd "$LLVM_BUILD_DIR";

cmake -G Ninja \
	"${CMAKE_OPTIONS[@]}" \
	"${LLVM_OPTIONS[@]}" \
	"${CLANG_OPTIONS[@]}" \
	"${LLD_OPTIONS[@]}" \
    "${LLVM_SOURCE}/llvm" >>"$LOG_FILE";

log_ok "LLVM configure";

if [ "$BUILD_TYPE" = "llvm_test" ]
then
	build_all;
	log_ok "LLVM build";

	build check-all;
	log_ok "LLVM tests";

	exit 1;
fi

for dist in "${DISTRIBUTIONS[@]}"
do
	build_distribution "$dist";
	log_ok "LLVM build $dist";
done

if [ "$BUILD_TYPE" = "llvm_build" ]
then
	exit 1;
fi

for dist in "${DISTRIBUTIONS[@]}"
do
	install_distribution "$dist";
	mkdir -p "$INSTALL_TOOLS_BASE/$dist/licences";
	cp -T "${LLVM_SOURCE}/LICENSE.TXT" "$INSTALL_TOOLS_BASE/$dist/licences/llvm.txt";
done

rm -rf "$INSTALL_TMP_PATH";

log_ok "LLVM install";

if [ -v MSYS ]
then
	cd ../../..

	for dist in "${DISTRIBUTIONS[@]}"
	do
		./copy-msys-dependencies.sh "${INSTALL_TOOLS_BASE}/${dist}" "$MSYS" >>"$LOG_FILE";
	done

	log_ok "LLVM MSYS dependencies";
fi