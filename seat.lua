local Action = require "action"
local Player = require "player"
local Card = require "card"

local Seat = {
    hallId = 0,
    roomId = 0,
    cardPool = {},
    bankerUid = 0,
    point = {},
    lastAction = {}, --{uid, aciton , cards} 
    players = {}
}

function Seat:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.players = {}
    o.point = {}
    return o
end


function Seat:show()
    print("bankerUid ", self.bankerUid)
    for v, k in pairs(self.players) do
        k:show()
    end
    print("lastAction: ")
    print_r(self.lastAction)
end

-- xipai -- 
function Seat:shuffle()
    self.bankerUid = 1
    local banker, player, pool = Card:shuffle()
    self.cardPool = pool
    local p = Player:new({uid = 1})
    p:setHandCards(banker)
    self.players[self.bankerUid] = p
    p = Player:new({uid = 2})
    p:setHandCards(player)
    self.players[2] = p
    self:setLastAction(self.bankerUid, Action.Start, {banker[#banker]}) -- start
end

function Seat:setLastAction(uid, action, cards)
    self.lastAction = {uid = uid, action = action, cards = cards}
end

function Seat:nextUid(uid)
        for k, v in pairs(self.players) do
            if k ~= uid then
                return k
            end
        end
end

function Seat:isHu(uid)
    local player = self.players[uid]
    return player:isHu()
end

function Seat:isChowhu( uid)
    local player = self.players[uid]
    local card = self.lastAction.cards[1]
    return player:isChowhu(card)
end

function Seat:isTing( uid )
    local player = self.players[uid]
    return player:isTing()
end

function Seat:isConcealed( uid )
    local player =self.players[uid]
    return player:isConcealed()
end

function Seat:isChow( uid )
    local player = self.players[uid]
    return player:isChow(self.lastAction.cards[1])
end

function Seat:isChowkong( uid)
    local player = self.players[uid]
    return player:isChowkong(self.lastAction.cards[1])
end

function Seat:isPong(uid)
    local player = self.players[uid]
    return player:isPong(self.lastAction.cards[1])
end

function Seat:isPongkong(uid)
    local player = self.players[uid]
    return player:isPongkong(self.lastAction.cards[1])
end

function Seat:chow(uid, cards)
    local player = self.players[uid]
    local card = self.lastAction.cards[1]
    local other = self.players[self.lastAction.uid]
    other:setLastOutCardsAction(Action.CHOW)
    player:chow(self.lastAction.cards[1], cards)
    self.lastAction = {uid = uid, action = Action.CHOW, cards = {card, cards[1], cards[2]}}
end

function Seat:draw(uid, card)
    local player = self.players[uid]
    player:draw(card)
    self.lastAction = {uid = uid, action = Action.DRAW, cards = {card}}
end

function Seat:pop(uid, card)
    local player = self.players[uid]
    player:pop(card)
    self.lastAction = {uid = uid, action = Action.POP, cards = {card}}
end

function Seat:pong(uid)
    local player = self.players[uid]
    local card = self.lastAction.cards[1]
    local other = self.players[self.lastAction.uid]
    other:setLastOutCardsAction(Action.PONG)
    player:pong(card)
    self.lastAction = {uid = uid , action = Action.PONG, cards = {card}}
end

function Seat:conclead(uid, card)
    local player = self.players[uid]
    player:conclead(card)
    self.lastAction = {uid = uid, action = Action.CONCEALED, cards = {card}}
end

function Seat:chowkong(uid)
    local player = self.players[uid]
    local card = self.lastAction.cards[1]
    local other = self.players[self.lastAction.uid]
    other:setLastOutCardsAction(Action.CHOWKONG)
    player:chowkong(card)
    self.lastAction = {uid = uid, action = Action.CHOWKONG, cards = {card}}
end

function Seat:pongkong(uid)
    local player = self.players[uid]
    local card = self.lastAction.cards[1]
    player:pongkong(card)
    self.lastAction = {uid = uid, action = Action.PONGKONG, cards = {card}}
end

function Seat:ting(uid, popCard, willCards)
    local player = self.players[uid]
    player:ting(popCard, willCards)
    self.lastAction = {uid = uid, Action = Action.POP, cards = {card}}
end

function Seat:kongdraw(uid, card)
    local player = self.players[uid]
    player:kongdraw(card)
    self.lastAction = {uid = uid, Action = Action.KONGDRAW, cards = {card}}
end

function Seat:chowhu(uid, card)
    local player = self.players[uid]
    self.lastAction = {uid = uid, Action = Action.CHOWHU, cards = {card}}
    return   player:chowhu(card)   
end

function Seat:drawhu(uid)
    local player = self.players[uid]
    return player:drawhu()
end

function Seat:konghu(uid)
    local player = self.players[uid]
    return player:konghu()
end

--数番
function Seat:scoring(uid)
    local player = self.players[uid]
    return player:scoring()
end

-- TODO:听牌逻辑没有处理    
function Seat:nextAction( )
    local actions = {}
    local uid = 0
    local player = self.players[self.lastAction.uid]
    local num = player:handCardsNum()
    if num % 3 == 2 then --下一个动作该谁来做
        uid = self.lastAction.uid
        if self.lastAction.action ~= Action.CHOW and self.lastAction.action ~= Action.PONG  then
            if self:isHu(uid) then --  
                table.insert(actions, Action.DRAWHU)
                if self.lastAction.action == Action.KONGDRAW then
                    actions[1] = Action.KONGHU
                end
            else 
                local b, willCards = self:isTing(uid)
                if b then
                    table.insert(actions, Action.TING)
                end
            end
        else 
            local b, willCards = self:isTing(uid)
            if b then 
                table.insert(actions, Action.TING)
            end
        end

        local b, willCards = self:isConcealed(uid)
        if b then
            table.insert(actions, Action.CONCEALED)
        end
        b, willCards = self:isPongkong(uid)
        if b then
            table.insert(actions, Action.PONGKONG)
        end
        table.insert(actions, Action.POP)
    else
        if self.lastAction.action == Action.CHOWKONG or self.lastAction.action == Action.PONGKONG or self.lastAction.action == Action.CONCEALED then
            uid = self.lastAction.uid -- draw after kong
            table.insert(actions, aciton.KONGDRAW)
        else
            uid = self:nextUid(self.lastAction.uid)
            if self:isChowhu(uid) then
                table.insert(actions, Action.CHOWHU)
            end
            local b, willCards = self:isChow(uid)
            if b then
                table.insert(actions, Action.CHOW)
            end
            if self:isPong(uid) then
                table.insert(actions, Action.PONG)
            end
            if self:isChowkong(uid) then
                table.insert(actions, Action.CHOWKONG)
            end
            table.insert(actions, Action.DRAW)
        end
    end
    return uid, actions
end

--机器人下一个动作
function Seat:robotAction( )
    -- body
end

return Seat