scenes = {}
scene  = nil

local callbacks = { 
	'update', 'draw', 'mousepressed', 'mousereleased',
	'keypressed', 'keyreleased', 'focus' 
}

local function runScene(self)
	if scenes.current and scenes.current.quit then scenes.current.quit() end

	scenes.current = self
	scene          = self

	if not self._init and self.load then
		self.load()
		self._init = true
	end

	for _,v in ipairs(callbacks) do
		if self[v] then flow[v] = self[v] end
	end

end

function scenes.load(path)
	local s = require('scene/' .. path)
	s.run   = s.run or runScene
	return s
end

function scenes.run(path)
	scenes.load(path):run()
end