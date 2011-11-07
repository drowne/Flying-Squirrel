module(..., package.seeall)

local unpack = unpack
local pairs = pairs
local ipairs = ipairs

function physicsData(scale)
	local physics = { data =
	{ 
		
		["squirrel"] = {
			
				{
					density = 0.1, friction = 1.0, bounce = 0.5, name = "squirrel",
					type = "bullet", rotation = 0,
					filter = { categoryBits = 1, maskBits = 65535 },
					shape = {   -52.5, 27.5  ,  -54.5, -32.5  ,  95.5, -32.5  ,  96.5, 28.5  }
				}  
		}
		
	} }

	-- apply scale factor
	local s = scale or 1.0
	for bi,body in pairs(physics.data) do
		for fi,fixture in ipairs(body) do
			for ci,coordinate in ipairs(fixture.shape) do
				fixture.shape[ci] = s * coordinate
			end
		end
	end
	
	function physics:get(name)
		return unpack(self.data[name])
	end
	
	return physics;
end


