ESX = exports["es_extended"]:getSharedObject()
local webhook = 'https://discord.com/api/webhooks/1205477821343072267/DVeflYCEJ4CJTnuN6jTw4iByv_c6xVMqVv2mZQq2ZRnH65qZQevt8YRuMO3S9IiANf1D'

ESX.RegisterServerCallback('Dezzu_houserobbery:checkitem', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        if xPlayer.getInventoryItem('lockpick').count > 0 then
            TriggerClientEvent('Dezzu_houserobbery:teleport', source)
            sendLog(webhook, 3066993, 'Powiadomienie', ESX.GetPlayerFromId(source).GetPlayerName(source)..' ('..GetPlayerIdentifiers(source)[1]..') rozpoczął napad ')
            cb(true)
        else
            xPlayer.showNotification('Brakuje Ci wytrychu!')
            cb(false)
        end
    end
end)

function sendLog(webhook, color, name, message)
    local currentDate = os.date("%Y-%m-%d")
    local currentTime = os.date("%H:%M:%S")
    local embed = {
        {
            ["color"] = color,
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
            ["text"] = currentTime.." "..currentDate,
            },
        }
    }

    PerformHttpRequest(webhook, function(err, text, headers) 
    end, 'POST', json.encode({embeds = embed}), { ['Content-Type'] = 'application/json' })
end
