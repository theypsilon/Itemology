-- setting folder base structure
project = '../'

require 'lib.Import/init' .add_package_path("./")

-- loading game main module
local Itemology   = require 'Itemology'

-- using standard application in this bootstrap
local Application = require 'Application'

-- run the game
Itemology.run(Application)