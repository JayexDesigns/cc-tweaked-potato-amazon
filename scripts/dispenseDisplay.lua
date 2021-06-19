rednet.open("bottom")

Display = peripheral.wrap("top")

DisplayWidth, DisplayHeight = Display.getSize()



function PrintPrices()
    Display.clear()
    Display.setTextScale(1)

    local prices = {
        ["1"] = {
            ["price"] = 1,
            ["display"] = "Iron Ingots",
            ["color"] = "8"
        },
        ["2"] = {
            ["price"] = 10,
            ["display"] = "Iron Blocks",
            ["color"] = "8"
        },
        ["3"] = {
            ["price"] = 14,
            ["display"] = "Diamonds",
            ["color"] = "3"
        },
        ["4"] = {
            ["price"] = 144,
            ["display"] = "Netherite Scrap",
            ["color"] = "e"
        }
    }

    Display.setCursorPos(2,2)
    local text = "Potato Prices"
    Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))
    Display.setCursorPos(1,3)
    Display.blit(string.rep("-", DisplayWidth), string.rep("0", DisplayWidth), string.rep("f", DisplayWidth))

    local lowestElementPos = 0

    for key, val in pairs(prices) do
        Display.setCursorPos(2, 4 + tonumber(key) * 2)
        text = val["display"]
        Display.blit(text, string.rep(val["color"], string.len(text)), string.rep("f", string.len(text)))
        text = " " .. string.rep("-", DisplayWidth - 6 - string.len(val["display"]) - string.len(tostring(val["price"]))) .. " "
        Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))
        text = tostring("1:" .. val["price"])
        Display.blit(text, string.rep("1", string.len(text)), string.rep("f", string.len(text)))

        local _, y = Display.getCursorPos()
        if y > lowestElementPos then
            lowestElementPos = y
        end
    end

    Display.setCursorPos(2, lowestElementPos + 3)
    text = "New payment options soon!"
    Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))
    Display.setCursorPos(2, lowestElementPos + 5)
    text = "Prices may change"
    Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))
end


function ProcessingTransaction()
    Display.clear()
    Display.setTextScale(1)

    Display.setCursorPos(1, math.floor(DisplayHeight/2))
    local text = "Please wait for the"
    text = string.rep(" ", (DisplayWidth-string.len(text))/2) .. text
    Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))
    Display.setCursorPos(1, math.floor(DisplayHeight/2)+1)
    text = "transaction to finish"
    text = string.rep(" ", (DisplayWidth-string.len(text))/2) .. text
    Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))
end


function LimitReached(time)
    local resetTime = 1000 * 60 * 5

    local timeLeft = math.floor((resetTime - (os.epoch('utc') - time))/1000)

    while timeLeft > 0 do
        timeLeft = math.floor((resetTime - (os.epoch('utc') - time))/1000)

        Display.clear()
        Display.setTextScale(1)

        Display.setCursorPos(1, math.floor(DisplayHeight/2))
        local text = "Limit reached"
        text = string.rep(" ", (DisplayWidth-string.len(text))/2) .. text
        Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))
        Display.setCursorPos(1, math.floor(DisplayHeight/2)+1)
        text = "Wait " .. timeLeft .. " more seconds"
        text = string.rep(" ", (DisplayWidth-string.len(text))/2) .. text
        Display.blit(text, string.rep("0", string.len(text)), string.rep("f", string.len(text)))
        sleep(0.2)
    end
end



PrintPrices()

while true do
    local id, message, protocol = rednet.receive()
    if protocol == "printPrices" then
        PrintPrices()
    elseif protocol == "processingTransaction" then
        ProcessingTransaction()
    elseif protocol == "limitReached" then
        LimitReached(message)
    end
end