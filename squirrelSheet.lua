module(...)


function getSpriteSheetData()
    local sheet = {
        frames = {
            {
                name = "squirrelflying1.png",
                spriteColorRect = { x = 0, y = 24, width = 211, height = 85 },
                textureRect = { x = 0, y = 0, width = 211, height = 85 },
                spriteSourceSize = { width = 217, height = 113 },
                spriteTrimmed = true,
                textureRotated = false
            },
            {
                name = "squirrelflying2.png",
                spriteColorRect = { x = 10, y = 6, width = 201, height = 107 },
                textureRect = { x = 0, y = 85, width = 201, height = 107 },
                spriteSourceSize = { width = 217, height = 113 },
                spriteTrimmed = true,
                textureRotated = false
            },
        }
    }
    return sheet
end

