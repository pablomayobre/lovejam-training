-- Based *Heavily* on a pull request made by Bart van Strien
-- https://github.com/kikito/middleclass/pull/12

local middleclass = require('lib.middleclass')

local common = {}

function common.class(name, klass, superclass)
  local c = middleclass(name, superclass)

  for i, v in pairs(klass) do
    c[i] = v
  end

  if klass.init then
    c.initialize = klass.init
  end

  return c
end

function common.instance(class, ...)
  return class:new(...)
end

return common
