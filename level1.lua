module(..., package.seeall)

-- Load and start physics and dependencies
local ui 		= require( "ui" )
local squirrel 	= require( "squirrel" )
local physics 	= require( "physics" )
local catapult 	= require( "catapult" )
local bird 		= require( "bird" )
local json 		= require( "json" )
local coin		= require( "coin" )
local director 	= require ("director")

local backSound = audio.loadSound("music.mp3")

-- debug
io.output():setvbuf('no') 

-- facebook variables
local facebook 	= require( "facebook" )
local appId = "157824117627995"

-- Facebook Commands
local fbCommand	
local LOGOUT = 1
local SHOW_DIALOG = 2
local POST_MSG = 3
local POST_PHOTO = 4
local GET_USER_INFO = 5 
local GET_PLATFORM_INFO = 6
local statusMessage

-- background variables
local background0
local background1
local background2
local backgroundColor

local checkBG1
local checkBG2
local clouds
local sun
local backgroundOffset = 1248

-- global variables
local catapulta
local _W = display.contentWidth;
local _H = display.contentHeight;
local scoreText
local bonusText
local bonusTextLabel
local globalScore = 0
local catapultX = 200
local cameraOffset = 200
local paused = false;
local pausedOnce = false;
local reset = false;
_G.bonus = 0;
_G.bonusEach = 50;

-- end level variables
_G.levelEnded   = false
local endedOnce = false
_G.newHighscore = false

-- display layers
local globalLayer
local gameLayer
local birdsLayer
local coinsLayer
local skyLayer
local UIlayer
local pauseLayer
local endLayer
local levelChooserLayer
local tutorialLayer

function pauseGame()
	
	if not paused then
		
		--if not pausedOnce then
			pauseLayer.isVisible = true
			pausedOnce = true;
			paused = true;
	
			physics.pause()
	
			local popupBackground = display.newImage("pausebg.png", true)
			popupBackground:scale(1.3,1.3)
			popupBackground.y = _H/2
	
			local continueButton = ui.newButton {
				default = "playoff.png",
				over = "playon.png",
				onPress = continue
			}
			
			continueButton:scale(0.9, 0.9)
			continueButton.x = (_W/2) - 150
			continueButton.y = (_H/2) + 200
	
			local restartButton = ui.newButton {
				default = "reset.png",
				over = "reseton.png",
				onPress = restart
			}
	
			restartButton:scale(0.9, 0.9)
			restartButton.x = (_W/2) + 50
			restartButton.y = (_H/2) + 200
	
			local levelChooserButton = ui.newButton {
				default = "highscore.png",
				onPress = restartWithLevelChooser
			}
	
			levelChooserButton:scale(0.9, 0.9)
			levelChooserButton.x = (_W/2) + 250
			levelChooserButton.y = (_H/2) + 200
	
			pauseLayer:insert(popupBackground)
			
			pauseLayer:insert(continueButton)
			pauseLayer:insert(restartButton)
			pauseLayer:insert(levelChooserButton)
		
	end
end

function continue()
	
	pauseLayer.isVisible = false
	paused = false;
	physics.start()
	
end

-- facebook handlers

local function createStatusMessage( message, x, y )
	-- Show text, using default bold font of device (Helvetica on iPhone)
	local textObject = display.newText( message, 0, 0, native.systemFontBold, 24 )
	textObject:setTextColor( 255,255,255 )

	-- A trick to get text to be centered
	local group = display.newGroup()
	group.x = x
	group.y = y
	group:insert( textObject, true )

	-- Insert rounded rect behind textObject
	local r = 10
	local roundedRect = display.newRoundedRect( 0, 0, textObject.contentWidth + 2*r, textObject.contentHeight + 2*r, r )
	roundedRect:setFillColor( 55, 55, 55, 190 )
	group:insert( 1, roundedRect, true )

	group.textObject = textObject
	return group
end

local function getInfo_onRelease( event )
	-- call the login method of the FB session object, passing in a handler
	-- to be called upon successful login.
	fbCommand = GET_USER_INFO
	facebook.login( appId, facebookListener, {"publish_stream"}  )
end

local function postMsg_onRelease( event )
	-- call the login method of the FB session object, passing in a handler
	-- to be called upon successful login.
	fbCommand = POST_MSG
	facebook.login( appId, facebookListener, {"publish_stream"} )
end

local function showDialog_onRelease( event )
	-- call the login method of the FB session object, passing in a handler
	-- to be called upon successful login.
	fbCommand = SHOW_DIALOG
	facebook.login( appId, facebookListener, {"publish_stream"}  )
end

local function logOut_onRelease( event )
	-- call the login method of the FB session object, passing in a handler
	-- to be called upon successful login.
	fbCommand = LOGOUT
	facebook.logout()
end

function removeStatusMessage()
	if statusMessage then
		statusMessage.isVisible = false
		statusMessage:removeSelf()
	end
end

local function facebookListener( event )
	print( "Facebook Listener events:" )
	
	local maxStr = 20		-- set maximum string length
	local endStr
	
	for k,v in pairs( event ) do
		local valueString = tostring(v)
		if string.len(valueString) > maxStr then
			endStr = " ... #" .. tostring(string.len(valueString)) .. ")"
		else
			endStr = ")"
		end
		print( "   " .. tostring( k ) .. "(" .. tostring( string.sub(valueString, 1, maxStr ) ) .. endStr )
	end
--- End of debug Event routine -------------------------------------------------------

    print( "event.name", event.name ) -- "fbconnect"
    print( "event.type:", event.type ) -- type is either "session" or "request" or "dialog"
	print( "isError: " .. tostring( event.isError ) )
	print( "didComplete: " .. tostring( event.didComplete) )
-----------------------------------------------------------------------------------------
	-- After a successful login event, send the FB command
	-- Note: If the app is already logged in, we will still get a "login" phase
	--
    if ( "session" == event.type ) then
        -- event.phase is one of: "login", "loginFailed", "loginCancelled", "logout"
		statusMessage.textObject.text = event.phase		-- tjn Added
		
		print( "Session Status: " .. event.phase )
		
		if event.phase ~= "login" then
			statusMessage.textObject.text = "Hey mate, something didn't work out, try again in 5"
			timer.performWithDelay(1000, removeStatusMessage)
			-- Exit if login error
			return
		end
		
		-- The following displays a Facebook dialog box for posting to your Facebook Wall
		if fbCommand == SHOW_DIALOG then
			statusMessage.textObject.text = "show dialog"
			facebook.showDialog( {action="stream.publish"} )
		end
	
		-- Request the Platform information (FB information)
		if fbCommand == GET_PLATFORM_INFO then
			statusMessage.textObject.text = "platform info"
			facebook.request( "platform" )		-- **tjn Displays info about Facebook platform
		end

		-- Request the current logged in user's info
		if fbCommand == GET_USER_INFO then
			statusMessage.textObject.text = "get user info"
			facebook.request( "me" )
--			facebook.request( "me/friends" )		-- Alternate request
		end

		-- This code posts a photo image to your Facebook Wall
		--
		if fbCommand == POST_PHOTO then
			
			statusMessage.textObject.text = "post photo"
			
			local attachment = {
				name = "Developing a Facebook Connect app using the Corona SDK!",
				link = "http://developer.anscamobile.com/forum",
				caption = "Link caption",
				description = "Corona SDK for developing iOS and Android apps with the same code base.",
				picture = "http://developer.anscamobile.com/demo/Corona90x90.png",
				actions = json.encode( { { name = "Learn More", link = "http://anscamobile.com" } } )
			}
		
			facebook.request( "me/feed", "POST", attachment )		-- posting the photo
		end
		
		-- This code posts a message to your Facebook Wall
		if fbCommand == POST_MSG then
			
			statusMessage.textObject.text = "posting message"
			
			local postMsg = {
				message = "I'm playing Flying Squirrel from my iPhone and I scored " .. globalScore + _G.bonus .. " points!!! Try to beat me!"
			}
		
			facebook.request( "me/feed", "POST", postMsg )		-- posting the message
		end
-----------------------------------------------------------------------------------------
	end
	
    if ( "request" == event.type ) then
        -- event.response is a JSON object from the FB server
        local response = event.response
        statusMessage.textObject.text = "response"
		timer.performWithDelay(1000, removeStatusMessage)

		if ( not event.isError ) then
	        response = json.decode( event.response )
	        
			statusMessage.textObject.text = "response not error"
	
	        if fbCommand == GET_USER_INFO then
				statusMessage.textObject.text = response.name
				print( "name", response.name )
				
			elseif fbCommand == POST_PHOTO then
				statusMessage.textObject.text = "Photo Posted"
							
			elseif fbCommand == POST_MSG then
				statusMessage.textObject.text = "Message Posted"
			else
				-- Unknown command response
				print( "Unknown command response" )
				statusMessage.textObject.text = "Hey mate, something didn't work out, try again in 5"
			end

        else
        	-- Post Failed
			statusMessage.textObject.text = "Hey mate, something didn't work out, try again in 5"
		end
		
	elseif ( "dialog" == event.type ) then
		-- showDialog response
		--
		print( "dialog response:", event.response )
		statusMessage.textObject.text = event.response
    end
end

function publishOnFacebook()
	statusMessage = createStatusMessage( "Connecting to Facebook", 0.5*display.contentWidth, 30 )
	fbCommand = POST_MSG
	facebook.login( appId, facebookListener, {"publish_stream"} )
end

function endLevel()
	
	if not endedOnce then
	
		endedOnce = true;

		physics.pause()

		endLayer = display.newGroup()
		globalLayer:insert(endLayer)
		
		-- check highscore for background
		local popupBackground 
		
		if _G.newHighscore then
			
			popupBackground = display.newImage("win.png", true)
			
		else
			
			popupBackground = display.newImage("lose.png", true)
			
		end
		
		popupBackground:scale(1.3,1.3)
		popupBackground.y = _H/2
	
		local scoreTextLabel = display.newText("SCORE: " .. math.floor(catapult.getSquirrel().x) + _G.bonus, 0,0, "Komikoz", 38)
		scoreTextLabel:setTextColor(0, 0, 0)
		scoreTextLabel.x = (_W/2) - 200
		scoreTextLabel.y = (_H/2) - 200
	
		local facebookButton = ui.newButton {
			default = "fboff.png",
			over = "fbon.png",
			onPress = publishOnFacebook
		}

		facebookButton:scale(0.9, 0.9)
		facebookButton.x = (_W/2) - 350
		facebookButton.y = (_H/2) + 50

		local restartButton = ui.newButton {
			default = "reset.png",
			over = "reseton.png",
			onPress = restart
		}

		restartButton:scale(0.9, 0.9)

		restartButton.x = (_W/2) - 150
		restartButton.y = (_H/2) + 50

		endLayer:insert(popupBackground)
		endLayer:insert(scoreTextLabel)
		endLayer:insert(facebookButton)
		endLayer:insert(restartButton)
	end
end

function resetBackground()
	
	background0.x = 1
	background1.x = backgroundOffset
	background2.x = backgroundOffset*2
	
end

function setupBackground()

	backgroundColor = display.newRect(-300,0,1500,960)
	backgroundColor:setFillColor (120, 183, 227) -- SKY BLUE
	backgroundColor:toBack()
	
	-- background images
	
	background0 = display.newImage("bgbeach1.jpg", true)
	background0:scale(1.3, 1.3)
	background0.x = 1
	background0.y = 400
	
	background1 = display.newImage("bgbeach0.jpg", true)
	background1:scale(1.3, 1.3)
	background1.x = backgroundOffset
	background1.y = 400
	
	background2 = display.newImage("bgbeach2.jpg", true)
	background2:scale(1.3, 1.3)
	background2.y = 400
	background2.x = backgroundOffset*2
	
	clouds = display.newImage("clouds.png", true)
	sun = display.newImage("sun.png", true)
	
	gameLayer:insert( background0 )
	gameLayer:insert( background1 )
	gameLayer:insert( background2 )
	gameLayer:insert( clouds )
	gameLayer:insert( sun )
		
	checkBG1 = false
	checkBG2 = true
	
end

function setupVisualLayers()
	-- different layers for drawables
	globalLayer = display.newGroup()
	gameLayer   = display.newGroup()
	skyLayer    = display.newGroup()
 	birdsLayer  = display.newGroup()
	coinsLayer  = display.newGroup()
	UIlayer     = display.newGroup()
	pauseLayer  = display.newGroup()
	endLayer    = display.newGroup()
	levelChooserLayer = display.newGroup()
	
	globalLayer:insert( gameLayer )
	globalLayer:insert( skyLayer )
	globalLayer:insert( birdsLayer )
	globalLayer:insert( coinsLayer )
	globalLayer:insert( UIlayer )
	globalLayer:insert( pauseLayer )
	globalLayer:insert( endLayer )
	globalLayer:insert( levelChooserLayer )
	
end

function setupPhysics()
	-- debug drawing
	-- physics.setDrawMode( "hybrid" )
	physics.start()
end

function createBirds() 
	
	bird.setLayer(birdsLayer)
	
	local bird1  = bird.newBird(250, 0, 1, 100000)
	local bird2  = bird.newBird(350, 1500, 2, 150000)
	local bird2b = bird.newBird(300, 4000, 3, 300000)
	local bird3  = bird.newBird(400, 5000, 1, 800000)
	
	gameLayer:insert( birdsLayer )
		
end

function createCoins() 
	
	coin.setLayer(coinsLayer)
	
	local coin1  = coin.newCoin(250, 200)
	local coin2  = coin.newCoin(500, 150)
	local coin3  = coin.newCoin(600, 0)
	local coin4  = coin.newCoin(300, 100)
	local coin5  = coin.newCoin(350, 50)
	local coin6  = coin.newCoin(210, -30)
	
	local coin7  = coin.newCoin(100, 200)
	local coin8  = coin.newCoin(1000, 150)
	local coin9  = coin.newCoin(70, 0)
	local coin10  = coin.newCoin(250, 100)
	local coin11  = coin.newCoin(0, 50)
	local coin12  = coin.newCoin(150, -30)
	
	local coin13  = coin.newCoin(1500, 700)
	local coin14  = coin.newCoin(1400, 700)
	local coin15  = coin.newCoin(1500, 700)
	local coin16  = coin.newCoin(1600, 700)
	local coin17  = coin.newCoin(1700, 700)
	
	local coin18  = coin.newCoin(1500, 500)
	local coin19  = coin.newCoin(1400, 500)
	local coin20  = coin.newCoin(1500, 500)
	local coin21  = coin.newCoin(1600, 500)
	local coin22  = coin.newCoin(1700, 500)
	
	gameLayer:insert( coinsLayer )
		
end

local function setupUI()

	local scoreTextLabel = display.newText("SCORE:", 0,0, "Komikoz", 38)
	scoreTextLabel:setTextColor(0, 0, 0)
	scoreTextLabel:setReferencePoint(display.TopLeftReferencePoint)
	scoreTextLabel.x = -50
	scoreTextLabel.y = 0
	
	scoreText = display.newText("", 0,0, "Komikoz", 38)
	scoreText:setReferencePoint(display.TopLeftReferencePoint)
	scoreText:setTextColor(0, 0, 0)
	scoreText.x = 200
	scoreText.y = 0
	
	bonusTextLabel = display.newText("BONUS:", 0,0, "Komikoz", 38)
	bonusTextLabel:setTextColor(0, 0, 0)
	bonusTextLabel:setReferencePoint(display.TopRightReferencePoint)
	bonusTextLabel.x = _W - 50
	bonusTextLabel.y = 0
	
	bonusText = display.newText("", 0,0, "Komikoz", 38)
	bonusText:setReferencePoint(display.TopRightReferencePoint)
	bonusText:setTextColor(0, 0, 0)
	bonusText.x = _W 
	bonusText.y = 0
	
	local pauseButton = ui.newButton {
		default = "pause.png",
		onPress = pauseGame
	}
	
	pauseButton.x = -5
	pauseButton.y = _H - 55 
	
	UIlayer:insert(scoreTextLabel)
	UIlayer:insert(scoreText)
	UIlayer:insert(bonusTextLabel)
	UIlayer:insert(bonusText)
	UIlayer:insert(pauseButton)	
	
end

function setScore( score )

	scoreText.text = math.floor(score);
	scoreText:setReferencePoint(display.BottomLeftReferencePoint)
 	scoreText.x = 200
	scoreText.y = 92
	globalScore = scoreText.text + _G.bonus
	
	if _G.bonus > 9999 then
		bonusTextLabel.x = _W - 250
	elseif _G.bonus > 999 then
		bonusTextLabel.x = _W - 200
	elseif 	_G.bonus > 99 then
		bonusTextLabel.x = _W - 150
	elseif 	_G.bonus > 0 then
		bonusTextLabel.x = _W - 100
	end

	bonusText.text = _G.bonus;
	bonusText.x = _W
	bonusText.y = 92
	bonusText:setReferencePoint(display.BottomRightReferencePoint)

	print(scoreText.y, bonusText.y)

end

function moveBG(event)
	
	if ( checkBG1 and catapult.getSquirrel().x > background0.x ) then
		
		background1.x = background0.x + backgroundOffset
		background2.x = background1.x + backgroundOffset
		
		checkBG1 = false
		checkBG2 = true
		
	end
	
	if ( checkBG2 and catapult.getSquirrel().x > background1.x ) then
		
		background0.x = background1.x + backgroundOffset
		background2.x = background0.x + backgroundOffset
		
		checkBG1 = true
		checkBG2 = false
		
	end
	
	-- check the distance between the squirrel and the clouds
	-- and reposition the clouds if too far
		
	if( clouds.x - catapult.getSquirrel().x < -2000 ) then
		clouds.x = catapult.getSquirrel().x + 5000
	end
	
end

function moveCamera(event)	
	-- Reposition "camera"

	if catapult.getSquirrel()
		then
		
		if( squirrel.isLaunched() and catapult.getSquirrel().x > cameraOffset) then
			gameLayer.x = - catapult.getSquirrel().x + cameraOffset
			
			if(catapult.getSquirrel().y < 100) then
				gameLayer.y = - catapult.getSquirrel().y + 100
			end
			
			setScore(catapult.getSquirrel().x)

		end
	
		if reset then
		
			-- reposition the camera
			gameLayer.x = - catapult.getSquirrel().x + cameraOffset
			gameLayer.y = - catapult.getSquirrel().y + 520
			setScore(0)
			reset = false
			
		end
		
		if levelEnded and not endedOnce then
			endLevel()
		end
	
	
	end

end

function changeLevelTo1()
	changeLevel(1)
end

function changeLevelTo2()
	changeLevel(2)
end

function changeLevelTo3()
	changeLevel(3)
end

function changeLevel( _level )
	
	-- remove old stuff
	
	if backgroundColor then
		backgroundColor:removeSelf()
	end
	
	if background0 then
		background0:removeSelf()
	end
	
	if background1 then
		background1:removeSelf()
	end
	
	if background2 then
		background2:removeSelf()
	end
	
	if clouds then
		clouds:removeSelf()
	end
	
	if sun then
		sun:removeSelf()
	end
	
	-- setup new assets
	
	if _level == 1 then
		
		-- beach
		backgroundColor = display.newRect(-300,0,1500,960)
		backgroundColor:setFillColor (120, 183, 227) -- SKY BLUE
		backgroundColor:toBack()

		-- background images

		background0 = display.newImage("bgbeach1.jpg", true)
		background0:scale(1.3, 1.3)
		background0.x = 1
		background0.y = 400

		background1 = display.newImage("bgbeach0.jpg", true)
		background1:scale(1.3, 1.3)
		background1.x = backgroundOffset
		background1.y = 400

		background2 = display.newImage("bgbeach2.jpg", true)
		background2:scale(1.3, 1.3)
		background2.y = 400
		background2.x = backgroundOffset*2

		clouds = display.newImage("clouds.png", true)
		sun = display.newImage("sun.png", true)

	end
	
	if _level == 2 then
		
		-- forest
		backgroundColor = display.newRect(-300,0,1500,960)
		backgroundColor:setFillColor (23, 57, 30) -- forest green
		backgroundColor:toBack()

		-- background images

		background0 = display.newImage("forest1.jpg", true)
		background0:scale(1.3, 1.3)
		background0.x = 1
		background0.y = 400

		background1 = display.newImage("forest2.jpg", true)
		background1:scale(1.3, 1.3)
		background1.x = backgroundOffset
		background1.y = 400

		background2 = display.newImage("forest3.jpg", true)
		background2:scale(1.3, 1.3)
		background2.y = 400
		background2.x = backgroundOffset*2

		clouds = display.newGroup()
		sun = display.newGroup()

	end
	
	if _level == 3 then
		
		-- industrial
		backgroundColor = display.newRect(-300,0,1500,960)
		backgroundColor:setFillColor (164, 170, 194) -- industrial gray
		backgroundColor:toBack()

		-- background images

		background0 = display.newImage("industrial1.jpg", true)
		background0:scale(1.3, 1.3)
		background0.x = 1
		background0.y = 400

		background1 = display.newImage("industrial2.jpg", true)
		background1:scale(1.3, 1.3)
		background1.x = backgroundOffset
		background1.y = 400

		background2 = display.newImage("industrial3.jpg", true)
		background2:scale(1.3, 1.3)
		background2.y = 400
		background2.x = backgroundOffset*2

		clouds = display.newGroup()
		sun = display.newGroup()
		
	end
	
	gameLayer:insert( background0 )
	gameLayer:insert( background1 )
	gameLayer:insert( background2 )
	gameLayer:insert( clouds )
	gameLayer:insert( sun )
	
	checkBG1 = false
	checkBG2 = true
	
	levelChooserLayer.isVisible = false
	
	coinsLayer:toFront()
	birdsLayer:toFront()
	catapulta:toFront()
	squirrel.getSquirrelInstance():toFront()

end

function moveToMainMenu()
	director:changeScene("menu")
end

function createLevelChooser()
	
	levelChooserLayer:toFront()
	
	-- show new background
	local levelChooserBG = display.newImage("levelchooserbg.png")
	levelChooserBG:scale(2.5, 2.5)
	levelChooserBG.x = _W/2
	levelChooserBG.y = _H/2
	
	levelChooserLayer:insert(levelChooserBG)
	
	-- setup icons
	
	local level1Button = ui.newButton {
		default = "iconbg2.png",
		onPress = changeLevelTo1
	}
	
	level1Button.x = _W/5
	level1Button.y = _H/2
	
	local level2Button = ui.newButton {
		default = "iconbg1.png",
		onPress = changeLevelTo2
	}
	
	level2Button.x = _W/2
	level2Button.y = _H/2
	
	local level3Button = ui.newButton {
		default = "iconbg3.png",
		onPress = changeLevelTo3
	}
	
	level3Button.x = _W - _W/5
	level3Button.y = _H/2
	
	--[[
	
	local backButton = ui.newButton {
		default = "back.png",
		onPress = moveToMainMenu
	}
	
	backButton.x = 50
	backButton.y = _H - 110  
	levelChooserLayer:insert(backButton)
	]]--
	
	levelChooserLayer:insert(level1Button)
	levelChooserLayer:insert(level2Button)
	levelChooserLayer:insert(level3Button)
	
	
end

function showLevelChooser()
	levelChooserLayer.isVisible = true
end

function new()
	
	-- debug
	io.output():setvbuf('no')

	-- game initializations
	setupPhysics()
	setupVisualLayers()
	setupBackground()
	setupUI()
	
	-- show level chooser
	createLevelChooser()
	
	-- populate level
	createBirds()
	
	-- create coins
	createCoins()
	
	-- create catapult for the squirrel
	catapulta = catapult.newCatapult( catapultX, 600 )
	
	-- start the audio
	audio.play( backSound, { channel=1, loops=-1, fadein=5000 } )
	
	gameLayer:insert(catapulta)
	gameLayer:insert(catapult.getSquirrel())
	
	Runtime:addEventListener("enterFrame", moveCamera)
	Runtime:addEventListener("enterFrame", moveBG)	
	
	return globalLayer
	
end

function restartBirds()
	bird.setRestart(false)
end

function restartWithLevelChooser()
	
	catapult.removeTimer()
	
	resetBackground()
	squirrel.reset()
	bird.setRestart(true)
	
	reset = true;
	pauseLayer.isVisible = false
	endLayer.isVisible = false
	endedOnce = false
	_G.levelEnded = false
	_G.bonus = 0
	paused = false
	pausedOnce = false
	catapult.finishedFalse()
	
	timer.performWithDelay(10000, restartBirds)
	
	showLevelChooser()
	
	physics.start()

end

function restart()
	
	catapult.removeTimer()
	
	resetBackground()
	squirrel.reset()
	bird.setRestart(true)
	
	reset = true;
	pauseLayer.isVisible = false
	endLayer.isVisible = false
	endedOnce = false
	_G.levelEnded = false
	_G.bonus = 0
	paused = false
	pausedOnce = false
	catapult.finishedFalse()
	
	timer.performWithDelay(10000, restartBirds)
	
	physics.start()

end