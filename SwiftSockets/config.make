# GNUmakefile

UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
  SWIFT_SNAPSHOT=swift-2.2-SNAPSHOT-2015-12-10-a
  SWIFT_TOOLCHAIN_BASEDIR=/Library/Developer/Toolchains
  SWIFT_TOOLCHAIN=$(SWIFT_TOOLCHAIN_BASEDIR)/$(SWIFT_SNAPSHOT).xctoolchain/usr/bin
else
  OS=$(shell lsb_release -si | tr A-Z a-z)
  VER=$(shell lsb_release -sr)
  SWIFT_SNAPSHOT=swift-2.2-SNAPSHOT-2015-12-10-a-$(OS)$(VER)
  SWIFT_TOOLCHAIN_BASEDIR=$(HOME)/swift-not-so-much
  SWIFT_TOOLCHAIN=$(SWIFT_TOOLCHAIN_BASEDIR)/$(SWIFT_SNAPSHOT)/usr/bin
endif

ifeq ($(debug),on)
SWIFT_INTERNAL_BUILD_FLAGS = -c debug
else
SWIFT_INTERNAL_BUILD_FLAGS = -c release
endif

SWIFT_BUILD_TOOL=$(SWIFT_TOOLCHAIN)/swift build $(SWIFT_INTERNAL_BUILD_FLAGS)
SWIFT_CLEAN_TOOL=$(SWIFT_TOOLCHAIN)/swift build --clean
SWIFT_BUILD_DIR=$(PACKAGE_DIR)/.build/debug
