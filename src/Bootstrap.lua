-- setting folder base structure
project = project and project or '../'
libpath = '../lib/'
srcpath = './'

--package.path = package.path .. ";../lib/?.lua"
require(srcpath .. 'lib.Import').add_package_path(srcpath)
require(srcpath .. 'lib.Import').add_package_path(project)

-- loading game main module
local Itemology   = require 'Itemology'

-- using standard application in this bootstrap
local Application = require 'Application'

-- run the game
Itemology.run(Application)