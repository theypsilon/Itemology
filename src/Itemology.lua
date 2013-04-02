name = 'Itemology'
main = {}

require 'rapanui-sdk.rapanui'
require 'pl'
require 'engine.GameEngine'
require 'InputManager'
require 'lib.Extensions'

local engine = nil
local tasks  = {}

main.endFrameTask = tasks

function main.setEngine   (newEngine)
	assert(utils.is_callable(newEngine))
	engine = newEngine
end

function main.setEngineWithSetup(newEngine)
	newEngine:setup()
	newEngine()
	main.setEngine(newEngine)
end

function main.addEndFrameTask      (task)
	assert(utils.is_callable  (task))
	table.insert(tasks,task)
end

function main.getEngine()
	return engine
end

local function frame()
	engine()
	if next(tasks) ~= nil then
		for _,task in pairs(tasks) do
			task()
		end
		tasks = {}
	end
end

main.setEngineWithSetup(GameEngine())
RNListeners:addEventListener("enterFrame", frame)

-- local table = dofile('res/maps/plattform.lua')
-- for k,v in pairs(table.layers) do
-- 	table.layers[k].data = '...'
-- end
-- pretty.dump(table)

map = RNMapFactory.loadMap(RNMapFactory.TILEDLUA, "res/maps/plattform.lua")

aTileset = map:getTileset(0)
--aTileset:updateImageSource("res/maps/plattform.png")

map:drawMapAt(0, 0, aTileset)
--map:setAlpha(0.5)