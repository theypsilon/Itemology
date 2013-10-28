local function validatePath(path, type)
    if MOAIFileSystem.checkFileExists(path) then return end
    if not type then type = 'Unknown resource' end
    error(type .. ' not found in following path: ' .. path)
end

local loader = {}
function loader.Image(path, cpu)
    validatePath(path, 'Image')
    local image = 'table' == type(cpu) and cpu.new() or 
                                  cpu and MOAIImage.new() or MOAITexture.new()
    image:load(path)
    return image
end

function loader.Callable(key, func, ...)
    return func(...)
end

return loader