local print_r = require "print_r"

local Hu = {}

function analyze(cards, zi)
    if not next(cards) then
        return true
    end
    local start
    local over
    if zi then
        start = 10
        over = 16
    else 
        start = 1
        over = 9
    end
    local finish = true
    for i = start, over do
        if cards[i] and cards[i] ~= 0 then
            start = i
            finish = false
            break
        end
    end
    if finish then -- 手牌为空
        return true
    end
    local result
    if cards[start] and cards[start] >= 3 then -- 刻牌
        cards[start] = cards[start] - 3
        result = analyze(cards , zi)
        cards[start] = cards[start] + 3
        return result
    end
    if not zi and cards[start +1] and cards[start + 2] and cards[start + 1] > 0 and cards[start + 2] > 0 then
        cards[start ] = cards[start ] - 1
        cards[start + 1] = cards[start + 1] - 1
        cards[start + 2] = cards[start + 2] - 1
        result = analyze(cards, zi)
        cards[start ] = cards[start ] + 1
        cards[start + 1] = cards[start + 1] + 1
        cards[start + 2] = cards[start + 2] + 1
        return result
    end
    return false
end

function fmod( arr, num)
    local count = 0
    for k, v in pairs(arr) do
        count = count + v
    end
    return count % num
end

--是否可胡牌
function Hu:win( cards)
    local jiangPos
    local yuShu
    local jiangExisted = false
    local wan = {}
    local zi = {}
    for k, v in pairs(cards) do
        if k < 10 then
            wan[k] = v
        else
            zi[k] = v
        end
    end
    -- wan
    yuShu = fmod(wan, 3)
    if yuShu == 1 then
        return false
    elseif yuShu == 2 then
        jiangPos = wan
        jiangExisted = true
    end
    --zi
    yuShu = fmod(zi, 3)
    if yuShu == 1 then
        return false
    elseif yuShu == 2  then
        if jiangExisted then
            return false
        else
            jiangPos = zi
        end
    end

    if jiangPos == wan then
       if not analyze(zi, true) then
            return false
        end
    elseif not analyze(wan, false) then
        return false
    end 
    if not jiangPos then -- no jiang
        return false
    end
    -- jiang
    local success = false
    for k, v in pairs(jiangPos) do
        if v >= 2 then
            jiangPos[k] = v - 2
            if analyze(jiangPos, jiangPos == zi) then
                success = true
            end
            jiangPos[k] = v
            if success then
                break
            end 
        end
    end
    return success
end

--怎么听牌
function Hu:ting(cards)
    local success = false
    local post = {}
    local will = {}
    for k ,v in pairs(cards) do
        if v > 0 then
            cards[k] = cards[k] - 1
            local willCards = {}
            for i = 1, 16 do
                if i ~= k then
                    if cards[i] then
                        cards[i] = cards[i] + 1
                    else
                        cards[i] = 1
                    end
                    success = self:win(cards)
                    cards[i] = cards[i] - 1
                    if success then
                        table.insert(willCards, i)
                    end
                end
            end
            cards[k] = cards[k] + 1
            if next(willCards) then
                will[k] = willCards
            end
        end
    end
    if next(will) then
        return true, will
    else
        return false
    end
end

local player = {
    [1]    = 1,
    [2] = 1,
    [3] = 1,
    [4] = 3,
    [10] = 3,
    [12] = 1,
    [13] = 1,
}

return Hu