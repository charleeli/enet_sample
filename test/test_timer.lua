package.cpath = package.cpath..";./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path  = package.path..";./lualib/?.lua"..";./example/simple/?.lua"
                ..";./build/lualib/?.lua;./build/lualib/?.lua;./test/?.lua"

local levent = require "levent.levent"
local timer = require 'timer'
local log = require "log"
log.init{log_basename = "test_timer",service_name = "test timer" }

local data = 'xxx'

local t = timer.Timer()

t:set_interval(2, function()
    print('set_interval 2',levent.now())
end)

function test_timer()
    local t1 = timer.Timer(1)

    t1:set_interval(1, function()
        print('set_interval 1',levent.now())
    end)
end

function read_data(sec)
    while true do
        levent.sleep(sec)
        print("read_data:", data)
    end
end

function write_data(sec)
    while true do
        levent.sleep(sec)
        data = data .. '+'
        print("write_data:", data)
    end
end

function main()
    levent.spawn(test_timer)
    levent.spawn(read_data, 2)
    levent.spawn(write_data, 3)

    while true do
        levent.sleep(1)
        print("main")
    end
end

levent.start(main)

log.exit()

