local States

love.load = function ()
  States = require "lib.state"

  local screens = {
    splash  = require "src.splash",
    --menu    = require "src.menu"
  }

  States.init(screens, "splash", "menu")

  --Register to all love events
  States.registerCallbacks()
end
