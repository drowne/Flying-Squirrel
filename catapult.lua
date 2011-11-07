module(..., package.seeall)

local highscore = require( "highscore" )
local squirrel 	= require( "squirrel" )

local squirrel1
local target
local finished = false

local restart = false

local squirrelYOffset = -80
local squirrelXOffset = 0

local lineLeftXOffset = -40
local lineLeftYOffset = -80
local lineRightXOffset = 30
local lineRightYOffset = -80

local loseSound = audio.loadSound("lose.wav")

local timerID

-- adjustment values
local slingshotStrenght = 3
-- display group
local slingshot_container = display.newGroup();

function isFinished()
	return finished
end

function finishedFalse()
	finished = false
end

function getSquirrel()
	return squirrel1
end

function setSquirrel( _squirrel )
	squirrel1 = _squirrel
end

function isRestarting()
	return restart
end

function removeListener()
	Runtime:removeEventListener("enterFrame", checkPosition)
end

function removeTimer()
	
	if timerID then
		timer.cancel(timerID)
	end
	
end

function newCatapult( _x, _y )

	-- create the squirrel
 	squirrel1 = squirrel.newSquirrel(_x +squirrelXOffset, _y +squirrelYOffset)
	finished = false

	slingshot_container:insert(squirrel1)

	-- slingshot image
	local slingshot = display.newImage( "slingshot.png" )
	slingshot.x = _x
	slingshot.y = _y
	slingshot:scale(1,1)
	slingshot_container:insert(slingshot)

	-- squirrel sprite
	target = display.newGroup()
	target.x = squirrel1.x; 
	target.y = squirrel1.y; 
	target.alpha = 0
	slingshot_container:insert(target)

	local slingshot_line = display.newLine(0, 0, 0, 0)
	-- Set the elastic band's visual attributes
	slingshot_line:setColor(54,24,12)
	slingshot_line.width = 8
	slingshot_container:insert(slingshot_line)

	
	local function dragCatapult( event )
		
		if not squirrel.isLaunched() then
		
			local t = event.target

			local phase = event.phase
			if "began" == phase then
				display.getCurrentStage():setFocus(t)
				t.isFocus = true
				
				-- stop the movement
				t:setLinearVelocity(0,0)
				t.angularVelocity = 0
				
				-- initial position           
				t.x0 = event.x - t.x
				t.y0 = event.y - t.y

				myLine = nil
				line = nil

				elseif t.isFocus then

					slingshot_line.isVisible = false

					if "moved" == phase then
						
						-- set the loading animation
						squirrel.setGraphics(1);
						
						-- if exist a line then remove it
						if (myLine) then
							myLine.parent:remove(myLine)
							line.parent:remove(line)
						end
						
						local distanceX = event.x - t.x0
						local distanceY = event.y - t.y0
						
						t.x = distanceX
						
						-- limit Y distance
						if distanceY < 600 then 
						
							t.y = distanceY
						
						end

							--Set the elastic attached to the touch
							-- RIGHT LINE
							line = display.newLine(t.x, t.y, slingshot.x + lineLeftXOffset, slingshot.y + lineLeftYOffset)
							-- Set the elastic band's visual attributes
							line:setColor(54,24,12)
							line.width = 12;
							-- LEFT LINE
							--Set the target line visual attributes
							myLine = display.newLine(t.x, t.y, slingshot.x + lineRightXOffset, slingshot.y + lineRightYOffset)
							myLine:setColor(54,24,12)
							myLine.width = 12
						
						
						
						elseif "ended" == phase or "cancelled" == phase then
						-- remove focus
						display.getCurrentStage():setFocus( nil ) 
						t.isFocus = false

						--local hideTarget = transition.to(target, {alpha = 0, time = 200, yScale = 1.0, xScale = 1.0 })

						slingshot_line.isVisible = false

						-- if exist a line then remove it
						if (myLine) then
							myLine.parent:remove(myLine)
							line.parent:remove(line)
							myLine = nil
							line = nil
						end
						
						if (line) then
							line.parent:remove(line)
							line = nil
						end

						-- apply force to the squirrel according to the distance of the drag
						local distanceX = (t.x - target.x)
						local distanceY = (t.y - target.y)

						-- start applying gravity on it
						t.bodyType = "dynamic"
						-- apply impulse to throw it
						t:applyForce( distanceX * (-slingshotStrenght), distanceY * (-slingshotStrenght), t.x, t.y)
						
						squirrel.setLaunched(true);
						-- set the flying animation
						squirrel.setGraphics(2);
					
					end
				end

				return true
			end
		end
		
		local function levelEnd()
			
			if not _G.levelEnded then
				_G.levelEnded = true
			end
			
		end
		
		local function endAnimation()
			
			if not finished then
			
				-- set the dead sprite
				squirrel.setGraphics(3);
				
				squirrel1.launched = false
				squirrel1:setLinearVelocity(0, -300)
				finished = true
				
				audio.play( loseSound )
				
				-- check highscore
				if highscore.checkHighscore(math.floor(squirrel1.x)+_G.bonus) then
					_G.newHighscore = true
				else
					_G.newHighscore = false
				end
				
				timerID = timer.performWithDelay(2000, levelEnd)
			
			end
			
		end
		
		-- end the game when landed
		local function checkPosition( event )
						
			if squirrel.isLaunched() then
			
				if squirrel1.y > display.contentHeight +50  then
				
					endAnimation()	

				end	
			
			end
			
		end

		Runtime:addEventListener("enterFrame", checkPosition)
		squirrel1:addEventListener("touch", dragCatapult )

		return slingshot

	end