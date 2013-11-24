require 'Globals'

local flow, scenes, layer, data = require 'Flow', require 'Scenes', require 'Layer', require 'Data'
local resource = require 'resource'

function flow.load()
	print 'Welcome to Itemology!'

    layer.main:setPartition(MOAIPartition.new())

    resource.IMAGE_PATH = 'res/img/'

	scenes.run('First')
end

function flow.quit()
	print 'Bye bye!'
end

flow.run(data.MainConfig)