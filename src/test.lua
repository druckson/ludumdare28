local merge = (require "utils/diff").merge
require "lib/json"

local o1 = {
    k1 = "Value",
    k2 = {
        k3 = "Value",
        k4 = {
            k5 = "value"
        }
    }
}
o1 = {}

local o2 = {
    k1 = "Value1",
    k2 = {
        k3 = "Value2",
        k4 = {
            k5 = "value3"
        }
    }
}

--o2 = {
--    k1 = "Value1",
--    k2 = {
--        k3 = "Value2"
--    }
--}


local o3 = merge(o1, o2)

print(json.encode(o1))
print(json.encode(o2))
print(json.encode(o3))
