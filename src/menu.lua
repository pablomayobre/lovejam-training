local Base    = require "lib.state.base"

local Menu = {}

function Menu.new ()
  local self = Base.new()

  local levels = {
    1, 2, 3, 4, 5
  }

  local display = 2
  local area, square

  function self:init()
    local h = love.graphics.getHeight()

    area = h / display

    square = area - 60
  end

  function self:draw ()
      local row, col = 0, 0
      love.graphics.setColor(255, 255, 255)
      for _, _ in ipairs(levels) do
        local padding = (area - square) / 2
        local x, y = row * area + padding, col * area + padding

        love.graphics.rectangle("fill", x, y, square, square)

        col = col + 1
        if col == 2 then
          col, row = 0, row + 1
        end
      end
  end

  return self
end

return Menu
