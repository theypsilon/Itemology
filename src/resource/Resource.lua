resource = {}

resource.IMAGE_PATH = nil
resource.DIRECTORY_SEPARATOR = '/'

local function validate(path, type)
    if MOAIFileSystem.checkFileExists(path) then return end
    if not type then type = 'Unknown resource' end
    error(type .. ' not found in following path: ' .. path)
end

local loader = require 'resource.Loader'
local store  = setmetatable({}, {__mode = 'k'})
function resource.getResource(path, type, ...)
    validate(path, type)

    if not store[path] then 
        store[path] = loader[type](path, ...) 
    end
    
    return store[path]
end

function resource.getImage(path, cpu)
    if MOAIFileSystem.checkFileExists(resource.IMAGE_PATH .. path) then
        path = resource.IMAGE_PATH .. path
    end

    return resource.getResource(path, 'Image', cpu)
end

function resource.getCallable(path, func)
    return resource.getResource(path, 'Callable', func)
end

function resource.getDirectoryPath(path)
    return path:match("(.*"..resource.DIRECTORY_SEPARATOR..")")
end