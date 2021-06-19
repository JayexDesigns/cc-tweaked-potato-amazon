TotalPotatoes = 0

rednet.open("left")



function PotatoQuantity(id, potatoes)
    TotalPotatoes = potatoes
    print("Total potatoes updated: " .. TotalPotatoes)
end

function GivePotatoes(id, potatoes)
    print("Vending machine giving away " .. potatoes .. " potatoes")
end


Protocols = {
    ["potatoQuantity"] = PotatoQuantity,
    ["givePotatoes"] = GivePotatoes
}


while true do
    local id, message, protocol = rednet.receive()
    Protocols[protocol](id, message)
end