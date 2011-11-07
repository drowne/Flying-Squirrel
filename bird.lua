module (..., package.seeall)

require "sprite"

local squirrel = require( "squirrel" )
local catapult = require( "catapult" )

-- birds layer
local layer

-- restart variable to restart the movement of the stopped birds
local restart = false

-- physics info
local scaleFactor = 2.0
local physicsData = (require "exportedBird").physicsData(scaleFactor)

-- animation and graphics variables
local bird1SheetData = require ("bird1")
local bird2SheetData = require ("bird2")
local bird3SheetData = require ("bird3")
local data1 = bird1SheetData.getSpriteSheetData()
local data2 = bird2SheetData.getSpriteSheetData()
local data3 = bird3SheetData.getSpriteSheetData()
local spriteSheet
local animationSpriteSet

local birdSound = audio.loadSound("jump.mp3")

function setRestart( value )
	restart = value
end

function setLayer( _birdsLayer )
	layer = _birdsLayer
end

function newBird( _y, _phase, type, _destroyAt )
	
	-- load correct sprites and animations
	-- depending on bird type
	
	local _deadImage
	local deadImage
	
	-- stop the movement of the bird at this score
	local destroyAt = _destroyAt
	local stopped = false
	
	
	if(type == 1) then
		_deadImage = "bird1dead.png"
		spriteSheet = sprite.newSpriteSheetFromData( "bird1.png", data1 )
		animationSpriteSet = sprite.newSpriteSet(spriteSheet, 1, 2)
		sprite.add( animationSpriteSet, "flying", 1, 2, 350, 0 )
	end
	
	if(type == 2) then
		_deadImage = "bird2dead.png"
		spriteSheet = sprite.newSpriteSheetFromData( "bird2.png", data2 )
		animationSpriteSet = sprite.newSpriteSet(spriteSheet, 1, 2)
		sprite.add( animationSpriteSet, "flying", 1, 2, 1000, 0 )
	end
	
	if(type == 3) then
		_deadImage = "bird3dead.png"
		spriteSheet = sprite.newSpriteSheetFromData( "bird3.png", data3 )
		animationSpriteSet = sprite.newSpriteSet(spriteSheet, 1, 2)
		sprite.add( animationSpriteSet, "flying", 1, 2, 1000, 0 )
	end
	
	local flyingSpriteSet = sprite.newSprite( animationSpriteSet ); 
	flyingSpriteSet:prepare("flying")
	
	local _bird
	local birdSpeedMin = 150
	local birdSpeedMax = 350
	local birdSpeed = 200
	local startingX = -250
	local jumpImpulseX = 350
	local jumpImpulseY = -500
	local borderXright = 300
	
	local isAlive = true
	local randRightXMin = 1100
	local randRightXMax = 1800
	local randLeftXMin = 200
	local randLeftXMax = 1200
	
	local function newBirdSpeed()
		birdSpeed = math.random(birdSpeedMin, birdSpeedMax)
	end
	
	local function restartMovement()

		if not isAlive then
			-- this means the bird was previously hit. So reset the Y position to the original one
			_bird.y = _y
			-- and change the sprite back to flying
		end
		
		newBirdSpeed()
		
		_bird.x = startingX
		_bird:setLinearVelocity(birdSpeed, 0)
	end
		
	-- respawn when out of display
	local function checkBirdOutOfWindow( event )
		
		if not stopped then
																		
			if squirrel.isLaunched() then
						
			-- if the squirrel has been launched
				if _bird.x < squirrel.getSquirrelInstance().x - borderXright then
				
					startingX = squirrel.getSquirrelInstance().x + math.random(randRightXMin, randRightXMax)
					deadImage.isVisible = false
					flyingSpriteSet.isVisible = true
					restartMovement()
			
				end
			
			else
				
				-- squirrel has not been launched yet
				if _bird.x - squirrel.getSquirrelInstance().x > 1300 then
				
					_bird.x = squirrel.getSquirrelInstance().x - math.random(randLeftXMin, randLeftXMax)
					deadImage.isVisible = false
					flyingSpriteSet.isVisible = true
					newBirdSpeed()
					_bird:setLinearVelocity(birdSpeed, 0)
				end
				
			end	
		
			if squirrel.getSquirrelInstance().x > destroyAt then
				stopped = true
			end
		
		else
			
			-- bird is stopped
			
			if restart then
				stopped = false
			end
			
		end
	end
	
	local function onLocalCollision( self, event )
	        if ( event.phase == "began" ) then
					
				--event.other:applyLinearImpulse(jumpImpulseX, jumpImpulseY, event.other.x, event.other.y)
				local velX, velY = event.other:getLinearVelocity()
				
				-- make the squirrel jump
				event.other:setLinearVelocity( velX+jumpImpulseX, jumpImpulseY )
				audio.play( birdSound )
				
				-- kill the bird
				isAlive = false
				_bird:setLinearVelocity(0, birdSpeed*2)
				-- set the correct image for the bird
				deadImage.isVisible = true
				flyingSpriteSet.isVisible = false

	        end
	end
	
	-- create the bird
	local function createBird( event )
		
		-- Set up physical properties	
		physics.addBody( _bird, "kinematic", physicsData:get("bird1flying") )
		_bird:setLinearVelocity(birdSpeed,0)
		_bird.linearDamping = 0.0;
		_bird.angularDamping = 0.0;
		_bird.isBullet = true;
		
		_bird.collision = onLocalCollision
		_bird:addEventListener( "collision", _bird )
		
		layer:insert(_bird)
		
		Runtime:addEventListener("enterFrame", checkBirdOutOfWindow)
		
	end
	
	-- bird image
	_bird = display.newGroup()
	deadImage = display.newImage( _deadImage )
	deadImage:scale(0.3, 0.3)
	
	deadImage.isVisible = false
	flyingSpriteSet.isVisible = true
	
	_bird:insert( flyingSpriteSet )
	_bird:insert( deadImage )
	
	-- resets position of the image inside the group
	flyingSpriteSet.x = 0
	flyingSpriteSet.y = 0
	
	deadImage.x = 0
	deadImage.y = 0
	
	_bird.x = startingX
	_bird.y = _y
	_bird:scale(2,2)

	_bird.name = "bird"
	
	-- create the bird with the right phase
	flyingSpriteSet:play()
	timer.performWithDelay(_phase, createBird)
	
	return _bird
	
end
