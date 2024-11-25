ESX = exports["es_extended"]:getSharedObject()

local webhook = Config.webhook
local shopCooldowns = {}
local valueCooldowns = {}

local function getShopKey(coords)
    if coords then
        return string.format("%.2f_%.2f_%.2f", coords.x, coords.y, coords.z)
    else
        return nil
    end
end


RegisterNetEvent('Dezzu_shoprobbery:ban')
AddEventHandler('Dezzu_shoprobbery:ban', function()
    local source = source
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local withinTarget = false
    local targetCoords = nil

    for i = 1, #Config.shops.shop do
        local shopCoords = Config.shops.shop[i]
        local distance = #(playerCoords - shopCoords)
        if distance < 4.5 then
            withinTarget = true
            targetCoords = shopCoords
            break
        end
    end

    if withinTarget then
        
        TriggerEvent('Dezzu_shoprobbery:checkCooldown', targetCoords, 'shops', source)
    else
        
        sendLog(webhook, 66666, 'Shoprobbery', '[ID ' .. source .. '] ' .. GetPlayerName(source) .. ' Cheater!!!')
        DropPlayer(source, 'Cheater')
    end
end)


RegisterNetEvent('Dezzu_shoprobbery:checkCooldown')
AddEventHandler('Dezzu_shoprobbery:checkCooldown', function(shopCoords, shopType, source)
    local currentTime = os.time()
    local shopKey = getShopKey(shopCoords)
    local cooldownTime = Config.shops.cooldownTime[shopType] or 5000

    if shopCooldowns[shopKey] and (currentTime - shopCooldowns[shopKey]) < cooldownTime then
        TriggerClientEvent('Dezzu_shoprobbery:notify', source, {
            title = 'Cooldown',
            description = 'Musisz poczekać, zanim ponownie spróbujesz.',
            type = 'error'
        })
        return
    end
    shopCooldowns[shopKey] = currentTime
    TriggerClientEvent('Dezzu_shoprobbery:startRobbery', source, shopCoords, shopType)
end)


RegisterNetEvent('Dezzu_shoprobbery:rob')
AddEventHandler('Dezzu_shoprobbery:rob', function(shopCoords, shopType)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local rewardConfig = Config.shops.reward

    if not rewardConfig then
        print(string.format("[Błąd] Typ sklepu '%s' nie istnieje w konfiguracji!", shopType))
        return
    end

    local money = math.random(rewardConfig['shops']['min'], rewardConfig['shops']['max'])
    local shopKey = getShopKey(shopCoords)
    sendLog(webhook, 66666, 'Shoprobbery', '[ID ' .. source .. '] ' .. GetPlayerName(source) .. ' ukradł ' .. money .. '$ ze sklepu!')
    xPlayer.addInventoryItem('money', money)

    print(string.format("Gracz [%s] okradł sklep [%s] i otrzymał %d$", source, shopKey, money))
end)


RegisterNetEvent('Dezzu_shoprobbery:banValue')
AddEventHandler('Dezzu_shoprobbery:banValue', function()
    local source = source
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local withinTarget = false

    for i = 1, #Config.shops.value do
        local targetCoords = Config.shops.value[i]
        local distance = #(playerCoords - targetCoords)
        if distance < 4.5 then
            withinTarget = true
            TriggerEvent('Dezzu_shoprobbery:checkCooldownValue', source, targetCoords)
            break
        end
    end

    if not withinTarget then
        sendLog(webhook, 66666, 'Shoprobbery', '[ID ' .. source .. '] ' .. GetPlayerName(source) .. ' Cheater!!!')
        DropPlayer(source, 'Cheater')
    end
end)


RegisterNetEvent('Dezzu_shoprobbery:checkCooldownValue')
AddEventHandler('Dezzu_shoprobbery:checkCooldownValue', function(source, targetCoords)
    local currentTime = os.time()

    if valueCooldowns[source] and (currentTime - valueCooldowns[source]) < Config.shops.cooldownTime['value'] then
        TriggerClientEvent('Dezzu_shoprobbery:notify', source, {
            title = 'Cooldown',
            description = 'Musisz poczekać, zanim ponownie spróbujesz.',
            type = 'error'
        })
        return
    end

    valueCooldowns[source] = currentTime
    TriggerEvent('Dezzu_shoprobbery:checkLockpick', source)
end)


RegisterNetEvent('Dezzu_shoprobbery:checkLockpick')
AddEventHandler('Dezzu_shoprobbery:checkLockpick', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        if xPlayer.getInventoryItem('lockpick').count > 0 then
            TriggerClientEvent('Dezzu_minigame:start', source) -- Rozpoczęcie mini-gry
        else
            TriggerClientEvent('Dezzu_shoprobbery:notify', source, {
                title = 'Brak Wytrychu',
                description = 'Brakuje Ci wytrychu!',
                type = 'error'
            })
        end
    end
end)


RegisterNetEvent('Dezzu_shoprobbery:value')
AddEventHandler('Dezzu_shoprobbery:value', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local money = math.random(Config.shops.reward['value']['min'], Config.shops.reward['value']['max'])

    if xPlayer then
        xPlayer.addInventoryItem('money', money)
        sendLog(webhook, 66666, 'Shoprobbery', '[ID ' .. source .. '] ' .. GetPlayerName(source) .. ' ukradł ' .. money .. '$ ze sejfu')
    end
end)






function sendLog(webhook, color, name, message)
    if not webhook or webhook == "" then
        print("^1[BŁĄD] Webhook URL jest pusty lub niepoprawny!^7")
        return
    end
    if not color or not name or not message then
        print("^1[BŁĄD] Nieprawidłowe dane wejściowe do funkcji sendLog!^7")
        return
    end
    local currentDate = os.date("%Y-%m-%d")
    local currentTime = os.date("%H:%M:%S")
    local embed = {
        {
            ["color"] = color,
            ["title"] = "**" .. tostring(name) .. "**",
            ["description"] = tostring(message),
            ["footer"] = {
                ["text"] = currentTime .. " " .. currentDate,
            },
        }
    }
    print("^2[DEBUG] Wysyłanie webhooka: ^7" .. json.encode(embed))
    PerformHttpRequest(webhook, function(err, text, headers)
        if err ~= 200 then
            print("^1[BŁĄD Webhooka] Kod błędu: ^7" .. tostring(err))
            print("^1[DEBUG] Treść odpowiedzi: ^7" .. tostring(text))
        else
            print("^2[SUKCES] Webhook wysłany poprawnie!^7")
        end
    end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end



