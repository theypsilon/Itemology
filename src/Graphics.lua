local Data; import()

local graphics = defined('love') and love.graphics or {}

function graphics.getWidth()
    return Data.MainConfig.world.width
end
function graphics.getHeight()
    return Data.MainConfig.world.height
end

function graphics.getScreenW()
    return  MOAIEnvironment.screenWidth
end
function graphics.getScreenH()
    return  MOAIEnvironment.screenHeight
end

return graphics