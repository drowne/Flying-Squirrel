module(...)

-- red bird

function getSpriteSheetData()
    local sheet = {
        frames = {
            {
                name = "bird2.png",
                spriteColorRect = { x = 16, y = 0, width = 71, height = 56 },
                textureRect = { x = 0, y = 0, width = 71, height = 56 },
                spriteSourceSize = { width = 105, height = 76 },
                spriteTrimmed = true,
                textureRotated = false
            },
            {
                name = "bird2f.png",
                spriteColorRect = { x = 16, y = 25, width = 71, height = 50 },
                textureRect = { x = 0, y = 60, width = 71, height = 50 },
                spriteSourceSize = { width = 105, height = 71 },
                spriteTrimmed = true,
                textureRotated = false
            },
        }
    }
    return sheet
end

