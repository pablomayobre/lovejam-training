local Base = {};

local NULL = function () end

function Base.new()
    local self = {
      -- Callbacks stubs

      init = NULL,
      close = NULL,

      update = NULL,
      draw = NULL,

      keypressed = NULL,
      keyreleased = NULL,
      textinput = NULL,
      textedited = NULL,

      directorydropped = NULL,
      filedropped = NULL,

      visible = NULL,
      focus = NULL,
      mousefocus = NULL,
      resize = NULL,


      mousepressed = NULL,
      mousereleased = NULL,
      mousemoved = NULL,
      wheelmoved = NULL,

      touchpressed = NULL,
      touchreleased = NULL,
      touchmoved = NULL,

      threaderror = NULL,
      lowmemory = NULL,
      quit = NULL,

      gamepadaxis = NULL,
      gamepadpressed = NULL,
      gamepadreleased = NULL,

      joystickadded = NULL,
      joystickaxis = NULL,
      joystickhat = NULL,
      joystickpressed = NULL,
      joystickreleased = NULL,
      joystickremoved = NULL,
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
