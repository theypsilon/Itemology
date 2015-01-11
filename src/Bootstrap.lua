-- setting folder base structure
project = '../'
package.path = package.path .. ';?/init.lua'

-- loading game main module
local Itemology   = require 'Itemology'

-- using standard application in this bootstrap
local Application = require 'Application'

-- run the game
Itemology.run(Application)