-- require 3rd party libs

local Fun = require 'lib.fun'

-- own lua libs

local Import = require 'lib.lua-import'
local Strict = require 'lib.lua-strict'
local Type = require 'lib.lua-type'
local Table = require 'lib.lua-table'
local Class = require 'lib.lua-class'
local Dump = require 'lib.lua-dump'
local Lazy = require 'lib.lua-lazy'

-- export inner definitions to scope

Fun() -- already includes helper for exporting to global scope
Import.make_exportable(Import)(_G)
Import.make_exportable(Strict)(_G)
Import.make_exportable(Type)(_G)
Import.make_exportable(Table)(table)
Import.make_exportable(Class)(_G)
Import.make_exportable(Dump)(_G)
Import.make_exportable(Lazy)(_G)

-- setting strict mode to avoid defining more globals by mistake

set_strict(_G)

-- application globals

local Tasks = require 'Tasks'

global{gTasks    = Tasks  ()}
global{timeStart = os.time()}
global{tickClock = {ticks = 0}}

global{nothing = function(   )                      end}
global{die     = function(...) dump(...); os.exit() end}

global('scene')