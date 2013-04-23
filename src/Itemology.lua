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


    mapLoader = TMXMapLoader()
    mapData = mapLoader:loadLueFile(project .. "res/maps/plattform.lua")

    -- mapView = TMXMapView()
    -- mapView:loadMap(mapData)
    -- mapView:setScene(scene)