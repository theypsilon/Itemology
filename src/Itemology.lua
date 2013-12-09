-- setting folder base structure
libpath = project .. 'lib/'
srcpath = project .. 'src/'

require (srcpath .. 'lib.Import') . add_package_path(srcpath)

-- defining global variables
require 'Globals'

-- Running the GAME 
-- * from now on, declaring globals is avoided, and an error might be thrown

local Flow, Scenes, Layer, Data, Input, map, resource; import()
Flow.run(Data.MainConfig, function()
    print 'Welcome to Itemology!'

    Layer.main:setPartition(MOAIPartition.new())

               map.PATH = project .. 'res/maps/'
    resource.IMAGE_PATH = project .. 'res/img/'

    for k,v in pairs(Data.Keys) do
        Input.bindActionToKeyCode(k, v)
    end
    Input.bindAction('ESC', function() die('ESC says shut down!') end)
    Input.bindAction(1    , function() debug.debug()              end)

    Scenes.run('First')
end)

print 'Game running!'