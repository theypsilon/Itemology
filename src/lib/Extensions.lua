function table.flip ( tab )
    local newTable = {}
 
    for k,v in pairs ( tab ) do
        newTable[v] = k
    end
 
    return newTable
end

local oldTileDeck2Dnew = MOAITileDeck2D.new
MOAITileDeck2D.new = function()
	local new = oldTileDeck2Dnew()
	local oldSetTexture = new.setTexture
	new.setTexture = function (self, source)
		local function correctImage(newDir)
		    if path and not path.exists(source) 
		                and path.exists(newDir .. source) then
		        source = newDir .. source
		    end
		end
		correctImage('res/')
		correctImage('res/maps/')
		oldSetTexture(self, source)
	end
	return new
end

if inspect and debug then
    if dump then error 'dump already defined' end
    local function internal_dump(object, level)
        if     type(v) == 'function' then
            object = debug.func(object)
        elseif type(v) ~= 'string'   then
            object = inspect(object,level)
        end
        return object
    end
    
    function dump(...)
        local args = pack(...)
        for k,v in ipairs(args) do
            args[k] = internal_dump(v)
        end
        print(unpack(args))
    end

    function dumpi(object, level)
        object = internal_dump(object,level)
        print(object)
    end

    function debug.func(f)
        return inspect(debug.getinfo(f))
    end
end