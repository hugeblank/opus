local Ansi   = require('ansi')
local Config = require('config')
local UI     = require('ui')

local colors = _G.colors

if _G.http.websocket then
  local config = Config.load('cloud')

  local tab = UI.Tab {
    tabTitle = 'Cloud',
    description = 'Cloud catcher options',
    key = UI.TextEntry {
      x = 3, ex = -3, y = 2,
      limit = 32,
      value = config.key,
      shadowText = 'Cloud key',
      accelerators = {
        enter = 'update_key',
      },
    },
    button = UI.Button {
      x = 3, y = 4,
      text = 'Update',
      event = 'update_key',
    },
    labelText = UI.TextArea {
      x = 2, ex = -2, y = 6,
      textColor = colors.yellow,
      marginRight = 0,
      value = string.format(
  [[Use a non-changing cloud key. Note that only a single computer can use this session at one time.
  To obtain a key, visit:
  %shttps://cloud-catcher.squiddev.cc%s then bookmark:
  %shttps://cloud-catcher.squiddev.cc/?id=%sKEY
    ]],
      Ansi.white, Ansi.reset, Ansi.white, Ansi.white),
    },
  }

  function tab:eventHandler(event)
    if event.type == 'update_key' then
      if #self.key.value > 0 then
        config.key = self.key.value
      else
        config.key = nil
      end
      Config.update('cloud', config)
      self:emit({ type = 'success_message', message = 'Updated' })
    end
  end

  return tab
end
