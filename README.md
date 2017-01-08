## Basic requirements
[ubuntu kylin 14.04/16.04 lts](http://www.ubuntukylin.com/downloads/)

## Ubuntu setup
```
sudo apt-get install autoconf libreadline-dev git gitg
```

## Building from source
```
git clone https://github.com/charleeli/srpc.git
cd srpc
make
```

## Test
```
cd srpc
./build/bin/lua example/simple/server.lua
./build/bin/lua example/simple/client.lua
```
