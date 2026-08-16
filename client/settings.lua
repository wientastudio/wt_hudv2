local settingsOpen = false

local Settings = {
    enabled = Config.Defaults.enabled,
    scale = Config.Defaults.scale,
    accent = Config.Defaults.accent,

    statusStyle = Config.Defaults.statusStyle,
    vehicleStyle = Config.Defaults.vehicleStyle,
minimapMode = Config.Defaults.minimapMode,
minimapShape = Config.Defaults.minimapShape,
alwaysShowStatus =
    Config.Defaults.alwaysShowStatus,
    

    playerInfo = Config.PlayerInfo.enabled,
    status = Config.Status.enabled,
    vehicle = Config.Vehicle.enabled,
    location = Config.Location.enabled,
    voice = Config.VoiceHud.enabled,
    weapon = Config.Weapon.enabled,

    positions = {}
}



local function GetKvpKey()
    return (Config.Kvp.prefix or 'wienta_hud_') .. 'settings'
end

local function SaveSettings()
    if not Config.Kvp.enabled then
        return
    end

    SetResourceKvp(
        GetKvpKey(),
        json.encode(Settings)
    )
end

local function LoadSettings()
    if not Config.Kvp.enabled then
        return
    end

    local saved = GetResourceKvpString(
        GetKvpKey()
    )

    if not saved then
        return
    end

    local success, data = pcall(
        json.decode,
        saved
    )

    if not success or type(data) ~= 'table' then
        return
    end

    for key, value in pairs(data) do
        if Settings[key] ~= nil then
            Settings[key] = value
        end
    end
end



local function RefreshHudElements()
    TriggerEvent('wienta_hud:client:refreshMinimap')
    TriggerEvent('wienta_hud:client:refreshPlayerInfo')
    TriggerEvent('wienta_hud:client:refreshStatus')
    TriggerEvent('wienta_hud:client:refreshVehicle')
    TriggerEvent('wienta_hud:client:refreshLocation')
    TriggerEvent('wienta_hud:client:refreshVoice')
    TriggerEvent('wienta_hud:client:refreshWeapon')
end

local function ApplySettings()
    TriggerEvent(
        'wienta_hud:client:setMinimapMode',
        Settings.minimapMode
    )

    Config.Minimap.shape =
        Settings.minimapShape
        or Config.Minimap.shape

    WientaHUD.State.settings =
        WientaHUD.CopyTable(Settings)

    WientaHUD.SetVisible(
        Settings.enabled == true
    )

    WientaHUD.Send(
        'settings:apply',
        Settings
    )

    WientaHUD.Send('layout:load', {
        positions = Settings.positions or {}
    })

    RefreshHudElements()
end


local function BuildMenuData()
    return {
        settings = Settings,

options = {
    statusStyles =
        Config.Status.availableStyles,

    vehicleStyles =
        Config.Vehicle.availableStyles,

    minimapModes =
        Config.Minimap.availableModes,

    minimapShapes =
        Config.Minimap.availableShapes,

    colors =
        Config.Colors.presets
},

        permissions = {
            scale =
                Config.Settings.allowScale,

            accent =
                Config.Settings.allowAccentColor,

            statusStyle =
                Config.Settings.allowStatusStyle,

            vehicleStyle =
                Config.Settings.allowVehicleStyle,
            
            minimapShape =
                Config.Settings.allowMinimapShape,    

            minimapMode =
                Config.Settings.allowMinimapMode,

            elementToggle =
                Config.Settings.allowElementToggle,

            layout =
                Config.Settings.allowLayoutEditor,

            reset =
                Config.Settings.allowReset
        }
    }
end



local function OpenSettings()
    if not Config.Settings.enabled then
        return
    end

    if settingsOpen then
        return
    end

    settingsOpen = true

    -- Kayıtlı HUD durumunu tekrar NUI ile senkronla.
    -- /hud komutu HUD'u kendi kendine açmasın.
    WientaHUD.SetVisible(
        Settings.enabled == true
    )

    SetNuiFocus(true, true)

    WientaHUD.Send(
        'settings:open',
        BuildMenuData()
    )
end


local function CloseSettings()
    if not settingsOpen then
        return
    end

    settingsOpen = false

    SetNuiFocus(false, false)

    WientaHUD.Send(
        'settings:close'
    )
end


RegisterCommand(
    Config.Command,
    function()
        OpenSettings()
    end,
    false
)

RegisterNUICallback(
    'settings:close',
    function(_, cb)
        WientaHUD.State.settings =
            WientaHUD.CopyTable(Settings)

        WientaHUD.SetVisible(
            Settings.enabled == true
        )

        WientaHUD.Send(
            'settings:apply',
            Settings
        )

        RefreshHudElements()

        CloseSettings()

        cb('ok')
    end
)

RegisterNUICallback(
    'settings:save',
    function(data, cb)
        if type(data) ~= 'table' then
            cb(false)
            return
        end

        if data.enabled ~= nil then
            Settings.enabled =
                data.enabled == true
        end

        if data.scale
            and Config.Settings.allowScale
        then
            Settings.scale =
                WientaHUD.Clamp(
                    tonumber(data.scale) or 1.0,
                    0.7,
                    1.4
                )
        end

        if data.alwaysShowStatus ~= nil then
    Settings.alwaysShowStatus =
        data.alwaysShowStatus == true
end

        if data.accent
            and Config.Settings.allowAccentColor
        then
            Settings.accent =
                tostring(data.accent)
        end

        if data.statusStyle
            and Config.Settings.allowStatusStyle
        then
            Settings.statusStyle =
                tostring(data.statusStyle)
        end

        if data.vehicleStyle
            and Config.Settings.allowVehicleStyle
        then
            Settings.vehicleStyle =
                tostring(data.vehicleStyle)
        end

        if data.minimapMode
            and Config.Settings.allowMinimapMode
        then
            Settings.minimapMode =
                tostring(data.minimapMode)
        end

        if data.minimapShape
    and Config.Settings.allowMinimapShape
then
    local shape =
        tostring(data.minimapShape)

    if shape == 'square'
        or shape == 'circle'
    then
        Settings.minimapShape = shape
    end
end

        if Config.Settings.allowElementToggle then
            if data.playerInfo ~= nil then
                Settings.playerInfo =
                    data.playerInfo == true
            end

            if data.status ~= nil then
                Settings.status =
                    data.status == true
            end

            if data.vehicle ~= nil then
                Settings.vehicle =
                    data.vehicle == true
            end

            if data.location ~= nil then
                Settings.location =
                    data.location == true
            end

            if data.voice ~= nil then
                Settings.voice =
                    data.voice == true
            end

            if data.weapon ~= nil then
                Settings.weapon =
                    data.weapon == true
            end
        end

        SaveSettings()
        ApplySettings()

        cb(true)
    end
)



RegisterNUICallback(
    'settings:preview',
    function(data, cb)
        if type(data) ~= 'table' then
            cb(false)
            return
        end

        local previewSettings =
            WientaHUD.CopyTable(Settings)

        for key, value in pairs(data) do
            if previewSettings[key] ~= nil then
                previewSettings[key] = value
            end
        end

        WientaHUD.State.settings =
            previewSettings

        WientaHUD.SetVisible(
            previewSettings.enabled ~= false
        )

        WientaHUD.Send(
            'settings:preview',
            previewSettings
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
            'wienta_hud:client:refreshWeapon'
        )

        cb(true)
    end
)



RegisterNUICallback(
    'minimap:shapePreview',
    function(data, cb)
        if type(data) ~= 'table'
            or type(data.shape) ~= 'string'
        then
            cb(false)
            return
        end

        local shape = data.shape

        if shape ~= 'square'
            and shape ~= 'circle'
        then
            cb(false)
            return
        end

        Config.Minimap.shape = shape

        TriggerEvent(
            'wienta_hud:client:refreshMinimap'
        )

        cb(true)
    end
)



RegisterNUICallback(
    'minimap:preview',
    function(data, cb)
        if type(data) ~= 'table'
            or type(data.mode) ~= 'string'
        then
            cb(false)
            return
        end

        local allowed = {
            always = true,
            vehicle = true,
            walking = true,
            hidden = true
        }

        if not allowed[data.mode] then
            cb(false)
            return
        end

        Config.Minimap.mode =
            data.mode

        TriggerEvent(
            'wienta_hud:client:refreshMinimap'
        )

        cb(true)
    end
)



RegisterNUICallback(
    'settings:reset',
    function(_, cb)
        if not Config.Settings.allowReset then
            cb(false)
            return
        end

Settings = {
    enabled =
        Config.Defaults.enabled,

    scale =
        Config.Defaults.scale,

    accent =
        Config.Defaults.accent,

    alwaysShowStatus =
    Config.Defaults.alwaysShowStatus,    

    statusStyle =
        Config.Defaults.statusStyle,

    vehicleStyle =
        Config.Defaults.vehicleStyle,

    minimapMode =
        Config.Defaults.minimapMode,

minimapShape =
    Config.Defaults.minimapShape, 

    playerInfo =
        Config.PlayerInfo.enabled,

    status =
        Config.Status.enabled,

    vehicle =
        Config.Vehicle.enabled,

    location =
        Config.Location.enabled,

    voice =
        Config.VoiceHud.enabled,

    weapon =
        Config.Weapon.enabled,

    positions = {}
}

        if Config.Kvp.enabled then
            DeleteResourceKvp(
                GetKvpKey()
            )
        end

        ApplySettings()

        WientaHUD.Send(
            'settings:reset',
            Settings
        )

        cb(Settings)
    end
)



RegisterNUICallback(
    'settings:escape',
    function(_, cb)
        CloseSettings()

        cb('ok')
    end
)



RegisterNUICallback('layout:open', function(_, cb)
    if not Config.Layout.enabled
        or not Config.Settings.allowLayoutEditor
    then
        cb({
            allowed = false,
            positions = {}
        })

        return
    end

    settingsOpen = false

    SetNuiFocus(true, true)

    cb({
        allowed = true,
        positions = Settings.positions or {}
    })
end)



RegisterNUICallback('layout:save', function(data, cb)
    if not Config.Layout.enabled
        or not Config.Settings.allowLayoutEditor
    then
        cb(false)

        return
    end

    if type(data) ~= 'table'
        or type(data.positions) ~= 'table'
    then
        cb(false)

        return
    end

    Settings.positions = {}

    for name, position in pairs(data.positions) do
        if Config.Layout.movable[name]
            and type(position) == 'table'
        then
            local x = tonumber(position.x)
            local y = tonumber(position.y)

            if x and y then
                Settings.positions[name] = {
                    x = WientaHUD.Clamp(x, 0.0, 1.0),
                    y = WientaHUD.Clamp(y, 0.0, 1.0)
                }
            end
        end
    end

    SaveSettings()

    WientaHUD.Send('layout:load', {
        positions = Settings.positions
    })

    SetNuiFocus(false, false)

    cb(true)
end)



RegisterNUICallback('layout:cancel', function(_, cb)
    WientaHUD.Send('layout:load', {
        positions = Settings.positions or {}
    })

    SetNuiFocus(false, false)

    cb(true)
end)



RegisterNUICallback('layout:reset', function(_, cb)
    if not Config.Layout.enabled
        or not Config.Settings.allowReset
    then
        cb(false)
        return
    end

    cb({
        positions = {}
    })
end)



AddEventHandler(
    'wienta_hud:client:initialized',
    function()
        LoadSettings()
        ApplySettings()
    end
)

AddEventHandler(
    'wienta_hud:client:nuiReady',
    function()
        LoadSettings()
        ApplySettings()
    end
)


RegisterNetEvent(
    'wienta_hud:client:openSettings',
    function()
        OpenSettings()
    end
)

RegisterNetEvent(
    'wienta_hud:client:closeSettings',
    function()
        CloseSettings()
    end
)



exports(
    'OpenHudSettings',
    function()
        OpenSettings()
    end
)

exports(
    'CloseHudSettings',
    function()
        CloseSettings()
    end
)

exports(
    'GetHudSettings',
    function()
        return WientaHUD.CopyTable(Settings)
    end
)