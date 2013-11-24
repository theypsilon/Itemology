local Flow = require 'Flow'

local graphics = defined('love') and love.graphics or {}

function graphics.getWidth()
    return Flow.config.world.width
end
function graphics.getHeight()
    return Flow.config.world.height
end

function graphics.getScreenW()
    return  MOAIEnvironment.screenWidth
end
function graphics.getScreenH()
    return  MOAIEnvironment.screenHeight
end

return graphics