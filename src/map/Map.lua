local function validate(path)
	local pathList = {
		[path] = path:sub(-3),
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

	if format == 'lua' or format == 'tmx' then
		return path, format
	end

	error('file format "'..format..'" is unknown as tiled map')
end

class.Map()
function Map:_init(path)
	path, format  = validate(path)

	local loader  = require 'map.Loader'
	local data    = loader[format](path)

	self:_setData(data)
end

function Map:_setData(data)
	dump(data)
end