class.Camera()

function Camera:_init()
	self.layers = {}
end

function Camera:addLayer(func)
	table.insert(self.layers, {draw = func})
end

function Camera:draw()
	for _,layer in ipairs(self.layers) do
		layer.draw()
	end
end