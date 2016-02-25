local logger = require "log.core"
logger.init(0,1024,5,"log","test")

local log = { service_name = "main" }

function log.init(conf)
	logger.init(conf.level or 0,conf.log_rollsize or 1024,conf.log_flushinterval or 5,
		conf.log_dirname or "log",conf.log_basename or "test")
	log.service_name = conf.service_name
end

function log.exit()
	logger.exit()
end

function log.debug(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end

	logger.debug(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), log.service_name, msg))
end

function log.info(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end

	logger.info(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), log.service_name, msg))
end

function log.warning(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end

	logger.warning(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), log.service_name, msg))
end

function log.error(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end

	logger.error(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), log.service_name, msg))
end

function log.fatal(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end

	logger.fatal(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), log.service_name, msg))
end

return log
