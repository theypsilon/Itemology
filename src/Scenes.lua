local Scenes = {}

local callbacks = { 
	'update', 'draw', 'mousepressed', 'mousereleased',
	'keypressed', 'keyreleased', 'focus' 
}

local function runScene(self, ...)
	if Scenes.current and Scenes.current.quit then Scenes.current.quit() end

	Scenes.current = self

	if not self._init and self.load then
		self:load(...)
		self._init = true
	end

end

function Scenes.load(path)
	local file = 'scene.' .. path
	package.loaded[file] = nil
	require(file)
	local s = scene
	s.run   = s.run or runScene
	return s
end

function Scenes.run(path, ...)
	if defined('scene') and scene.clear then scene:clear() end
	Scenes.load(path):run(...)
end

return Scenes