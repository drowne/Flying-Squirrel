module (..., package.seeall)

local director 	= require ("director")
local ui		= require("ui")
local highscore = require("highscore")

local globalLayer

local _W = display.contentWidth;
local _H = display.contentHeight;

function backToMenu()
	director:changeScene("menu", "fade")
end

function new()
	
	globalLayer = display.newGroup()
	
	local back = display.newImage("highscoreBG.png")
	back.x = _W/2
	back.y = _H/2
	back:scale(2.4, 2.4)
	
	local highscoreButton = ui.newButton {
		default = "highscore.png",
		onPress = backToMenu
	}
	
	highscoreButton.x = 50
	highscoreButton.y = _H - 115
	
	-- highscore text
	
	local score = highscore.getHighScore()
	
	local scoreTextLabel = display.newText("YOUR HIGHSCORE", 0,0, "Komikoz", 38)
	scoreTextLabel:setTextColor(0, 0, 0)
	scoreTextLabel:setReferencePoint(display.TopLeftReferencePoint)
	scoreTextLabel.x = _W/5
	scoreTextLabel.y = _H/4
	
	local scoreText = display.newText(score, 0,0, "Komikoz", 56)
	scoreText:setTextColor(0, 0, 0)
	scoreText:setReferencePoint(display.TopLeftReferencePoint)
	scoreText.x = _W/3
	scoreText.y = _H/2.5
	
	globalLayer:insert(back)
	globalLayer:insert(highscoreButton)
	globalLayer:insert(scoreTextLabel)
	globalLayer:insert(scoreText)
	
	return globalLayer
	
end