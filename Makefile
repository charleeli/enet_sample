.PHONY: all clean

TOP=$(PWD)
BUILD_DIR =             build
BUILD_BIN_DIR =         $(BUILD_DIR)/bin
BUILD_INCLUDE_DIR =     $(BUILD_DIR)/include
BUILD_LUALIB_DIR =      $(BUILD_DIR)/lualib
BUILD_LUACLIB_DIR =     $(BUILD_DIR)/luaclib
BUILD_CLIB_DIR =        $(BUILD_DIR)/clib
BUILD_STATIC_LIB_DIR =  $(BUILD_DIR)/staticlib
BUILD_SPROTO_DIR =      $(BUILD_DIR)/sproto

PLAT ?= linux
SHARED := -fPIC --shared
CFLAGS = -g -O2 -Wall -I$(BUILD_INCLUDE_DIR) 
LDFLAGS= -L$(BUILD_CLIB_DIR) -Wl,-rpath $(BUILD_CLIB_DIR) -lpthread -lm -ldl -lrt
DEFS = -DHAS_SOCKLEN_T=1 -DLUA_COMPAT_APIINTCASTS=1 

all : submodule build lua53 json spb libenet.so

build:
	-mkdir $(BUILD_DIR)
	-mkdir $(BUILD_BIN_DIR)
	-mkdir $(BUILD_INCLUDE_DIR)
	-mkdir $(BUILD_LUALIB_DIR)
	-mkdir $(BUILD_LUACLIB_DIR)
	-mkdir $(BUILD_CLIB_DIR)
	-mkdir $(BUILD_STATIC_LIB_DIR)
	-mkdir $(BUILD_SPROTO_DIR)

lua53:
	cd 3rd/lua/ && $(MAKE) MYCFLAGS="-O2 -fPIC -g" linux
	install -p -m 0755 3rd/lua/lua $(BUILD_BIN_DIR)/lua
	install -p -m 0755 3rd/lua/luac $(BUILD_BIN_DIR)/luac
	install -p -m 0644 3rd/lua/liblua.a $(BUILD_STATIC_LIB_DIR)
	install -p -m 0644 3rd/lua/lua.h $(BUILD_INCLUDE_DIR)
	install -p -m 0644 3rd/lua/lauxlib.h $(BUILD_INCLUDE_DIR)
	install -p -m 0644 3rd/lua/lualib.h $(BUILD_INCLUDE_DIR)
	install -p -m 0644 3rd/lua/luaconf.h $(BUILD_INCLUDE_DIR)

json:
	cp 3rd/json-lua/JSON.lua $(TOP)/$(BUILD_LUALIB_DIR)/

spb:
	cp 3rd/sproto/sproto.lua 3rd/sproto/sprotoparser.lua $(BUILD_LUALIB_DIR)/
	
libenet.so:3rd/enet/callbacks.c 3rd/enet/compress.c 3rd/enet/host.c \
           3rd/enet/list.c 3rd/enet/packet.c 3rd/enet/peer.c \
           3rd/enet/protocol.c 3rd/enet/unix.c
	cp -r 3rd/enet/include/enet/ $(BUILD_INCLUDE_DIR)/
	$(CC) $(DEFS) $(CFLAGS) $(SHARED) $^ -o $(BUILD_CLIB_DIR)/libenet.so 

submodule :
	git submodule update --init
	
LUACLIB = sproto lpeg log enet lfs

all : \
  $(foreach v, $(LUACLIB), $(BUILD_LUACLIB_DIR)/$(v).so)

$(BUILD_CLIB_DIR) :
	mkdir $(BUILD_CLIB_DIR)

$(BUILD_LUALIB_DIR) :
	mkdir $(BUILD_LUALIB_DIR)

$(BUILD_LUACLIB_DIR) :
	mkdir $(BUILD_LUACLIB_DIR)

$(BUILD_LUACLIB_DIR)/sproto.so : 3rd/sproto/sproto.c 3rd/sproto/lsproto.c | $(BUILD_LUACLIB_DIR)
	$(CC) $(CFLAGS) $(SHARED) -I3rd/sproto $^ -o $@ 

$(BUILD_LUACLIB_DIR)/lpeg.so : 3rd/lpeg/lpcap.c 3rd/lpeg/lpcode.c \
    3rd/lpeg/lpprint.c 3rd/lpeg/lptree.c 3rd/lpeg/lpvm.c \
    | $(BUILD_LUACLIB_DIR)
	$(CC) $(CFLAGS) $(SHARED) -I3rd/lpeg $^ -o $@

$(BUILD_LUACLIB_DIR)/log.so : lualib-src/lua-log.c | $(BUILD_LUACLIB_DIR)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ $(LDFLAGS)

$(BUILD_LUACLIB_DIR)/enet.so : lualib-src/lua-enet.c | $(BUILD_LUACLIB_DIR)
	$(CC) $(DEFS) $(CFLAGS) $(SHARED) $^ -o $@ $(LDFLAGS) -lenet

$(BUILD_LUACLIB_DIR)/lfs.so: 3rd/luafilesystem/src/lfs.c | $(BUILD_LUACLIB_DIR)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

all : schema

schema:
	cd $(TOP) && cp $(TOP)/$(BUILD_LUACLIB_DIR)/lpeg.so $(TOP)/3rd/sprotodump/

	cd $(TOP)/3rd/sprotodump/ && $(TOP)/$(BUILD_BIN_DIR)/lua sprotodump.lua \
	-spb `find -L $(TOP)/sproto/client  -name "*.sproto"`   \
	`find -L $(TOP)/sproto/common  -name "*.sproto"`    \
	-o $(TOP)/$(BUILD_SPROTO_DIR)/c2s.spb

	cd $(TOP)/3rd/sprotodump/ && $(TOP)/$(BUILD_BIN_DIR)/lua sprotodump.lua \
	-spb `find -L $(TOP)/sproto/server  -name "*.sproto"`   \
	`find -L $(TOP)/sproto/common  -name "*.sproto"`    \
	-o $(TOP)/$(BUILD_SPROTO_DIR)/s2c.spb

clean :
	-rm -rf build
