local Atlass, Layer, resource; 			import()
local LayerObject, LayerTile, Loader; 	import 'map'

local LayerFactory = require 'map.Layer'.factory

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
	return resource.getCallable(path, function()
		local path, format  = validate(path)

		local data    = Loader[format](path)

		data.path = resource.getDirectoryPath(path)

		self:_setData(data)

		return self
	end)
end

function Map:_setData(data)
	self.tileWidth   = data.tilewidth
	self.tileHeight  = data.tileheight
	self.mapWidth    = data.width
	self.mapHeight   = data.height
	self.orientation = data.orientation
	self.properties  = data.properties

	self:_setTilesets(data.tilesets, data.path)
	self:_setLayers  (data.layers)
end

local TileSet = require 'map.TileSet'

function Map:_setTilesets(tilesets, dir)
	local sets = {}
	for _,tileset in ipairs(tilesets) do
		sets[#sets + 1] = TileSet(tileset, dir)
	end
	self.tilesets   = sets
	self.tileatlass = setmetatable({}, {__mode = 'k'})
end

function Map:_setLayers(layers)
	local tileLayers, objectLayers, i = {}, {}, 0
	for _,layer in ipairs(layers) do
		layer.id, i    = i, i + 1
		local newLayer = LayerFactory(layer, self)
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

function Map:toXYO(x, y)
    return  math.floor(x / self.tileWidth),
            math.floor(y / self.tileHeight)
end

function Map:getCenter()
    return  self.tileWidth  * self.mapWidth  / 2,
            self.tileHeight * self.mapHeight / 2
end

function Map:getBorder()
    return  self.tileWidth  * self.mapWidth,
            self.tileHeight * self.mapHeight
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

	    atlass = Atlass({image='../maps/' .. ts.image, frames=frame}
	    	            ,Layer.main, MOAIImage)

	    self.tileatlass[index] = atlass
	else
		atlass = self.tileatlass[index]
	end
	return atlass
end

return Map