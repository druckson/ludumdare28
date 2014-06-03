function merge(data1, data2)
    local out = {}

    if data1 then
        for key, value in pairs(data1) do
            if type(value) == "table" then
                if data2 then
                    out[key] = merge(value, data2[key])
                else
                    out[key] = merge(value, nil)
                end
            else
                out[key] = value
            end
        end
    end

    if data2 then
        for key, value in pairs(data2) do
            if type(value) == "table" then
                if data1 then
                    out[key] = merge(data1[key], value)
                else
                    out[key] = merge(nil, value)
                end
            else
            --if not data1[key] then
                out[key] = value
            end
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
