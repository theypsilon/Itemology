-- import helper

require 'lib.Import'()

-- require 3rd party libs

require 'lib.fun' ()

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

global{gTasks    = Tasks  ()}
global{timeStart = os.time()}
global{tickClock = {ticks = 0}}

global{nothing = function(   )                      end}
global{die     = function(...) dump(...); os.exit() end}

global('scene')