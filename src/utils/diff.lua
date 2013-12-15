function merge(data1, data2)
    local out = {}

    for key, value in pairs(data1) do
        if data2[key] ~= nil and type(value) == "table" then
            out[key] = merge(data1[key], data2[key])
        else
            out[key] = value
        end
    end

    for key, value in pairs(data2) do
        if data1[key] == nil then
            out[key] = value
        end
    end

    return out
end

function diff(data1, data2)
    local out = {}

    for key, value in pairs(data2) do
        if not data1[key] then
            out[key] = value
        elseif type(data1[key]) == 'table' and type(data2[key]) == 'table' then
            out[key] = diff(data1[key], data2[key])
        elseif data1[key] ~= data2[key] then
            out[key] = value
        end
    end

    return out
end

return {
    diff = diff,
    merge = merge
}
