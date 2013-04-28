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

require 'src.lib.Import'

addPackagePath(srcpath)

name  = 'tiled_flower_test'
require 'tiled_flower_test'