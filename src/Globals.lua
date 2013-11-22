-- import helper

require 'lib.Import'

-- own lua libs

require 'lib.Strict'()
require 'lib.Type'  ()
require 'lib.Table' (table)
require 'lib.Class' ()
require 'lib.Debug' ()
require 'lib.Reload'()

-- application

global{timeStart = os.time ()    }
global{nothing   = function() end}
require 'resource.Resource'()
require 'Graphics'