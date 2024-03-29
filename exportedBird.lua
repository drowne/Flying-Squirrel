-- This file is for use with Corona(R) SDK
--
-- This file is automatically generated with PhysicsEdtior (http://physicseditor.de). Do not edit
--
-- Usage example:
--			local scaleFactor = 1.0
--			local physicsData = (require "shapedefs").physicsData(scaleFactor)
--			local shape = display.newImage("objectname.png")
--			physics.addBody( shape, physicsData:get("objectname") )
--

-- copy needed functions to local scope
local unpack = unpack
local pairs = pairs
local ipairs = ipairs

module(...)

function physicsData(scale)
	local physics = { data =
	{ 
		
		["bird1flying"] = {
			
				{
					name 	 = "bird",
					type 	 = "bullet",
					density = 2, friction = 0, bounce = 0, 
					filter = { categoryBits = 1, maskBits = 65535 },
					shape = {   21, 23  ,  -18.5, 27.5  ,  -44, 4.25  ,  27.5, 1.25  ,  43.25, 8.25  },
					isSensor = true
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


