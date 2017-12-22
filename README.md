# xcc - cross compiler collection

xcc is a collection of Docker images containing cross compilers capable
of building static binaries targeting Linux with musl libc on a variety
of CPU architectures.

## xcc:base

GCC and G++ cross compilers are installed in /opt/xcc/

    docker build -f Dockerfile -t xcc:base .

The base image is available at docker.io as wglozer/xcc:base

## xcc:rust

rustup and rust toolchains are installed in /root/.cargo and a number
of C and C++ libraries are prebuilt with the x86_64 cross compiler and
installed in /opt/xcc/x86_64-linux-musl.

    docker build -f Dockerfile.rust -t xcc:rust .

Installed libraries:

 * zlib
 * openssl
 * libcurl
 * libpq
 * libpcap
 * libmysqlclient

The rust image is available at docker.io as wglozer/xcc:rust
