local QBCore = exports['qb-core']:GetCoreObject()

WientaHUD = WientaHUD or {}

WientaHUD.QBCore = QBCore

WientaHUD.State = {
    loaded = false,
    visible = true,
    nuiReady = false,

    playerData = {},
    settings = {},

    inVehicle = false,
    cinematic = false
}

function WientaHUD.Send(action, data)
    if not WientaHUD.State.nuiReady then
        return
    end

    SendNUIMessage({
        action = action,
        data = data
    })
end



function WientaHUD.SetVisible(state)
    state = state == true

    WientaHUD.State.visible = state

    WientaHUD.Send('hud:visibility', {
        visible = state
    })
end

function WientaHUD.Toggle()
    WientaHUD.SetVisible(not WientaHUD.State.visible)
end

function WientaHUD.IsElementEnabled(name)
    local settings = WientaHUD.State.settings

    if type(settings) ~= 'table' then
        return true
    end

    return settings[name] ~= false
end


function WientaHUD.GetPlayerData()
    return WientaHUD.State.playerData
end

function WientaHUD.SetPlayerData(data)
    WientaHUD.State.playerData = data or {}
end

function WientaHUD.RefreshPlayerData()
    WientaHUD.SetPlayerData(QBCore.Functions.GetPlayerData())
end



local function InitializeHUD()
    if WientaHUD.State.loaded then
        return
    end

    WientaHUD.RefreshPlayerData()

    WientaHUD.State.loaded = true

    WientaHUD.Debug('HUD initialized')

    TriggerEvent('wienta_hud:client:initialized')
end


RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    WientaHUD.RefreshPlayerData()

    WientaHUD.State.loaded = true

    TriggerEvent('wienta_hud:client:playerLoaded')
end)



RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    WientaHUD.State.loaded = false
    WientaHUD.State.playerData = {}

    WientaHUD.Send('hud:reset')
end)



RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    WientaHUD.SetPlayerData(data)

    TriggerEvent('wienta_hud:client:playerDataUpdated', data)
end)



RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    local playerData = WientaHUD.GetPlayerData()

    playerData.job = job

    WientaHUD.SetPlayerData(playerData)

    TriggerEvent('wienta_hud:client:jobUpdated', job)
end)



RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
    local playerData = WientaHUD.GetPlayerData()

    playerData.gang = gang

    WientaHUD.SetPlayerData(playerData)

    TriggerEvent('wienta_hud:client:gangUpdated', gang)
end)



RegisterNetEvent('hud:client:OnMoneyChange', function(type, amount)
    local playerData = WientaHUD.GetPlayerData()

    playerData.money = playerData.money or {}
    playerData.money[type] = amount

    WientaHUD.SetPlayerData(playerData)

    TriggerEvent(
        'wienta_hud:client:moneyUpdated',
        type,
        amount
    )
end)



RegisterNUICallback('ready', function(_, cb)
    WientaHUD.State.nuiReady = true

    WientaHUD.Send('hud:init', {
        visible = WientaHUD.State.visible,
        config = {
            accent = Config.Defaults.accent,
            scale = Config.Defaults.scale,
            statusStyle = Config.Defaults.statusStyle,
            vehicleStyle = Config.Defaults.vehicleStyle
        }
    })

    TriggerEvent('wienta_hud:client:nuiReady')

    cb('ok')
end)



AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    CreateThread(function()
        while not NetworkIsPlayerActive(PlayerId()) do
            Wait(250)
        end

        InitializeHUD()
    end)
end)



AddEventHandler('onClientResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    SetNuiFocus(false, false)
    DisplayRadar(true)
end)



exports('IsHudVisible', function()
    return WientaHUD.State.visible
end)

exports('SetHudVisible', function(state)
    WientaHUD.SetVisible(state)
end)

exports('ToggleHud', function()
    WientaHUD.Toggle()
end)