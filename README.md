## Basic requirements
[ubuntu kylin 14.04/16.04 lts](http://www.ubuntukylin.com/downloads/)

[redis desktop manager](https://github.com/uglide/RedisDesktopManager/releases)

## Ubuntu setup
```
sudo apt-get install autoconf libtool libreadline-dev git gitg
```

## Building from source
```
git clone https://github.com/charleeli/quick-aux.git
cd quick-aux
make
```

## Test
```
cd quick-aux
./build/bin/lua example/complex/main.lua
./build/bin/lua example/complex/testclt_enet.lua

./build/bin/lua example/complex/testclt_tcp.lua
enter: send_private_chat {uuid=123,msg="hello"}
```
