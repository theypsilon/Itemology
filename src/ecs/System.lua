local System = class()

function System:_init(manager, logger)
	local array = self:requires()
	assert(is_array(array) and #array >= 1)
	assert(getmetatable(self).update_all == System.update_all, "don't overwrite update_all")

	self.components = array
	self.entities   = {}
	self.manager    = manager

	if logger then
		self.update, self.remove_entity = logger:proxy_updating_methods(self)
	end
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

function System:update(e, dt)
	error 'system must overwrite "update" or "update_all" method'
end

function System:update_all(dt)
	local args = table.keys(self.components)
	local del  = {}
	local logger = self.logger
	local comp
	local backup
	for e,_ in pairs(self.entities) do
		for k, c in pairs(self.components) do
			comp = e[c]
			args[k] = comp
			if not comp then break end
		end
		if comp then
			self:update(e, dt, unpack(args))
		else
			table.insert(del, e)
		end
	end
	for _,e in pairs(del) do self:remove_entity(e) end
end

return System