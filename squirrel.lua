module(..., package.seeall)

require "sprite"

local state = {};
local ready = false;
local shot = {};
local band_stretch = {};
local launched = false
local squirrelInstance
local decelleration = 5
local verticalDangerZone = 450
local boostOnTouch = 5

local initialX, initialY

local bullet = display.newGroup();

-- animation data
local squirrelSheetData = require "squirrelSheet"
local datat = squirrelSheetData.getSpriteSheetData()
local spriteSheet = sprite.newSpriteSheetFromData( "squirrelSheet.png", datat )
local animationSpriteSet = sprite.newSpriteSet(spriteSheet, 1, 2)
sprite.add( animationSpriteSet, "flying", 1, 2, 200, 0 )

-- graphics variables
flyingSpriteSet = sprite.newSprite( animationSpriteSet ); 
idleGraphics = display.newImage( "squirrelidle.png" )
loadingGraphics = display.newImage( "squirrelloading.png" )
deadGraphics = display.newImage( "squirreldead.png" )

function isLaunched()
	return launched
end

function setLaunched( value )
	launched = value
end

function removeListener()
	Runtime:removeEventListener("touch", touchDown)
end

function reset()
	
	setGraphics(0)
	bullet.bodyType = "kinematic"
	bullet.x = initialX
	bullet.y = initialY
	bullet:setLinearVelocity( 0, 0 )
	launched = false
	
end

function setGraphics( number ) 
	
	if( number == 0 ) then
		--idle animation
		flyingSpriteSet.isVisible = false
		idleGraphics.isVisible = true
		loadingGraphics.isVisible = false
		deadGraphics.isVisible = false
		
	end
	
	if( number == 1 ) then
		--loading animation
		flyingSpriteSet.isVisible = false
		idleGraphics.isVisible = false
		loadingGraphics.isVisible = true
		deadGraphics.isVisible = false
		
	end
	
	if( number == 2 ) then
		--flying animation
		flyingSpriteSet.isVisible = true
		idleGraphics.isVisible = false
		loadingGraphics.isVisible = false
		deadGraphics.isVisible = false
		flyingSpriteSet:play()
		
	end
	
	if( number == 3 ) then
		--dead animation
		flyingSpriteSet.isVisible = false
		idleGraphics.isVisible = false
		loadingGraphics.isVisible = false
		deadGraphics.isVisible = true
		
	end
	
end

function touchDown( event )

	if ( event.phase == "began" and launched ) then
				
		if squirrelInstance.y > verticalDangerZone then
		
			-- if the squirrel is in the danger zone
			-- handle the tap and make the squirrel glide
		
			local velX, velY = squirrelInstance:getLinearVelocity()
		
			if(velY<5) then
				velY = velY + decelleration
			else
				velY = 5
			end

			squirrelInstance:setLinearVelocity( velX, velY )
		
		else
			
			-- otherwise the squirrel is not in the danger zone
			-- so make him boost left or right
			-- depending on touch posizion
			if(event.x > display.contentWidth/2) then 
				squirrelInstance:applyLinearImpulse( boostOnTouch, 0, squirrelInstance.x, squirrelInstance.y )
			else
				local vx, vy = squirrelInstance:getLinearVelocity()
				-- apply the impulse only if going right direction
				if vx > 0 then
					squirrelInstance:applyLinearImpulse( -boostOnTouch, 0, squirrelInstance.x, squirrelInstance.y )
				end
			end
			
		end
	end
end

function newSquirrel( _x, _y )

	initialX = _x
	initialY = _y

	launched = false

	-- Import easing plugin
	local easingx  = require("easing");
	
	-- Bullet properties
	local squirrel_bullet = {
		name 	 = "squirrel",
		type 	 = "bullet",
		density  = 0.1,
		friction = 1.0,
		bounce 	 = 0.5,
		size 	 = 30,
		rotation = 0
	}
	
	-- flying animation
	flyingSpriteSet.isVisible = false;
	bullet:insert( flyingSpriteSet )
	
	-- idle image
	bullet:insert( idleGraphics )
	idleGraphics.x = 0
	idleGraphics.y = 0
	
	-- loading image
	loadingGraphics.isVisible = false;
	bullet:insert( loadingGraphics )
	loadingGraphics.x = 0
	loadingGraphics.y = 0
	
	-- dead image
	deadGraphics.isVisible = false;
	bullet:insert( deadGraphics )
	deadGraphics.x = 0
	deadGraphics.y = 0
	
	squirrelInstance = bullet;
	bullet.name = "squirrel"
	-- Place bullet
	bullet.x = _x; 
	bullet.y = _y;
	-- Set up physical properties	
	physics.addBody(bullet, "kinematic", {density=squirrel_bullet.density, friction=squirrel_bullet.friction, bounce=squirrel_bullet.bounce, radius=squirrel_bullet.size});
	
	bullet.linearDamping = 0.0;
	bullet.angularDamping = 0.0;
	bullet.isBullet = true;
	
	flyingSpriteSet:prepare("flying")
	--flyingSpriteSet:prepare("dead")
	--flyingSpriteSet:prepare("loading")
	--flyingSpriteSet:prepare("idle")
	--flyingSpriteSet:play()
	
	Runtime:addEventListener("touch", touchDown )
	
	return bullet;
	
end

function getSquirrelInstance()
	return squirrelInstance
end
