local QBCore = WientaHUD.QBCore

local lastData = {}



local function GetCharacterName(charinfo)
    if not charinfo then
        return ''
    end

    local firstname = charinfo.firstname or ''
    local lastname = charinfo.lastname or ''

    return (firstname .. ' ' .. lastname):gsub('^%s*(.-)%s*$', '%1')
end

local function GetJobLabel(job)
    if not job then
        return ''
    end

    return job.label or job.name or ''
end

local function GetJobGrade(job)
    if not job then
        return ''
    end

    if type(job.grade) == 'table' then
        return job.grade.name or job.grade.label or tostring(job.grade.level or '')
    end

    return tostring(job.grade or '')
end

local function GetGangLabel(gang)
    if not gang then
        return ''
    end

    return gang.label or gang.name or ''
end

local function GetMoney(money, account)
    if not money then
        return 0
    end

    return tonumber(money[account]) or 0
end



local function BuildPlayerInfo()
    local PlayerData = WientaHUD.GetPlayerData()

    if not PlayerData then
        return {}
    end

    local job = PlayerData.job or {}
    local gang = PlayerData.gang or {}
    local money = PlayerData.money or {}

    return {
        serverName = Config.PlayerInfo.serverName,

        characterName = GetCharacterName(PlayerData.charinfo),
        playerId = GetPlayerServerId(PlayerId()),

        job = GetJobLabel(job),
        jobGrade = GetJobGrade(job),
        duty = job.onduty == true,

        gang = GetGangLabel(gang),

        cash = GetMoney(money, 'cash'),
        bank = GetMoney(money, 'bank'),
        crypto = GetMoney(money, 'crypto'),

        visibility = {
            serverName = Config.PlayerInfo.showServerName,
            characterName = Config.PlayerInfo.showCharacterName,
            playerId = Config.PlayerInfo.showPlayerId,

            job = Config.PlayerInfo.showJob,
            jobGrade = Config.PlayerInfo.showJobGrade,
            duty = Config.PlayerInfo.showDuty,

            cash = Config.PlayerInfo.showCash,
            bank = Config.PlayerInfo.showBank,
            crypto = Config.PlayerInfo.showCrypto,

            gang = Config.PlayerInfo.showGang
        }
    }
end


local function SendPlayerInfo(force)
    local settings =
        WientaHUD.State.settings or {}

    if not WientaHUD.State.visible
        or settings.playerInfo == false
        or not Config.PlayerInfo.enabled
        or (
            WientaHUD.State.cinematic
            and Config.Cinematic.hidePlayerInfo
        )
    then
        WientaHUD.Send(
            'playerInfo:visibility',
            {
                visible = false
            }
        )

        return
    end

    WientaHUD.Send(
        'playerInfo:visibility',
        {
            visible = true
        }
    )

    local data =
        BuildPlayerInfo()

    if not force then
        local encoded =
            json.encode(data)

        local previous =
            json.encode(lastData)

        if encoded == previous then
            return
        end
    end

    lastData =
        WientaHUD.CopyTable(data)

    WientaHUD.Send(
        'playerInfo:update',
        data
    )
end



AddEventHandler('wienta_hud:client:initialized', function()
    SendPlayerInfo(true)
end)

AddEventHandler('wienta_hud:client:nuiReady', function()
    SendPlayerInfo(true)
end)



AddEventHandler('wienta_hud:client:playerLoaded', function()
    SendPlayerInfo(true)
end)



AddEventHandler('wienta_hud:client:playerDataUpdated', function()
    SendPlayerInfo()
end)



AddEventHandler('wienta_hud:client:jobUpdated', function()
    SendPlayerInfo()
end)



AddEventHandler('wienta_hud:client:gangUpdated', function()
    SendPlayerInfo()
end)



AddEventHandler('wienta_hud:client:moneyUpdated', function()
    SendPlayerInfo()
end)



RegisterNetEvent('wienta_hud:client:refreshPlayerInfo', function()
    WientaHUD.RefreshPlayerData()
    SendPlayerInfo(true)
end)



exports('RefreshPlayerInfo', function()
    SendPlayerInfo(true)
end)
