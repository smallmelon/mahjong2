local Table = require "table"
local Action = require "action"
local Hu = require "hu"

local Player = {
    uid = 0,
    handCards = {0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0},
    outCards = {}, -- {{action= 0, card = 0}}
    paired = {}, -- {{action = 0, cards : {}}}
    willCards = {}, -- {1,4}..
    bTing = false,
    host = false,
    ready = false
}

function Player:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.handCards = {0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0}
    o.outCards = {} 
    o.paired = {}
    willCards = {}
    return o
end

function Player:show()
    print("uid: ", self.uid, "handCards:")
    print_r(self.handCards)
    print("outCards:")
    print_r(self.outCards)
    print("paired")
    print_r(self.paired)
end

function Player:setLastOutCardsAction(action)
    local last = self.outCards[#self.outCards]
    last.action = action
end

function Player:setHandCards(cards)
    for i = 1, #cards do
        self.handCards[cards[i]] = self.handCards[cards[i]] + 1
    end
end

function Player:handCardsNum( )
    local num = 0
    for k, v in pairs(self.handCards) do
        num = num + v
    end
    return num
end

function Player:isChow(card)
    print("uid", self.uid, "isChow", "card", card)
    if card > 9 then -- zi
        return false
    end
    local will = {}
    if card > 2 and self.handCards[card - 1] > 0 and self.handCards[card - 2] > 0 then
        table.insert(will, {card -1, card - 2})
    end
    if card > 1 and card < 9 and self.handCards[card- 1] > 0 and self.handCards[card + 1] > 0 then
        table.insert(will, {card -1, card + 1})
    end
    if card > 8 and self.handCards[card + 1] > 0 and self.handCards[card + 2] > 0 then
        table.insert(will, {card +1 , card + 2})
    end
    return #will > 0, will
end

function Player:isPong(card)
    if self.handCards[card] and self.handCards[card] > 1 then
        return true
    end
    return false
end

function Player:isChowkong(card)
    if self.handCards[card] and self.handCards[card] == 3 then
        return true
    end
    return false
end

function Player:isConcealed()
    local will = {}
    for i = 1, #self.handCards do
        if self.handCards[i] == 4 then
            table.insert(will, i)
        end
    end
    return #will > 0 , will
end

--TODO 应该拿手上的牌去遍历，pong的牌吗？
function Player:isPongkong()
    local willCards = {}
    for i = 1, #self.paired do 
        local pair = self.paired[i]
        if pair.action == Action.PONG and self.handCards[pair.cards[1]] == 1 then
             table.insert(willCards, pair.cards[1])
        end
    end
    return #willCards > 0, willCards
end

function Player:isHu()
    return Hu:win(self.handCards)
end

-- chow hu
function Player:isChowhu(card)
    self.handCards[card] = self.handCards[card] + 1
    local b = Hu:win(self.handCards)
    self.handCards[card]  = self.handCards[card] - 1
    return b
end

function Player:isTing()
    if self.bTing == true then
        return true
    end
    return Hu:ting(self.handCards)
end

function Player:draw(card)
    self.handCards[card]  = self.handCards[card] + 1
end

function Player:pop(card)
    self.handCards[card] = self.handCards[card] - 1
    table.insert(self.outCards, {aciton = Action.POP, card = card})
end

function Player:pong(card)
    self.handCards[card] = self.handCards[card] - 2
    table.insert(self.paired, {action = Action.PONG, cards = {card}})
end

function Player:chow(chow, cards)
    for i = 1, #cards do
        self.handCards[cards[i]] = self.handCards[cards[i]] - 1
    end
    table.insert(self.paired, {action = Action.CHOW, cards = {chow, cards[1], cards[2]}})
end

function Player:chowkong( card)
    self.handCards[card] = self.handCards[card] - 3
    table.insert(self.paired, {action = Action.CHOWKONG, cards = {card}})
end

function Player:pongkong(card)
    self.handCards[card] = 0
    for k, v in pairs(self.paired) do
        if v.action == Action.PONG and v.cards[1] == card then
            v.action = Action.PONGKONG 
            break
        end
    end
end

function Player:concealed(card)
    self.handCards[card] = self.handCards[card] - 4
end

function Player:ting(card, willCards)
    self:pop(card)
    self.willCards = willCards 
    self.bTing = true
end

function Player:chowhu( card)
    -- body
end

function Player:drawhu()
    -- body
end

function Player:konghu()
    -- body
end

return Player