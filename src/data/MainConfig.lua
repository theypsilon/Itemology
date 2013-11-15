local config = { screen = {}, world = {}}

config.title    = 'Itemology'    -- The title of the window the game is in (string)
config.author   = 'theypsilon'   -- The author of the game (string)
config.url      = nil            -- The website of the game (string)
config.console  = false          -- Attach a console (boolean, Windows only)
config.release  = false          -- Enable release mode (boolean)

config.screen.width      = 1136   -- 1136 1366 The window width (number)
config.screen.height     = 640   -- 640 768 The window height (number)
config.screen.fullscreen = false -- Enable fullscreen (boolean)
config.screen.vsync      = false  -- Enable vertical sync (boolean)
config.screen.fsaa       = 0     -- The number of FSAA-buffers (number)

config.world.width       = 568
config.world.height      = 320

config.sanitychecks   = true--timeStart % 10 == 0
if not config.sanitychecks then
    config.autoreloaddata = false
    config.reloaddata     = true
end

--config.debugPhysics = true

return config