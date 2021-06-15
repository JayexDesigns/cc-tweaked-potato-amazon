TotalPotatoes = 0

rednet.open("left")



function PotatoQuantity(id, potatoes)
    TotalPotatoes = potatoes
    print("Total potatoes updated: ".. TotalPotatoes)
end


Protocols = {
    ["potatoQuantity"] = PotatoQuantity
}


while true do
    local id, message, protocol = rednet.receive()
    Protocols[protocol](id, message)
end