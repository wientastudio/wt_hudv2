local lastPayload = nil

local Postals = {}
local postalsLoaded = false

-- =========================================================
-- COMPASS
-- =========================================================

local function GetDirection(heading)
    heading = heading % 360.0

    if heading >= 337.5 or heading < 22.5 then
        return Config.Compass.directions.N
    elseif heading < 67.5 then
        return Config.Compass.directions.NE
    elseif heading < 112.5 then
        return Config.Compass.directions.E
    elseif heading < 157.5 then
        return Config.Compass.directions.SE
    elseif heading < 202.5 then
        return Config.Compass.directions.S
    elseif heading < 247.5 then
        return Config.Compass.directions.SW
    elseif heading < 292.5 then
        return Config.Compass.directions.W
    end

    return Config.Compass.directions.NW
end

-- =========================================================
-- STREET
-- =========================================================

local function GetStreetData(coords)
    local streetHash, crossingHash = GetStreetNameAtCoord(
        coords.x,
        coords.y,
        coords.z
    )

    local street = ''
    local crossing = ''

    if streetHash and streetHash ~= 0 then
        street = GetStreetNameFromHashKey(streetHash)
    end

    if crossingHash and crossingHash ~= 0 then
        crossing = GetStreetNameFromHashKey(crossingHash)
    end

    return street, crossing
end



local function LoadPostals()
    if postalsLoaded then
        return
    end

    local file = Config.Location.postalFile or 'data/postals.json'
    local raw = LoadResourceFile(
    GetCurrentResourceName(),
    'data/postals.json'
)

print(
    '[Wienta HUD] Postal test:',
    GetCurrentResourceName(),
    raw and #raw or 'NIL'
)

    if not raw or raw == '' then
        print(('[Wienta HUD] Postal dosyası bulunamadı: %s'):format(file))
        return
    end

    local success, data = pcall(json.decode, raw)

    if not success or type(data) ~= 'table' then
        print('[Wienta HUD] Postal JSON okunamadı.')
        return
    end

    Postals = {}

    for i = 1, #data do
        local postal = data[i]
        local x = tonumber(postal.x)
        local y = tonumber(postal.y)
        local code = postal.code

        if x and y and code ~= nil then
            Postals[#Postals + 1] = {
                x = x,
                y = y,
                code = tostring(code)
            }
        end
    end

    postalsLoaded = true

    if Config.Debug then
        print(('[Wienta HUD] %s postal yüklendi.'):format(#Postals))
    end
end


local function GetPostal(coords)
    if not Config.Location.postal then
        return nil
    end

    if not postalsLoaded then
        LoadPostals()
    end

    if #Postals == 0 then
        return nil
    end

    local nearest = nil
    local nearestDistance = math.huge

    for i = 1, #Postals do
        local postal = Postals[i]
        local dx = coords.x - postal.x
        local dy = coords.y - postal.y
        local distance = (dx * dx) + (dy * dy)

        if distance < nearestDistance then
            nearestDistance = distance
            nearest = postal
        end
    end

    return nearest and nearest.code or nil
end



local function BuildLocationData()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local street, crossing = GetStreetData(coords)

    return {
        compass = {
            direction = GetDirection(heading),
            heading = WientaHUD.Round(heading)
        },

        street = street,
        crossing = crossing,
        postal = GetPostal(coords),

        visibility = {
            compass = Config.Location.compass and Config.Compass.enabled,
            heading = Config.Location.heading,
            street = Config.Location.street,
            crossing = Config.Location.crossing,
            postal = Config.Location.postal
        }
    }
end


local function SendLocation(force)
    if WientaHUD.State.cinematic
        and Config.Cinematic.hidePlayerHud
    then
        WientaHUD.Send('location:visibility', {
            visible = false
        })
        return
    end

    if not Config.Location.enabled then
        WientaHUD.Send('location:visibility', {
            visible = false
        })
        return
    end

    local payload = BuildLocationData()
    local encoded = json.encode(payload)

    if not force and lastPayload == encoded then
        return
    end

    lastPayload = encoded

    WientaHUD.Send('location:update', payload)
end



CreateThread(function()
    Wait(500)

    if Config.Location.postal then
        LoadPostals()
    end
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
            SendLocation()

            Wait(
                Config.Performance.locationInterval
                or Config.Location.updateInterval
                or 500
            )
        else
            Wait(
                Config.Performance.inactiveInterval
                or 1000
            )
        end
    end
end)



AddEventHandler('wienta_hud:client:nuiReady', function()
    SendLocation(true)
end)

AddEventHandler('wienta_hud:client:playerLoaded', function()
    SendLocation(true)
end)

RegisterNetEvent('wienta_hud:client:refreshLocation', function()
    SendLocation(true)
end)



exports('RefreshLocation', function()
    SendLocation(true)
end)
