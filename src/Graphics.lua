global('love', 'graphics')
graphics = love and love.graphics or {}

local flow = require 'Flow'

function graphics.getWidth()
    return flow.config.world.width
end
function graphics.getHeight()
    return flow.config.world.height
end