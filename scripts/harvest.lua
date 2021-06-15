PotatoesCollected = 0
SLOT_COUNT = 16
NoFuel = false



function CheckFuel()
    if(turtle.getFuelLevel() < 50) then
        for slot = 1, SLOT_COUNT, 1 do
            turtle.select(slot)
            if(turtle.refuel()) then
                NoFuel = false
                return true
            end
        end
        return false
    else
        NoFuel = false
        return true
    end
end

function GetItemIndex(itemName)
    for slot = 1, SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            if(item["name"] == itemName) then
                return slot
            end
        end
    end
end



function DropPotatoes(potatoIndex)
    local numPotatoes = turtle.getItemCount(potatoIndex) - 1

    if numPotatoes > 0 then
        turtle.select(potatoIndex)
        turtle.dropDown(numPotatoes)
    end

    potatoIndex = GetItemIndex("minecraft:poisonous_potato")
    if potatoIndex ~= nil then
        turtle.select(potatoIndex)
        turtle.dropDown()
    end

    return numPotatoes
end



function Succ()
    for i = 1, 6, 1 do
        turtle.suck()
    end
end



function CheckGrowth()
    local isBlock, data = turtle.inspect()
    if(isBlock) then
        if (data['state']['age'] == 7) then
            return true
        end
    else
        return false
    end
end



function Harvest()
    local isBlock, data = turtle.inspect()
    if(CheckGrowth()) then
        if (data['state']['age'] == 7) then
            local potatoIndex = GetItemIndex("minecraft:potato")
            turtle.select(potatoIndex)
            turtle.dig()
            turtle.place()
            Succ()

            local numPotatoes = DropPotatoes(potatoIndex)
            PotatoesCollected = PotatoesCollected + numPotatoes
        end
    else
        Succ()
        local potatoIndex = GetItemIndex("minecraft:potato")
        turtle.select(potatoIndex)
        turtle.place()
    end

    Succ()
end

function HarvestRow()
    while true do
        Harvest()
        turtle.turnLeft()
        if (turtle.detect()) then
            turtle.turnLeft()
            return
        else
            turtle.turnLeft()
            Harvest()
            turtle.turnRight()
            turtle.forward()
            turtle.turnRight()
        end
    end
end



function WaitForGrowth()
    while not CheckGrowth() do
        sleep(5)
    end
end





print('Beginning Harvest...')

while true do
    if (not CheckFuel()) then
        if (not NoFuel) then
            print("There is no fuel, I can't continue")
            NoFuel = true
        end
        sleep(2)
    else
        WaitForGrowth()
        HarvestRow()
        print(PotatoesCollected .. ' potatoes harvested')
    end
end