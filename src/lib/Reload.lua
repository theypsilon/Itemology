local ospath_last_time = {}
local function reload_file(file, alwaysload)
	local  loaded = package.loaded[file]
	if not loaded then
		   file   = file:gsub('%.' , '/')
		   loaded = package.loaded[file]
	end

	if loaded then
		local ospath    = srcpath .. file:gsub('%.' , '/') .. '.lua'
		local time      = declared('lfs') and lfs.attributes(ospath, 'modification') or nil
		local last_time = time and ospath_last_time[ospath] or nil

		alwaysload = alwaysload == true or not time

		if alwaysload or (last_time and last_time < time) then
			ospath_last_time[ospath] = time
			package.loaded  [file]   = nil
			return require(file)
		elseif not last_time then ospath_last_time[ospath] = time end
	end
	return false
end

local function get_related_files(table)
	if type(table) ~= 'table' then return {} end

	local files = {}
	for k,v in pairs(table) do
		assert(type(k) == 'string')
		if type(v) == 'function' then
			files[debug.getinfo(v).short_src] = true
		end
	end

	local meta = getmetatable(table)
	if meta then
		for k,_ in pairs(get_related_files(meta)) do
			files[k] = true
		end
	end
	return files
end

local function reload_related_files(item)
	if type(item) == 'function' then
		return reload_file(debug.getinfo(item).short_src)
	end

	if type(item) == 'table' then
		for file,_ in pairs(get_related_files(item)) do
			reload_file(file)
		end
		return true
	end

	error 'reload_related_files can only deduce functions or tables'
end

local exports = { 
	reload_file          = reload_file,
	reload_related_files = reload_related_files,
	get_related_files    = get_related_files,
}

require('lib.Import').make_exportable(exports)

return exports