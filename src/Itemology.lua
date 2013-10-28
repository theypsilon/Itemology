require 'Includes'

local config = { screen = {}, world = {}}

config.title    = 'Itemology'    -- The title of the window the game is in (string)
config.author   = 'theypsilon'   -- The author of the game (string)
config.url      = nil            -- The website of the game (string)
config.console  = false          -- Attach a console (boolean, Windows only)
config.release  = false          -- Enable release mode (boolean)

config.screen.width      = 800   -- The window width (number)
config.screen.height     = 600   -- The window height (number)
config.screen.fullscreen = false -- Enable fullscreen (boolean)
config.screen.vsync      = false  -- Enable vertical sync (boolean)
config.screen.fsaa       = 0     -- The number of FSAA-buffers (number)

config.world.width       = 320
config.world.height      = 224

function flow.load()
	print 'Welcome to Itemology!'

    layer.main:setPartition(MOAIPartition.new())

    resource.IMAGE_PATH = 'res/img/'

    global{sprites = Atlass(data.atlass.Sprites)}
	scenes.run('First')
end

function flow.quit()
	print 'Bye bye!'
end

flow.run(config)