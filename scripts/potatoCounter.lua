ServerId = 14
PreviousPotatoQuantity = 0
PotatoQuantity = 0
Chest = peripheral.find("minecraft:chest")
rednet.open("right")

while true do
    PotatoQuantity = 0
    local items = Chest.list()
    for slot, item in pairs(items) do
        PotatoQuantity = PotatoQuantity + item.count
    end
    if (PreviousPotatoQuantity ~= PotatoQuantity) then
        rednet.send(ServerId, PotatoQuantity, "potatoQuantity")
    end
    PreviousPotatoQuantity = PotatoQuantity
    sleep(5)
end