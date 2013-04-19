----------------------------------------------------------------
-- Copyright (c) 2010-2011 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
----------------------------------------------------------------

mainpath = (function ()
	local path = debug.getinfo(1).source
		  path =                     path:gsub('@'       , '/')
	      path = lfs.currentdir() .. path:gsub('main.lua', '' )
	return path
end)()

function addPackagePath(path)
	package.path = package.path .. ';' .. path .. '?.lua'
	package.path = package.path .. ';' .. path .. '?/init.lua'
end

function hackedRequire(floorpath, match)
    local len     = type(match) == 'string' and match:len() or nil
    local require = require
    return function(path)
        if len and path:sub(0,len) == match then
            return require(floorpath .. path)
        else
            return require(path)
        end
    end
end

addPackagePath(mainpath)
addPackagePath(mainpath .. '../lib/')
addPackagePath(mainpath .. '../lib/penlight/lua/')

require 'Itemology'