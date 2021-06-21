rednet.open("right")

SLOT_COUNT = 16
SendersId = nil

Prices = {
    ["minecraft:iron_ingot"] = 1,
    ["minecraft:iron_block"] = 10,
    ["minecraft:diamond"] = 14,
    ["minecraft:netherite_scrap"] = 144
}



while true do
    local function suckItems()
        while true do
            if SendersId then
                if turtle.suckUp() then
                    local balance = 0
                    for i = 1, SLOT_COUNT, 1 do
                        turtle.select(i)
                        local item = turtle.getItemDetail()

                        if item then
                            if Prices[item["name"]] then
                                balance = balance + Prices[item["name"]] * item["count"]
                                turtle.dropDown()

                            else
                                turtle.dropUp()
                            end
                        end
                    end
                    turtle.select(1)
                    rednet.send(SendersId, balance, "balanceUpdate")
                end
            end

            sleep(0.2)
        end
    end

    local function waitForRequests()
        while true do
            local id, message, protocol = rednet.receive()
            if protocol == "userLogged" then
                if not message then
                    SendersId = nil
                elseif message then
                    SendersId = id
                end
            end
        end
    end

    parallel.waitForAny(suckItems, waitForRequests)
end