TotalPotatoes = 0

rednet.open("left")



function potatoQuantity(potatoes)
    TotalPotatoes = potatoes
    print("Total potatoes updated: ".. TotalPotatoes)
end


while (true) do
    local id, message, protocol = rednet.receive()
    if (protocol == "potatoQuantity") then
        TotalPotatoes = message
        print("Total potatoes updated: ".. TotalPotatoes)
    end
end