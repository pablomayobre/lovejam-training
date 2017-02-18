local State = {};

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local screens;
local stack = {};

local changes = {};
local height = 0;

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Close and remove all screens from the stack.
--
local function clear()
    for i = #stack, 1, -1 do
        stack[i]:close();
        stack[i] = nil;
    end
end

---
-- Close and pop the current active state and activate the one beneath it
--
local function pop()
    -- Close the currently active screen.
    local tmp = State.peek();

    -- Remove the now inactive screen from the stack.
    stack[#stack] = nil;

    -- Close the previous screen.
    tmp:close();

    -- Activate next screen on the stack.
    State.peek():setActive( true );
end

---
-- Deactivate the current state, push a new state and initialize it
--
local function push( screen, args )
  if State.peek() then
      State.peek():setActive( false );
  end

  -- Push the new screen onto the stack.
  stack[#stack + 1] = screens[screen].new();

  -- Create the new screen and initialise it.
  stack[#stack]:init( unpack( args ) );
end

---
-- Check if the screen is valid or error if not
--
local function validateScreen( func, arg, screen )
    if not screens[screen] then
        error('bad argument #' .. arg .. ' to ' ..  func .. ', ("' .. tostring( screen ) .. '" is not a valid screen)');
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- If there was a change of screen, change it immediatly
--
function State.performChanges()
    if #changes == 0 then
        return
    end

    for _, change in ipairs( changes ) do
        if change.action == 'pop' then
            pop();
        elseif change.action == 'switch' then
            clear();
            push( change.screen, change.args );
        elseif change.action == 'push' then
            push( change.screen, change.args );
        end
    end

    changes = {};
end

---
-- Initialise the State.
-- Sets up the State and pushes the first screen.
-- @param nscreens (table)  A table containing pointers to the different screen
--                           classes. The keys will are used to call a specific
--                           screen.
-- @param screen   (string) The key of the first screen to push to the stack.
--                           Use the key under which the screen in question is
--                           stored in the nscreens table.
-- @param ...      (vararg) One or multiple arguments passed to the new screen.
--
function State.init( nscreens, screen, ... )
    screens = nscreens;

    validateScreen( 'init', 2, screen );

    State.switch( screen, ... );
    State.performChanges();
end

---
-- Switches to a screen.
-- Removes all screens from the stack, creates a new screen and switches to it.
-- Use this if you don't want to stack onto other screens.
-- @param screen (string) The key of the screen to switch to.
-- @param ...    (vararg) One or multiple arguments passed to the new screen.
--
function State.switch( screen, ... )
    validateScreen( 'switch', 1, screen );
    height = 1;
    changes[#changes + 1] = { action = 'switch', screen = screen, args = { ... } };
end

---
-- Pushes a new screen to the stack.
-- Creates a new screen and pushes it on the screen stack, where it will overlay
-- the other screens below it. Screens below the this new screen will be set
-- inactive.
-- @param screen (string) The key of the screen to push to the stack.
-- @param ...    (vararg) One or multiple arguments passed to the new screen.
--
function State.push( screen, ... )
    validateScreen( 'push', 1, screen );
    height = height + 1;
    changes[#changes + 1] = { action = 'push', screen = screen, args = { ... } };
end

---
-- Returns the screen on top of the screen stack without removing it.
-- @return (table) The screen on top of the stack.
--
function State.peek()
    return stack[#stack];
end

---
-- Removes the topmost screen of the stack.
--
function State.pop()
    if height > 1 then
        height = height - 1;
        changes[#changes + 1] = { action = 'pop' };
    else
        error("Can't close the last screen. Use switch() to clear the screen manager and add a new screen.", 2);
    end
end

---
-- Returns a boolean indicating if the screen is already in the stack.
-- @param screen (string) The key of the screen we wanna know if it's in the stack.
-- @return (boolean) True if the screen is in the stack, false otherwise.
--
function State.isInStack( screen )
    validateScreen( 'isInStack', 1, screen );
    local tmp = screens[screen];

    for _, state in ipairs( stack ) do
        if tmp == state then
          return true;
        end
    end

    return false;
end

---
-- Get the table of a specified screen
-- @param screen (string) The key of the screen we
-- @return (tabe) The screen table
--
function State.getScreen( screen )
    validateScreen( 'getScreen', 1, screen );
    return screens[screen];
end

-- ------------------------------------------------
-- LOVE Callbacks
-- ------------------------------------------------

---
-- Reroutes the directorydropped callback to the currently active screen.
-- @param path (string) The full platform-dependent path to the directory.
--                       It can be used as an argument to love.filesystem.mount,
--                       in order to gain read access to the directory with
--                       love.filesystem.
--
function State.directorydropped( path )
    State.peek():directorydropped( path );
end

---
-- Reroutes the draw callback to all screens on the stack.
-- Screens that are higher on the stack will overlay screens that are below
-- them.
--
function State.draw()
    for i = 1, #stack do
        stack[i]:draw();
    end

    State.performChanges()
end

---
-- Reroutes the filedropped callback to the currently active screen.
-- @param file (File) The unopened File object representing the file that was
--                     dropped.
--
function State.filedropped( file )
    State.peek():filedropped( file );
end

---
-- Reroutes the focus callback to all screens on the stack.
-- @param focus (boolean) True if the window gains focus, false if it loses focus.
--
function State.focus( focus )
    for i = 1, #stack do
        stack[i]:focus( focus );
    end
end

---
-- Reroutes the keypressed callback to the currently active screen.
-- @param key      (KeyConstant) Character of the pressed key.
-- @param scancode (Scancode)    The scancode representing the pressed key.
-- @param isrepeat (boolean)     Whether this keypress event is a repeat. The
--                                delay between key repeats depends on the
--                                user's system settings.
--
function State.keypressed( key, scancode, isrepeat )
    State.peek():keypressed( key, scancode, isrepeat );
end

---
-- Reroutes the keyreleased callback to the currently active screen.
-- @param key      (KeyConstant) Character of the released key.
-- @param scancode (Scancode)    The scancode representing the released key.
--
function State.keyreleased( key, scancode )
    State.peek():keyreleased( key, scancode );
end

---
-- Reroutes the lowmemory callback to the currently active screen.
-- mobile devices.
--
function State.lowmemory()
    State.peek():lowmemory();
end

---
-- Reroutes the mousefocus callback to the currently active screen.
-- @param focus (boolean) Wether the window has mouse focus or not.
--
function State.mousefocus( focus )
    State.peek():mousefocus( focus );
end

---
-- Reroutes the mousemoved callback to the currently active screen.
-- @param x  (number) Mouse x position.
-- @param y  (number) Mouse y position.
-- @param dx (number) The amount moved along the x-axis since the last time
--                     love.mousemoved was called.
-- @param dy (number) The amount moved along the y-axis since the last time
--                     love.mousemoved was called.
--
function State.mousemoved( x, y, dx, dy )
    State.peek():mousemoved( x, y, dx, dy );
end

---
-- Reroutes the mousepressed callback to the currently active screen.
-- @param x       (number)  Mouse x position, in pixels.
-- @param y       (number)  Mouse y position, in pixels.
-- @param button  (number)  The button index that was pressed. 1 is the primary
--                           mouse button, 2 is the secondary mouse button and 3
--                           is the middle button. Further buttons are mouse
--                           dependent.
-- @param istouch (boolean) True if the mouse button press originated from a
--                           touchscreen touch-press.
--
function State.mousepressed( x, y, button, istouch )
    State.peek():mousepressed( x, y, button, istouch );
end

---
-- Reroutes the mousereleased callback to the currently active screen.
-- @param x       (number)  Mouse x position, in pixels.
-- @param y       (number)  Mouse y position, in pixels.
-- @param button  (number)  The button index that was released. 1 is the primary
--                           mouse button, 2 is the secondary mouse button and 3
--                           is the middle button. Further buttons are mouse
--                           dependent.
-- @param istouch (boolean) True if the mouse button release originated from a
--                           touchscreen touch-release.
--
function State.mousereleased( x, y, button, istouch )
    State.peek():mousereleased( x, y, button, istouch );
end

---
-- Reroutes the quit callback to the currently active screen.
-- @return quit (boolean) Abort quitting. If true, do not close the game.
--
function State.quit()
    State.peek():quit();
end

---
-- Reroutes the resize callback to all screens on the stack.
-- @param w (number) The new width, in pixels.
-- @param h (number) The new height, in pixels.
--
function State.resize( w, h )
    for i = 1, #stack do
        stack[i]:resize( w, h );
    end
end

---
-- Reroutes the textedited callback to the currently active screen.
-- @param text   (string) The UTF-8 encoded unicode candidate text.
-- @param start  (number) The start cursor of the selected candidate text.
-- @param length (number) The length of the selected candidate text. May be 0.
--
function State.textedited( text, start, length )
    State.peek():textedited( text, start, length );
end

---
-- Reroutes the textinput callback to the currently active screen.
-- @param input (string) The UTF-8 encoded unicode text.
--
function State.textinput( input )
    State.peek():textinput( input );
end

---
-- Reroutes the threaderror callback to all screens.
-- @param thread   (Thread) The thread which produced the error.
-- @param errorstr (string) The error message.
--
function State.threaderror( thread, errorstr )
    for i = 1, #stack do
        stack[i]:threaderror( thread, errorstr );
    end
end


---
-- Reroutes the touchmoved callback to the currently active screen.
-- @param id       (light userdata) The identifier for the touch press.
-- @param x        (number)         The x-axis position of the touch press inside the
--                                   window, in pixels.
-- @param y        (number)         The y-axis position of the touch press inside the
--                                   window, in pixels.
-- @param dx       (number)         The x-axis movement of the touch inside the
--                                   window, in pixels.
-- @param dy       (number)         The y-axis movement of the touch inside the
--                                   window, in pixels.
-- @param pressure (number)         The amount of pressure being applied. Most
--                                   touch screens aren't pressure sensitive,
--                                   in which case the pressure will be 1.
--
function State.touchmoved( id, x, y, dx, dy, pressure )
    State.peek():touchmoved( id, x, y, dx, dy, pressure );
end

---
-- Reroutes the touchpressed callback to the currently active screen.
-- @param id       (light userdata) The identifier for the touch press.
-- @param x        (number)         The x-axis position of the touch press inside the
--                                   window, in pixels.
-- @param y        (number)         The y-axis position of the touch press inside the
--                                   window, in pixels.
-- @param dx       (number)         The x-axis movement of the touch inside the
--                                   window, in pixels.
-- @param dy       (number)         The y-axis movement of the touch inside the
--                                   window, in pixels.
-- @param pressure (number)         The amount of pressure being applied. Most
--                                   touch screens aren't pressure sensitive,
--                                   in which case the pressure will be 1.
--
function State.touchpressed( id, x, y, dx, dy, pressure )
    State.peek():touchpressed( id, x, y, dx, dy, pressure );
end

---
-- Reroutes the touchreleased callback to the currently active screen.
-- @param id       (light userdata) The identifier for the touch press.
-- @param x        (number)         The x-axis position of the touch press inside the
--                                   window, in pixels.
-- @param y        (number)         The y-axis position of the touch press inside the
--                                   window, in pixels.
-- @param dx       (number)         The x-axis movement of the touch inside the
--                                   window, in pixels.
-- @param dy       (number)         The y-axis movement of the touch inside the
--                                   window, in pixels.
-- @param pressure (number)         The amount of pressure being applied. Most
--                                   touch screens aren't pressure sensitive,
--                                   in which case the pressure will be 1.
--
function State.touchreleased( id, x, y, dx, dy, pressure )
    State.peek():touchreleased( id, x, y, dx, dy, pressure );
end

---
-- Reroutes the update callback to all screens.
-- @param dt (number) Time since the last update in seconds.
--
function State.update( dt )
    for i = 1, #stack do
        stack[i]:update( dt );
    end
end

---
-- Reroutes the visible callback to all screens.
-- @param visible (boolean) True if the window is visible, false if it isn't.
--
function State.visible( visible )
    for i = 1, #stack do
        stack[i]:visible( visible );
    end
end

---
-- Reroutes the wheelmoved callback to the currently active screen.
-- @param x (number) Amount of horizontal mouse wheel movement. Positive values
--                    indicate movement to the right.
-- @param y (number) Amount of vertical mouse wheel movement. Positive values
--                    indicate upward movement.
--
function State.wheelmoved( x, y )
    State.peek():wheelmoved( x, y );
end

---
-- Reroutes the gamepadaxis callback to the currently active screen.
-- @param joystick (Joystick)    The joystick object.
-- @param axis     (GamepadAxis) The joystick object.
-- @param value    (number)      The new axis value.
--
function State.gamepadaxis( joystick, axis, value )
    State.peek():gamepadaxis( joystick, axis, value );
end

---
-- Reroutes the gamepadpressed callback to the currently active screen.
-- @param joystick (Joystick)      The joystick object.
-- @param button   (GamepadButton) The virtual gamepad button.
--
function State.gamepadpressed( joystick, button )
    State.peek():gamepadpressed( joystick, button );
end

---
-- Reroutes the gamepadreleased callback to the currently active screen.
-- @param joystick (Joystick)      The joystick object.
-- @param button   (GamepadButton) The virtual gamepad button.
--
function State.gamepadreleased( joystick, button )
    State.peek():gamepadreleased( joystick, button );
end

---
-- Reroutes the joystickadded callback to the currently active screen.
-- @param joystick (Joystick) The newly connected Joystick object.
--
function State.joystickadded( joystick )
    State.peek():joystickadded( joystick );
end

---
-- Reroutes the joystickhat callback to the currently active screen.
-- @param joystick  (Joystick)    The newly connected Joystick object.
-- @param hat       (number)      The hat number.
-- @param direction (JoystickHat) The new hat direction.
--
function State.joystickhat( joystick, hat, direction )
    State.peek():joystickhat( joystick, hat, direction );
end

---
-- Reroutes the joystickpressed callback to the currently active screen.
-- @param joystick (Joystick) The newly connected Joystick object.
-- @param button   (number)   The button number.
--
function State.joystickpressed( joystick, button )
    State.peek():joystickpressed( joystick, button );
end

---
-- Reroutes the joystickreleased callback to the currently active screen.
-- @param joystick (Joystick) The newly connected Joystick object.
-- @param button   (number)   The button number.
--
function State.joystickreleased( joystick, button )
    State.peek():joystickreleased( joystick, button );
end

---
-- Reroutes the joystickremoved callback to the currently active screen.
-- @param joystick (Joystick) The now-disconnected Joystick object.
--
function State.joystickremoved( joystick )
    State.peek():joystickremoved( joystick );
end

---
-- Register to multiple LÖVE callbacks, defaults to all.
-- @param callbacks (table) Table with the names of the callbacks to register to.
--
function State.registerCallbacks( callbacks )
    local registry = {}
    local function null() end

    if type( callbacks ) ~= 'table' then
        callbacks = {'update', 'draw'}

        for name in pairs( love.handlers ) do
            callbacks[#callbacks + 1] = name
        end
    end

    for _, f in ipairs( callbacks ) do
        registry[f] = love[f] or null

        love[f] = function( ... )
            registry[f]( ... )
            return State[f]( ... )
        end
    end
end

-- ------------------------------------------------
-- Return Module
-- ------------------------------------------------

return State;
