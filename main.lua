local States

io.stdout:setvbuf "no"

--Debug
log = require "lib.log"

love.load = function ()
  States = require "lib.state"

  log.trace("love.load")

  local screens = {
    splash  = require "src.splash",
    menu    = require "src.menu"
  }

  States.init(screens, "splash", "menu")

  --Register to all love events
  States.registerCallbacks()
end
