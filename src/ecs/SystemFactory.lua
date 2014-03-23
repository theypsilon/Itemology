local System; import 'ecs'

local Factory = {}

function Factory.create(name, requires, updater)
	local s    = class(name, System)
	s.requires = function() return requires end
	s.update   = updater
	return s
end

return Factory