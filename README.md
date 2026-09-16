# llvm_moduly

llvm_moduly is a modular distribution of LLVM designed to provide consistent behavior across all supported platforms. It relies exclusively on LLVM’s own tools and runtimes, avoiding system‑specific differences and ensuring a predictable, uniform toolchain regardless of the host environment.

The project aims to offer a simple way to build and use LLVM without relying on external libraries or fragmented implementations. The build system automatically collects and propagates license information, reducing the burden on users and keeping the packaging process clean even when individual components use different licensing models.

For more information, please refer to:
- doc/info.cs.txt (Czech version)
- doc/info.en.txt (English version)
- doc/versions.txt

## distribution

I would like to distribute only self-hosted version of llvm_moduly.
This however brings some limitations such as impossibility to build lldb on Linux.
Due to this Linux distribution currently depends on system runtime (glibc, libsdtc++ etc.).
If you think you have any solution, let me know via issues.