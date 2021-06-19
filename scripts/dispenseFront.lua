args = {...}
if not args[1] or not args[2] then
    error("Set the id of the receiver and the display controller")
end
ReceiverId = tonumber(args[1])
DisplayId = tonumber(args[2])
SLOT_COUNT = 16

rednet.open("right")

Prices = {
    ["minecraft:iron_ingot"] = 1,
    ["minecraft:iron_block"] = 10,
    ["minecraft:diamond"] = 14,
    ["minecraft:netherite_scrap"] = 144
}



StartTime = os.epoch('utc')
ResetTime = 1000 * 60 * 5

CurrentPaid = 0
PayLimit = 420

function CheckTime()
    local time = os.epoch('utc')
    if time - StartTime >= ResetTime then
        StartTime = os.epoch('utc')
        CurrentPaid = 0
    end
end



LimitReached = false

while true do
    rednet.send(DisplayId, "", "printPrices")

    CheckTime()
    if CurrentPaid >= PayLimit then
        if not LimitReached then
            rednet.send(DisplayId, StartTime, "limitReached")
            LimitReached = true
        end
    else
        LimitReached = false
        turtle.suckUp()
    end

    local itemsCount = 0
    for i = 1, SLOT_COUNT, 1 do
        itemsCount = itemsCount + turtle.getItemCount(i)
    end

    if itemsCount > 0 then
        local potatoes = 0

        for i = 1, SLOT_COUNT, 1 do
            turtle.select(i)
            local item = turtle.getItemDetail()

            if item then
                if Prices[item["name"]] then
                    rednet.send(DisplayId, "", "processingTransaction")
                    potatoes = potatoes + Prices[item["name"]] * item["count"]
                    turtle.dropDown()

                else
                    turtle.dropUp()
                end
            end
        end
        turtle.select(1)

        if potatoes ~= 0 then
            CurrentPaid = potatoes
            rednet.send(ReceiverId, potatoes, "givePotatoes")
            local id, message = rednet.receive()
        end
    end

    sleep(0.2)
end