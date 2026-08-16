local lastPayload = nil
local seatbelt = false
local cruise = false
local cruiseSpeed = 0.0
local lastVehicleSpeed = 0.0
local lastVehicleVelocity = vector3(0.0, 0.0, 0.0)
local ejectCooldown = 0



local function GetSpeed(vehicle)
    local speed = GetEntitySpeed(vehicle)

    if Config.Vehicle.speedUnit == 'mph' then
        return WientaHUD.Round(speed * 2.236936)
    end

    return WientaHUD.Round(speed * 3.6)
end

local function GetRPM(vehicle)
    return WientaHUD.Clamp(
        WientaHUD.Round(GetVehicleCurrentRpm(vehicle) * 100),
        0,
        100
    )
end

local function GetGear(vehicle)
    if GetEntitySpeed(vehicle) < 0.5 then
        local gear = GetVehicleCurrentGear(vehicle)

        if gear == 0 then
            return 'N'
        end
    end

    local gear = GetVehicleCurrentGear(vehicle)

    if gear == 0 then
        return 'R'
    end

    return tostring(gear)
end

local function GetFuel(vehicle)
    local fuel = GetVehicleFuelLevel(vehicle)

    return WientaHUD.Clamp(
        WientaHUD.Round(fuel),
        0,
        100
    )
end

local function GetEngineHealth(vehicle)
    local health = GetVehicleEngineHealth(vehicle)

    return WientaHUD.Clamp(
        WientaHUD.Round(health / 10),
        0,
        100
    )
end

local function GetLights(vehicle)
    local _, lightsOn, highBeamsOn =
        GetVehicleLightsState(vehicle)

    return {
        enabled = lightsOn == 1,
        highBeam = highBeamsOn == 1
    }
end

local function IsDriver(ped, vehicle)
    return GetPedInVehicleSeat(
        vehicle,
        -1
    ) == ped
end




local function ResetEjectState()
    lastVehicleSpeed = 0.0
    lastVehicleVelocity = vector3(0.0, 0.0, 0.0)
end

local function EjectFromVehicle(ped, vehicle)
    local cfg = Config.Vehicle.seatbeltEject

    if not cfg or cfg.enabled == false then
        return
    end

    local velocity = lastVehicleVelocity

    -- GTA'ya gerçekten "araçtan atla" diyoruz
    TaskLeaveVehicle(
        ped,
        vehicle,
        4160
    )

    Wait(100)

    -- Çarpışma öncesi momentum devam etsin
    SetEntityVelocity(
        ped,
        velocity.x * 1.15,
        velocity.y * 1.15,
        velocity.z + 1.0
    )

    SetPedToRagdoll(
        ped,
        cfg.ragdollTime or 3500,
        cfg.ragdollTime or 3500,
        0,
        true,
        true,
        false
    )

    ejectCooldown =
        GetGameTimer()
        + (cfg.cooldown or 2500)

    ResetEjectState()
end

CreateThread(function()
    while true do
        local cfg =
            Config.Vehicle.seatbeltEject

        if not cfg
            or cfg.enabled == false
        then
            ResetEjectState()
            Wait(1000)

            goto continue
        end

        local ped =
            PlayerPedId()

        if not IsPedInAnyVehicle(
            ped,
            false
        ) then
            ResetEjectState()
            Wait(250)

            goto continue
        end

        local vehicle =
            GetVehiclePedIsIn(
                ped,
                false
            )

        if vehicle == 0 then
            ResetEjectState()
            Wait(250)

            goto continue
        end

        local currentSpeed =
            GetEntitySpeed(vehicle)
            * 3.6

        local currentVelocity =
            GetEntityVelocity(vehicle)

        if not seatbelt
            and GetGameTimer() >= ejectCooldown
            and lastVehicleSpeed >= (
                cfg.minSpeed or 70
            )
        then
            local speedLoss =
                lastVehicleSpeed
                - currentSpeed

            if speedLoss >= (
                cfg.impactSpeedLoss or 25
            )
            then
                EjectFromVehicle(
                    ped,
                    vehicle
                )

                Wait(500)

                goto continue
            end
        end

        lastVehicleSpeed =
            currentSpeed

        lastVehicleVelocity =
            currentVelocity

        Wait(50)

        ::continue::
    end
end)



local function BuildVehicleData(vehicle)
    local lights = GetLights(vehicle)

    return {
        speed = GetSpeed(vehicle),
        speedUnit = Config.Vehicle.speedUnit,

        rpm = GetRPM(vehicle),
        gear = GetGear(vehicle),

        fuel = GetFuel(vehicle),
        engine = GetEngineHealth(vehicle),

        seatbelt = seatbelt,
        cruise = cruise,

        lights = lights.enabled,
        highBeam = lights.highBeam,

        handbrake = GetVehicleHandbrake(vehicle),

        engineRunning = GetIsVehicleEngineRunning(vehicle)
    }
end

local function CanShowVehicleHud()
    local settings =
        WientaHUD.State.settings or {}

    if not Config.Vehicle.enabled then
        return false
    end

    if not WientaHUD.State.visible then
        return false
    end

    if settings.vehicle == false then
        return false
    end

    if WientaHUD.State.cinematic
        and Config.Cinematic.hideVehicleHud
    then
        return false
    end

    return true
end


local function HideVehicleHud()
    if not WientaHUD.State.inVehicle then
        return
    end

    WientaHUD.State.inVehicle = false
    lastPayload = nil

    WientaHUD.Send('vehicle:visibility', {
        visible = false
    })
end

local function ShowVehicleHud()
    if not CanShowVehicleHud() then
        HideVehicleHud()
        return
    end

    if WientaHUD.State.inVehicle then
        return
    end

    WientaHUD.State.inVehicle = true

    WientaHUD.Send(
        'vehicle:visibility',
        {
            visible = true
        }
    )
end



local function SendVehicleData(vehicle, force)
    if not CanShowVehicleHud() then
        HideVehicleHud()
        return
    end

    local payload =
        BuildVehicleData(vehicle)

    local encoded =
        json.encode(payload)

    if not force
        and encoded == lastPayload
    then
        return
    end

    lastPayload = encoded

    WientaHUD.Send(
        'vehicle:update',
        payload
    )
end



CreateThread(function()
    while true do
        if not WientaHUD.State.loaded
            or not WientaHUD.State.visible
            or (
                WientaHUD.State.cinematic
                and Config.Cinematic.hideVehicleHud
            )
        then
            HideVehicleHud()

            Wait(
                Config.Performance.inactiveInterval
                or 1000
            )

            goto continue
        end

        local ped = PlayerPedId()

        if not IsPedInAnyVehicle(ped, false) then
            HideVehicleHud()
            Wait(500)
            goto continue
        end

        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle == 0 then
            HideVehicleHud()
            Wait(500)
            goto continue
        end

        ShowVehicleHud()
        SendVehicleData(vehicle)

        Wait(
            Config.Performance.vehicleInterval
            or Config.Vehicle.updateInterval
            or 75
        )

        ::continue::
    end
end)



AddEventHandler('baseevents:enteredVehicle', function(vehicle)
    if vehicle == 0 then
        return
    end

    ShowVehicleHud()
    SendVehicleData(vehicle, true)
end)



AddEventHandler(
    'baseevents:leftVehicle',
    function()
        seatbelt = false

        cruise = false
        cruiseSpeed = 0.0

        lastVehicleSpeed = 0.0

        lastVehicleVelocity =
            vector3(
                0.0,
                0.0,
                0.0
            )

        HideVehicleHud()
    end
)



local function SetSeatbelt(state)
    seatbelt = state == true

    local ped = PlayerPedId()

    if not IsPedInAnyVehicle(ped, false) then
        return
    end

    local vehicle =
        GetVehiclePedIsIn(ped, false)

    if vehicle ~= 0 then
        SendVehicleData(
            vehicle,
            true
        )
    end
end

local function ToggleSeatbelt()
    local ped = PlayerPedId()

    if not IsPedInAnyVehicle(ped, false) then
        return
    end

    SetSeatbelt(
        not seatbelt
    )
end

RegisterCommand(
    '+wienta_seatbelt',
    function()
        ToggleSeatbelt()
    end,
    false
)

RegisterCommand(
    '-wienta_seatbelt',
    function()
    end,
    false
)

RegisterKeyMapping(
    '+wienta_seatbelt',
    'Toggle Seatbelt',
    'keyboard',
    'B'
)

RegisterNetEvent(
    'wienta_hud:client:setSeatbelt',
    function(state)
        SetSeatbelt(state)
    end
)

exports(
    'SetSeatbelt',
    function(state)
        SetSeatbelt(state)
    end
)

exports(
    'GetSeatbelt',
    function()
        return seatbelt
    end
)


local function RefreshCruiseHud()
    local ped = PlayerPedId()

    if not IsPedInAnyVehicle(
        ped,
        false
    ) then
        return
    end

    local vehicle =
        GetVehiclePedIsIn(
            ped,
            false
        )

    if vehicle ~= 0 then
        SendVehicleData(
            vehicle,
            true
        )
    end
end

local function SetCruise(state)
    state = state == true

    if not state then
        cruise = false
        cruiseSpeed = 0.0

        RefreshCruiseHud()
        return
    end

    local ped = PlayerPedId()

    if not IsPedInAnyVehicle(ped, false) then
        return
    end

    local vehicle =
        GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        return
    end

    if not IsDriver(ped, vehicle) then
        return
    end

    if not GetIsVehicleEngineRunning(vehicle) then
        return
    end

    local speed =
        GetEntitySpeed(vehicle)

    -- yaklaşık 20 KM/H
    if speed < 5.55 then
        return
    end

    cruiseSpeed = speed
    cruise = true

    SendVehicleData(
        vehicle,
        true
    )
end

local function ToggleCruise()
    if cruise then
        SetCruise(false)
        return
    end

    SetCruise(true)
end

RegisterCommand(
    '+wienta_cruise',
    function()
        ToggleCruise()
    end,
    false
)

RegisterCommand(
    '-wienta_cruise',
    function()
    end,
    false
)

RegisterKeyMapping(
    '+wienta_cruise',
    'Toggle Cruise Control',
    'keyboard',
    'Y'
)

RegisterNetEvent(
    'wienta_hud:client:setCruise',
    function(state)
        SetCruise(state)
    end
)

exports(
    'SetCruise',
    function(state)
        SetCruise(state)
    end
)

exports(
    'GetCruise',
    function()
        return cruise
    end
)



CreateThread(function()
    while true do
        if not cruise then
            Wait(500)
            goto continue
        end

        local ped =
            PlayerPedId()

        if not IsPedInAnyVehicle(
            ped,
            false
        ) then
            SetCruise(false)
            goto continue
        end

        local vehicle =
            GetVehiclePedIsIn(
                ped,
                false
            )

        if vehicle == 0
            or not IsDriver(
                ped,
                vehicle
            )
            or not GetIsVehicleEngineRunning(
                vehicle
            )
        then
            SetCruise(false)
            goto continue
        end

        -- Fren veya el freni cruise'u iptal eder.
        if IsControlPressed(0, 72)
            or IsControlPressed(0, 76)
        then
            SetCruise(false)
            goto continue
        end

        local speed =
            GetEntitySpeed(vehicle)

        if math.abs(
            speed - cruiseSpeed
        ) > 0.15 then
            SetVehicleForwardSpeed(
                vehicle,
                cruiseSpeed
            )
        end

        Wait(100)

        ::continue::
    end
end)



AddEventHandler(
    'wienta_hud:client:nuiReady',
    function()
        local ped = PlayerPedId()

        if not IsPedInAnyVehicle(
            ped,
            false
        ) then
            WientaHUD.State.inVehicle = false
            lastPayload = nil

            WientaHUD.Send(
                'vehicle:visibility',
                {
                    visible = false
                }
            )

            return
        end

        local vehicle =
            GetVehiclePedIsIn(
                ped,
                false
            )

        if vehicle ~= 0 then
            ShowVehicleHud()
            SendVehicleData(
                vehicle,
                true
            )
        else
            WientaHUD.Send(
                'vehicle:visibility',
                {
                    visible = false
                }
            )
        end
    end
)





RegisterNetEvent(
    'wienta_hud:client:refreshVehicle',
    function()
        local ped =
            PlayerPedId()

if not IsPedInAnyVehicle(
    ped,
    false
) then
    WientaHUD.State.inVehicle = false
    lastPayload = nil

    WientaHUD.Send(
        'vehicle:visibility',
        {
            visible = false
        }
    )

    return
end
        local vehicle =
            GetVehiclePedIsIn(
                ped,
                false
            )

        if vehicle ~= 0 then
            ShowVehicleHud()
            SendVehicleData(
                vehicle,
                true
            )
        end
    end
)

exports('RefreshVehicleHud', function()
    TriggerEvent('wienta_hud:client:refreshVehicle')
end)
