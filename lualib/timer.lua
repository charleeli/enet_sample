local levent = require "levent.levent"
local class = require "levent.class"

local Timer = class("Timer")

function Timer:_init(check_interval)
    self.check_interval = check_interval or 1
    self.running = false
    self.timestamp = 0
    self.handle = 1
    self.to_deleted = {}
    self.pending = {}
    self.timers = {}
end

function Timer:add_timer(interval, func, immediate, times)
    assert(interval >= self.check_interval, interval)
    local handle = self.handle
    self.handle = handle + 1

    self.pending[handle] = {interval = interval, 
        func = func, 
        wakeup = immediate and 0 or interval,
        times = times or 0,
        timestamp = levent.now()
    }
    return handle
end

function Timer:remove_timer(handle)
    self.to_deleted[handle] = true
end

function Timer:update()
    for k,v in pairs(self.pending) do
        self.timers[k] = v
    end
    for k,_ in pairs(self.to_deleted) do
        self.timers[k] = nil
    end
    local second = levent.now()
    for k,v in pairs(self.timers) do
        local interval = second - v.timestamp
        if v.wakeup <= interval then
            v.wakeup = v.wakeup + v.interval
            local ok, err = pcall(v.func)
            if not ok then
                LOG_ERROR("time mgr update err<%s>", err)
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

function Timer:start()
    if self.running then
        return
    end
    self.running = true
    self.timestamp = levent.now()
    levent.spawn(function ()
        while self.running do
            self:update()
            levent.sleep(self.check_interval)
        end
    end)
    return
end

function Timer:stop()
    self.running = false
end

function Timer:set_interval(interval, func)
    self:start()
    return self:add_timer(interval, func)
end

function Timer:clear_interval(handle)
    self.to_deleted[handle] = true
end

local M = {}
M.Timer = Timer.new
return M
