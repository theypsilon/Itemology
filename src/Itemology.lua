-- defining global variables, after this, declaring a global is forbidden
require 'Globals'

local ArgFile = require 'lib.lua-arg-file'
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
        scene = Scenes.load("test." .. args[2])
    else
        scene = Scenes.load('First')
    end
    scene.init_package = {}
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
    if not scene then
        print 'Itemology ends now!'
        os.exit()
    end

    if not scene.manager then
        scene:init()
    end

    scene:update(dt)
    scene:draw()

    if scene.manager.next then
        scene:clear()
        local next_scene   = scene.manager.next
        scene              = Scenes.load(next_scene.name)
        scene.init_package = next_scene.params
    end
end

return Itemology