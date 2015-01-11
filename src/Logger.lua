local Logger = class()

local function dirname(str)
    if str:match(".-/.-") then
        local name = string.gsub(str, "(.*/)(.*)", "%1")
        return name
    else
        return ''
    end
end

function Logger:_init(filepath)
    os.execute('mkdir -p "' .. dirname(filepath) .. '"')
    self.file = io.open(filepath, "a")
end

function Logger.timer()
    return os.clock()
end

function Logger:log(level, message)
    local entry = string.format("%g |%s| %s\n", self.timer(), level, message)
    self.file:write(entry)
    self.file:flush()
end 

function Logger:debug(message)
    self:log("DEBUG", message)
end

function Logger:info(message)
    self:log("INFO", message)
end

function Logger:notice(message)
    self:log("NOTICE", message)
end

function Logger:warning(message)
    self:log("WARNING", message)
end

function Logger:error(message)
    self:log("ERROR", message)
end

function Logger:alert(message)
    self:log("ALERT", message)
end

function Logger:emergency(message)
    self:log("EMERGENCY", message)
end

function Logger:critical(message)
    self:log("CRITICAL", message)
end

return Logger