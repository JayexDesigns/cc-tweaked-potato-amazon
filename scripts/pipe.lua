args = {...}
SLOT_COUNT = 16
Directions = {
    ["potatoDirection"] = args[1],
    ["moneyDirection"] = args[2]
}
TurtleDirections = {
    ["f"] = turtle.drop,
    ["u"] = turtle.dropUp,
    ["d"] = turtle.dropDown
}
if not Directions["potatoDirection"] then
    error("Set the direction of the baked potatos (f)ront, (u)p or (d)own")
end



while true do
    sleep(0.1)
    for i = 1, SLOT_COUNT, 1 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        if item ~= nil then
            if item["name"] == "minecraft:baked_potato" then
                TurtleDirections[Directions["potatoDirection"]]()
            else
                TurtleDirections[Directions["moneyDirection"]]()
            end
        end
    end
end