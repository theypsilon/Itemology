local System; import 'ecs'

local EntityManager = class()

function EntityManager:_init(di)
	self.systems        = {}
	self.entities       = {}
	self.system_by_name = {}
	self.components     = {}
	self.di             = di or {}

	self.new_index = function(entity, k, v)
		rawset(entity, k, v)
		if not self.components[k] then return end
		for _, system in pairs(self.components[k]) do
			system:add_entity(entity)
		end
	end
end

function EntityManager:add_entity(entity)
	local m = getmetatable(entity)
	if not m then
		m = {}
		setmetatable(entity, m)
	end

	m.__newindex = self.new_index

	for _, system in pairs(self.systems) do
		system:add_entity(entity)
	end
	self.entities[entity] = true
end

function EntityManager:remove_entity(entity)
	for _, system in pairs(self.systems) do
		system:remove_entity(entity)
	end
	self.entities[entity] = nil
end

function EntityManager:update(dt)
	for _, system in pairs(self.systems) do
		system:update_all(dt)
	end
end

function EntityManager:add_system(name)
	if self.system_by_name[name] then error('already there: '..name) end

	local system_class = require ('ecs.system.'..name)
	rawset(system_class, '_name', name)
	local system = system_class(self, self.di.system_logger)
	for _, c in pairs(system:requires()) do
		self.components[c] = self.components[c] or {}
		table.insert(self.components[c], system)
	end

	local array = self.systems
	array[#array + 1] = system

	for _, e in pairs(self.entities) do
		system:add_entity(e)
	end

	self.system_by_name[name] = system
end

function EntityManager:remove_system   (name)
	local  system = self.system_by_name[name]
	if not system then error('it wasnt there: '..name) end

	local index

	for k, v in pairs(self.systems) do
		if v == system then index = k end
	end

	self.systems       [index] = nil
	self.system_by_name[name]  = nil

	return index
end

return EntityManager