require 'rapanui-sdk.rapanui'
require 'pl'
require 'engine.GameEngine'

local engine = nil

function setCurrentEngine   (engineClass)
	assert(utils.is_callable(engineClass))
	local  instance =        engineClass()
	assert(instance:is_a(Engine))
	       instance:setup()
	
	engine = instance
end

function getCurrentEngine()
	return engine
end

setCurrentEngine(GameEngine)

RNListeners:addEventListener("enterFrame", function()
	engine:update()
end)