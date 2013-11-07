local scenes = {}

local flow = require 'Flow'

local callbacks = { 
	'update', 'draw', 'mousepressed', 'mousereleased',
	'keypressed', 'keyreleased', 'focus' 
}

local function runScene(self, ...)
	if scenes.current and scenes.current.quit then scenes.current.quit() end

	scenes.current = self

	if not self._init and self.load then
		self:load(...)
		self._init = true
	end

end

function scenes.load(path)
	local file = 'scene/' .. path
	package.loaded[file] = nil
	require(file)
	local s = scene
	s.run   = s.run or runScene
	return s
end

function scenes.run(path, ...)
	if defined('scene') and scene.clear then scene.clear() end
	scenes.load(path):run(...)
end

return scenes