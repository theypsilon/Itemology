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

addPackagePath(mainpath)
addPackagePath(mainpath .. '../lib/rapanui/')
addPackagePath(mainpath .. '../lib/penlight/lua/')

require 'Itemology'