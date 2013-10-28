-- import helper

require 'lib.Import'

-- libs

addPackagePath(libpath)

--require 'middleclass'
require 'inspect'
require 'penlight'

-- 
-- require 'ATL'
-- require 'rapanui'
-- require 'flower'
-- require 'hanappe'

-- ad-hoc libs

require 'lib.Strict'
require 'lib.Extensions'
global{class  = require 'lib.Class' }
global{reload = require 'lib.Reload'}

-- application

require 'Engine'
require 'Data'
require 'Alias'
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