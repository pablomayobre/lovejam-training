local States = {}

local stack
local screens

local next
local args
local should_clear
local should_pop

-- Private Function
-- Close and remove all screens from the stack.
local function clear()
  for i = 1, #stack do
    stack[i]:close()
    stack[i] = nil
  end
end

local NULL = function () end

local validScreen = function (screen)
  if not screens[screen] then
    local str = "{"
    for i, _ in pairs(screens) do
      str = str .. i .. ', '
    end
    str = str:sub(1, -3) .. "}"
    error('"' .. tostring(screen) .. '" is not a valid screen. You will have to add a new one to your screen list or use one of the existing screens: ' .. str, 3)
  end
end

-- Public Functions

--If there was a change of screen, change it immediatly
function States.performChange ()
  if should_pop then
    -- Close the currently active screen.
    local tmp = States.peek()

    -- Remove the now inactive screen from the stack.
    stack[#stack] = nil

    -- Close the previous screen.
    tmp:close()

    -- Activate next screen on the stack.
    States.peek():setActive(true)

    should_pop = false
  elseif next then
    if should_clear then
      clear()
    end

    if States.peek() then
      States.peek():setActive(false)
    end

    -- Push the new screen onto the stack.
    stack[#stack + 1] = screens[next].new()

    -- Create the new screen and initialise it.
    stack[#stack]:init(unpack(args))

    should_clear, next, args = false, nil, nil
  end
end

-- Initialise the States.
-- Sets up the States and pushes the first screen.
function States.init (nscreens, screen, ...)
  stack = {}
  screens = nscreens
  States.push(screen, ...)
  States.performChange()
end

-- Switches to a screen.
-- Removes all screens from the stack, creates a new screen and switches to it.
-- Use this if you don't want to stack onto other screens.
function States.switch (screen, ...)
  validScreen(screen)
  next = screen
  args = {...}
  should_clear = true
  should_pop = false
end

-- Pushes a new screen to the stack.
-- Creates a new screen and pushes it on the screen stack,
-- where it will overlay the other screens below it.
-- Screens below the this new screen will be set inactive.

function States.push (screen, ...)
  validScreen(screen)
  next = screen
  args = {...}
  should_clear = false
  should_pop = false
end

-- Returns the screen on top of the screen stack without removing it.
function States.peek ()
  return stack[#stack]
end

-- Removes and returns the topmost screen of the stack.
function States.pop ()
  if #stack > 1 then
    should_pop = true
    should_clear = false
    next = nil
    args = nil
  else
    error("Can't close the last screen. Use switch() to clear the screen manager and add a new screen.")
  end
end

-- LOVE Callbacks

-- Reroutes the directorydropped callback to the currently active screen.
function States.directorydropped (path)
  States.peek():directorydropped(path)
end

-- Reroutes the draw callback to all screens on the stack.
-- Screens that are higher on the stack will overlay screens that are below them
function States.draw ()
  for i = 1, #stack do
    stack[i]:draw()
  end
  States.performChange()
end

-- Reroutes the filedropped callback to the currently active screen.
function States.filedropped (file)
  States.peek():filedropped(file)
end

-- Reroutes the focus callback to all screens on the stack.
function States.focus (focus)
  for i = 1, #stack do
    stack[i]:focus(focus)
  end
end

-- Reroutes the keypressed callback to the currently active screen.
function States.keypressed(key, scancode, isrepeat)
  States.peek():keypressed(key, scancode, isrepeat)
end

-- Reroutes the keyreleased callback to the currently active screen.
function States.keyreleased (key, scancode)
  States.peek():keyreleased(key, scancode)
end

-- Reroutes the lowmemory callback to the currently active screen.
function States.lowmemory ()
  States.peek():lowmemory()
end

-- Reroutes the mousefocus callback to the currently active screen.
function States.mousefocus (focus)
  States.peek():mousefocus(focus)
end

-- Reroutes the mousemoved callback to the currently active screen.
function States.mousemoved (x, y, dx, dy)
  States.peek():mousemoved(x, y, dx, dy)
end

-- Reroutes the mousepressed callback to the currently active screen.
function States.mousepressed (x, y, button, istouch)
  States.peek():mousepressed(x, y, button, istouch)
end

-- Reroutes the mousereleased callback to the currently active screen.
function States.mousereleased (x, y, button, istouch)
  States.peek():mousereleased(x, y, button, istouch)
end

-- Reroutes the quit callback to the currently active screen.
function States.quit ()
  States.peek():quit()
end

-- Reroutes the resize callback to all screens on the stack.
function States.resize (w, h)
  for i = 1, #stack do
    stack[i]:resize(w, h)
  end
end

-- Reroutes the textedited callback to the currently active screen.
function States.textedited (text, start, length)
  States.peek():textedited(text, start, length)
end

-- Reroutes the textinput callback to the currently active screen.
function States.textinput (input)
  States.peek():textinput(input)
end

-- Reroutes the threaderror callback to all screens.
function States.threaderror (thread, errorstr)
  for i = 1, #stack do
    stack[i]:threaderror(thread, errorstr)
  end
end

-- Reroutes the touchmoved callback to the currently active screen.
function States.touchmoved (id, x, y, dx, dy, pressure)
  States.peek():touchmoved(id, x, y, dx, dy, pressure)
end

-- Reroutes the touchpressed callback to the currently active screen.
function States.touchpressed (id, x, y, dx, dy, pressure)
  States.peek():touchpressed(id, x, y, dx, dy, pressure)
end

-- Reroutes the touchreleased callback to the currently active screen.
function States.touchreleased (id, x, y, dx, dy, pressure)
  States.peek():touchreleased(id, x, y, dx, dy, pressure)
end

-- Reroutes the update callback to all screens.
function States.update (dt)
  for i = 1, #stack do
    stack[i]:update(dt)
  end
end

-- Reroutes the visible callback to all screens.
function States.visible (visible)
  for i = 1, #stack do
    stack[i]:visible(visible)
  end
end

-- Reroutes the wheelmoved callback to the currently active screen.
function States.wheelmoved (x, y)
  States.peek():wheelmoved(x, y)
end

-- Reroutes the gamepadaxis callback to the currently active screen.
function States.gamepadaxis (joystick, axis, value)
  States.peek():gamepadaxis(joystick, axis, value)
end

-- Reroutes the gamepadpressed callback to the currently active screen.
function States.gamepadpressed(joystick, button)
  States.peek():gamepadpressed(joystick, button)
end

-- Reroutes the gamepadreleased callback to the currently active screen.
function States.gamepadreleased (joystick, button)
  States.peek():gamepadreleased(joystick, button)
end

-- Reroutes the joystickadded callback to the currently active screen.
function States.joystickadded (joystick)
  States.peek():joystickadded(joystick)
end

-- Reroutes the joystickhat callback to the currently active screen.
function States.joystickhat (joystick, hat, direction)
  States.peek():joystickhat(joystick, hat, direction)
end

-- Reroutes the joystickpressed callback to the currently active screen.
function States.joystickpressed (joystick, button)
  States.peek():joystickpressed(joystick, button)
end

-- Reroutes the joystickreleased callback to the currently active screen.
function States.joystickreleased (joystick, button)
  States.peek():joystickreleased(joystick, button)
end

-- Reroutes the joystickremoved callback to the currently active screen.
function States.joystickremoved (joystick)
  States.peek():joystickremoved(joystick)
end

--Register event handlers callbacks
local all_callbacks = { 'draw', 'update' }
for k in pairs(love.handlers) do
	all_callbacks[#all_callbacks+1] = k
end

function States.registerCallbacks (callbacks)
  local registry = {}
  callbacks = callbacks or all_callbacks
  for _, f in ipairs(callbacks) do
    registry[f] = love[f] or NULL
    love[f] = function(...)
      registry[f](...)
      return States[f](...)
    end
  end
end

function States.all (func, ...)
  for i = 1, #stack do
    local state = stack[i]
    if type(state[func]) == "function" then
      state[func](state, ...)
    end
  end
end

function States.first (func, ...)
  local first = States.peek()
  if type(first) == "table" and type(first[func]) == "function" then
    first[func](first, ...)
  end
end

return States
