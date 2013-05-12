require 'Includes'

scale = 2

if scale == 1 then scale = nil end
if scale then
	local oldGetWidth  = love.graphics.getWidth
	local oldGetHeight = love.graphics.getHeight
	function love.graphics.getWidth()
		return oldGetWidth() / scale
	end
	function love.graphics.getHeight()
		return oldGetHeight() / scale
	end
end

function flow.load()
	print 'Welcome to Itemology!'

	sprites = require 'Sprites'
	scenes.run('First')
end

function flow.quit()
	print 'Bye bye!'
end	