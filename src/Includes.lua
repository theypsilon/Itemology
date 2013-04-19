-- import helper

require 'lib.Import'

-- libs

addPackagePath(libpath)
addPackagePath(libpath .. 'penlight/lua/')

require 'pl'
require 'rapanui'
require 'flower'

-- application

require 'engine.GameEngine'
require 'InputManager'
require 'lib.Extensions'