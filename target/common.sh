# shellcheck shell=bash
# shellcheck disable=SC2034

if [ -x "$1" ] && [ -f "$1" ]
then
	COMMAND="$1";
	shift;
else
	COMMAND="./build_all.sh";
fi