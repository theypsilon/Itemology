require 'Globals'

local Flow, Scenes, Layer, Data, resource; import()

function Flow.load()
	print 'Welcome to Itemology!'

    Layer.main:setPartition(MOAIPartition.new())

    resource.IMAGE_PATH = 'res/img/'

	Scenes.run('First')
end

function Flow.quit()
	print 'Bye bye!'
end

Flow.run(Data.MainConfig)