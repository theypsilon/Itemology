-- import helper

require 'lib.Import'

-- libs

addPackagePath(libpath)

require 'inspect'

-- ad-hoc libs

require 'lib.Strict'
require 'lib.Extensions'
global{class  = require 'lib.Class' }
global{reload = require 'lib.Reload'}

-- application

global{timeStart = os.time ()    }
global{nothing   = function() end}
require 'Test'
require 'Tasks'
require 'Data'
require 'Flow'
require 'resource.Resource'
require 'Graphics'
require 'Input'
require 'Layer'
require 'Atlass'
require 'Physics'
require 'Level'
require 'Camera'
require 'Scenes'
require 'Animation'