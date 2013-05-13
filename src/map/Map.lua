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

	data.path = resource.getDirectoryPath(path)

	self:_setData(data)
end

function Map:_setData(data)
	self.tileWidth   = data.tilewidth
	self.tileHeight  = data.tileheight
	self.mapWidth    = data.width
	self.mapHeight   = data.height
	self.orientation = data.orientation

	self:_setTilesets(data.tilesets, data.path)
	self:_setLayers  (data.layers)
end

local function loadTileset(tileset, dir)
	tileset.tex = resource.getImage(dir .. tileset.image, true)
	return tileset
end

function Map:_setTilesets(tilesets, dir)
	local sets = {}
	for _,tileset in ipairs(tilesets) do
		sets[tileset.name] = loadTileset(tileset, dir)
	end
	self.tilesets = sets
end

function Map:_setLayers(layers)
	local tileLayers = {}
	for _,layer in ipairs(layers) do
		if layer.type == "tilelayer" then

		else

		end
	end
end

function Map:setLayer(layer)
	self.layer = layer
end

function Map:setLoc(x, y)

end