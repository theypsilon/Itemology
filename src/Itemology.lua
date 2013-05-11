require 'Includes'

 -- Path to the tmx files. The file structure must be similar to how they are saved in Tiled
tiled.path = "res/maps/"

scale = 1


function setStrict(strict, env)
	env        = env or _G
	local meta = getmetatable(env)
	if strict then
		if not meta then
			meta = {}
			setmetatable(env, meta)
		end
		meta.__newindex = function(t,i) error('strictness forbids: '..i) end
	elseif meta then
		meta.__newindex = nil
	end
end

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
end

function flow.quit()
	print 'Bye bye!'
end	

scenes.run('First')

setStrict()