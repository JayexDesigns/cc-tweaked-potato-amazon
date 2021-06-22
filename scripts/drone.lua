rednet.open("right")

DeliverHeight = 85
ReturnHeight = 86
Direction = nil
StartDirection = nil
SLOT_COUNT = 16



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

function StringSplit(input, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(input, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
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
    return nil
end

function LookAt(direction)
    local directions = {
        [1] = "north",
        [2] = "east",
        [3] = "south",
        [4] = "west",
    }
    local currentDirection
    for k, v in pairs(directions) do
        if Direction == v then
            currentDirection = k
        end
    end
    while directions[currentDirection] ~= direction do
        currentDirection = currentDirection + 1
        turtle.turnRight()
        if currentDirection > 4 then
            currentDirection = 1
        end
    end
    Direction = directions[currentDirection]
end



local id, message, protocol = rednet.receive()
if protocol == "droneStart" then
    local function repeatAction(action, times)
        for i = 1, times, 1 do
            action()
        end
    end

    if not CheckFuel() then
        rednet.send(id, "", "droneEnd")
    else
        local data = StringSplit(message)
        local x = tonumber(data[1])
        local y = tonumber(data[2])
        local z = tonumber(data[3])
        local quantity = tonumber(data[4])

        repeatAction(turtle.up, 6)
        repeatAction(turtle.turnRight, 2)

        local startX, _, startZ = gps.locate()
        turtle.forward()
        local endX, _, endZ = gps.locate()
        if startX > endX then
            Direction = "south"
            StartDirection = "south"
        elseif startX < endX then
            Direction = "north"
            StartDirection = "north"
        elseif startZ > endZ then
            Direction = "west"
            StartDirection = "west"
        elseif startZ < endZ then
            Direction = "east"
            StartDirection = "east"
        end

        turtle.turnLeft()
        repeatAction(turtle.forward, 5)
        turtle.turnLeft()
        for i = 1, math.floor(quantity / 64) do
            turtle.suck(64)
        end
        turtle.suck(quantity % 64)
        turtle.turnLeft()
        repeatAction(turtle.forward, 2)
        turtle.turnRight()
        turtle.forward()
        turtle.turnLeft()
        repeatAction(turtle.forward, 3)
        repeatAction(turtle.up, 4)
        repeatAction(turtle.forward, 2)

        local currentX, currentY, currentZ = gps.locate()
        repeatAction(turtle.up, DeliverHeight - currentY)
        if currentX > x then
            LookAt("east")
        elseif currentX < x then
            LookAt("west")
        end
        repeatAction(turtle.forward, math.abs(currentX - x))
        if currentZ > z then
            LookAt("south")
        elseif currentZ < z then
            LookAt("north")
        end
        repeatAction(turtle.forward, math.abs(currentZ - z))

        local steps = 0
        while not turtle.detectDown() do
            turtle.down()
            steps = steps + 1
        end
        while true do
            local slot = GetItemIndex("minecraft:baked_potato")
            if slot then
                turtle.select(slot)
                turtle.drop()
            else
                break
            end
        end

        repeatAction(turtle.up, steps + 1)
        if currentX > x then
            LookAt("west")
        elseif currentX < x then
            LookAt("east")
        end
        repeatAction(turtle.forward, math.abs(currentX - x))
        if currentZ > z then
            LookAt("north")
        elseif currentZ < z then
            LookAt("south")
        end
        repeatAction(turtle.forward, math.abs(currentZ - z))

        repeatAction(turtle.down, ReturnHeight - currentY)

        LookAt(StartDirection)
        repeatAction(turtle.turnLeft, 2)

        repeatAction(turtle.forward, 2)
        repeatAction(turtle.down, 10)

        rednet.send(id, "", "droneEnd")
    end
end