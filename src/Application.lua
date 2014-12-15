local Application = {}

-- private use
function Application.create_window(title, width, height, fps, fullscreen)
    MOAISim.openWindow ( title, width, height )
    MOAISim.setStep ( 1.0 / fps )
    MOAISim.clearLoopFlags()
    MOAISim.setLoopFlags ( MOAISim.SIM_LOOP_ALLOW_BOOST )
    MOAISim.setBoostThreshold ( 0 )

    if fullscreen then MOAISim.enterFullscreenMode() end
end

-- private use
function Application.create_viewport(SCREEN_UNITS_X, SCREEN_UNITS_Y, DEVICE_WIDTH, DEVICE_HEIGHT)
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

-- init the application by creating window and viewport
function Application.init(config)
    assert(not Application.viewport)

    config = config or { 
        title  = 'Noname', 
        screen = {width = 800, height = 600}, 
        world  = {width = 800, height = 600},
    }

    assert(is_table   (config ))

    if config.dev.sanitychecks then print '*sanity checks enabled*' end

    Application.create_window(config.title, config.screen.width, config.screen.height, 100, false)

    Application.fixedticks = config.fixedticks
    Application.viewport   = Application.create_viewport( 
        config. world.width, config. world.height, 
        config.screen.width, config.screen.height
    )
end

-- runs the main loop, init should be ran before this
function Application.run(update)
    assert(not Application.thread)

    local function running()
        local lastTime, now, fixed = MOAISim.getElapsedTime(), nil, Application.fixedticks

        local time_tick = is_positive(fixed) and 
            function()
                return fixed
            end or function()
                now  = MOAISim.getElapsedTime()
                local dt = now - lastTimeSS
                lastTime = now
                return dt
            end

        while true do
            coroutine.yield ()      
            update(time_tick())
        end 
    end

    Application.thread = MOAIThread.new ()
    Application.thread:run(running)
end

return Application