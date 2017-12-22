FROM debian:stable

ARG MUSLCM=https://github.com/richfelker/musl-cross-make/archive/v0.9.7.tar.gz

RUN apt-get update && apt-get install -y \
        autoconf    \
        curl        \
        g++         \
        gcc         \
        libtool     \
        make        \
        patch       \
        pkg-config

WORKDIR /work

ADD config.mak musl-cross-make/
RUN curl -L $MUSLCM | tar xz -C musl-cross-make --strip-components=1

ENV TARGET=x86_64-linux-musl
RUN cd musl-cross-make && make && make install OUTPUT=/opt/xcc/$TARGET

ENV TARGET=aarch64-linux-musl
RUN cd musl-cross-make && make && make install OUTPUT=/opt/xcc/$TARGET

ENV TARGET=arm-linux-musleabi
RUN cd musl-cross-make && make && make install OUTPUT=/opt/xcc/$TARGET

# --------------------------------------------------------------------------

FROM debian:stable

RUN apt-get update && apt-get install -y \
        autoconf    \
        bison       \
        cmake       \
        curl        \
        flex        \
        libtool     \
        make        \
        patch       \
        pkg-config

WORKDIR /work

COPY --from=0 /opt/xcc /opt/xcc

CMD bash
