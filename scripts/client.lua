args = {...}
if not args[1] or not args[2] or not args[3] or not args[4] then
    error("Set the id of the server, your username, your password and the quantity of potatoes you want to request")
end

ServerId = tonumber(args[1])
Username = args[2]
Password = args[3]
PotatoQuantity = tonumber(args[4])

rednet.open("left")



function SendLogin()
    rednet.send(ServerId, Username .. " " .. Password, "clientLogin")
end

function SendLocation()
    local x, y, z = gps.locate()
    rednet.send(ServerId, x .. " " .. y .. " " .. z, "clientLocation")
end

function RequestPotatoes()
    SendLogin()
    SendLocation()
    rednet.send(ServerId, PotatoQuantity, "requestPotatoes")
end



RequestPotatoes()