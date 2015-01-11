-- require 3rd party libs

local Fun = require 'lib.fun'

-- own lua libs

local Import = require 'lib.Import'
local Strict = require 'lib.Strict'
local Type = require 'lib.Type'
local Table = require 'lib.Table'
local Class = require 'lib.Class'
local Dump = require 'lib.lua-dump'
local Lazy = require 'lib.Lazy'

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