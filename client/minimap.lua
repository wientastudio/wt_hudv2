local radarVisible = false
local currentShape = nil



local function ShouldShowRadar()
    if not Config.Minimap.enabled
        or not WientaHUD.State.loaded
        or not WientaHUD.State.visible
        or (
    WientaHUD.State.cinematic
    and Config.Cinematic.hideMinimap
)
    then
        return false
    end

    local mode =
        Config.Minimap.mode or 'vehicle'

    if mode == 'always' then
        return true
    end

    local inVehicle =
        IsPedInAnyVehicle(
            PlayerPedId(),
            false
        )

    if mode == 'vehicle' then
        return inVehicle
    end

    if mode == 'walking' then
        return not inVehicle
    end

    return false
end

local function SendRadarState(state, force)
    state = state == true

    if not force
        and radarVisible == state
    then
        return
    end

    radarVisible = state

    WientaHUD.Send(
        'minimap:visibility',
        {
            visible = state
        }
    )
end

local function UpdateRadar(force)
    local shouldShow = ShouldShowRadar()

    DisplayRadar(shouldShow)

    if not force
        and radarVisible == shouldShow
    then
        return
    end

    radarVisible = shouldShow

    WientaHUD.Send(
        'minimap:visibility',
        {
            visible = shouldShow
        }
    )
end



local function GetMinimapOffset()
    local defaultAspect =
        1920 / 1080

    local resolutionX,
        resolutionY =
        GetActiveScreenResolution()

    if resolutionY <= 0 then
        return 0.0
    end

    local aspect =
        resolutionX / resolutionY

    if aspect <= defaultAspect then
        return 0.0
    end

    return (
        (defaultAspect - aspect) / 3.6
    ) - 0.008
end



local function LoadTextureDict(dict)
    if HasStreamedTextureDictLoaded(dict) then
        return true
    end

    RequestStreamedTextureDict(
        dict,
        false
    )

    local timeout =
        GetGameTimer() + 3000

    while not HasStreamedTextureDictLoaded(dict) do
        if GetGameTimer() >= timeout then
            return false
        end

        Wait(10)
    end

    return true
end

local function ClearMinimapTextures()
    RemoveReplaceTexture(
        'platform:/textures/graphics',
        'radarmasksm'
    )

    RemoveReplaceTexture(
        'platform:/textures/graphics',
        'radarmask1g'
    )
end



local function ApplySquareMap(offset)
    if not LoadTextureDict('squaremap') then
        return
    end

    SetMinimapClipType(0)

    AddReplaceTexture(
        'platform:/textures/graphics',
        'radarmasksm',
        'squaremap',
        'radarmasksm'
    )

    AddReplaceTexture(
        'platform:/textures/graphics',
        'radarmask1g',
        'squaremap',
        'radarmasksm'
    )

    SetMinimapComponentPosition(
        'minimap',
        'L',
        'B',
        0.0 + offset,
        -0.047,
        0.1638,
        0.183
    )

    SetMinimapComponentPosition(
        'minimap_mask',
        'L',
        'B',
        0.0 + offset,
        0.0,
        0.128,
        0.20
    )

    SetMinimapComponentPosition(
        'minimap_blur',
        'L',
        'B',
        -0.01 + offset,
        0.025,
        0.262,
        0.300
    )
end



local function ApplyCircleMap(offset)
    if not LoadTextureDict('circlemap') then
        return
    end

    SetMinimapClipType(1)

    AddReplaceTexture(
        'platform:/textures/graphics',
        'radarmasksm',
        'circlemap',
        'radarmasksm'
    )

    AddReplaceTexture(
        'platform:/textures/graphics',
        'radarmask1g',
        'circlemap',
        'radarmasksm'
    )

-- MAP
SetMinimapComponentPosition(
    'minimap',
    'L',
    'B',
    -0.0100 + offset,
    0.030,
    0.180,
    0.258
)

-- MASK
SetMinimapComponentPosition(
    'minimap_mask',
    'L',
    'B',
    0.200 + offset,
    0.060,
    0.065,
    0.20
)

-- BLUR
SetMinimapComponentPosition(
    'minimap_blur',
    'L',
    'B',
    0.0 + offset,
    0.075,
    0.252,
    0.338
)
end


local function ApplyDefaultMap(offset)
    SetMinimapClipType(0)

    SetMinimapComponentPosition(
        'minimap',
        'L',
        'B',
        0.0 + offset,
        -0.047,
        0.1638,
        0.183
    )

    SetMinimapComponentPosition(
        'minimap_mask',
        'L',
        'B',
        0.0 + offset,
        0.0,
        0.128,
        0.20
    )

    SetMinimapComponentPosition(
        'minimap_blur',
        'L',
        'B',
        -0.01 + offset,
        0.025,
        0.262,
        0.300
    )
end


local function ApplyMinimapShape(force)
    local shape =
        Config.Minimap.shape or 'square'

    if not force
        and currentShape == shape
    then
        return
    end

    ClearMinimapTextures()

    local offset =
        GetMinimapOffset()

    if shape == 'square' then
        ApplySquareMap(offset)

    elseif shape == 'circle'
        or shape == 'rounded'
    then
        -- "rounded" eski settings değerleri bozulmasın
        -- diye şimdilik circlemap'e yönleniyor.
        ApplyCircleMap(offset)

    else
        ApplyDefaultMap(offset)
    end

    local north =
        GetNorthRadarBlip()

    if north
        and north ~= 0
    then
        SetBlipAlpha(
            north,
            0
        )
    end

    SetBigmapActive(
        true,
        false
    )

    Wait(50)

    SetBigmapActive(
        false,
        false
    )

    currentShape = shape
end



local function RefreshMinimap()
    ApplyMinimapShape(true)

    local show =
        ShouldShowRadar()

    SendRadarState(
        show,
        true
    )

    DisplayRadar(show)
end



CreateThread(function()
    Wait(1000)

    RefreshMinimap()

    while true do
        local show =
            ShouldShowRadar()

        SendRadarState(show)

        if show then
            -- Başka resource radarı kapatmaya çalışırsa
            -- bizim HUD açık tutmaya devam etsin.
            DisplayRadar(true)

            Wait(0)
        else
            DisplayRadar(false)

            Wait(250)
        end
    end
end)


AddEventHandler(
    'wienta_hud:client:nuiReady',
    function()
        ApplyMinimapShape()
        UpdateRadar(true)
    end
)


RegisterNetEvent(
    'wienta_hud:client:refreshMinimap',
    function()
        RefreshMinimap()
    end
)



RegisterNetEvent(
    'wienta_hud:client:setMinimapMode',
    function(mode)
        if mode ~= 'always'
            and mode ~= 'vehicle'
            and mode ~= 'walking'
            and mode ~= 'hidden'
        then
            return
        end

        Config.Minimap.mode =
            mode

        RefreshMinimap()
    end
)

RegisterNetEvent(
    'wienta_hud:client:setMinimapShape',
    function(shape)
        if shape ~= 'square'
            and shape ~= 'circle'
        then
            return
        end

        Config.Minimap.shape =
            shape

        ApplyMinimapShape()
    end
)



exports(
    'RefreshMinimap',
    function()
        RefreshMinimap()
    end
)

exports(
    'SetMinimapMode',
    function(mode)
        TriggerEvent(
            'wienta_hud:client:setMinimapMode',
            mode
        )
    end
)

exports(
    'SetMinimapShape',
    function(shape)
        TriggerEvent(
            'wienta_hud:client:setMinimapShape',
            shape
        )
    end
)



AddEventHandler(
    'onResourceStop',
    function(resource)
        if resource ~=
            GetCurrentResourceName()
        then
            return
        end

        ClearMinimapTextures()

        SetMinimapClipType(0)
    end
)