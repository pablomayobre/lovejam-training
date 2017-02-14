local gamestate

love.load = function (args)
  local states = require "src.states"

  gamestate = states {
    --You define ALL states here
    splash  = require "src.splash",
    --menu    = require "src.menu"
  }

  --Register to all love events
  gamestate.register()

  --(state, ...) -> state.enter(...)
  gamestate.setState("splash", "menu")

  --state.load(args) gets called
  gamestate.call("load", args)
end
