args = {...}
if not args[1] or not args[2] then
    error("Set the id of the server and the receiver")
end
ServerId = tonumber(args[1])
ReceiverId = tonumber(args[2])

rednet.open("bottom")

Display = peripheral.wrap("top")

DisplayWidth, DisplayHeight = Display.getSize()


CurrentAccount = nil



function DrawButton(xPos, yPos, text, color, bgColor)
    Display.setCursorPos(xPos, yPos)
    local row = "\x81" .. string.rep("\x80", DisplayWidth-4) .. "\x82"
    Display.blit(row, bgColor .. string.rep(bgColor, string.len(row)-2) .. bgColor, color .. string.rep(color, string.len(row)-2) .. color)
    Display.setCursorPos(xPos, yPos+1)
    Display.blit(string.rep("\x80", DisplayWidth-2), string.rep(bgColor, DisplayWidth-2), string.rep(color, DisplayWidth-2))
    Display.setCursorPos(xPos, yPos+2)
    row = "\x90" .. string.rep("\x80", DisplayWidth-4) .. "\x9f"
    Display.blit(row, bgColor .. string.rep(bgColor, string.len(row)-2) .. color, color .. string.rep(color, string.len(row)-2) .. bgColor)
    Display.setCursorPos((DisplayWidth - string.len(text))/2+1, yPos+1)
    Display.blit(text, string.rep(bgColor, string.len(text)), string.rep(color, string.len(text)))
    return xPos, yPos+2
end

function DrawKeyboard()
    local text = ""
    Display.setCursorPos(1, DisplayHeight-8)
    Display.blit(string.rep("-", DisplayWidth), string.rep("0", DisplayWidth), string.rep("f", DisplayWidth))
    Display.setCursorPos(1, DisplayHeight-7)
    text = "q w e r t y u i o p"
    text = string.rep(" ", math.floor((DisplayWidth - string.len(text))/2)) .. text
    Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))

    Display.setCursorPos(1, DisplayHeight-5)
    text = "a s d f g h j k l"
    text = string.rep(" ", math.floor((DisplayWidth - string.len(text))/2)) .. text
    Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))

    Display.setCursorPos(1, DisplayHeight-3)
    text = "z x c v b n m"
    text = string.rep(" ", math.floor((DisplayWidth - string.len(text))/2)) .. text
    Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))

    Display.setCursorPos(1, DisplayHeight-1)
    text = "back up down send"
    text = string.rep(" ", math.floor((DisplayWidth - string.len(text))/2)) .. text
    Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))
end

function GetKeyboardPress()
    local _, _, x, y = os.pullEvent("monitor_touch")

    local keys = {
        ["q"] = {
            x = 6,
            y = 12
        },
        ["w"] = {
            x = 8,
            y = 12
        },
        ["e"] = {
            x = 10,
            y = 12
        },
        ["r"] = {
            x = 12,
            y = 12
        },
        ["t"] = {
            x = 14,
            y = 12
        },
        ["y"] = {
            x = 16,
            y = 12
        },
        ["u"] = {
            x = 18,
            y = 12
        },
        ["i"] = {
            x = 20,
            y = 12
        },
        ["o"] = {
            x = 22,
            y = 12
        },
        ["p"] = {
            x = 24,
            y = 12
        },
        ["a"] = {
            x = 7,
            y = 14
        },
        ["s"] = {
            x = 9,
            y = 14
        },
        ["d"] = {
            x = 11,
            y = 14
        },
        ["f"] = {
            x = 13,
            y = 14
        },
        ["g"] = {
            x = 15,
            y = 14
        },
        ["h"] = {
            x = 17,
            y = 14
        },
        ["j"] = {
            x = 19,
            y = 14
        },
        ["k"] = {
            x = 21,
            y = 14
        },
        ["l"] = {
            x = 23,
            y = 14
        },
        ["z"] = {
            x = 9,
            y = 16
        },
        ["x"] = {
            x = 11,
            y = 16
        },
        ["c"] = {
            x = 13,
            y = 16
        },
        ["v"] = {
            x = 15,
            y = 16
        },
        ["b"] = {
            x = 17,
            y = 16
        },
        ["n"] = {
            x = 19,
            y = 16
        },
        ["m"] = {
            x = 21,
            y = 16
        },
        ["back"] = {
            x1 = 7,
            x2 = 10,
            y = 18
        },
        ["up"] = {
            x1 = 12,
            x2 = 13,
            y = 18
        },
        ["down"] = {
            x1 = 15,
            x2 = 18,
            y = 18
        },
        ["send"] = {
            x1 = 20,
            x2 = 23,
            y = 18
        }
    }

    for k, v in pairs(keys) do
        if type(v["x"]) == "number" and v["x"] == x and v["y"] == y then
            return k
        elseif type(v["x"]) == "nil" and v["x1"] <= x and v["x2"] >= x and v["y"] == y then
            return k
        end
    end
    return nil, x, y
end



function PrintMainScreen()
    Display.setCursorBlink(false)
    Display.setTextScale(1)
    Display.clear()

    Display.setCursorPos(2, 2)
    local text = "Add Potato Coins"
    Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))
    Display.setCursorPos(1, 3)
    Display.blit(string.rep("-", DisplayWidth), string.rep("0", DisplayWidth), string.rep("f", DisplayWidth))

    local xPos, yPos = DrawButton(2, 7, "Register", "4", "f")
    xPos, yPos = DrawButton(xPos, yPos+2, "Login", "0", "f")

    Display.setCursorPos(xPos, DisplayHeight)
    text = "No refunds"
    Display.blit(text, string.rep("7", string.len(text)), string.rep("f", string.len(text)))

    while true do
        Display.setCursorBlink(false)
        local _, _, x, y = os.pullEvent("monitor_touch")
        if x >= 2 and x <= 28 and y >= 7 and y <= 9 then
            local username, password = PrintFormScreen()
            if username == nil then
                break
            end
            rednet.send(ServerId, username .. " " .. password, "registerRequest")
            local id, message, protocol = rednet.receive()
            if message and protocol == "registerRequest" then
                PrintLoggedScreen(username)
                break
            elseif not message and protocol == "registerRequest" then
                break
            end

        elseif x >= 2 and x <= 28 and y >= 11 and y <= 13 then
            local username, password = PrintFormScreen()
            if username == nil then
                break
            end
            rednet.send(ServerId, username .. " " .. password, "loginRequest")
            local id, message, protocol = rednet.receive()
            if message and protocol == "loginRequest" then
                PrintLoggedScreen(username)
                break
            elseif not message and protocol == "loginRequest" then
                break
            end
        end
    end
end

function PrintFormScreen()
    Display.clear()

    DrawKeyboard()

    local text = "Return"
    Display.setCursorPos(DisplayWidth - string.len(text), 1)
    Display.blit(text, string.rep("4", string.len(text)), string.rep("f", string.len(text)))

    Display.setCursorPos(2, 3)
    Display.blit(string.rep("\x80", DisplayWidth-2), string.rep("f", DisplayWidth-2), string.rep("0", DisplayWidth-2))
    Display.setCursorPos(2, 5)
    Display.blit(string.rep("\x80", DisplayWidth-2), string.rep("f", DisplayWidth-2), string.rep("0", DisplayWidth-2))

    local username = ""
    local password = ""

    Display.setCursorBlink(true)
    Display.setCursorPos(2, 3)

    while true do
        local key, x, y = GetKeyboardPress()
        if key == nil then
            if x >= DisplayWidth - string.len(text) and x <= DisplayWidth and y == 1 then
                return nil
            end
        elseif string.len(key) == 1 then
            local _, cy = Display.getCursorPos()
            if cy == 3 and string.len(username) < DisplayWidth-2 then
                username = username .. key
            elseif cy == 5 and string.len(password) < DisplayWidth-2 then
                password = password .. key
            end
        elseif key == "back" then
            local _, cy = Display.getCursorPos()
            if cy == 3 then
                username = string.sub(username, 1, string.len(username)-1)
            elseif cy == 5 then
                password = string.sub(password, 1, string.len(password)-1)
            end
        elseif key == "up" then
            Display.setCursorPos(2, 3)
        elseif key == "down" then
            Display.setCursorPos(2, 5)
        elseif key == "send" then
            return username, password
        end

        local _, cy = Display.getCursorPos()
        Display.setCursorPos(2, 3)
        Display.blit(
            username .. string.rep("\x80", DisplayWidth-2-string.len(username)),
            string.rep("0", string.len(username)) .. string.rep("f", DisplayWidth-2-string.len(username)),
            string.rep("f", string.len(username)) .. string.rep("0", DisplayWidth-2-string.len(username))
        )
        Display.setCursorPos(2, 5)
        Display.blit(
            string.rep("*", string.len(password)) .. string.rep("\x80", DisplayWidth-2-string.len(password)),
            string.rep("0", string.len(password)) .. string.rep("f", DisplayWidth-2-string.len(password)),
            string.rep("f", string.len(password)) .. string.rep("0", DisplayWidth-2-string.len(password))
        )
        if cy == 3 then
            Display.setCursorPos(math.max(string.len(username)+1, 2), cy)
        elseif cy == 5 then
            Display.setCursorPos(math.max(string.len(password)+1, 2), cy)
        end
    end
end

function PrintLoggedScreen(username, balance)
    if balance == nil then
        balance = 0
        rednet.send(ServerId, username, "getBalanceRequest")
        local id, message, protocol = rednet.receive()
        if protocol == "getBalanceRequest" then
            balance = message
        end
    end

    rednet.send(ReceiverId, true, "userLogged")

    Display.setCursorBlink(false)
    Display.clear()

    Display.setCursorPos(2, 2)
    local text = "Logged in as"
    Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))
    Display.setCursorPos(2,3)
    Display.blit(username, string.rep("0", string.len(username)), string.rep("f", string.len(username)))
    Display.setCursorPos(1,4)
    Display.blit(string.rep("-", DisplayWidth), string.rep("0", DisplayWidth), string.rep("f", DisplayWidth))

    text = "You have " .. tostring(balance) .. " potato coins"
    Display.setCursorPos(math.floor((DisplayWidth - string.len(text))/2)+1,7)
    Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))
    text = "Throw materials supported"
    Display.setCursorPos(math.floor((DisplayWidth - string.len(text))/2)+1,9)
    Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))
    text = "in exchange for potato coins"
    Display.setCursorPos(math.floor((DisplayWidth - string.len(text))/2)+1,10)
    Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))

    DrawButton(2, 14, "Done", "0", "f")

    local ended = false
    local function waitForButtonPress()
        while true do
            local _, _, x, y = os.pullEvent("monitor_touch")
            if x >= 2 and x <= 28 and y >= 14 and y <= 16 then
                ended = true
                rednet.send(ReceiverId, false, "userLogged")
                break
            end
        end
    end

    local function waitForBalanceUpdate()
        while true do
            local id, message, protocol = rednet.receive()
            if protocol == "balanceUpdate" then
                rednet.send(ServerId, username .. " " .. message, "addBalance")
                balance = balance + message
                break
            end
        end
    end

    parallel.waitForAny(waitForButtonPress, waitForBalanceUpdate)
    if ended == true then
        return
    else
        PrintLoggedScreen(username, balance)
    end
end



while true do
    PrintMainScreen()
end