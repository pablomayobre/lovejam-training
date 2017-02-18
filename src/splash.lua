local splashes = require "lib.splash"
local States   = require "lib.state"
local Base     = require "lib.state.base"

local Splash = {}

function Splash.new ()
  local self = Base.new()

  local splash = splashes.new()

  function self:init(next)
    splash.onDone = function ()
      States.switch(next)
    end
  end

  function self:update (dt)
    splash:update(dt)
  end

  function self:draw ()
    splash:draw()
  end

  return self
end

return Splash
