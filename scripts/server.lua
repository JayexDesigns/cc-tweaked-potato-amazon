TotalPotatoes = 0

rednet.open("left")



DBName = ""

function CreateDatabase(dbName)
    DBName = dbName
    if not fs.exists(dbName) then
        local db = fs.open(dbName, "w")
        db.close()
    end
end

function GetUserTable()
    local db = fs.open(DBName, "r")
    local dbData = db.readAll()
    local users = {}
    for userData in string.gmatch(dbData, "([^\n]+)") do
        for u, p, b in string.gmatch(userData, "(%w+)%s(%w+)%s(%w+)") do
            users[u] = {
                ["password"] = p,
                ["balance"] = b
            }
        end
    end
    db.close()
    return users
end

function Register(username, password)
    if GetBalance(username) then
        return false
    else
        local db = fs.open(DBName, "a")
        db.writeLine(username .. " " .. password .. " " .. "0")
        db.close()
        return true
    end
end

function Login(username, password)
    local users = GetUserTable()
    for k, v in pairs(users) do
        if k == username and v["password"] == password then
            return true
        end
    end
    return false
end

function GetBalance(username)
    local users = GetUserTable()
    for k, v in pairs(users) do
        if k == username then
            return v["balance"]
        end
    end
    return nil
end

function ChangeBalance(username, balance)
    local users = GetUserTable()
    users[username]["balance"] = tostring(balance)
    local dbData = ""
    for k, v in pairs(users) do
        dbData = dbData .. k .. " " .. v["password"] .. " " .. v["balance"] .. "\n"
    end
    local db = fs.open(DBName, "w")
    db.write(dbData)
    db.close()
end



function RegisterRequest(id, message)
    local username
    local password
    for u, p in string.gmatch(message, "(%w+)%s(%w+)") do
        username = u
        password = p
    end
    print("Got a register request from " .. username)
    sleep(0.2)
    rednet.send(id, Register(username, password), "registerRequest")
end

function LoginRequest(id, message)
    local username
    local password
    for u, p in string.gmatch(message, "(%w+)%s(%w+)") do
        username = u
        password = p
    end
    sleep(0.2)
    rednet.send(id, Login(username, password), "loginRequest")
end

function GetBalanceRequest(id, message)
    sleep(0.2)
    rednet.send(id, GetBalance(message), "getBalanceRequest")
end

function AddBalance(id, message)
    local username
    local quantity
    for u, q in string.gmatch(message, "(%w+)%s(%w+)") do
        username = u
        quantity = tonumber(q)
    end
    local balance = GetBalance(username)
    sleep(0.2)
    print("Adding " .. quantity .. " potato coins to " .. username)
    ChangeBalance(username, balance + quantity)
    rednet.send(id, true, "addBalance")
end

function SubstractBalance(id, message)
    local username
    local quantity
    for u, q in string.gmatch(message, "(%w+)%s(%w+)") do
        username = u
        quantity = tonumber(q)
    end
    local balance = GetBalance(username)
    sleep(0.2)
    if tonumber(balance) < quantity then
        rednet.send(id, false, "substractBalance")
    else
        print("Substracting " .. quantity .. " potato coins to " .. username)
        ChangeBalance(username, balance - quantity)
        rednet.send(id, true, "substractBalance")
    end
end


function PotatoQuantity(id, potatoes)
    TotalPotatoes = potatoes
    print("Total potatoes updated: " .. TotalPotatoes)
end

function GivePotatoes(id, potatoes)
    print("Vending machine giving away " .. potatoes .. " potatoes")
end


Clients = {}

function ClientLogin(id, data)
    local username, password
    for u, p in string.gmatch(data, "(%w+)%s(%w+)") do
        username = u
        password = p
    end
    if Login(username, password) then
        Clients[tostring(id)] = {
            ["username"] = username,
            ["password"] = password
        }
    end
end

function ClientLocation(id, location)
    local function stringSplit(input, sep)
        if sep == nil then
            sep = "%s"
        end
        local t={}
        for str in string.gmatch(input, "([^"..sep.."]+)") do
            table.insert(t, str)
        end
        return t
    end

    location = stringSplit(location)
    if Clients[tostring(id)] then
        Clients[tostring(id)]["x"] = location[1]
        Clients[tostring(id)]["y"] = location[2]
        Clients[tostring(id)]["z"] = location[3]
    end
end

function RequestPotatoes(id, quantity)
    quantity = tonumber(quantity)
    local client = Clients[tostring(id)]
    if client and client["username"] and client["password"] and client["x"] and client["y"] and client["z"] and quantity then
        local balance = GetBalance(client["username"])
        if tonumber(balance) >= quantity then
            ChangeBalance(client["username"], balance - quantity)
        else
            return false
        end
        if DeployerId then
            rednet.send(DeployerId, client["x"] .. " " .. client["y"] .. " " .. client["z"] .. " " .. quantity, "deploy")
            print("Sending " .. quantity .. " potatoes to " .. client["username"] .. " in " .. client["x"] .. " " .. client["y"] .. " " .. client["z"])
        end
    end
end



DeployerId = nil

function DeployerPing(id, message)
    DeployerId = tonumber(id)
end



Protocols = {
    ["registerRequest"] = RegisterRequest,
    ["loginRequest"] = LoginRequest,
    ["getBalanceRequest"] = GetBalanceRequest,
    ["addBalance"] = AddBalance,
    ["substractBalance"] = SubstractBalance,
    ["potatoQuantity"] = PotatoQuantity,
    ["givePotatoes"] = GivePotatoes,
    ["clientLogin"] = ClientLogin,
    ["clientLocation"] = ClientLocation,
    ["requestPotatoes"] = RequestPotatoes,
    ["deployerPing"] = DeployerPing
}



CreateDatabase("database")

while true do
    local id, message, protocol = rednet.receive()
    Protocols[protocol](id, message)
end