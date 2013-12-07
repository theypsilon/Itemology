-- setting folder base structure
libpath = project .. 'lib/'
srcpath = project .. 'src/'

require (srcpath .. 'lib.Import') . add_package_path(srcpath)

-- defining global variables
require 'Globals'

-- running the game 
-- ** from now on, declaring global vars is illegal, and an error is thrown

local Flow, Scenes, Layer, Data, map, resource; import()
Flow.run(Data.MainConfig, function()
    print 'Welcome to Itemology!'

    Layer.main:setPartition(MOAIPartition.new())

    map.PATH = project
    resource.IMAGE_PATH = project .. 'res/img/'

    Scenes.run('First')
end)

print 'Game running!'