ESX = exports["es_extended"]:getSharedObject()


local npcModel = ("a_m_m_hillbilly_01") 
local npcCoords = Config.npc.coords
local npcHeading = Config.npc.heading
local hasActive = false
local inProgress = false

if hasActive  then
    exports.ox_lib:notify({
        title = 'Powiadomienie',
        description = 'Jest juz aktywny',
        type = 'error'
    })

end




Citizen.CreateThread(function()
    RequestModel(GetHashKey(npcModel))
    while not HasModelLoaded(GetHashKey(npcModel)) do
        Wait(1)
    end
    local npc = CreatePed(4, GetHashKey(npcModel), npcCoords.x, npcCoords.y, npcCoords.z, npcHeading, false, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    TaskStartScenarioInPlace(npc, "WORLD_HUMAN_HIKER", 0, true)
end)


exports.ox_target:addSphereZone({
    coords = Config.npc.coords,
    radius = 0.5,
    debug = true,
    DrawSprite = true,
    options = {
        {
            name = 'elo zelo',
            onSelect = function()
                ESX.TriggerServerCallback('Dezzu_houserobbery:checkitem', function(cb)
                    if cb then
                        print('true')
                    end
                end, GetPlayerServerId(PlayerId()))
            end,
            icon = 'fa-solid fa-message',
            label = "Tajniackie Informacje",
        },
    }
})



RegisterNetEvent('Dezzu_houserobbery:house')
AddEventHandler('Dezzu_houserobbery:house', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if inProgress then
        xPlayer.showNotification('Jest juz aktywny')
        return
    else
        xPlayer.showNotification('Rozpoczynam napad')
    end
    hasActive = true
    inProgress = true

end)

RegisterCommand('tp', function()
    hasActive = true 
    inProgress = true
end)



AddEventHandler('Dezzu_houserobbery:start', function()
    hasActive = true
    inProgress = true
    if (GetCurrentResourceName() == 'Dezzu_houserobbery') then
        local randomCoords = Config.robberyproperty[math.random(1, #Config.robberyproperty)]
        exports.ox_target:addBoxZone({
            coords = randomCoords,
            size = vector3(1.5, 1.5, 1.5),
            rotation = 0,
            debug = true,
            DrawSprite = true,
            options = {
                {
                    name = 'start',
                    onSelect = function()
                        if inProgress then
                            ESX.TriggerServerCallback('Dezzu_houserobbery:checkitem', function(success) 
                                if success then
                                    inProgress = true
                                end
                            end, GetPlayerServerId(PlayerId()))
                        else
                            exports.ox_lib:notify({
                                title = 'Powiadomienie',
                                description = 'Jest juz aktywny',
                                type = 'error'
                            })
                        end
                    end,
                    canInteract = function()
                        return hasActive
                    end,
                    icon = 'fa-solid fa-message',
                    label = "Tajniackie Informacje",
                },
            }
        })

    end
end)

RegisterNetEvent('Dezzu_houserobbery:teleport')
AddEventHandler('Dezzu_houserobbery:teleport', function()
    local success = exports.ox_lib:skillCheck('easy', {'w', 'a', 's', 'd'})
    if success then
        DoScreenFadeOut(1000)
        Wait(1000)
        DoScreenFadeIn(1000)
        SetEntityCoords(PlayerPedId(), 1022.4351, -2398.9622, 30.1387)
        exports.removeboxzone:removeBoxZones('start')
    else
        exports.ox_lib:notify({
            title = 'Powiadomienie',
            description = 'Nieudane otwarcie zamka.',
            type = 'error'
        })
        hasActive = false
        inProgress = false
    end
end)



exports.ox_target:addBoxZone({
    coords = vector3(1022.5941, -2397.1653, 30.1387),
    size = vector3(1.5, 1.5, 1.5),
    debug = true,
    DrawSprite = true,
    options = {
        {
            name = 'elo zelo123',
            onSelect = function()
                if inProgress then
                    TriggerEvent('Dezzu_houserobbery:teleportback')
                else
                    exports.ox_lib:notify({
                        title = 'Powiadomienie',
                        description = 'Jest juz aktywny',
                        type = 'error'
                    })
                end
            end,
            icon = 'fa-solid fa-message',
            canInteract = function()
                return inProgress
            end,
            label = "Wyjdź z domu",
        },
    }
})
RegisterNetEvent('Dezzu_houserobbery:teleportback')
AddEventHandler('Dezzu_houserobbery:teleportback', function()

    DoScreenFadeOut(1000)
    Wait(1000)
    DoScreenFadeIn(1000)
    SetEntityCoords(PlayerPedId(), 1024.3132, -2398.6978, 30.1214)
    hasActive = false
    inProgress = false
    exports.ox_lib:notify({
        title = 'Powiadomienie',
        description = 'Zlecenie zostało zakończone.',
        type = 'success'
    })
    
end)


