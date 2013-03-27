class =         require 'pl.class'
path  = path or require 'pl.path'

local class_to_file = {}
local function getFileFromClass(class)
	if class_to_file[class] == nil then
		local file = nil
		for k,_ in pairs(package.loaded) do
			if stringx.endswith(k,'.'..class) then file = k end
		end

		class_to_file[class] = file
	end

	return class_to_file[class]
end

local function reloadBases(metaClass)
	local alwaysload = nil
	if metaClass._base ~= nil then
		alwaysload = reloadBases(metaClass._base)
	end
	return reloadClass(getFileFromClass(metaClass._name), alwaysload)
end

function updateInstance(instance)
	local meta = getmetatable(instance)

	reloadBases(meta)

	if _G[meta._name] ~= meta._class then
		local class = _G[meta._name]
		setmetatable(instance,class)
		return true
	end
	return false
end

local file_last_time = {}
function reloadClass(class, alwaysload)
	if package.loaded[class] ~= nil then

		local file      = mainpath .. class:gsub('%.' , '/') .. '.lua'
		local time      =  path.getmtime(file) 
		local last_time = file_last_time[file]

		if alwaysload or not last_time or last_time < time then
			file_last_time[file ] = time
			package.loaded[class] = nil
			require(class)
			return true
		end
	end
	return false
end