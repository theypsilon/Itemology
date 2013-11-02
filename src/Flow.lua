local flow = {}

local layer = require 'Layer'

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
	if love then
		love.event.push("quit")
	else
		os.exit()
	end
end

function flow.run(config)
	if love then return end

	config = config or { 
		title  = 'Noname', 
		screen = {width = 800, height = 600}, 
		world  = {width = 800, height = 600},
	}

	if config.sanitychecks then print '*sanity checks enabled*' end

	flow.config = config

	MOAISim.openWindow ( config.title, config.screen.width, config.screen.height )
	MOAISim.setStep ( 1 / 60 )
	MOAISim.clearLoopFlags()
	MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_BOOST )
	MOAISim.setBoostThreshold ( 0 )

    global{viewport = MOAIViewport.new()}
    viewport:setSize (config.screen.width, config.screen.height)
    viewport:setScale(config.world .width,-config.world .height)
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
					scene.update( dt )
					--for _,v in pairs(layer) do v:clearTemp() end
					scene.draw()
				end
			end				
		end 
	)
end

function flow.clear()
	local i = 0
	local physics = require 'Physics'
	
	physics:clear()
	layer.main:clear()
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