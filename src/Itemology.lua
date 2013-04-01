name = 'Itemology'

require 'rapanui-sdk.rapanui'
require 'pl'
require 'engine.GameEngine'
require 'InputManager'

local engine = nil

endFrameTasks = {}

function setCurrentEngine   (newEngine)
	assert(utils.is_callable(newEngine))
	engine = newEngine
end

function setCurrentEngineWithSetup(newEngine)
	newEngine:setup()
	newEngine()
	setCurrentEngine(newEngine)
end

function addEndFrameTask      (task)
	assert(utils.is_callable  (task))
	table.insert(endFrameTasks,task)
end

function getCurrentEngine()
	return engine
end

local function frame()
	engine()
	if next(endFrameTasks) ~= nil then
		for _,task in pairs(endFrameTasks) do
			task()
		end
		endFrameTasks = {}
	end
end

setCurrentEngineWithSetup(GameEngine())
RNListeners:addEventListener("enterFrame", frame)