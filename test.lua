local print_r = require "print_r"
local Acount = {
    a = 0,
    b = 0,
    c = {}
}

function Acount:new( o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

local obj1 = Acount:new()
obj1.a = obj1.a + 2
table.insert(obj1.c, 1)
print("obj1", obj1.a)
print_r(obj1.c)
local obj2 = Acount:new()
obj2.a = obj2.a + 4
table.insert(obj1.c, 3)
print("obj2", obj2.a)
print_r(obj2.c)