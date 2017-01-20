package.cpath = package.cpath..";./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path = package.path..";./lualib/?.lua"..";./example/simple/?.lua"
                ..";./build/lualib/?.lua;./build/lualib/?.lua;./lualib/?.lua"

local uv = require('luv')

local timer_id = uv.new_thread(function()
    local uv = require('luv')

    local function set_interval(interval, callback)
        local timer = uv.new_timer()
        local function ontimeout()
            callback(timer)
        end
        uv.timer_start(timer, interval, interval, ontimeout)
        return timer
    end

    set_interval(3000, function()
        print("interval...")
    end)

    uv.run()
end)

local hare_id = uv.new_thread(function()
    local uv = require('luv')
    while true do
        uv.sleep(1000)
        print("Hare ran ++++++")
    end
end)

local tortoise_id = uv.new_thread(function()
    local uv = require('luv')
    while true do
        uv.sleep(2000)
        print("Tortoise ran ******")
    end
end)

uv.thread_join(timer_id)
uv.thread_join(hare_id)
uv.thread_join(tortoise_id)
