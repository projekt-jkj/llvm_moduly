#!/bin/bash

# This skript provides a quick sanity check for the C/C++ toolchain.
# It is a temporary development script intended for local testing and is not configurable for custom installation prefixes.
# Users building with a different layout or install path may need to adjust or replace it.

set -ue

TEST_PATH="$(pwd)/tests";

C_EXE="$TEST_PATH/c.exe";
CPP_EXE="$TEST_PATH/cpp.exe";
FILESYSTEM_EXE="$TEST_PATH/filesystem.exe";
THREADS_EXE="$TEST_PATH/threads.exe";
EXCEPTIONS_EXE="$TEST_PATH/exceptions.exe";
STD_EXE="$TEST_PATH/std.exe";

ROOT="$1";
CLANG_PATH="$ROOT/bin";
STD_MODULE_PATH="$ROOT/sysroot/share/libc++/v1/std.cppm";

CFLAGS="$CFLAGS -static";
CXXFLAGS="$CXXFLAGS -static -std=c++23";

echo ""
echo "==========================="
echo "       c compilation       "
echo "==========================="
echo ""

"$CLANG_PATH/clang" "$CFLAGS" -v "$TEST_PATH/main.c" -o "$C_EXE";

echo ""
echo "---------------------------"
echo "        run output         "
echo "---------------------------"
echo ""

"$C_EXE";

echo ""
echo "---------------------------"
echo "     dynamic libraries     "
echo "---------------------------"
echo ""

ldd "$C_EXE" || true;

echo ""
echo "==========================="
echo "      cpp compilation      "
echo "==========================="
echo ""

"$CLANG_PATH/clang++" "$CXXFLAGS" -v "$TEST_PATH/main.cpp" -o "$CPP_EXE";

echo ""
echo "---------------------------"
echo "        run output         "
echo "---------------------------"
echo ""

"$CPP_EXE";

echo ""
echo "---------------------------"
echo "     dynamic libraries     "
echo "---------------------------"
echo ""

ldd "$CPP_EXE";

echo ""
echo "==========================="
echo "       thread check        "
echo "==========================="
echo ""

"$CLANG_PATH/clang++" "$CXXFLAGS" "$TEST_PATH/threads.cpp" -o "$THREADS_EXE";
"$THREADS_EXE";

echo ""
echo "==========================="
echo "     filesystem check      "
echo "==========================="
echo ""

"$CLANG_PATH/clang++" "$CXXFLAGS" "$TEST_PATH/filesystem.cpp" -o "$FILESYSTEM_EXE";
"$FILESYSTEM_EXE";

echo ""
echo "==========================="
echo "     exceptions check      "
echo "==========================="
echo ""

"$CLANG_PATH/clang++" "$CXXFLAGS" "$TEST_PATH/exceptions.cpp" -o "$EXCEPTIONS_EXE";
"$EXCEPTIONS_EXE";

echo ""
echo "==========================="
echo "     import std check      "
echo "==========================="
echo ""

"$CLANG_PATH/clang++" "$CXXFLAGS" -x c++-module "$STD_MODULE_PATH" --precompile -o "$TEST_PATH/std.pcm";
"$CLANG_PATH/clang++" "$CXXFLAGS" "$TEST_PATH/std.cpp" "-fprebuilt-module-path=$TEST_PATH" "$TEST_PATH/std.pcm" -o "$STD_EXE";
"$STD_EXE";

echo "";
echo "info.sh ended successfully"
echo "";