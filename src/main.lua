----------------------------------------------------------------
-- Copyright (c) 2010-2011 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
----------------------------------------------------------------

srcpath = (debug and lfs) and (function ()
	local path = debug.getinfo(1).source
		  path =                     path:gsub('@'       , '/')
	      path = lfs.currentdir() .. path:gsub('main.lua', '' )
	return path
end)() or ''

project = srcpath ..  '../'
libpath = project .. 'lib/'

function addPackagePath(path)
    if path == '' then return end
	package.path = package.path .. ';' .. path .. '?.lua'
	package.path = package.path .. ';' .. path .. '?/init.lua'
end

addPackagePath(srcpath)

name  = 'Itemology'
require 'Itemology'