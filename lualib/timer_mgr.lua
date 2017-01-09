local levent = require "levent.levent"
local class = require 'pl.class'
local ctime = require "ctime"

local TimerMgr = class()

function TimerMgr:_init(check_interval)
    self.check_interval = check_interval
    self.running = false
    self.timestamp = 0
    self.handle = 1
    self.to_deleted = {}
    self.pending = {}
    self.timers = {}
end

function TimerMgr:add_timer(interval, func, immediate, times)
    assert(interval >= self.check_interval, interval)
    local handle = self.handle
    self.handle = handle + 1

    self.pending[handle] = {interval = interval, 
        func = func, 
        wakeup = immediate and 0 or interval,
        times = times or 0,
        timestamp = ctime.timestamp(),
    }
    return handle
end

function TimerMgr:remove_timer(handle)
    self.to_deleted[handle] = true
end

function TimerMgr:update()
    for k,v in pairs(self.pending) do
        self.timers[k] = v
    end
    for k,_ in pairs(self.to_deleted) do
        self.timers[k] = nil
    end
    local second = ctime.timestamp()
    for k,v in pairs(self.timers) do
        local interval = second - v.timestamp
        if v.wakeup <= interval then
            v.wakeup = v.wakeup + v.interval
            local ok, err = pcall(v.func)
            if not ok then
                print("time mgr update err<%s>", err)
            end
            if v.times > 0 then
                if v.times == 1 then
                    self:remove_timer(k)
                else
                    v.times = v.times - 1
                end
            end
        end
    end
end

function TimerMgr:start()
    if self.running then
        return
    end
    self.running = true
    self.timestamp = ctime.timestamp()
    levent.spawn(function ()
        while self.running do
            self:update()
            levent.sleep(self.check_interval)
        end
    end)
    return
end

function TimerMgr:stop()
    self.running = false
end

return TimerMgr
