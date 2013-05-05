local class_to_file = {}
local function getFileFromClass(class)
	if class_to_file[class] == nil then
		for k,_ in pairs(package.loaded) do
			if stringx.endswith(k, '.' .. class) then 
				class_to_file[class] = k 
			end
		end
	end

	return class_to_file[class]
end

local ospath_last_time = {}
local function reloadFile(file, alwaysload)
	local  loaded = package.loaded[file]
	if not loaded then
		   file   = file:gsub('%.' , '/')
		   loaded = package.loaded[file]
	end

	if loaded then
		local ospath    = srcpath .. file:gsub('%.' , '/') .. '.lua'
		local time      = path and   path. getmtime(ospath) or nil
		local last_time = time and ospath_last_time[ospath] or nil

		if alwaysload or not last_time or last_time < time then
			ospath_last_time[ospath] = time
			package.loaded  [file]   = nil
			require(file)
			return true
		end
	end
	return false
end

local function reloadBases(metaClass)
	local alwaysload = nil
	if metaClass._base ~= nil then
		alwaysload = reloadBases(metaClass._base)
	end
	return reloadFile(getFileFromClass(metaClass._name), alwaysload)
end

local function updateInstance(instance)
	local meta = getmetatable(instance)

	if reloadBases(meta) then
		local class = _G[meta._name]
		setmetatable(instance,class)
		return true
	end
	return false
end

local function reloadTasks()
	for _,v in ipairs(reload.tasks) do
		if type(v) == 'string' then reload.file(v) else reload.instance(v) end
	end
end

reload = reload or {}
reload.instance = updateInstance
reload.file     = reloadFile
reload.tasks    = reload.tasks or {}
reload.all      = reloadTasks

return reload