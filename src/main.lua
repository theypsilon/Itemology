----------------------------------------------------------------
-- Copyright (c) 2010-2011 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
----------------------------------------------------------------

mainpath = (function ()
	local path = debug.getinfo(1).source
		  path =                     string.gsub(path, '@'       , '/')
	      path = lfs.currentdir() .. string.gsub(path, 'main.lua', '' )
	return path
end)()

function addPackagePath(path)
	package.path = package.path .. ';' .. path .. '?.lua'
	package.path = package.path .. ';' .. path .. '?/init.lua'
end

addPackagePath(mainpath)
addPackagePath(mainpath .. '../lib/rapanui/')
addPackagePath(mainpath .. '../lib/penlight/lua/')


-- require "config"
-- require "rapanui-sdk.rapanui"

require "second"

-- package.path = package.path .. ';' .. mainpath .. '../lib/penlight/lua/pl'

require 'pl'

utils.printf("%s\n","That feels better")

projectpath = mainpath .. '../'

MOAISim.openWindow ( "test", 320, 480 )

viewport = MOAIViewport.new ()
viewport:setSize ( 320, 480 )
viewport:setScale ( 320, 480 )

layer = MOAILayer2D.new ()
layer:setViewport ( viewport )
MOAISim.pushRenderPass ( layer )

gfxQuad = MOAIGfxQuad2D.new ()
gfxQuad:setTexture ( projectpath .. "res/img/moai.png" )
gfxQuad:setRect ( -64, -64, 64, 64 )

prop = MOAIProp2D.new ()
prop:setDeck ( gfxQuad )
prop:setLoc ( 0, 80 )
layer:insertProp ( prop )

font = MOAIFont.new ()
font:loadFromTTF ( projectpath .. "res/fonts/arialbd.ttf", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.?!", 12, 163 )

textbox = MOAITextBox.new ()
textbox:setFont ( font )
textbox:setRect ( -160, -80, 160, 80 )
textbox:setLoc ( 0, -100 )
textbox:setYFlip ( true )
textbox:setAlignment ( MOAITextBox.CENTER_JUSTIFY )
layer:insertProp ( textbox )

textbox:setString ( "Te huele el culo a canela!!!!!!!!.\n<c:0F0>Meow.<c>" )
textbox:spool ()

thread = MOAIThread.new ()
thread:run ( twirlingTowardsFreedom )
