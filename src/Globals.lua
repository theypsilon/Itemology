-- libs

local Fun = require 'lib.Fun.fun'
local Import = require 'lib.Import'
local Strict = require 'lib.Strict'
local Type = require 'lib.Type'
local Table = require 'lib.Table'
local Class = require 'lib.Class'
local Dump = require 'lib.Dump'
local Lazy = require 'lib.Lazy'

-- export inner definitions to scope

Import.export(Import)
Import.export(Strict)
Import.export(Type)
Import.export(Table, table)
Import.export(Class)
Import.export(Dump)
Import.export(Lazy)
Import.export(Fun)

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