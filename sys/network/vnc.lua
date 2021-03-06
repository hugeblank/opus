local Event  = require('event')
local Socket = require('socket')
local Util   = require('util')

local os       = _G.os
local terminal = _G.device.terminal

local function vncHost(socket)
	local methods = { 'blit', 'clear', 'clearLine', 'setCursorPos', 'write',
										'setTextColor', 'setTextColour', 'setBackgroundColor',
										'setBackgroundColour', 'scroll', 'setCursorBlink', }

	local oldTerm = Util.shallowCopy(terminal)

	for _,k in pairs(methods) do
		terminal[k] = function(...)
			if not socket.queue then
				socket.queue = { }
				Event.onTimeout(0, function()
					socket:write(socket.queue)
					socket.queue = nil
				end)
			end
			table.insert(socket.queue, {
				f = k,
				args = { ... },
			})
			oldTerm[k](...)
		end
	end

	while true do
		local data = socket:read()
		if not data then
			print('vnc: closing connection to ' .. socket.dhost)
			break
		end

		if data.type == 'shellRemote' then
			os.queueEvent(table.unpack(data.event))
		elseif data.type == 'termInfo' then
			terminal.getSize = function()
				return data.width, data.height
			end
			os.queueEvent('term_resize')
		end
	end

	for k,v in pairs(oldTerm) do
		terminal[k] = v
	end
	os.queueEvent('term_resize')
end

Event.addRoutine(function()

	print('vnc: listening on port 5900')

	while true do
		local socket = Socket.server(5900)

		print('vnc: connection from ' .. socket.dhost)

		-- no new process - only 1 connection allowed
		-- due to term size issues
		vncHost(socket)
		socket:close()
	end
end)
