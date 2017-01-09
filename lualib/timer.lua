local levent = require "levent.levent"
local ltimer = require 'ltimer'
local timer = {id = 0, max_id = 4294967295, pool = {}, running = false }

local id = 0

local function expire()
    ltimer.expire(function(id)
        local info = timer.pool[id]
        if info then
            if info.once then
                info.func()
                timer.pool[id] = nil
            else
                ltimer.add(id, info.elapse)
                info.func()
            end
        end
    end)
end

local function cancel(id)
    if timer.pool[id] then
        timer.pool[id] = nil
        ltimer.delete(id)
    end
end

local function cancelall()
    timer.pool = {}
    timer.running = false
    ltimer.deleteall()
end

local function timeout(elapse_, func_, once_)
    if timer.id == timer.max_id then
        id = 1
    else
        id = timer.id + 1
    end
    while timer.pool[id] do
        id = id + 1
        if id == timer.id then
            error("timer id is used up")
        end
    end

    if not timer.running then
        timer.running = true
        levent.spawn(function ()
            while timer.running do
                expire()
            end
        end)
    end

    timer.id = id
    timer.pool[id] = {elapse = elapse_, func = func_, once = once_}
    ltimer.add(id, elapse_)
    return id
end

function timer.setInterval(func, millisec)
    return timeout(millisec * 1000, func, false)
end

function timer.clearInterval(id_of_setInterval)
    return cancel(id_of_setInterval)
end

function timer.setTimeout(func, millisec)
    return timeout(millisec * 1000, func, true)
end

function timer.clearTimeout(id_of_setTimeout)
    return cancel(id_of_setTimeout)
end

function timer.stop()
    return cancelall()
end

ltimer.init()

return timer
