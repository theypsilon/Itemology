class.Map()

local function validate(path)
	local pathList = {
		[path] = path:sub(-3,3),
		[path .. '.tmx'] = 'tmx',
		[path .. '.lua'] = 'lua',
		[path .. '.lue'] = 'lua'
	}

	path, format = (function()
		for path, format in pairs(pathList) do
			if MOAIFileSystem.checkFileExists(path) then
				return path, format
			end
		end
		error('file "'..path..'" does not exist')
	end)()

	if not MOAIFileSystem.checkFileExists(path) then error('file "'..path..'" does not exist') end

	local suffix = path:sub()
end

function Map:_init(path)
	validate(path)

	path:sub

	self.atlass = graphics.newImage('res/img/' .. path)
	function self.graphic_draw(that, x,y) 
		graphics.drawq(self.atlass, that.quad, x, y) 
	end
end

local function load_sprite(self, gr) 
	gr.quad = graphics.newQuad(
				gr.x, gr.y, 
				gr.w, gr.h, 
				self.atlass:getWidth(), 
				self.atlass:getHeight()
			)
	gr.draw = self.graphic_draw
end

function Map:get(name)
	local  gr = self.graphics[name]
	if not gr      then return nil            end
	if not gr.quad then load_sprite(self, gr) end
	return gr
end