package.cpath = package.cpath..";./build/luaclib/?.so;./build/luaclib/levent/?.so"
package.path = package.path..";./lualib/?.lua"..";./example/simple/?.lua"
                ..";./build/lualib/?.lua;./build/lualib/?.lua"

local levent = require "levent.levent"
local log = require "log"
log.init{log_basename = "test_timer",service_name = "test timer" }

local TimerMgr = require 'timer_mgr'

local timer_mgr = TimerMgr(1)

local function main()
    log.info("main...")
	timer_mgr:add_timer(
        3.5,
        function()
			print("save db")
        end
    )

	timer_mgr:start()
end

levent.start(main)

log.exit()
