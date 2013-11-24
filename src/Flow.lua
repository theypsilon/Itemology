local Layer; import()

local flow = {}

local callbacks = {
	'load', 'update', 'draw', 'mousepressed', 'mousereleased',
	'keypressed', 'keyreleased', 'focus', 'quit'
}

local cbmap = table.flip(callbacks)

function flow.get()
	local callStatus = {}
	for _,v in ipairs(callbacks) do
		callStatus[v] = flow[v]
	end
	return callStatus
end

function flow.set(callStatus)
	for k,v in pairs(callStatus) do
		if cbmap[k] ~= nil then
			flow[k] = v
		end
	end
end

local stack = {}

function flow.push()
	table.insert(stack, flow.get())
end

function flow.pop()
	flow.set(table.remove(stack, #stack))
end

function flow.reset()
	for _,v in ipairs(callbacks) do
		flow[k] = nil
	end
end

function flow.exit()
	if defined('love') then
		love.event.push("quit")
	else
		os.exit()
	end
end

function flow.run(config)
	if defined('love') then return end

	config = config or { 
		title  = 'Noname', 
		screen = {width = 800, height = 600}, 
		world  = {width = 800, height = 600},
	}

	if config.dev.sanitychecks then print '*sanity checks enabled*' end

	flow.config = config

	MOAISim.openWindow ( config.title, config.screen.width, config.screen.height )
	MOAISim.setStep ( 1 / 100 )
	MOAISim.clearLoopFlags()
	MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_BOOST )
	MOAISim.setBoostThreshold ( 0 )

	local SCREEN_UNITS_X = config.world.width
	local SCREEN_UNITS_Y = config.world.height
	local SCREEN_X_OFFSET = 0
	local SCREEN_Y_OFFSET = 0

	local DEVICE_WIDTH, DEVICE_HEIGHT = config.screen.width, config.screen.height

	local gameAspect = SCREEN_UNITS_Y / SCREEN_UNITS_X
	local realAspect = DEVICE_HEIGHT / DEVICE_WIDTH

	local SCREEN_WIDTH, SCREEN_HEIGHT
	if realAspect > gameAspect then
		SCREEN_WIDTH = DEVICE_WIDTH
		SCREEN_HEIGHT = DEVICE_WIDTH * gameAspect
	else
		SCREEN_WIDTH = DEVICE_HEIGHT / gameAspect
		SCREEN_HEIGHT = DEVICE_HEIGHT
	end

	if SCREEN_WIDTH < DEVICE_WIDTH then
		SCREEN_X_OFFSET = ( DEVICE_WIDTH - SCREEN_WIDTH ) * 0.5
	end

	if SCREEN_HEIGHT < DEVICE_HEIGHT then
		SCREEN_Y_OFFSET = ( DEVICE_HEIGHT - SCREEN_HEIGHT ) * 0.5
	end

    global{viewport = MOAIViewport.new()}
	viewport:setSize ( SCREEN_X_OFFSET, SCREEN_Y_OFFSET, SCREEN_X_OFFSET + SCREEN_WIDTH, SCREEN_Y_OFFSET + SCREEN_HEIGHT )
	viewport:setScale ( SCREEN_UNITS_X, -SCREEN_UNITS_Y )
    -- viewport:setSize (config.screen.width, config.screen.height)
    -- viewport:setScale(config.world .width,-config.world .height)
    viewport:setOffset(-1,1)
    flow.viewport = viewport

	if flow.load then flow.load() end

	local mainThread = MOAIThread.new ()

	mainThread:run ( 
		function ()
			local lastTime, curTime, dt = MOAISim.getElapsedTime(), 0, 0
			while true do
			  
				coroutine.yield ()		
					
				curTime  = MOAISim.getElapsedTime()
				dt       = curTime - lastTime;
				lastTime = curTime;

				if scene then
					scene:update( dt )
					--for _,v in pairs(Layer) do v:clearTemp() end
					scene:draw()
				end
			end				
		end 
	)
end

function flow.clear()
	local i = 0
	local physics = require 'Physics'
	
	physics:clear()
	Layer.main:clear()
	-- table.each_recursive(item, function(k, v)
	-- 	local t = type(v)

	-- 	if t ~= 'table' and t ~= 'userdata' then return end

	-- 	-- if t == 'userdata' then
	-- 	-- if v.destroy then v:destroy(); v.destroy = nil end
	-- 	-- if v.remove then v:remove(); v.remove = nil end
	-- 	-- end
		
	-- 	if v.clear then 
	-- 		v:clear()
	-- 		v.clear = nil
	-- 	end
	-- end)

end

return flow