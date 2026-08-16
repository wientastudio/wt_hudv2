Config = {}



Config.Command = 'hud'

Config.Defaults = {
    enabled = true,
    alwaysShowStatus = false,

    scale = 1.0,
    accent = '#7C5CFF',

    statusStyle = 'minimal',
    vehicleStyle = 'digital',

    minimapMode = 'vehicle',
    minimapShape = 'square',

    dynamicStatus = true,
    cinematic = false
}



Config.Framework = 'qb'

Config.Inventory = 'ox_inventory'
Config.Voice = 'pma-voice'



Config.Status = {
    enabled = true,

    updateInterval = 350,

    style = 'minimal',

    availableStyles = {
        'minimal',
        'circle',
        'capsule',
        'blocks',
        'compact',
        'glass'
    },

    elements = {
        health = {
            enabled = true,
            mode = 'always'
        },

        armor = {
            enabled = true,
            mode = 'dynamic',
            hideAt = 0
        },

        hunger = {
            enabled = true,
            mode = 'dynamic',
            showBelow = 85
        },

        thirst = {
            enabled = true,
            mode = 'dynamic',
            showBelow = 85
        },

        stress = {
            enabled = false,
            mode = 'dynamic',
            showAbove = 10
        },

        stamina = {
            enabled = true,
            mode = 'dynamic'
        },

        oxygen = {
            enabled = true,
            mode = 'dynamic'
        }
    }
}



Config.PlayerInfo = {
    enabled = true,

    showServerName = true,
    serverName = 'Wienta Roleplay',

    showCharacterName = true,
    showPlayerId = true,

    showJob = true,
    showJobGrade = true,
    showDuty = true,

    showCash = true,
    showBank = true,
    showCrypto = false,

    showGang = false,

    moneyFormat = true
}


Config.Vehicle = {
    enabled = true,

    updateInterval = 75,

    speedUnit = 'kmh',

    style = 'digital',

    availableStyles = {
        'digital',
        'sport',
        'minimal',
        'arc',
        'compact'
    },

seatbeltEject = {
    enabled = true,

    minSpeed = 50,
    impactSpeedLoss = 15,

    ragdollTime = 3500,
    cooldown = 2500
},

    speed = true,
    rpm = true,
    gear = true,
    fuel = true,

    engineHealth = true,
    seatbelt = true,

    lights = true,
    cruise = true,

    handbrake = false,

    hideWhenStopped = false,

    fuelResource = 'auto'
}



Config.Seatbelt = {
    enabled = true,

    command = 'seatbelt',
    key = 'B',

    ejectEnabled = true,

    ejectMinSpeed = 70,

    ejectDamageMultiplier = 1.0
}



Config.Cruise = {
    enabled = true,

    command = 'cruise',
    key = 'Y',

    minimumSpeed = 30
}



Config.Minimap = {
    enabled = true,

    mode = 'vehicle',

    availableModes = {
        'always',
        'vehicle',
        'walking',
        'hidden'
    },

shape = 'square',

availableShapes = {
    'square',
    'circle'
}
}



Config.Location = {
    enabled = true,

    updateInterval = 500,

    compass = true,
    heading = true,

    street = true,
    crossing = true,

    postal = true,
    postalFile = 'data/postals.json'
}



Config.Compass = {
    enabled = true,

    directions = {
        N = 'N',
        NE = 'NE',
        E = 'E',
        SE = 'SE',
        S = 'S',
        SW = 'SW',
        W = 'W',
        NW = 'NW'
    }
}


Config.VoiceHud = {
    enabled = false,


    showRange = true,
    showTalking = true,

    showRadioChannel = true,
    showRadioTalking = true,

    ranges = {
        [1] = 'Whisper',
        [2] = 'Normal',
        [3] = 'Shout'
    }
}



Config.Weapon = {
    enabled = true,

    showWeaponName = true,
    showAmmo = true,

    hideUnarmed = true
}



Config.Cinematic = {
    enabled = true,

    command = 'cinematic',

hideMinimap = true,
hidePlayerHud = true,
hideVehicleHud = false,
hidePlayerInfo = false,

    blackBars = true
}



Config.Settings = {
    enabled = true,

    allowScale = true,
    allowAccentColor = true,

    allowStatusStyle = true,
    allowVehicleStyle = true,

    allowMinimapMode = true,

    allowMinimapShape = true,

    allowElementToggle = true,

    allowLayoutEditor = true,

    allowReset = true
}





Config.Layout = {
    enabled = true,

    movable = {
        status = true,
        playerInfo = true,
        vehicle = true,
        location = true,
        voice = false,
        weapon = true
    }
}



Config.Colors = {
    presets = {
        {
            name = 'Wienta Purple',
            value = '#7C5CFF'
        },

        {
            name = 'Blue',
            value = '#3B82F6'
        },

        {
            name = 'Red',
            value = '#EF4444'
        },

        {
            name = 'Green',
            value = '#22C55E'
        },

        {
            name = 'Orange',
            value = '#F97316'
        },

        {
            name = 'White',
            value = '#FFFFFF'
        }
    },

    allowCustom = true
}



Config.Dynamic = {
    enabled = true,

    hideFullHealth = false,

    hideEmptyArmor = true,

    hideHighHunger = true,
    hideHighThirst = true,

    hideZeroStress = true,

    staminaOnlyWhenRunning = true,
    oxygenOnlyUnderwater = true
}



Config.Performance = {
    statusInterval = 350,
    vehicleInterval = 75,
    locationInterval = 500,

    inactiveInterval = 1000
}



Config.Kvp = {
    enabled = true,

    prefix = 'wienta_hud_'
}



Config.Debug = false