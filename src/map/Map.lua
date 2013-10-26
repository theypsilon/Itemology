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

	resource.getCallable(path, function()
		local data    = loader[format](path)

		data.path = resource.getDirectoryPath(path)

		self:_setData(data)
	end)
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
	tileset.tex = resource.getImage(dir .. tileset.image)
	return tileset
end

function Map:_setTilesets(tilesets, dir)
	local sets = {}
	for _,tileset in ipairs(tilesets) do
		sets[#sets + 1] = loadTileset(tileset, dir)
	end
	self.tilesets   = sets
	self.tileatlass = setmetatable({}, {__mode = 'k'})
end

function Map:_setLayers(layers)
	local tileLayers, objectLayers, i = {}, {}, 0
	for _,layer in ipairs(layers) do
		layer.id, i    = i, i + 1
		local newLayer = Layer.factory(layer, self)
		if layer.type == 'tilelayer' then
			tileLayers  [layer.name] = newLayer
		else
			objectLayers[layer.name] = newLayer
		end
	end
	self.  tilelayers =   tileLayers
	self.objectlayers = objectLayers
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
	local  layer = self.tilelayers[name]
	return layer and layer or self.objectlayers[name]
end

function Map:getTilesetAsAtlass(index)
	local atlass
	if not self.tilesets  [index] then error('wrong tileset: ' .. index) end
	if not self.tileatlass[index] then

	    local ts = self.tilesets[index]
	    local iw, ih, tw, th = ts.imagewidth, ts.imageheight, 
	    				       ts.tilewidth,  ts.tileheight

		local frame, n = {}, 0
	    for j = 0, ih - th, th do for i = 0, iw - tw, tw  do
	        frame[n] = {code = n, x = i, w = tw, y = j, h = th}
	        n        = n + 1
	    end end

	    atlass = Atlass('../maps/' .. ts.image, 
	    	            frame, layer.main, MOAIImage)

	    self.tileatlass[index] = atlass
	else
		atlass = self.tileatlass[index]
	end
	return atlass
end

return Map