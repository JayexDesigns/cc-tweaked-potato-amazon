args = {...}
ReceiverId = tonumber(args[1])
SLOT_COUNT = 16

rednet.open("right")

Prices = {
    ["minecraft:coal"] = 1,
    ["minecraft:iron_ingot"] = 2,
    ["minecraft:diamond"] = 8
}

while true do
    turtle.suckUp()
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
                    potatoes = potatoes + Prices[item["name"]] * item["count"]
                    turtle.dropDown()

                else
                    turtle.dropUp()
                end
            end
        end

        if potatoes ~= 0 then
            rednet.send(ReceiverId, potatoes, "givePotatoes")
        end
    end
end