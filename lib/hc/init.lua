local common_local = require(_NAME .. '.class')
local Shapes       = require(_NAME .. '.shapes')
local Spatialhash  = require(_NAME .. '.spatialhash')

local newPolygonShape = Shapes.newPolygonShape
local newCircleShape  = Shapes.newCircleShape
local newPointShape   = Shapes.newPointShape

local HC = {}
function HC:init(cell_size)
	self.hash = common_local.instance(Spatialhash, cell_size or 100)
end

-- spatial hash management
function HC:resetHash(cell_size)
	local hash = self.hash
	self.hash = common_local.instance(Spatialhash, cell_size or 100)
	for shape in pairs(hash:shapes()) do
		self.hash:register(shape, shape:bbox())
	end
	return self
end

function HC:register(shape)
	self.hash:register(shape, shape:bbox())

	-- keep track of where/how big the shape is
	for _, f in ipairs({'move', 'rotate', 'scale'}) do
		local old_function = shape[f]
		shape[f] = function(this, ...)
			local x1,y1,x2,y2 = this:bbox()
			old_function(this, ...)
			self.hash:update(this, x1,y1,x2,y2, this:bbox())
			return this
		end
	end

	return shape
end

function HC:remove(shape)
	self.hash:remove(shape, shape:bbox())
	for _, f in ipairs({'move', 'rotate', 'scale'}) do
		shape[f] = function()
			error(f.."() called on a removed shape")
		end
	end
	return self
end

-- shape constructors
function HC:polygon(...)
	return self:register(newPolygonShape(...))
end

function HC:rectangle(x,y,w,h)
	return self:polygon(x,y, x+w,y, x+w,y+h, x,y+h)
end

function HC:circle(x,y,r)
	return self:register(newCircleShape(x,y,r))
end

function HC:point(x,y)
	return self:register(newPointShape(x,y))
end

-- collision detection
function HC:neighbors(shape)
	local neighbors = self.hash:inSameCells(shape:bbox())
	rawset(neighbors, shape, nil)
	return neighbors
end

function HC:collisions(shape)
	local candidates = self:neighbors(shape)
	for other in pairs(candidates) do
		local collides, dx, dy = shape:collidesWith(other)
		if collides then
			rawset(candidates, other, {dx,dy, x=dx, y=dy})
		else
			rawset(candidates, other, nil)
		end
	end
	return candidates
end

-- the class and the instance
HC = common_local.class('HardonCollider', HC)
local instance = common_local.instance(HC)

-- the module
return setmetatable({
	new       = function(...) return common_local.instance(HC, ...) end,
	resetHash = function(...) return instance:resetHash(...) end,
	register  = function(...) return instance:register(...) end,
	remove    = function(...) return instance:remove(...) end,

	polygon   = function(...) return instance:polygon(...) end,
	rectangle = function(...) return instance:rectangle(...) end,
	circle    = function(...) return instance:circle(...) end,
	point     = function(...) return instance:point(...) end,

	neighbors  = function(...) return instance:neighbors(...) end,
	collisions = function(...) return instance:collisions(...) end,
	hash       = function() return instance.hash end,
}, {__call = function(_, ...) return common_local.instance(HC, ...) end})
