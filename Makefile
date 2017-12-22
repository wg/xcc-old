TARGET  ?= x86_64-linux-musl
PREFIX  := /opt/xcc/${TARGET}

ZLIB    := 1.2.11
OPENSSL := 1.1.0g
CURL    := 7.57.0
PG      := 10.1
PCAP    := 1.8.1
MDBC    := 3.0.2

export CC              := $(TARGET)-cc
export CXX             := $(TARGET)-c++

export PATH            := $(PREFIX)/bin:$(PATH)
export PKG_CONFIG_PATH := $(PREFIX)/lib/pkgconfig

BUILD   := build/$(TARGET)
LIBS    :=                           \
	$(PREFIX)/lib/libz.a             \
	$(PREFIX)/lib/libcrypto.a        \
	$(PREFIX)/lib/libssl.a           \
	$(PREFIX)/lib/libcurl.a          \
	$(PREFIX)/lib/libpq.a            \
	$(PREFIX)/lib/libpcap.a          \
	$(PREFIX)/lib/libmysqlclient.a

all: $(BUILD) $(LIBS)

# -- zlib

$(PREFIX)/lib/libz.a: $(BUILD)/zlib-$(ZLIB)/Makefile
	$(MAKE) -C $(<D) install

$(BUILD)/zlib-$(ZLIB)/Makefile: | $(BUILD)/zlib-$(ZLIB)
	cd $(@D) && ./configure --prefix=$(PREFIX)

$(BUILD)/zlib-$(ZLIB): sources/zlib-$(ZLIB).tar.gz
	tar xzf $< -C $(@D)

sources/zlib-$(ZLIB).tar.gz: | sources $(BUILD)
	curl -L -o $@ http://zlib.net/$(@F)
	touch $@

# -- OpenSSL

$(PREFIX)/lib/libcrypto.a $(PREFIX)/lib/libssl.a: $(BUILD)/openssl-$(OPENSSL)/Makefile
	$(MAKE) -C $(<D) install_sw

$(BUILD)/openssl-$(OPENSSL)/Makefile: | $(BUILD)/openssl-$(OPENSSL)
	cd $(@D) && ./config --prefix=$(PREFIX) no-async no-dso no-shared

$(BUILD)/openssl-$(OPENSSL): sources/openssl-$(OPENSSL).tar.gz
	tar xzf $< -C $(@D)
	rm $@/Makefile

sources/openssl-$(OPENSSL).tar.gz: | sources $(BUILD)
	curl -L -o $@ https://www.openssl.org/source/$(@F)
	touch $@

# -- curl

$(PREFIX)/lib/libcurl.a: $(BUILD)/curl-$(CURL)/Makefile
	$(MAKE) -C $(<D) install

$(BUILD)/curl-$(CURL)/Makefile: $(PREFIX)/lib/libssl.a
$(BUILD)/curl-$(CURL)/Makefile: $(PREFIX)/lib/libz.a
$(BUILD)/curl-$(CURL)/Makefile: $(BUILD)/curl-$(CURL)/configure
	cd $(@D) && ./configure --prefix=$(PREFIX) --host=$(TARGET) --disable-shared

$(BUILD)/curl-$(CURL)/configure: | $(BUILD)/curl-$(CURL)

$(BUILD)/curl-$(CURL): sources/curl-$(CURL).tar.gz
	tar xzf $< -C $(@D)

sources/curl-$(CURL).tar.gz: | sources $(BUILD)
	curl -L -o $@ https://curl.haxx.se/download/$(@F)
	touch $@

# -- PostgreSQL

$(PREFIX)/lib/libpq.a: $(BUILD)/postgresql-$(PG)/GNUmakefile
	$(MAKE) -C $(<D)/src/interfaces/libpq
	$(MAKE) -C $(<D)/src/interfaces/libpq install

$(BUILD)/postgresql-$(PG)/GNUmakefile: CFGENV += CFLAGS=-I$(PREFIX)/include
$(BUILD)/postgresql-$(PG)/GNUmakefile: CFGENV += LDFLAGS=-L$(PREFIX)/lib
$(BUILD)/postgresql-$(PG)/GNUmakefile: CFGENV += USE_OPENSSL_RANDOM=1

$(BUILD)/postgresql-$(PG)/GNUmakefile: $(PREFIX)/lib/libssl.a
$(BUILD)/postgresql-$(PG)/GNUmakefile: $(PREFIX)/lib/libz.a
$(BUILD)/postgresql-$(PG)/GNUmakefile: | $(BUILD)/postgresql-$(PG)
	cd $(@D) && $(CFGENV) ./configure --prefix=$(PREFIX) --host=$(TARGET) --without-readline

$(BUILD)/postgresql-$(PG): sources/postgresql-$(PG).tar.gz
	tar xzf $< -C $(@D)
	rm $@/Makefile

sources/postgresql-$(PG).tar.gz: | sources $(BUILD)
	curl -L -o $@ https://ftp.postgresql.org/pub/source/v$(PG)/$(@F)
	touch $@

# -- libpcap

$(PREFIX)/lib/libpcap.a: $(BUILD)/libpcap-$(PCAP)/Makefile
	$(MAKE) -C $(<D) install

$(BUILD)/libpcap-$(PCAP)/Makefile: | $(BUILD)/libpcap-$(PCAP)
	cd $(@D) && ./configure --prefix=$(PREFIX) --host=$(TARGET) --with-pcap=linux

$(BUILD)/libpcap-$(PCAP): sources/libpcap-$(PCAP).tar.gz
	tar xzf $< -C $(@D)

sources/libpcap-$(PCAP).tar.gz: | sources $(BUILD)
	curl -L -o $@ http://www.tcpdump.org/release/$(@F)
	touch $@

# -- MariaDB client

$(PREFIX)/lib/libmysqlclient.a: $(BUILD)/mariadb-connector-c-$(MDBC)-src/Makefile
	$(MAKE) -C $(<D) install

$(BUILD)/mariadb-connector-c-$(MDBC)-src/Makefile: $(PREFIX)/lib/libssl.a
$(BUILD)/mariadb-connector-c-$(MDBC)-src/Makefile: $(PREFIX)/lib/libz.a
$(BUILD)/mariadb-connector-c-$(MDBC)-src/Makefile: | $(BUILD)/mariadb-connector-c-$(MDBC)-src
	cd $(@D) && cmake . -DCMAKE_INSTALL_PREFIX=$(PREFIX) -DWITH_MYSQLCOMPAT=ON

$(BUILD)/mariadb-connector-c-$(MDBC)-src: sources/mariadb-connector-c-$(MDBC)-src.tar.gz
	tar xzf $< -C $(@D)

sources/mariadb-connector-c-$(MDBC)-src.tar.gz: | sources $(BUILD)
	curl -L -o $@ https://downloads.mariadb.com/Connectors/c/connector-c-$(MDBC)/$(@F)
	touch $@

# -- misc

$(BUILD):
	mkdir -p $@

sources:
	mkdir -p $@

.SUFFIXES:
