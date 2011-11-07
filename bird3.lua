module(...)

-- yellow bird

function getSpriteSheetData()
    local sheet = {
        frames = {
            {
                name = "bird3.png",
                spriteColorRect = { x = 1, y = 1, width = 99, height = 66 },
                textureRect = { x = 0, y = 0, width = 99, height = 66 },
                spriteSourceSize = { width = 105, height = 94 },
                spriteTrimmed = true,
                textureRotated = false
            },
            {
                name = "bird3f.png",
                spriteColorRect = { x = 1, y = 36, width = 99, height = 54 },
                textureRect = { x = 0, y = 70, width = 99, height = 85 },
                spriteSourceSize = { width = 105, height = 95 },
                spriteTrimmed = true,
                textureRotated = false
            },
        }
    }
    return sheet
end

