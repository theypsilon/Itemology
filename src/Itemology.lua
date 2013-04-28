require 'Includes'

local engine = nil
local tasks  = {}

main = {}
main.endFrameTask = tasks

local function is_callable(func)
	return (type(func) == 'function') or 
	       (type(func) == 'table' and is_callable(getmetatable(func).__call))
end

function main.setEngine   (newEngine)
	assert(is_callable(newEngine))
	engine = newEngine
end

function main.setEngineWithSetup(newEngine)
	newEngine:setup()
	newEngine()
	main.setEngine(newEngine)
end

function main.addEndFrameTask      (task)
	assert(is_callable  (task))
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
-- RNListeners:addEventListener("enterFrame", frame)


-- map = RNMapFactory.loadMap(RNMapFactory.TILEDLUA, "res/maps/plattform.lua")

-- aTileset = map:getTileset(0)

-- map:drawMapAt(0, 0, aTileset)

-- setting
local screenWidth = MOAIEnvironment.horizontalResolution or 320
local screenHeight = MOAIEnvironment.verticalResolution or 480
local screenDpi = MOAIEnvironment.screenDpi or 120
local viewScale = math.floor(screenDpi / 240) + 1

-- open scene
flower.openWindow("Flower samples", screenWidth, screenHeight, viewScale)
flower.openScene("scene.Main")