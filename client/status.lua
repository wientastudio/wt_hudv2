local QBCore = WientaHUD.QBCore

local lastPayload = nil

-- =========================================================
-- HELPERS
-- =========================================================

local function GetMetadata(name)
    local PlayerData = WientaHUD.GetPlayerData()
    local metadata = PlayerData and PlayerData.metadata

    if not metadata then
        return 0
    end

    return tonumber(metadata[name]) or 0
end

local function GetHealth(ped)
    local maxHealth = GetEntityMaxHealth(ped)
    local health = GetEntityHealth(ped)

    if maxHealth <= 100 then
        return 100
    end

    return WientaHUD.Clamp(
        WientaHUD.Round(((health - 100) / (maxHealth - 100)) * 100),
        0,
        100
    )
end

local function GetArmor(ped)
    return WientaHUD.Clamp(
        GetPedArmour(ped),
        0,
        100
    )
end

local function GetStamina()
    return WientaHUD.Clamp(
        WientaHUD.Round(GetPlayerSprintStaminaRemaining(PlayerId())),
        0,
        100
    )
end

local function GetOxygen(playerId)
    if not IsPedSwimmingUnderWater(PlayerPedId()) then
        return 100
    end

    local remaining = GetPlayerUnderwaterTimeRemaining(playerId)

    return WientaHUD.Clamp(
        WientaHUD.Round((remaining / 10.0) * 100),
        0,
        100
    )
end


local function ShouldShow(name, value)
    local element = Config.Status.elements[name]

    if not element or element.enabled == false then
        return false
    end

    if element.mode == 'hidden' then
        return false
    end

    if element.mode == 'always' then
        return true
    end

    local settings = WientaHUD.State.settings
    if settings and settings.alwaysShowStatus == true then
        return true
    end

    if name == 'health' then
        return not Config.Dynamic.hideFullHealth or value < 100
    end

    if name == 'armor' then
        return not Config.Dynamic.hideEmptyArmor or value > (element.hideAt or 0)
    end

    if name == 'hunger' then
        return not Config.Dynamic.hideHighHunger
            or value < (element.showBelow or 85)
    end

    if name == 'thirst' then
        return not Config.Dynamic.hideHighThirst
            or value < (element.showBelow or 85)
    end

    if name == 'stress' then
        return not Config.Dynamic.hideZeroStress
            or value > (element.showAbove or 0)
    end

    if name == 'stamina' then
        if Config.Dynamic.staminaOnlyWhenRunning then
            return IsPedRunning(PlayerPedId())
                or IsPedSprinting(PlayerPedId())
        end

        return true
    end

    if name == 'oxygen' then
        if Config.Dynamic.oxygenOnlyUnderwater then
            return IsPedSwimmingUnderWater(PlayerPedId())
        end

        return true
    end

    return true
end



local function BuildStatus()
    local ped = PlayerPedId()
    local player = PlayerId()

    local health = GetHealth(ped)
    local armor = GetArmor(ped)
    local hunger = GetMetadata('hunger')
    local thirst = GetMetadata('thirst')
    local stress = GetMetadata('stress')
    local stamina = GetStamina()
    local oxygen = GetOxygen(player)

    return {
        health = {
            value = health,
            visible = ShouldShow('health', health)
        },

        armor = {
            value = armor,
            visible = ShouldShow('armor', armor)
        },

        hunger = {
            value = hunger,
            visible = ShouldShow('hunger', hunger)
        },

        thirst = {
            value = thirst,
            visible = ShouldShow('thirst', thirst)
        },

        stress = {
            value = stress,
            visible = ShouldShow('stress', stress)
        },

        stamina = {
            value = stamina,
            visible = ShouldShow('stamina', stamina)
        },

        oxygen = {
            value = oxygen,
            visible = ShouldShow('oxygen', oxygen)
        }
    }
end



local function SendStatus(force)
    if WientaHUD.State.cinematic
        and Config.Cinematic.hidePlayerHud
    then
        WientaHUD.Send('status:visibility', {
            visible = false
        })
        return
    end

    if not Config.Status.enabled then
        WientaHUD.Send('status:visibility', {
            visible = false
        })
        return
    end

    local payload = BuildStatus()
    local encoded = json.encode(payload)

    if not force and lastPayload == encoded then
        return
    end

    lastPayload = encoded

    WientaHUD.Send('status:update', payload)
end



AddEventHandler('wienta_hud:client:nuiReady', function()
    SendStatus(true)
end)

AddEventHandler('wienta_hud:client:playerLoaded', function()
    SendStatus(true)
end)

AddEventHandler('wienta_hud:client:playerDataUpdated', function()
    SendStatus()
end)



CreateThread(function()
    while true do
        if WientaHUD.State.loaded
            and WientaHUD.State.visible
            and (
                not WientaHUD.State.cinematic
                or not Config.Cinematic.hidePlayerHud
            )
        then
            SendStatus()

            Wait(
                Config.Performance.statusInterval
                or Config.Status.updateInterval
                or 350
            )
        else
            Wait(
                Config.Performance.inactiveInterval
                or 1000
            )
        end
    end
end)



RegisterNetEvent('wienta_hud:client:refreshStatus', function()
    SendStatus(true)
end)

exports('RefreshStatus', function()
    SendStatus(true)
end)
