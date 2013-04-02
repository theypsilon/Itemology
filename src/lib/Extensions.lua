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
		    if not path.exists(source) 
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