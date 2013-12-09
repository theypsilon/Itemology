local function explode(div,str) -- credit: http://richard.warburton.it
	if (div == '') then return false end

	local pos, arr = 0, {}

	for st, sp in function() return string.find(str, div, pos, true) end do
		arr[#arr + 1] = string.sub(str, pos, st - 1)
		pos = sp + 1
	end

	arr[#arr + 1] = string.sub(str, pos)
	return arr
end

local function fix_file_path(file)
	local max = 0

	for k, v in pairs(explode(';', package.path)) do
		local path = explode('?', v)[1]
		local len  = #path
		if file:sub(1, len) == path and len > max then max = len end
	end

	return file:sub(max + 1):gsub('[%/%\\]', '.')
end

local ospath_last_time = {}
local function reload_file(file, alwaysload, absolutepath)
	if absolutepath then file = fix_file_path(file) end

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
			return pcall(function() return require(file) end)
		elseif not last_time then ospath_last_time[ospath] = time end
	end
	return false
end

local function get_path_from_function(f)
	local  source = debug.getinfo(f).source
	return source:sub(2, #source - 4)
end

local function get_related_files(table)
	if type(table) ~= 'table' then return {} end

	local files = {}
	for k,v in pairs(table) do
		assert(type(k) == 'string')
		if type(v) == 'function' then
			files[get_path_from_function(v)] = {table, k}
		end
	end

	local meta = getmetatable(table)
	if meta then
		for k,v in pairs(get_related_files(meta)) do
			files[k] = v
		end
	end
	return files
end

local function reload_related_files(item, alwaysload)
	if type(item) == 'function' then
		return reload_file(get_path_from_function(item), alwaysload, true)
	end

	if type(item) == 'table' then
		local array, errors = {}, {}
		for file,_ in pairs(get_related_files(item)) do
			local ret, data = reload_file(file, alwaysload, true)

			local sol = ret and array or errors
			local val = ret and data  or {[file] = data}

			sol[#sol + 1] = val
		end
		return array, errors
	end

	error 'reload_related_files can only deduce functions or tables'
end

local exports = { 
	reload_file          = reload_file,
	reload_related_files = reload_related_files,
}

require('lib.Import').make_exportable(exports)

return exports