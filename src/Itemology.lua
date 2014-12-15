-- defining global variables, after this, declaring a global is forbidden
require 'Globals'

local ArgFile; import('lib')
local Scenes, Data, Input, map, resource; import()

local Itemology = {}

-- private use
function Itemology._get_arguments()
    return ArgFile.parse("../arguments")
end

-- private use
function Itemology._init(args)
    print 'Welcome to Itemology!'

    resource.IMAGE_PATH = project .. 'res/img/'
               map.PATH = project .. 'res/maps/'

    for k,v in pairs(Data.key.SDLKeycodes) do
        Input.bindActionToKeyCode(k, v)
    end
    Input.bindAction('ESC', function() die('ESC says shut down!') end)
    Input.bindAction(1    , function() debug.debug()              end)

    if args[1] == 'test' and  args[2] then
        Scenes.run("test." .. args[2])
    else
        Scenes.run('First')
    end
end

-- public interface
function Itemology.run(app)
    local args = Itemology._get_arguments()
    if args.error then
        error "Arguments could not be retrieved"
    end
    app.init(Data.MainConfig)
    Itemology._init(args)
    app.run(Itemology.loop)
end

-- private use
function Itemology.loop(dt)
    if scene then
        scene:update(dt)
        scene:draw()
    end
end

return Itemology