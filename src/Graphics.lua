local graphics = defined('love') and love.graphics or {}

local flow = require 'Flow'

function graphics.getWidth()
    return flow.config.world.width
end
function graphics.getHeight()
    return flow.config.world.height
end

function graphics.getScreenW()
    return  MOAIEnvironment.screenWidth
end
function graphics.getScreenH()
    return  MOAIEnvironment.screenHeight
end

return graphics