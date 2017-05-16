-- libs

local libpath = "lib/"

local Import = require (libpath .. 'Import')
local Strict = require (libpath .. 'Strict')
local Type   = require (libpath .. 'Type')
local Table  = require (libpath .. 'Table')
local Class  = require (libpath .. 'Class')
local Dump   = require (libpath .. 'Dump')
local Lazy   = require (libpath .. 'Lazy')
local Fun    = require (libpath .. 'Fun.fun')

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
global{debugUI = {ui = {}}}

global{nothing = function(   )                      end}
global{die     = function(...) dump(...); os.exit() end}

global('scene')