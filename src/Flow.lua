local function create_window(title, width, height, fps, fullscreen)
	MOAISim.openWindow ( title, width, height )
	MOAISim.setStep ( 1.0 / fps )
	MOAISim.clearLoopFlags()
	MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_BOOST )
	MOAISim.setBoostThreshold ( 0 )

	if fullscreen then MOAISim.enterFullscreenMode() end
end

local function create_viewport(SCREEN_UNITS_X, SCREEN_UNITS_Y, DEVICE_WIDTH, DEVICE_HEIGHT)
	local SCREEN_X_OFFSET = 0
	local SCREEN_Y_OFFSET = 0

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

    local viewport = MOAIViewport.new()
	viewport:setSize ( SCREEN_X_OFFSET, SCREEN_Y_OFFSET, SCREEN_X_OFFSET + SCREEN_WIDTH, SCREEN_Y_OFFSET + SCREEN_HEIGHT )
	viewport:setScale ( SCREEN_UNITS_X, -SCREEN_UNITS_Y )
    -- viewport:setSize (config.screen.width, config.screen.height)
    -- viewport:setScale(config.world .width,-config.world .height)
    viewport:setOffset(-1, 1)
    return viewport
end

local flow = {}
function flow.run(config, starter)

	config = config or { 
		title  = 'Noname', 
		screen = {width = 800, height = 600}, 
		world  = {width = 800, height = 600},
	}

	assert(is_table   (config ))
	assert(is_callable(starter))

	if config.dev.sanitychecks then print '*sanity checks enabled*' end

	create_window(config.title, config.screen.width, config.screen.height, 100, false)

    flow.viewport = create_viewport( 
    	config. world.width, config. world.height, 
    	config.screen.width, config.screen.height
    )


	--Layer.main:setPartition(MOAIPartition.new())

    starter()

	flow.thread = MOAIThread.new ()
	flow.thread:run ( 
		function ()
			local lastTime, curTime, fixed = MOAISim.getElapsedTime(), nil, config.fixedticks

			local time_tick = is_positive(fixed) and 
				function()
					return fixed
				end or function()
					curTime  = MOAISim.getElapsedTime()
					local dt = curTime - lastTime
					lastTime = curTime
					return dt
				end

			while true do
			  
				coroutine.yield ()		

				if scene then
					scene:update( time_tick() )
					--for _,v in pairs(Layer) do v:clearTemp() end
					scene:draw()
				end
			end				
		end 
	)
end

function flow.clear()
	local Layer, Physics; import()
	local i = 0
	
	Physics   :clear()
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