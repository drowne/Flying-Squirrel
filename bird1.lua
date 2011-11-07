module(...)

-- blue bird

function getSpriteSheetData()
    local sheet = {
        frames = {
            {
                name = "bird1.png",
                spriteColorRect = { x = 3, y = 0, width = 95, height = 59 },
                textureRect = { x = 0, y = 0, width = 95, height = 59 },
                spriteSourceSize = { width = 105, height = 59 },
                spriteTrimmed = true,
                textureRotated = false
            },
            {
                name = "bird1f.png",
                spriteColorRect = { x = 4, y = 0, width = 93, height = 46 },
                textureRect = { x = 0, y = 60, width = 93, height = 68 },
                spriteSourceSize = { width = 105, height = 20 },
                spriteTrimmed = true,
                textureRotated = false
            },
        }
    }
    return sheet
end

