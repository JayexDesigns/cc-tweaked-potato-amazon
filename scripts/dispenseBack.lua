rednet.open("right")

function SuckUp(quantity)
    while true do
        if turtle.suckUp(quantity) then
            return
        end
    end
end

while true do
    local id, message, protocol = rednet.receive()
    if protocol == "givePotatoes" then
        print("Giving away ".. message.. " potatoes")
        for i = 1, math.floor(message / 64) do
            turtle.suckUp(64)
            turtle.dropDown()
        end

        turtle.suckUp(message % 64)
        turtle.dropDown()

        rednet.send(id, "done")
    end
end