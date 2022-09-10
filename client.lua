local warnedshooting, menuOpen, mapOpend = false, false, false

CreateThread(function()
	while true do
        if IsPauseMenuActive() and not mapOpend then
            mapOpend = true
            SendNUIMessage({action = 'closeDispatch'})
        elseif not IsPauseMenuActive() and mapOpend then
            mapOpend = false
        end

		Wait(800)
	end
end)

CreateThread(function()
    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:playerUnloaded', function()
	ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob', function(job)
	ESX.PlayerData.job = job; SendNUIMessage({action = 'closeDispatch'})
end)

RegisterNetEvent('kk-dispatch:client:setMarker', function(coords)
    SetNewWaypoint(coords.x, coords.y)
end)

RegisterNetEvent('kk-dispatch:client:sendAlert', function(data)
    SendNUIMessage({action = 'addCall', data = data})
    PlaySound(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", 0, 0, 1)
end)

local function disableInputs()
    CreateThread(function()
        while menuOpen do
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 143, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 47, true)
            DisableControlAction(0, 58, true)
            DisablePlayerFiring(cache.ped, true)
    
            Wait(0)
        end
    end)
end

RegisterCommand('openDispatch', function()
    if not menuOpen then
        lib.showTextUI('[Z] - Close dispatch', {position = "left-center"})
        SendNUIMessage({action = 'showCalls'}); SetNuiFocus(true, true);  SetNuiFocusKeepInput(true); menuOpen = true; disableInputs()
    else
        SendNUIMessage({action = 'closeDispatch'})
    end
end, false)

RegisterKeyMapping('openDispatch', 'Open dispatch', 'keyboard', 'Z')

RegisterNUICallback('closeDispatch', function()
    SetNuiFocus(false, false); SetNuiFocusKeepInput(false); menuOpen = false; lib.hideTextUI()
end)

RegisterNUICallback('loadCalls', function(args, cb)
    lib.callback('kk-dispatch:loadCalls', false, function(response)
        SendNUIMessage({action = 'loadCalls', data = response})
    end)
end)

RegisterNUICallback('acceptCall', function(args, cb)
    TriggerServerEvent('kk-dispatch:server:acceptCall', args.id); SendNUIMessage({action = 'closeDispatch'})
end)

RegisterNetEvent('kk-dispatch:client:sendDispatch', function(call, job, message, answer)
    local playerCoords = GetEntityCoords(cache.ped)
    local street = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    local zone = GetNameOfZone(playerCoords)

    local data = {
        street = GetStreetNameFromHashKey(street),
        coords = playerCoords,
        zone = GetLabelText(zone),
        message = message,
        call = call
    }

    if answer then
        data['answer'] = GetPlayerServerId(PlayerId())
    end

    TriggerServerEvent('kk-dispatch:server:alert', job, data)
end)

RegisterNetEvent('kk-dispatch:client:showResponder', function(data)
    SendNUIMessage({action = 'addResponder', data = data})
end)

CreateThread(function()
    while true do
        if not warnedshooting and IsPedShooting(cache.ped) and not IsPedCurrentWeaponSilenced(cache.ped) then
            if ESX.PlayerData.job.name == 'police' then return end
            TriggerEvent('kk-dispatch:client:sendDispatch', '10-71', 'police', 'SHOOTING')

            warnedshooting = true
            SetTimeout(60000, function() warnedshooting = false end)
        end

        Wait(100)
    end
end)