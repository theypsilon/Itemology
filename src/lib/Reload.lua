if type(class) ~= 'table' then 
	class = require 'pl.class'
end

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
	if package.loaded[file] ~= nil then

		local ospath    = srcpath .. file:gsub('%.' , '/') .. '.lua'
		local time      =   path. getmtime(ospath) 
		local last_time = ospath_last_time[ospath]

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

reload = reload or {}
reload.instance = updateInstance
reload.file     = reloadFile

return reload