local gamestate = {}
local meta = {}

local NULL = function () end

function meta.__index (self, index)
  local raw = rawget(self, index)

  if not(raw == nil) then
    return raw
  elseif gamestate[index] then
    return function (...)
      return gamestate[index](self, ...)
    end
  elseif index == "draw" then
    return self.draw
  else
    local state = self.getState(self.current)

    if type(state) == "table" and type(state[index]) == "function" then
        return function (...)
          return state[index](state, self, ...)
        end
    else
      return NULL
    end
  end
end

--Initialize the gamestates
local new = function (tab)
  local stack = {}

  local self = {
    stack = stack,
    states = tab,

    --For hashing
    clearStack = false,
    popStack = false,

    next = false,
    args = false,
    current = false,
    previous = false,

    draw = false
  }

  self.draw = function (...)
    local last, a = self.getState(self.current)
    if last and type(last.draw) == "function" then
      a = {last.draw(last, self, ...)}
    end

    self.performChange()

    return unpack(a)
  end

  return setmetatable(self, meta)
end

--Register event handlers callbacks
local all_callbacks = { 'draw', 'errhand', 'update' }
for k in pairs(love.handlers) do
	all_callbacks[#all_callbacks+1] = k
end

gamestate.register = function (self, callbacks)
	local registry = {}
	callbacks = callbacks or all_callbacks
	for _, f in ipairs(callbacks) do
		registry[f] = love[f] or NULL
		love[f] = function(...)
			registry[f](...)
			return self[f](...)
		end
	end
end

gamestate.performChange = function (self)
  if self.next then
    self.leave()

    if self.clearStack then
      self.stack = {}
    elseif self.popStack then
      self.stack[#self.stack] = nil
      self.stack[#self.stack] = nil
    end
    self.stack[#self.stack + 1] = self.next
    self.current = self.next

    self.previous = self.stack[#self.stack - 1]

    self.enter(unpack(self.args))

    self.next, self.clearStack = false, false
  end
end

gamestate.firstState = function (self, state, ...)
  if #self.stack == 0 then
    self.stack[1] = state
    self.current = state

    self.enter(...)

    return true
  end

  return false
end

--Clear the stack and push (only use when strictly needed)
gamestate.setState = function (self, state, ...)
  if not self.firstState(state, ...) then
    local args = {...}
    if self.states[state] then
      self.next = state
      self.args = args
      self.clearStack = true
    end
  end
end

--Push to the stack
gamestate.push = function (self, state, ...)
  if not self.firstState(state, ...) then
    local args = {...}
    if self.states[state] then
      self.next = state
      self.args = args
    end
  end
end

--Pop from the stack
gamestate.pop = function (self, ...)
  local args = {...}
  local state = self.stack[#self.stack - 1]

  if state and self.states[state] then
    self.next = state
    self.args = args
    self.popStack = true
  end
end

--The top of the stack
gamestate.getState = function (self, state)
  return self.states[state]
end

--Call a function in all states
gamestate.call = function (self, func, ...)
  for _, state in pairs(self.states) do
    if type(state[func]) == "function" then
      state[func](state, self, ...)
    end
  end
end

return new
