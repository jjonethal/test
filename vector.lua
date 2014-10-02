-- find a path through a map
-- kurve
-- Gerade
-- Zurueck
-- nach oben
-- nach unten

vector = {}
function vector.length(self)
	local l=0
	for i,v in ipairs(self) do
		l = l + v * v
	end
	return math.sqrt(l)
end

function vector.add(self,v2)
	for i,v in ipairs(self) do
		self[i] = v + v2[i]
	end
	return self
end

function vector.sub(self,v2)
	for i,v in ipairs(self) do
		self[i] = v - v2[i]
	end
	return self
end

function vector.new(...)
	local v = {...}
	local h = getmetatable(v)
	if h == nil then
		h={}
	end
	h.__index = vector
	setmetatable(v,h)
	return v
end

function vector.copy(v1)
	local v1 = vector.new(unpack(v1))
	return v1
end

matrix = {}

function matrix.new(dimx, dimy)
end


-- ostacle center
-- obstacle radius
-- destination position
-- safe area

tt = vector.new(1,2,3)

--[[
meta information for every function


]]

