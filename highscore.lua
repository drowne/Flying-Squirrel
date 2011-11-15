module (..., package.seeall)

-- highscore file
local path = system.pathForFile( "flyingSquirrelHS.txt", system.DocumentsDirectory )

function getHighScore()
	
	-- io.open opens a file at path. returns nil if no file found
	local fh, reason = io.open( path, "r" )
	local score = 0
	
	if fh then
	   -- if file exists read highscore from file
 		score = fh:read( "*n" )
	else
		-- display failure message in terminal
	   print( "Reason open failed: " .. reason )  

	   -- create file because it doesn't exist yet
	   fh = io.open( path, "w" )

	   if fh then
	        print( "Created file" )
	   else
	        print( "Create file failed!" )
	   end

	   fh:write( "0" )

	end

	io.close( fh )
	
	return score
	
end

function saveHighScore( score )
	
	-- io.open opens a file at path. returns nil if no file found
	local fh, reason = io.open( path, "w" )

	if fh then
	   -- if file exists read highscore from file
	   fh:write( score )
	else
		-- display failure message in terminal
	   print( "Reason open failed: " .. reason )  

	   -- create file because it doesn't exist yet
	   fh = io.open( path, "w" )

	   if fh then
	        print( "Created file" )
	   else
	        print( "Create file failed!" )
	   end

	   fh:write( score )

	end

	io.close( fh )
	
end

function checkHighscore( score )
	
	-- retrieve old high score
	local oldHighScore = getHighScore()
	
	if score > oldHighScore then
		
		-- new high score
		saveHighScore( score )
		
		return true
	
	else
		return false
	
	end
	
end