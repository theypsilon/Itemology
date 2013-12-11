local function calculate_current_dirpath()
    local src = debug.getinfo(2).source:sub(2)
    local len = #src

    for i = len, 0, -1 do
        src = string.sub(src, 0, i)
        local char = string.sub(src, i, i)
        if char == '/' or char == '\\' then break end
    end
    return src
end

project = calculate_current_dirpath()

require(project .. 'src.Itemology')