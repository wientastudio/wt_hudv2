local currentWeapon = nil
local lastPayload = nil



local function IsWeaponAllowed(weapon)
    if not weapon then
        return false
    end

    if Config.Weapon.hideUnarmed and weapon.name == 'WEAPON_UNARMED' then
        return false
    end

    return true
end

local function GetLoadedAmmo(weapon)
    if not weapon or not weapon.metadata then
        return 0
    end

    return tonumber(weapon.metadata.ammo) or 0
end

local function GetReserveAmmo(weapon)
    if not weapon or not weapon.ammo then
        return 0
    end

    local count = exports.ox_inventory:Search(
        'count',
        weapon.ammo
    )

    return tonumber(count) or 0
end


local function HideWeaponHud()
    lastPayload = nil

    WientaHUD.Send('weapon:visibility', {
        visible = false
    })
end



local function BuildWeaponData()
    if not currentWeapon then
        return nil
    end

    local loadedAmmo = GetLoadedAmmo(currentWeapon)
    local reserveAmmo = GetReserveAmmo(currentWeapon)

    return {
        name = currentWeapon.name or '',
        label = currentWeapon.label or currentWeapon.name or '',

        hash = currentWeapon.hash,

        ammo = {
            loaded = loadedAmmo,
            reserve = reserveAmmo,
            total = loadedAmmo + reserveAmmo
        },

        melee = currentWeapon.melee == true,

        durability = currentWeapon.metadata
            and tonumber(currentWeapon.metadata.durability)
            or 100,

        visibility = {
            weaponName = Config.Weapon.showWeaponName,
            ammo = Config.Weapon.showAmmo
        }
    }
end



local function SendWeapon(force)
    if WientaHUD.State.cinematic
        and Config.Cinematic.hidePlayerHud
    then
        HideWeaponHud()
        return
    end

    if not Config.Weapon.enabled then
        HideWeaponHud()
        return
    end

    if not IsWeaponAllowed(currentWeapon) then
        HideWeaponHud()
        return
    end

    local payload = BuildWeaponData()

    if not payload then
        HideWeaponHud()
        return
    end

    local encoded = json.encode(payload)

    if not force and encoded == lastPayload then
        return
    end

    lastPayload = encoded

    WientaHUD.Send('weapon:update', payload)

    WientaHUD.Send('weapon:visibility', {
        visible = true
    })
end



AddEventHandler('ox_inventory:currentWeapon', function(weapon)
    currentWeapon = weapon

    if not weapon then
        HideWeaponHud()
        return
    end

    SendWeapon(true)
end)



AddEventHandler('ox_inventory:updateInventory', function()
    if not currentWeapon then
        return
    end

    local weapon = exports.ox_inventory:getCurrentWeapon()

    if not weapon then
        currentWeapon = nil
        HideWeaponHud()
        return
    end

    currentWeapon = weapon

    SendWeapon()
end)



AddEventHandler('wienta_hud:client:nuiReady', function()
    currentWeapon = exports.ox_inventory:getCurrentWeapon()

    if currentWeapon then
        SendWeapon(true)
    else
        HideWeaponHud()
    end
end)



AddEventHandler('wienta_hud:client:playerLoaded', function()
    currentWeapon = exports.ox_inventory:getCurrentWeapon()

    if currentWeapon then
        SendWeapon(true)
    else
        HideWeaponHud()
    end
end)



RegisterNetEvent('wienta_hud:client:refreshWeapon', function()
    currentWeapon = exports.ox_inventory:getCurrentWeapon()

    SendWeapon(true)
end)

exports('RefreshWeaponHud', function()
    currentWeapon = exports.ox_inventory:getCurrentWeapon()

    SendWeapon(true)
end)