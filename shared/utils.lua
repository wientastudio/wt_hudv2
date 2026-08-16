WientaHUD = WientaHUD or {}

function WientaHUD.Clamp(value, min, max)
    if value < min then
        return min
    end

    if value > max then
        return max
    end

    return value
end

function WientaHUD.Round(value)
    return math.floor(value + 0.5)
end

function WientaHUD.FormatMoney(value)
    value = tonumber(value) or 0

    local formatted = tostring(math.floor(value))

    while true do
        local new, count = formatted:gsub('^(-?%d+)(%d%d%d)', '%1.%2')

        formatted = new

        if count == 0 then
            break
        end
    end

    return formatted
end

function WientaHUD.CopyTable(tbl)
    if type(tbl) ~= 'table' then
        return tbl
    end

    local copy = {}

    for key, value in pairs(tbl) do
        copy[key] = WientaHUD.CopyTable(value)
    end

    return copy
end

function WientaHUD.Debug(...)
    if not Config.Debug then
        return
    end

    print('[Wienta HUD]', ...)
end