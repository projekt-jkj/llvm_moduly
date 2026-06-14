# shellcheck shell=bash
# shellcheck disable=SC2034

join()
{
	local IFS=";";
	echo "$*";
}
reset_dir()
{
	rm -rf "$1";
	mkdir -p "$1";
}

# -------------------
#    ninja helpers
# -------------------

build()
{
	ninja "$1-distribution"  "-j$CORES" >>"$LOG_FILE";
}
install()
{
	reset_dir "$INSTALL_BASE/tmp";
	ninja "install-$1-distribution-stripped"  "-j$CORES" >>"$LOG_FILE";
	mkdir -p "$INSTALL_BASE/$1";
	mv "$INSTALL_BASE"/tmp/* "$INSTALL_BASE/$1";
}

# ---------------------
#    logging helpers
# ---------------------

log_begin()
{
	echo "=== [$1] $(date '+%H:%M:%S') ===" | tee -a "$LOG_FILE";
}
log_ok()
{
	echo "=== [$1] OK ===" | tee -a "$LOG_FILE";
}