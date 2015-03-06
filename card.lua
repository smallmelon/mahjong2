local print_r = require "print_r"
local Card = {
    WAN = {
        YIWAN  = 1,
        ERWAN =  2,
        SANWAN = 3,
        SIWAN = 4,
        WUWAN = 5,
        LIUWAN = 6, 
        QIWAN = 7,
        BAWAN = 8,
        JIUWAN = 9
    },
    ZI = {
        DONGFENG = 10,
        NANFENG = 11,
        XIFENG = 12,
        BEIFENG = 13,
        HONGZHONG = 14,
        FACAI = 15,
        BAIBAN = 16
    }
}

function Card:shuffle()
    local pool = {}
    for i = 1, 16 do
        table.insert(pool, i)
        table.insert(pool, i)
        table.insert(pool, i)
        table.insert(pool, i)
    end
    local player = {} -- zhuang
    local banker ={} -- xian
    for i = 1, 13 do
        table.insert(player, table.remove(pool, math.random(1, #pool)))
    end
    for i = 1, 14 do
        table.insert(banker, table.remove(pool, math.random(1, #pool)))
    end
    table.sort(player)
    table.sort(banker)
    return banker, player, pool
end

return Card