.PHONY: all clean

TOP=$(PWD)
BUILD_DIR =             build
BUILD_BIN_DIR =         $(BUILD_DIR)/bin
BUILD_INCLUDE_DIR =     $(BUILD_DIR)/include
BUILD_LUACLIB_DIR =     $(BUILD_DIR)/luaclib
BUILD_CLIB_DIR =        $(BUILD_DIR)/clib

PLAT ?= linux
SHARED := -fPIC --shared
CFLAGS = -g -O2 -Wall -I$(BUILD_INCLUDE_DIR) 
LDFLAGS= -L$(BUILD_CLIB_DIR) -Wl,-rpath $(BUILD_CLIB_DIR) -lpthread -lm -ldl -lrt
DEFS = -DHAS_SOCKLEN_T=1 -DLUA_COMPAT_APIINTCASTS=1 

all : submodule build sproto libenet.so

build:
	-mkdir $(BUILD_DIR)
	-mkdir $(BUILD_BIN_DIR)
	-mkdir $(BUILD_INCLUDE_DIR)
	-mkdir $(BUILD_LUACLIB_DIR)
	-mkdir $(BUILD_CLIB_DIR)

sproto:
	cd 3rd/sproto/ && $(MAKE)
	
libenet.so:3rd/enet/callbacks.c 3rd/enet/compress.c 3rd/enet/host.c \
           3rd/enet/list.c 3rd/enet/packet.c 3rd/enet/peer.c \
           3rd/enet/protocol.c 3rd/enet/unix.c
	cp -r 3rd/enet/include/enet/ $(BUILD_INCLUDE_DIR)/
	$(CC) $(DEFS) $(CFLAGS) $(SHARED) $^ -o $(BUILD_CLIB_DIR)/libenet.so 

submodule :
	git submodule update --init
	
LUACLIB = log enet lfs

all : \
  $(foreach v, $(LUACLIB), $(BUILD_LUACLIB_DIR)/$(v).so) 

$(BUILD_LUACLIB_DIR) :
	mkdir $(BUILD_LUACLIB_DIR)
	
$(BUILD_CLIB_DIR) :
	mkdir $(BUILD_CLIB_DIR)

$(BUILD_LUACLIB_DIR)/log.so : lualib-src/lua-log.c | $(BUILD_LUACLIB_DIR)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ $(LDFLAGS)

$(BUILD_LUACLIB_DIR)/enet.so : lualib-src/lua-enet.c | $(BUILD_LUACLIB_DIR)
	$(CC) $(DEFS) $(CFLAGS) $(SHARED) $^ -o $@ $(LDFLAGS) -lenet

$(BUILD_LUACLIB_DIR)/lfs.so: 3rd/luafilesystem/src/lfs.c | $(BUILD_LUACLIB_DIR)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

clean :
	-rm -rf build
	
