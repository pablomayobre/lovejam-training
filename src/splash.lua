local lovesplash = require "lib.splash"

local splash = {}

function splash:enter(_, next)
  self.changeto = next
end

function splash:load (gamestate)
  self.love = lovesplash.new()
  self.love.onDone = function ()
    gamestate.push(self.changeto)
  end
end

function splash:update(_, dt)
  self.love:update(dt)
end

function splash:draw()
  self.love:draw()
end

return splash
