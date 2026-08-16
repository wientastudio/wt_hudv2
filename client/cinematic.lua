local function HidePlayerHud()
    WientaHUD.Send('status:visibility', {
        visible = false
    })

    WientaHUD.Send('location:visibility', {
        visible = false
    })

    WientaHUD.Send('voice:visibility', {
        visible = false
    })

    WientaHUD.Send('weapon:visibility', {
        visible = false
    })
end

local function HideVehicleHud()
    WientaHUD.Send('vehicle:visibility', {
        visible = false
    })
end

local function HidePlayerInfo()
    WientaHUD.Send('playerInfo:visibility', {
        visible = false
    })
end


local function RefreshHud()
    TriggerEvent(
        'wienta_hud:client:refreshMinimap'
    )

    TriggerEvent(
        'wienta_hud:client:refreshPlayerInfo'
    )

    TriggerEvent(
        'wienta_hud:client:refreshStatus'
    )

    TriggerEvent(
        'wienta_hud:client:refreshVehicle'
    )

    TriggerEvent(
        'wienta_hud:client:refreshLocation'
    )

    TriggerEvent(
        'wienta_hud:client:refreshVoice'
    )

    TriggerEvent(
        'wienta_hud:client:refreshWeapon'
    )
end



local function SetCinematic(state)
    if not Config.Cinematic.enabled then
        return
    end

    state = state == true

    if WientaHUD.State.cinematic == state then
        return
    end

    WientaHUD.State.cinematic = state

    if state then
        if Config.Cinematic.hideMinimap then
            DisplayRadar(false)
        end

        if Config.Cinematic.hidePlayerHud then
            HidePlayerHud()
        end

        if Config.Cinematic.hideVehicleHud then
            HideVehicleHud()
        end

        if Config.Cinematic.hidePlayerInfo then
            HidePlayerInfo()
        end

        WientaHUD.Send(
            'cinematic:update',
            {
                enabled = true,
                blackBars =
                    Config.Cinematic.blackBars == true
            }
        )

        return
    end

    WientaHUD.Send(
        'cinematic:update',
        {
            enabled = false,
            blackBars = false
        }
    )

    RefreshHud()
end



local function ToggleCinematic()
    SetCinematic(
        not WientaHUD.State.cinematic
    )
end


RegisterCommand(
    Config.Cinematic.command,
    function()
        ToggleCinematic()
    end,
    false
)




RegisterNetEvent(
    'wienta_hud:client:setCinematic',
    function(state)
        SetCinematic(state)
    end
)

RegisterNetEvent(
    'wienta_hud:client:toggleCinematic',
    function()
        ToggleCinematic()
    end
)



AddEventHandler(
    'wienta_hud:client:nuiReady',
    function()
        WientaHUD.Send(
            'cinematic:update',
            {
                enabled =
                    WientaHUD.State.cinematic,

                blackBars =
                    WientaHUD.State.cinematic
                    and Config.Cinematic.blackBars
            }
        )
    end
)



exports(
    'SetCinematic',
    function(state)
        SetCinematic(state)
    end
)

exports(
    'ToggleCinematic',
    function()
        ToggleCinematic()
    end
)

exports(
    'IsCinematic',
    function()
        return WientaHUD.State.cinematic
    end
)