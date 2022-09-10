local data = {}
local phoneNumbers = {}
local ox_inventory = exports.ox_inventory

local function registerCmd(table)
    phoneNumbers[string.lower(table.name)] = {}

    RegisterCommand(string.lower(table.name), function(source, args)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)

        if xPlayer then
            if xPlayer.getInventoryItem('phone').count > 0 then
                if args[1] then
                    local message = ''

                    for k,v in ipairs(args) do
                        message = message .. " " .. v
                    end

                    TriggerClientEvent('kk-dispatch:client:sendDispatch', xPlayer.source, 'PHONE: ' .. xPlayer.phone, table.name, string.upper(message), true)
                else
                    TriggerClientEvent('esx:showNotification', xPlayer.source, 'Please enter content for making a call.')
                end
            else
                TriggerClientEvent('esx:showNotification', xPlayer.source, "You don't have a phone.")
            end
        end
    end, false)
end

local function getCalls()
    return data
end

exports('getCalls', getCalls)

lib.callback.register('kk-dispatch:loadCalls', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    return data[xPlayer.job.name]
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    for k,v in pairs(phoneNumbers) do
        TriggerClientEvent('chat:addSuggestion', playerId, '/' .. k, 'Saada sisestatud tööle töösõnum.', {
            { name="sisu" }
        }) 
    end
end)

MySQL.ready(function()
	local result = MySQL.Sync.fetchAll('SELECT * FROM jobs', {})

	for i=1, #result, 1 do
        data[result[i].name] = {}
        registerCmd(result[i])
	end
end)

RegisterServerEvent('kk-dispatch:server:acceptCall', function(id)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local nr = tonumber(id)
    local count = #data[xPlayer.job.name]

    if count >= nr then
        local call = data[xPlayer.job.name][nr]

        if call then
            local xTargets = ESX.GetPlayers()

            TriggerClientEvent('kk-dispatch:client:setMarker', xPlayer.source, {x = call.coords.x, y = call.coords.y})

            for i = 1, #xTargets do
                local xTarget = ESX.GetPlayerFromId(xTargets[i])

                if xTarget.job.name == xPlayer.job.name then
                    TriggerClientEvent('kk-dispatch:client:showResponder', xTarget.source, {id = id, call = call.call, worker = xPlayer.name})
                end
            end    

            if call.answer then
                TriggerClientEvent('esx:showNotification', call.answer, 'Your call [' .. nr .. '] is being responded!')
            end
        else
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'At the moment, the dispatcher has not received any calls with a number '..nr..'.')
        end
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'At the moment, the dispatcher has not received any calls.')
    end
end)

RegisterServerEvent('kk-dispatch:server:alert')
AddEventHandler('kk-dispatch:server:alert', function(job, info)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if job and info then
		if data[job] then

			data[job][#data[job]+1] = {
                id = count,
                call = info.call,
                description = info.message,
                answer = info.answer,
                location = info.street .. ' | ' .. info.zone,
				coords = {x = info.coords.x, y =  info.coords.y}
			}
			
            local xPlayers = ESX.GetPlayers()

            local count = #data[job]

            data[job][#data[job]].id = count

            for i=1, #xPlayers, 1 do
                local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            
                if xPlayer.job.name == job then
                    TriggerClientEvent('kk-dispatch:client:sendAlert', xPlayer.source, {id = count, call = info.call, description = info.message, location = info.street .. ' | ' .. info.zone})
                end
            end
		end
	end
end)