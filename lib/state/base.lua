local Base = {};

local function null () end

function Base.new()
  local self = {
  -- Callbacks stubs
    init = null,
    close = null,

    update = null,
    draw = null,

    keypressed = null,
    keyreleased = null,
    textinput = null,
    textedited = null,

    directorydropped = null,
    filedropped = null,

    visible = null,
    focus = null,
    mousefocus = null,
    resize = null,


    mousepressed = null,
    mousereleased = null,
    mousemoved = null,
    wheelmoved = null,

    touchpressed = null,
    touchreleased = null,
    touchmoved = null,

    threaderror = null,
    lowmemory = null,
    quit = null,

    gamepadaxis = null,
    gamepadpressed = null,
    gamepadreleased = null,

    joystickadded = null,
    joystickaxis = null,
    joystickhat = null,
    joystickpressed = null,
    joystickreleased = null,
    joystickremoved = null,
  };

  local active = true

  -- Public Methods
  function self.isActive ()
    return active
  end

  function self.setActive (dactiv)
    active = dactiv
  end

  return self
end

return Base
