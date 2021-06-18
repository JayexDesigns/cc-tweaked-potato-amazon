args = {...}
if not args[1] then
    error("Set the id of the server")
end
ServerId = tonumber(args[1])
rednet.open("right")

function SuckUp(quantity)
    while true do
        if turtle.suckUp(quantity) then
            if turtle.getItemCount() == quantity then
                turtle.dropDown()
                return
            else
                quantity = quantity - turtle.getItemCount()
            end
        end
        print("Ran out of potatoes waiting...")
        sleep(5)
    end
end

while true do
    local id, message, protocol = rednet.receive()
    if protocol == "givePotatoes" then
        rednet.send(ServerId, message, "givePotatoes")
        print("Giving away ".. message.. " potatoes")
        for i = 1, math.floor(message / 64) do
            SuckUp(64)
        end

        SuckUp(message % 64)

        rednet.send(id, "done")
    end
end