require 'Includes'

 -- Path to the tmx files. The file structure must be similar to how they are saved in Tiled
tiled.path = "res/maps/"

function flow.load()
	print 'Welcome to Itemology!'
end

function flow.quit()
	print 'Bye bye!'
end

scenes.run('First')