-- simul.lua

terrain = [[
	-- w = wall
	-- o = obstacle surrounded by walls
	-- c = charger  surrounded by wall has * charging terminals
	-- * = charging terminal contact
	-- + = connection of borders
	-- - = object border
	-- | = object border
	-- \ = object border
	-- / = object border
	
	+-------------------W------------------+
	|   +-+                    +---+       |
	|   |O|   +------+         | O |       |
	|   +-+   |      |         |   |       |
	|         |  O   |         +---+       |
	|         |      |                     |
	W         +------+                     |
	|       +                              W
	|      / \                             |
	|     + O +          +-------+         |
	|      \ /           |   C   |*        |
	|       +            +-------+         |
	|                                      |
	+-----------W--------------------------+

]]

--- any line starting with -- will be removed
function stripComments(t)
	t = string.gsub(t,"^%s*%-%-[^\n\r]*","")
	t = string.gsub(t,"\n%s*%-%-[^\n\r]*","")
	return t
end

function itemAt(x,y, terrainTable)
	return terrainTable[y]:sub(x,x)
end

function parseTerrain(t)
	local terrain=stripComments(t)
	local lines={}
	terrain:gsub("([^\n\r]*)\n",function(l) lines[#lines+1]=l end)
	return lines
end

function simulateSonicSensor()
	
end
obstacle1={x,y,radius}
obstacle2={x,y,radius}

obstacleList={}

print(stripComments(terrain))
local l=parseTerrain(terrain)
for i,v in ipairs(l) do
	print(i,v)
end