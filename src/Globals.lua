-- import helper

require 'lib.Import'()

-- own lua libs

require 'lib.Strict'()
require 'lib.Type'  ()
require 'lib.Table' (table)
require 'lib.Class' ()
require 'lib.Debug' ()
require 'lib.Reload'()
require 'lib.Lazy'  ()

-- application globals

local Tasks = require 'Tasks'

global{gTasks    = Tasks   ()    }
global{timeStart = os.time ()    }
global{nothing   = function() end}
global('scene')
global{die = function(...)
    dump(...)
    os.exit()
end}