#!/bin/bash

set -ue;
shopt -s extglob;

INSTALLATION_PATH="${1-$(pwd)/install}";
WHERE="${2-$(pwd)/dist}";
TAG="${3-}";

pack_and_install()
{
	if [ ! -d "$1" ]
	then
		return;
	fi

	cd "$1";

	target="${1##+(?).}";
	target="${target%%/+(?)}";
	
	tar_name="${WHERE}/$2_${target}.tar.xz";

	tar --xz -cf "$tar_name" -- *;
	echo "$tar_name created";

	if [ -n "$TAG" ]
	then
		gh release upload "$TAG" "$tar_name";
		echo "$tar_name uploaded to $TAG";
	fi

	cd - &>/dev/null;
}

mkdir -p "$WHERE";

for package in "${INSTALLATION_PATH}"/tools.*/* "${INSTALLATION_PATH}"/libraries.*/*
do
	name=${package##+(?)/};
	pack_and_install "$package" "$name";
done

for package in "${INSTALLATION_PATH}"/runtime.*
do
	pack_and_install "$package" "runtime";
done