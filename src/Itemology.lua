require 'Includes'

 -- Path to the tmx files. The file structure must be similar to how they are saved in Tiled
tiled.path = "res/maps/"

scale = 2
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
end

function flow.quit()
	print 'Bye bye!'
end	

scenes.run('First')