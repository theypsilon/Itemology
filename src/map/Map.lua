local LayerObject = require 'map.LayerObject'
local LayerTile   = require 'map.LayerTile'
local Layer       = require 'map.Layer'
local loader      = require 'map.Loader'

local Map = class('Map')

local function validate(path)
	local pathList = {
		[path] = path:sub(-3),
		[path .. '.tmx'] = 'tmx',
		[path .. '.lua'] = 'lua',
		[path .. '.lue'] = 'lua'
	}

	local path, format = (function()
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

function Map:_init(path)
	local path, format  = validate(path)

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
		sets[#sets + 1] = loadTileset(tileset, dir)
	end
	self.tilesets = sets
end

function Map:_setLayers(layers)
	local tileLayers, i = {}, 0
	for _,layer in ipairs(layers) do
		           layer.id, i = i, i + 1
		tileLayers[layer.name] = Layer.factory(layer, self)
	end
	self.tilelayers = tileLayers
end

function Map:setLayer(renderLayer)
	for _,layer in pairs(self.tilelayers) do layer:setLayer(renderLayer) end
end

function Map:setLoc(x, y, z)
	for _,layer in pairs(self.tilelayers) do layer:setLoc(x, y, z) end
end

function Map:draw(x, y, z)
	for _,layer in pairs(self.tilelayers) do layer:draw(x, y, z) end
end

function Map:__call(name)
	return self.tilelayers[name]
end

return Map