module (..., package.seeall)

local director 	= require ("director")

local globalLayer

local slide1
local slide2
local slide3
local slide4

local _W = display.contentWidth;
local _H = display.contentHeight;

local counter = 1

function nextSlide()
	
	if counter == 1 then
		
		slide1.isVisible = false
		slide2.isVisible = true
		
	end
	
	if counter == 2 then
		
		slide2.isVisible = false
		slide3.isVisible = true
		
	end
	
	if counter == 3 then
		
		if _G.firstPlay then
			globalLayer:removeEventListener("tap", nextSlide)
			director:changeScene("level1", "fade")
		else
			slide3.isVisible = false
			slide4.isVisible = true
		end
		
	end
	
	if counter == 4 then
		
		globalLayer:removeEventListener("tap", nextSlide)

		if _G.firstPlay then
			director:changeScene("level1", "fade")
		else
			director:changeScene("menu", "fade")
		end	
	
	end
	
	counter = counter + 1
	
end

function new()
	
	globalLayer = display.newGroup()
	
	-- load all tutorial slides
	slide1 = display.newImage("1.png")
	slide2 = display.newImage("2.png")
	slide3 = display.newImage("3.png")
	slide4 = display.newImage("4.png")
	
	slide1.x = _W/2
	slide1.y = _H/2
	slide1:scale(2.4, 2.4)
	
	slide2.x = _W/2
	slide2.y = _H/2
	slide2:scale(2.4, 2.4)
	
	slide3.x = _W/2
	slide3.y = _H/2
	slide3:scale(2.4, 2.4)
	
	slide4.x = _W/2
	slide4.y = _H/2
	slide4:scale(2.4, 2.4)
	
	globalLayer:insert(slide1)
	globalLayer:insert(slide2)
	globalLayer:insert(slide3)
	globalLayer:insert(slide4)
	
	slide2.isVisible = false
	slide3.isVisible = false
	slide4.isVisible = false
	
	-- add the touch listener
	
	globalLayer:addEventListener("tap", nextSlide)
	
	return globalLayer

end