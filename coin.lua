module (..., package.seeall)

require "sprite"
local squirrel = require( "squirrel" )
local catapult = require( "catapult" )

local coinSound = audio.loadSound("coin.mp3")

-- coins layer
local layer

-- variables
local borderXright = 300
local randRightXMin = 1100
local randRightXMax = 1800

-- animation variables
local coinSheetData = require ("coinSheet")
local data1 = coinSheetData.getSpriteSheetData()
local spriteSheet = sprite.newSpriteSheetFromData( "coin.png", data1 )
local animationSpriteSet = sprite.newSpriteSet(spriteSheet, 1, 8)
sprite.add( animationSpriteSet, "flipping", 1, 8, 275, 0 )

function setLayer( _coinsLayer )
	layer = _coinsLayer
end

function newCoin(_x, _y)
	
	-- local variables
	local counted = false
	
	-- graphics and physics
	local _coin = display.newGroup()
	_coin:scale(2, 2)
	_coin.x = _x
	_coin.y = _y
	
	physics.addBody( _coin, "kinematic", { isSensor=true, density = 1.0, friction = 0.3, bounce = 0.2, radius = 30 } )
	

	local flippingSpriteSet = sprite.newSprite( animationSpriteSet )
	flippingSpriteSet:prepare("flipping")
	
	_coin:insert(flippingSpriteSet)
	layer:insert(_coin)
	
	flippingSpriteSet.x = 0
	flippingSpriteSet.y = 0
	flippingSpriteSet:play()
	
	-- respawn when out of display
	local function checkCoinOutOfWindow( event )
		if squirrel.isLaunched() then
			
			if _coin.x < squirrel.getSquirrelInstance().x - borderXright then
		
				_coin.x = squirrel.getSquirrelInstance().x + math.random(randRightXMin, randRightXMax)
				_coin.isVisible = true
				
				-- restart variables
				counted = false
				
			end
			
		else
			
			counted = false
			_coin.x = _x
			_coin.y = _y
			
		end
		
	end
	
	local function onLocalCollision( event )
	        if ( event.phase == "began" ) then
					
					_coin.isVisible = false
					_G.bonus = _G.bonus + _G.bonusEach;
					audio.play( coinSound )

	        end
	end
	
	Runtime:addEventListener("enterFrame", checkCoinOutOfWindow)
	_coin:addEventListener( "collision", onLocalCollision )
	
end

