resource = {}

resource.IMAGE_PATH = nil
resource.DIRECTORY_SEPARATOR = '/'

local function validate(path, root, type)
    if MOAIFileSystem.checkFileExists(root .. path) then
        return root .. path
    elseif MOAIFileSystem.checkFileExists(path) then
        return path
    end
    if not type then type = 'Unknown resource' end
    error(type .. ' not found in following path: ' .. path)
end

local images = setmetatable({}, {__mode = 'k'})

function resource.getImage(path, gpu)
    path = validate(path, resource.IMAGE_PATH, 'Image')

    if images[path] then return images[path] end

    local image = gpu and MOAITexture.new() or MOAIImage.new()
    image:load(path)
    images[path] = image
    return image
end

function resource.getDirectoryPath(path)
    return path:match("(.*"..resource.DIRECTORY_SEPARATOR..")")
end