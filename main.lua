local director 	= require ("director")
-- Hide status bar
display.setStatusBar(display.HiddenStatusBar)

local mainGroup = display.newGroup()

function main()

	mainGroup:insert(director.directorView)
	director:changeScene("menu", "fade")
	
end

main()