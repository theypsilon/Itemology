require 'Includes'
local flow, scenes, layer, data, Atlass = require 'Flow', require 'Scenes', require 'Layer', require 'Data', require 'Atlass'

function flow.load()
	print 'Welcome to Itemology!'

    layer.main:setPartition(MOAIPartition.new())

    resource.IMAGE_PATH = 'res/img/'

    global{sprites   = Atlass(data.atlass.Sprites)}

	scenes.run('First')
end

function flow.quit()
	print 'Bye bye!'
end

flow.run(data.MainConfig)