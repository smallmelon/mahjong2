local Action = {
    uid = 0,
    type = 0,
    cards = {},

    --
    START = 0,
    DRAW = 1,
    POP = 2,
    CHOW = 3,
    PONG = 4,
    EXPOSE = 5,
    CHOWKONG = 6,
    PONGKONG = 7,
    CONCEALED = 8,
    CHOWHU = 9,
    DRAWHU = 10,
    TING = 11,
    DISCARD = 12,
    PASSPUSH = 13,
    CONFIRMWIN = 14,
    KONGDRAW = 15,
    KONGHU = 16
}

function Action:new( uid, type, cards)
    local o = {
        uid = uid,
        type = type,
        cards = cards
    }
    setmetatable(o, self)
    self.__index = self
    return o
end


function Action:check( uid, acitonId)
    
end

return Action