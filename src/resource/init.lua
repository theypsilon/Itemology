local resource = {}

resource.IMAGE_PATH = nil
resource.DIRECTORY_SEPARATOR = '/'

local loader = require 'resource.Loader'
local store  = setmetatable({}, {__mode = 'k'})
function resource.getResource(key, type, ...)
    if not store[key] then 
        store[key] = loader[type](key, ...) 
    end
    
    return store[key]
end

function resource.getImage(path, cpu)
    if MOAIFileSystem.checkFileExists(resource.IMAGE_PATH .. path) then
        path = resource.IMAGE_PATH .. path
    end

    return resource.getResource(path, 'Image', cpu)
end

function resource.getAtlass(definition, cpu)
    return resource.getResource(definition, 'Callable', Atlass, definition, layer.main, cpu)
end

function resource.getCallable(key, func, ...)
    return resource.getResource(key, 'Callable', func, ...)
end

function resource.getDirectoryPath(path)
    return path:match("(.*"..resource.DIRECTORY_SEPARATOR..")")
end

return make_exportable(resource)