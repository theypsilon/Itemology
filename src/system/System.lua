local System = class()

function System:_init()
	local array = self:requires()
	assert(is_array(array) and #array >= 1)

	self.components = array
	self.entities   = {}
end

function System:requires()
	error 'systems must overwrite "requires" method, returning an array'
end

function System:add_entity(entity)
	assert(is_table(entity))

	for _, c in pairs(self.components) do
		if not entity[c] then return false end
	end

	self.entities[entity] = true
end

function System:remove_entity(entity)
	self.entities[entity] = nil
end

function System:update_all(dt)
	for e,_ in pairs(self.entities) do		
		self:update(e, dt)
	end
end

function System:update(e, dt)
	error 'system must overwrite "update" or "update_all" method'
end


function System:update_components(dt)
	local args  = table.keys(self.components)
	local count = #self.componets + 1
	for e,_ in pairs(self.entities) do
		for k, c in pairs(self.components) do
			args[k] = e[c]
		end
		args[count] = dt
		self:update(unpack(args))
	end
end

return System