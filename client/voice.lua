local voiceRange = 2
local radioChannel = 0
local radioTalking = false
local lastPayload = nil



local function GetVoiceLabel(range)
    local ranges = Config.VoiceHud.ranges

    return ranges[range] or tostring(range)
end

local function BuildVoiceData()
    local talking = NetworkIsPlayerTalking(PlayerId())

    return {
        talking = talking,

        range = voiceRange,
        rangeLabel = GetVoiceLabel(voiceRange),

        radioChannel = radioChannel,
        radioTalking = radioTalking,

        visibility = {
            range = Config.VoiceHud.showRange,
            talking = Config.VoiceHud.showTalking,
            radioChannel = Config.VoiceHud.showRadioChannel,
            radioTalking = Config.VoiceHud.showRadioTalking
        }
    }
end



local function SendVoice(force)
    if not Config.VoiceHud.enabled
    or not WientaHUD.IsElementEnabled('voice')
then
        WientaHUD.Send('voice:visibility', {
            visible = false
        })

        return
    end

    local payload = BuildVoiceData()
    local encoded = json.encode(payload)

    if not force and encoded == lastPayload then
        return
    end

    lastPayload = encoded

    WientaHUD.Send('voice:update', payload)
end



AddEventHandler('pma-voice:setTalkingMode', function(mode)
    voiceRange = tonumber(mode) or 2

    SendVoice(true)
end)

AddEventHandler('pma-voice:radioActive', function(state)
    radioTalking = state == true

    SendVoice(true)
end)

AddEventHandler('pma-voice:setRadioChannel', function(channel)
    radioChannel = tonumber(channel) or 0

    SendVoice(true)
end)



CreateThread(function()
    local lastTalking = false

    while true do
        if WientaHUD.State.loaded
            and WientaHUD.State.visible
            and (
    not WientaHUD.State.cinematic
    or not Config.Cinematic.hidePlayerHud
)
        then
            local talking = NetworkIsPlayerTalking(PlayerId())

            if talking ~= lastTalking then
                lastTalking = talking
                SendVoice(true)
            end

            Wait(150)
        else
            Wait(
                Config.Performance.inactiveInterval
                or 1000
            )
        end
    end
end)



AddEventHandler('wienta_hud:client:nuiReady', function()
    SendVoice(true)
end)

AddEventHandler('wienta_hud:client:playerLoaded', function()
    SendVoice(true)
end)



RegisterNetEvent('wienta_hud:client:setVoiceRange', function(range)
    voiceRange = tonumber(range) or voiceRange

    SendVoice(true)
end)

RegisterNetEvent('wienta_hud:client:setRadioChannel', function(channel)
    radioChannel = tonumber(channel) or 0

    SendVoice(true)
end)

RegisterNetEvent('wienta_hud:client:setRadioTalking', function(state)
    radioTalking = state == true

    SendVoice(true)
end)

RegisterNetEvent('wienta_hud:client:refreshVoice', function()
    SendVoice(true)
end)



exports('SetVoiceRange', function(range)
    voiceRange = tonumber(range) or voiceRange

    SendVoice(true)
end)

exports('SetRadioChannel', function(channel)
    radioChannel = tonumber(channel) or 0

    SendVoice(true)
end)

exports('SetRadioTalking', function(state)
    radioTalking = state == true

    SendVoice(true)
end)

exports('RefreshVoiceHud', function()
    SendVoice(true)
end)

