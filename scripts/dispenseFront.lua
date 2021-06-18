args = {...}
if not args[1] then
    error("Set the id of the receiver")
end
ReceiverId = tonumber(args[1])
SLOT_COUNT = 16

rednet.open("right")

Prices = {
    ["minecraft:iron_ingot"] = 1,
    ["minecraft:iron_block"] = 10,
    ["minecraft:diamond"] = 14,
    ["minecraft:netherite_scrap"] = 144
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
            local id, message = rednet.receive()
        end
    end
end