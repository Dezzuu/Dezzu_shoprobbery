
ESX = exports["es_extended"]:getSharedObject()

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for k, v in pairs(Config.shops.shop) do
            exports.ox_target:addSphereZone({
                coords = v,
                radius = 0.5,
                debug = true,
                drawSprite = true,
                options = {
                    {
                        name = 'elo zelo',
                        onSelect = function()
                        
                            TriggerServerEvent('Dezzu_shoprobbery:ban')
                        end,
                        icon = 'fa-solid fa-message',
                        label = "Okradnij",
                    },
                }
            })
        end
    end
end)

RegisterNetEvent('Dezzu_shoprobbery:notify')
AddEventHandler('Dezzu_shoprobbery:notify', function(data)
    exports.ox_lib:notify(data)
end)

RegisterNetEvent('Dezzu_shoprobbery:startRobbery')
AddEventHandler('Dezzu_shoprobbery:startRobbery', function(shopCoords, shopType)
    local playerPed = PlayerPedId()
    local hasWeapon = HasPedGotWeapon(playerPed, GetHashKey("weapon_pistol"), false)

    if hasWeapon then
        exports.ox_lib:progressBar({
            duration = 5000,
            label = 'Okradanie', 
            disable = { move = true },
            anim = { dict = 'anim@mp_snowball', clip = 'pickup_snowball' },
        })
        TriggerServerEvent('Dezzu_shoprobbery:rob', shopCoords, shopType)
    else
        exports.ox_lib:notify({
            title = 'Brak Broni',
            description = 'Nie posiadasz broni',
            type = 'error'
        })
    end
end)




local lastRobberyTime = 0 
local lastValueTime = 0 

RegisterCommand('elo', function ()
    TriggerServerEvent('Dezzu_shoprobbery:ban')
    
end)



AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for k, v in pairs(Config.shops.value) do
            exports.ox_target:addSphereZone({
                coords = v,
                radius = 0.5,
                debug = true,
                drawSprite = true,
                options = {
                    {
                        name = 'elo zelo',
                        onSelect = function()
                            TriggerServerEvent('Dezzu_shoprobbery:banValue')
                        end,
                        icon = 'fa-solid fa-message',
                        label = "Okradnij",
                    },
                }
            })
        end
    end
end)


RegisterCommand('elo2', function()
    TriggerServerEvent('Dezzu_shoprobbery:banValue')
end)


RegisterNetEvent('Dezzu_minigame:start')
AddEventHandler('Dezzu_minigame:start', function()
    local success = exports.ox_lib:skillCheck('easy', {'w', 'a', 's', 'd'})
    if success then
        TriggerServerEvent('Dezzu_shoprobbery:value') 
    else
        exports.ox_lib:notify({
            title = 'Niepowodzenie',
            description = 'Nieudane otwarcie zamka.',
            type = 'error'
        })
    end
end)


RegisterNetEvent('Dezzu_shoprobbery:notify')
AddEventHandler('Dezzu_shoprobbery:notify', function(data)
    exports.ox_lib:notify(data)
end)

