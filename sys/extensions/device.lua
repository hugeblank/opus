_G.requireInjector()

local Peripheral = require('peripheral')

_G.device = Peripheral.getList()

-- register the main term in the devices list
_G.device.terminal = _G.term.current()
