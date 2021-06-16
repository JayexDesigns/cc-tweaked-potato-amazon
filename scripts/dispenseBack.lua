rednet.open("right")

while true do
    local id, message, protocol = rednet.receive()
    if protocol == "givePotatoes" then
        print("Giving away ".. message.. " potatoes")
        for i = 1, math.floor(message / 64) do
            turtle.suckUp()
            turtle.dropDown()
        end

        turtle.suckUp(message % 64)
        turtle.dropDown()
    end
end