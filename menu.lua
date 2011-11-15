module (..., package.seeall)

local director 	= require ("director")
local ui		= require("ui")

-- Hide status bar
display.setStatusBar(display.HiddenStatusBar)

local mainGroup = display.newGroup()

function playGame()
	if _G.firstPlay then 
		director:changeScene("tutorial", "fade")
	else
		director:changeScene("level1", "fade")
	end	
end

function help()
	director:changeScene("tutorial", "fade")
end

function loadHighScore()
	director:changeScene("showhighscore", "fade")
end

function new()
	
	local background = display.newImage("menubg.png", true)
	background:scale(1.35, 1.35)
	background.y = display.contentHeight/2
	
	mainGroup:insert(background)
	
	local playButton = ui.newButton {
		default = "playoff.png",
		over = "playon.png",
		onPress = playGame
	}
	
	local highscoreButton = ui.newButton {
		default = "highscore.png",
		onPress = loadHighScore
	}
	
	local tutorialButton = ui.newButton {
		default = "help.png",
		onPress = help
	}

	--playButton:scale(0.9, 0.9)
	playButton.x = (display.contentWidth/2) - 200
	playButton.y = (display.contentHeight) - 150 
	
	highscoreButton:scale(0.9, 0.9)
	highscoreButton.x = (display.contentWidth/2) + 50
	highscoreButton.y = (display.contentHeight) - 150
	
	tutorialButton:scale(0.9, 0.9)
	tutorialButton.x = (display.contentWidth/2) + 240
	tutorialButton.y = (display.contentHeight) - 150
	
	mainGroup:insert(playButton)
	mainGroup:insert(highscoreButton)
	mainGroup:insert(tutorialButton)
	
	return mainGroup

end