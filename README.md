# llvm_moduly

llvm_moduly is a modular distribution of LLVM designed to provide consistent behavior across all supported platforms. It relies exclusively on LLVM’s own tools and runtimes, avoiding system‑specific differences and ensuring a predictable, uniform toolchain regardless of the host environment.

The project aims to offer a simple way to build and use LLVM without relying on external libraries or fragmented implementations. The build system automatically collects and propagates license information, reducing the burden on users and keeping the packaging process clean even when individual components use different licensing models.

For more information, please refer to:
- info.cs.txt (Czech version)
- info.en.txt (English version)

## notice

info.sh provides a quick sanity check for the C/C++ toolchain.
It is a temporary development script intended for local testing and is not configurable for custom installation prefixes.
Users building with a different layout or install path may need to adjust or replace it.