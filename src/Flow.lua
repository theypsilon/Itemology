global('flow', 'love', 'viewport', 'layer')
flow = love or {}

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

	flow.config = config

	MOAISim.openWindow ( config.title, config.screen.width, config.screen.height )
	MOAISim.setStep ( 1 / 60 )
	MOAISim.clearLoopFlags()
	MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_BOOST )
	MOAISim.setBoostThreshold ( 0 )

    viewport = MOAIViewport.new()
    viewport:setSize (config.screen.width, config.screen.height)
    viewport:setScale(config.world .width,-config.world .height)
    viewport:setOffset(-1,1)

	if flow.load then flow.load() end

	local renderTable = MOAIRenderMgr.getRenderTable()
	if not renderTable then
		renderTable = {}
		MOAIRenderMgr.setRenderTable(renderTable)
	end

	local tempLayerIndex = #renderTable + 1
	local layers = {MOAILayer2D.new(), MOAILayer2D.new()}
	for _,layer in ipairs(layers) do
		layer:setViewport(viewport)
	end

	renderTable[tempLayerIndex] = layers[1]

	local function swapTempLayers()
		renderTable[tempLayerIndex] = flow.tempLayer
		flow.tempLayer = flow.tempLayer == layers[1] and layers[2] or layers[1]
		flow.tempLayer:clear()
	end

	local mainThread = MOAIThread.new ()

	mainThread:run ( 
		function ()
			local lastTime, curTime, dt = MOAISim.getElapsedTime(), 0, 0
			while true do
			  
				coroutine.yield ()		
					
				curTime  = MOAISim.getElapsedTime()
				dt       = curTime - lastTime;
				lastTime = curTime;

				flow.update( dt )
				swapTempLayers()
				flow.draw()
			end				
		end 
	)
end

return flow