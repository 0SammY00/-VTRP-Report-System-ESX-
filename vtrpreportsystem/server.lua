local Reports = {}
local ReportCount = 0

-- Konfigurácia povolených skupín
local AdminGroups = {
    ['superadmin'] = true,
    ['admin'] = true,
    ['mod'] = true
}

function IsPlayerAdmin(xPlayer)
    if not xPlayer then return false end
    local group = xPlayer.getGroup()
    return AdminGroups[group] == true
end

-- Príkaz pre hráčov /report
RegisterCommand('report', function(source, args, rawCommand)
    TriggerClientEvent('modern_report:openClientReport', source)
end, false)

-- Príkaz pre adminov /reportsystem
RegisterCommand('reportsystem', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if IsPlayerAdmin(xPlayer) then
        TriggerClientEvent('modern_report:openAdminPanel', source, Reports)
    else
        xPlayer.showNotification('~r~Nemáš oprávnenie.')
    end
end, false)

-- Prijatie nového reportu
RegisterNetEvent('modern_report:submit')
AddEventHandler('modern_report:submit', function(data)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    ReportCount = ReportCount + 1

    local newReport = {
        id = ReportCount,
        targetSource = _source,
        name = xPlayer.getName(),
        category = data.category,
        text = data.text,
        resolved = false
    }

    table.insert(Reports, newReport)

    -- Notifikovať adminov
    local xPlayers = ESX.GetPlayers()
    for i=1, #xPlayers, 1 do
        local xAdmin = ESX.GetPlayerFromId(xPlayers[i])
        if IsPlayerAdmin(xAdmin) then
            -- Notifikácia na obrazovku (Top Middle)
            TriggerClientEvent('modern_report:sendAdminNotification', xPlayers[i], 'Nový report od ' .. xPlayer.getName() .. ' (ID: '.. _source ..')')
            -- Ak majú otvorené menu, aktualizovať zoznam
            TriggerClientEvent('modern_report:updateReportsList', xPlayers[i], Reports)
        end
    end
end)

-- Admin akcie (Goto, Bring, Resolve)
RegisterNetEvent('modern_report:performAction')
AddEventHandler('modern_report:performAction', function(action, data)
    local _source = source
    local xAdmin = ESX.GetPlayerFromId(_source)

    if not IsPlayerAdmin(xAdmin) then return end

    if action == 'goto' then
        local targetId = tonumber(data)
        local targetPed = GetPlayerPed(targetId)
        if targetPed ~= 0 then
            local coords = GetEntityCoords(targetPed)
            SetEntityCoords(GetPlayerPed(_source), coords.x, coords.y, coords.z)
            xAdmin.showNotification('~g~Portol si sa na hráča.')
        else
            xAdmin.showNotification('~r~Hráč nie je online.')
        end

    elseif action == 'bring' then
        local targetId = tonumber(data)
        local targetPed = GetPlayerPed(targetId)
        if targetPed ~= 0 then
            local coords = GetEntityCoords(GetPlayerPed(_source))
            SetEntityCoords(targetPed, coords.x, coords.y, coords.z)
            xAdmin.showNotification('~g~Pritiahol si hráča.')
            TriggerClientEvent('esx:showNotification', targetId, 'Admin ťa pritiahol.')
        else
            xAdmin.showNotification('~r~Hráč nie je online.')
        end

    elseif action == 'resolve' then
        local reportId = tonumber(data)
        for k, v in pairs(Reports) do
            if v.id == reportId then
                v.resolved = true
                -- Notifikovať hráča, že report bol vyriešený
                TriggerClientEvent('esx:showNotification', v.targetSource, '~g~Tvoj report bol označený ako vyriešený.')
                break
            end
        end
        
        xAdmin.showNotification('~g~Report vyriešený.')

        -- Aktualizovať UI všetkým adminom
        local xPlayers = ESX.GetPlayers()
        for i=1, #xPlayers, 1 do
            local xTarget = ESX.GetPlayerFromId(xPlayers[i])
            if IsPlayerAdmin(xTarget) then
                TriggerClientEvent('modern_report:updateReportsList', xPlayers[i], Reports)
            end
        end
    end
end)