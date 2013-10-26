local loader = {}
function loader.Image(path, cpu)
    local image = 'table' == type(cpu) and cpu.new() or 
                                  cpu and MOAIImage.new() or MOAITexture.new()
    image:load(path)
    return image
end

function loader.Callable(path, func)
    return func(path)
end

return loader