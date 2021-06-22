args = {...}
if not args[1] then
    error("Set the id of the server")
end

ServerId = tonumber(args[1])
SLOT_COUNT = 16

rednet.open("left")



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



rednet.send(ServerId, "", "deployerPing")

while true do
    local id, message, protocol = rednet.receive()
    if protocol == "deploy" then
        local slot = GetItemIndex("computercraft:turtle_normal")
        turtle.select(slot)
        turtle.place()
        slot = GetItemIndex("minecraft:coal")
        turtle.select(slot)
        turtle.drop()
        local drone = peripheral.wrap("front")
        drone.turnOn()
        sleep(1)
        local droneId = drone.getID()
        sleep(1)
        rednet.send(droneId, message, "droneStart")

    elseif protocol == "droneEnd" then
        turtle.dig()
    end
end