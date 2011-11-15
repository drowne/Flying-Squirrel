local director 	= require ("director")
local highscore = require("highscore")
-- Hide status bar
display.setStatusBar(display.HiddenStatusBar)

local mainGroup = display.newGroup()

_G.firstPlay = true

function main()

	mainGroup:insert(director.directorView)

	if highscore.getHighScore() == 0 then
		_G.firstPlay = true
	else
		_G.firstPlay = false
	end

	director:changeScene("menu", "fade")
	
end

main()