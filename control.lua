local Seat = require "seat"
local Action = require "action"
local print_r = require "print_r"

local Control = {
    seat = {}
}

function Control:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.seat = Seat:new()
    return o
end

function Control:shuffle()
    self.seat:shuffle()
end

function Control:preAction(actions)
    local second = {}
    local first
    local third
    for k, v in ipairs(actions) do
        if v == Action.DRAWHU or v == Action.CHOWHU or v == Action.KONGHU or v == Action.TING then
            first = v
        elseif v == Action.DRAW or v == Action.POP or v == Action.KONGDRAW then
            third = v
        else 
            table.insert(second, v)
        end
    end
    return first, second, third
end

function Control:first( uid, first, second, third)
    if first == Action.DRAWHU then
        print("select draw hu (1) or not (0) :")
        local s = io.read("*number")
        if s == 1 then
            self.seat:drawhu(uid)
            os.exit(0)
        end
    elseif first == Action.KONGHU then
        print("select kong hu (1) or not (0) :")
        local s = io.read("*number")
        if s == 1 then
            self.seat:konghu(uid)
            os.exit(0)
        end
    elseif first == Action.CHOWHU then
        print("select chow hu (1) or not (0) :")
        local s = io.read("*number")
        if s == 1 then
            self.seat:chowhu(uid)
            os.exit(0)
        end
    elseif first == Action.TING then
        print("select ting (1) or not (0) :")
        local s = io.read("*number")
        if s == 1 then
            local b , willCards = self.seat:isTing(uid)
            print_r(willCards)
            print("select pop card:")
            local s = io.read("*number")
            self.seat:ting(uid, s, willCards[s]) 
            return
        end
    end
    if next(second) then
        self:second(uid, second, third)
    else 
        self:third(uid, third)
    end
end

function Control:second(uid, second, third)
    print('second choice:')
    print_r(second)
    local action = io.read("*number")
    if action == Action.CONCEALED then
        print("select concealed (1) not (0) ")
        local s = io.read("*number")
        if s == 1 then        
            local b , willCards = self.seat:isConcealed(uid)
            print("select concealed : ")
            print_r(willCards)
            local s = io.read("*number")
            self.seat:concealed(uid, s)
            return
        end
    elseif action == Action.PONGKONG then
        print("select pongkong (1) not (0) ")
        local s = io.read("*number")
        if s == 1 then
            local b , willCards = self.seat.isPongkong(uid)
            print("select pongkong: ")
            print_r(willCards)
            local s = io.read("*number")
            self.seat:pongkong(uid, s)
            return
        end
    elseif action == Action.PONG then
        print("select pong (1) not (0)")
        local s = io.read("*number")
        if s == 1 then
            self.seat:pong(uid)
            return
        end
    elseif action == Action.CHOW then
        print("select chow (1) not (0)")
        local s = io.read("*number")
        if s == 1 then        
            local b, willCards = self.seat:isChow(uid)
            print("uid", uid, "select chow:")
            print_r(willCards)
            local s = io.read("*number")
            self.seat:chow(uid, willCards[s])
            return
        end
    elseif action == Action.CHOWKONG then
        print("select chowkong (1) not (0)")
        local s = io.read("*number")
        if s == 1 then
            self.seat:chowkong(uid)
            return
        end
    end
    self:third(uid, third)
end

function Control:third(uid,  third)
    print("uid ", uid, "action", third, Action.POP)
    if third == Action.DRAW then
        print("uid ", uid, "want draw card")
        local s = io.read("*number")
        self.seat:draw(uid, s)
    elseif third == Action.POP then
        print("uid", uid, "want pop card")
        local s = io.read("*number")
        self.seat:pop(uid, s)
    else
        os.exit(0)
    end
end

function Control:run()
    self.seat:show()
    local uid, actions = self.seat:nextAction()
    print("uid ", uid, "actions")
    print_r(actions)
    local first, second, third = self:preAction(actions)
    self:first(uid, first, second, third)
    self:run() -- run forever
end

local ctrl = Control:new()
ctrl:shuffle()
ctrl:run()

return Control