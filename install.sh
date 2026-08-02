#!/bin/bash

FROM="$1";
TO="$2";
TARGET="$3";

shift 3;
components=("$@");

mkdir -p "$TO";
for c in "${components[@]}"
do
	cp -r "-t$TO" "${FROM}/tools.${TARGET}/${c}"/* ; 
done
cp -r "-t$TO" "${FROM}/runtime.${TARGET}"/* ;