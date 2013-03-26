require "rapanui-sdk.rapanui"
require 'GameEngine'

local engine = nil

function setCurrentEngine(engineClass)
	if engineClass == nil then error 'there has to be always one valid engine' end
	engine = engineClass()
	engine:setup()
end

function getCurrentEngine()
	return engine
end

setCurrentEngine(GameEngine)

RNListeners:addEventListener("enterFrame", function()
	engine:update()
end)