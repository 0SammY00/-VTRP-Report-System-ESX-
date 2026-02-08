local isMenuOpen = false

-- Príkaz pre hráčov
RegisterNetEvent('modern_report:openClientReport')
AddEventHandler('modern_report:openClientReport', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openReport'
    })
    isMenuOpen = true
end)

-- Príkaz pre Adminov
RegisterNetEvent('modern_report:openAdminPanel')
AddEventHandler('modern_report:openAdminPanel', function(reports)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openAdmin',
        reports = reports
    })
    isMenuOpen = true
end)

-- Aktualizácia dát adminom (live update)
RegisterNetEvent('modern_report:updateReportsList')
AddEventHandler('modern_report:updateReportsList', function(reports)
    SendNUIMessage({
        action = 'updateReports',
        reports = reports
    })
end)

-- Notifikácia na obrazovke pre adminov
RegisterNetEvent('modern_report:sendAdminNotification')
AddEventHandler('modern_report:sendAdminNotification', function(msg)
    SendNUIMessage({
        action = 'notifyAdmin',
        text = msg
    })
end)

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    isMenuOpen = false
    cb('ok')
end)

RegisterNUICallback('submitReport', function(data, cb)
    TriggerServerEvent('modern_report:submit', data)
    ESX.ShowNotification('~g~Report bol úspešne odoslaný!')
    cb('ok')
end)

RegisterNUICallback('adminAction', function(data, cb)
    if data.type == 'goto' or data.type == 'bring' or data.type == 'resolve' then
        TriggerServerEvent('modern_report:performAction', data.type, data.data)
    end
    cb('ok')
end)