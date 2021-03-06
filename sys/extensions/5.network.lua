_G.requireInjector(_ENV)

local Config = require('config')

local device     = _G.device
local kernel     = _G.kernel
local os         = _G.os

_G.network = { }

local function startNetwork()
	kernel.run({
		title = 'Net daemon',
		path = 'sys/apps/netdaemon.lua',
		hidden = true,
	})
end

local function setModem(dev)
	if not device.wireless_modem and dev.isWireless() then
		local config = Config.load('os', { })
		if not config.wirelessModem or dev.name == config.wirelessModem then
			device.wireless_modem = dev
			os.queueEvent('device_attach', 'wireless_modem')
			return dev
		end
	end
end

-- create a psuedo-device named 'wireleess_modem'
kernel.hook('device_attach', function(_, eventData)
	local dev = device[eventData[1]]
	if dev and dev.type == 'modem' then
		if setModem(dev) then
			startNetwork()
		end
	end
end)

kernel.hook('device_detach', function(_, eventData)
	if device.wireless_modem and eventData[1] == device.wireless_modem.name then
		device['wireless_modem'] = nil
		os.queueEvent('device_detach', 'wireless_modem')
	end
end)

for _,dev in pairs(device) do
	if dev.type == 'modem' then
		if setModem(dev) then
			break
		end
	end
end

if device.wireless_modem then
	print('waiting for network...')
	startNetwork()
	os.pullEvent('network_up')
end
