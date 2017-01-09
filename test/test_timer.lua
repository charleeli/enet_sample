package.cpath = package.cpath..";./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path = package.path..";./lualib/?.lua"..";./example/simple/?.lua"
                ..";./build/lualib/?.lua;./build/lualib/?.lua"

local levent = require "levent.levent"
local timer = require "timer"
local log = require "log"
log.init{log_basename = "test_timer",service_name = "test timer" }

local function main()
    log.info("main...")
	timer.setTimeout(function() print("setTimeout 2000 ms" ) end, 2000)
    timer.setInterval(function() print("setInterval 3000 ms" ) end, 3000)
end

levent.start(main)
log.exit()
