-- ============================================
-- Vehicle List UI - Client Script
-- ============================================

local isMenuOpen = false

-- ---- Open the vehicle list menu ----
RegisterCommand('vehiclelist', function()
    if isMenuOpen then return end
    TriggerServerEvent('esx_vehiclelist:requestVehicles')
end, false)

-- Register a keybind (F5 by default)
RegisterKeyMapping('vehiclelist', 'Open Vehicle List', 'keyboard', 'F5')

-- ---- Receive vehicles from server ----
RegisterNetEvent('esx_vehiclelist:receiveVehicles')
AddEventHandler('esx_vehiclelist:receiveVehicles', function(vehicles)
    local processedVehicles = {}

    for _, v in ipairs(vehicles) do
        local vehicleData = {
            name = v.name or GetLabelText(GetDisplayNameFromVehicleModel(v.model)) or 'Unknown',
            brand = v.brand or 'Unknown',
            plate = v.plate or 'N/A',
            model = v.model or '',
            status = v.status or 'garage',
            image = v.image or nil,
            stats = v.stats or { speed = 50, acceleration = 50, traction = 50, braking = 50 },
            durability = v.durability or { engine = 100, body = 100, fuel = 100, oil = 100 },
            cosmetics = v.cosmetics or {
                primaryColor = '#333333',
                secondaryColor = '#333333',
                mods = {}
            }
        }

        -- Extract stats from vehicle properties if available
        if v.vehicle then
            vehicleData.stats = extractVehicleStats(v.vehicle)
            vehicleData.durability = extractDurability(v.vehicle)
            vehicleData.cosmetics = extractCosmetics(v.vehicle)
        end

        table.insert(processedVehicles, vehicleData)
    end

    -- Send to NUI
    SendNUIMessage({
        action = 'open',
        vehicles = processedVehicles
    })

    SetNuiFocus(true, true)
    isMenuOpen = true
end)

-- ---- Extract performance stats from vehicle properties ----
function extractVehicleStats(vehicleProps)
    local stats = {
        speed = 50,
        acceleration = 50,
        traction = 50,
        braking = 50
    }

    if not vehicleProps then return stats end

    -- Calculate based on mods
    local engineLevel = (vehicleProps.modEngine or -1) + 1
    local turbo = vehicleProps.modTurbo or false
    local transmission = (vehicleProps.modTransmission or -1) + 1
    local brakes = (vehicleProps.modBrakes or -1) + 1
    local suspension = (vehicleProps.modSuspension or -1) + 1

    -- Speed: base 50 + engine mods + turbo
    stats.speed = math.min(100, 50 + (engineLevel * 10) + (turbo and 15 or 0))

    -- Acceleration: base 50 + engine + turbo + transmission
    stats.acceleration = math.min(100, 45 + (engineLevel * 8) + (turbo and 12 or 0) + (transmission * 6))

    -- Traction: base 50 + suspension
    stats.traction = math.min(100, 55 + (suspension * 9))

    -- Braking: base 50 + brakes
    stats.braking = math.min(100, 50 + (brakes * 12))

    return stats
end

-- ---- Extract durability from vehicle properties ----
function extractDurability(vehicleProps)
    local durability = {
        engine = 100,
        body = 100,
        fuel = 100,
        oil = 100
    }

    if not vehicleProps then return durability end

    -- Engine health: 0-1000 mapped to 0-100%
    if vehicleProps.engineHealth then
        durability.engine = math.max(0, math.min(100, vehicleProps.engineHealth / 10))
    end

    -- Body health: 0-1000 mapped to 0-100%
    if vehicleProps.bodyHealth then
        durability.body = math.max(0, math.min(100, vehicleProps.bodyHealth / 10))
    end

    -- Fuel level: 0-100
    if vehicleProps.fuelLevel then
        durability.fuel = math.max(0, math.min(100, vehicleProps.fuelLevel))
    end

    -- Oil level (if your server tracks this)
    if vehicleProps.oilLevel then
        durability.oil = math.max(0, math.min(100, vehicleProps.oilLevel))
    end

    return durability
end

-- ---- Extract cosmetic data from vehicle properties ----
function extractCosmetics(vehicleProps)
    local cosmetics = {
        primaryColor = '#333333',
        secondaryColor = '#333333',
        mods = {}
    }

    if not vehicleProps then return cosmetics end

    -- Convert GTA color index to hex (simplified mapping)
    if vehicleProps.color1 then
        cosmetics.primaryColor = colorIndexToHex(vehicleProps.color1)
    end
    if vehicleProps.color2 then
        cosmetics.secondaryColor = colorIndexToHex(vehicleProps.color2)
    end

    -- Build mods list
    local mods = {}

    local engineLevel = (vehicleProps.modEngine or -1) + 1
    if engineLevel > 0 then
        table.insert(mods, { name = 'Engine', value = 'Level ' .. engineLevel })
    end

    if vehicleProps.modTurbo then
        table.insert(mods, { name = 'Turbo', value = vehicleProps.modTurbo })
    end

    local transmissionLevel = (vehicleProps.modTransmission or -1) + 1
    if transmissionLevel > 0 then
        table.insert(mods, { name = 'Transmission', value = 'Level ' .. transmissionLevel })
    end

    local brakesLevel = (vehicleProps.modBrakes or -1) + 1
    if brakesLevel > 0 then
        table.insert(mods, { name = 'Brakes', value = 'Level ' .. brakesLevel })
    end

    local suspensionLevel = (vehicleProps.modSuspension or -1) + 1
    if suspensionLevel > 0 then
        table.insert(mods, { name = 'Suspension', value = 'Level ' .. suspensionLevel })
    end

    local armorLevel = (vehicleProps.modArmor or -1) + 1
    if armorLevel > 0 then
        table.insert(mods, { name = 'Armor', value = 'Level ' .. armorLevel })
    end

    if vehicleProps.xenonColor then
        table.insert(mods, { name = 'Xenon', value = true })
    end

    if vehicleProps.neonEnabled then
        table.insert(mods, { name = 'Neon', value = true })
    end

    cosmetics.mods = mods
    return cosmetics
end

-- ---- GTA Color Index to Hex (common colors) ----
function colorIndexToHex(index)
    local colors = {
        [0]  = '#0d1116', -- Metallic Black
        [1]  = '#1c2529', -- Metallic Graphite Black
        [2]  = '#333333', -- Metallic Black Steel
        [3]  = '#545c60', -- Metallic Dark Silver
        [4]  = '#888c8c', -- Metallic Silver
        [5]  = '#c2c4c4', -- Metallic Blue Silver
        [6]  = '#979a97', -- Metallic Steel Gray
        [7]  = '#637380', -- Metallic Shadow Silver
        [8]  = '#4b5a5e', -- Metallic Stone Silver
        [9]  = '#35383b', -- Metallic Midnight Silver
        [10] = '#262b2f', -- Metallic Gun Metal
        [11] = '#2b3033', -- Metallic Anthracite Grey
        [27] = '#c00e1a', -- Metallic Red
        [28] = '#da1918', -- Metallic Torino Red
        [29] = '#b6111b', -- Metallic Formula Red
        [35] = '#2354a1', -- Metallic Blue
        [36] = '#6ea3c6', -- Metallic Ultra Blue
        [37] = '#3b7ea1', -- Metallic Racing Blue
        [49] = '#155c2d', -- Metallic Green
        [53] = '#ffdf00', -- Metallic Yellow
        [54] = '#ffd600', -- Metallic Race Yellow
        [55] = '#f5a623', -- Metallic Bronze
        [64] = '#f59e0b', -- Metallic Orange
        [88] = '#4a2f7f', -- Metallic Purple
        [111] = '#ffffff', -- Pure White
        [112] = '#f2f2f2', -- Worn White
        [134] = '#e74c3c', -- Bright Red
        [135] = '#3498db', -- Bright Blue
        [136] = '#2ecc71', -- Bright Green
        [138] = '#f1c40f', -- Bright Yellow
        [141] = '#9b59b6', -- Bright Purple
    }
    return colors[index] or '#333333'
end

-- ---- NUI Callbacks ----
RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    isMenuOpen = false
    cb({})
end)

RegisterNUICallback('selectVehicle', function(data, cb)
    -- Notify server about vehicle selection (for preview camera, etc.)
    TriggerServerEvent('esx_vehiclelist:selectVehicle', data.plate)
    cb({})
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    TriggerServerEvent('esx_vehiclelist:spawnVehicle', data.plate, data.model)
    cb({})
end)

RegisterNUICallback('repairVehicle', function(data, cb)
    TriggerServerEvent('esx_vehiclelist:repairVehicle', data.plate)
    cb({})
end)

RegisterNUICallback('transferVehicle', function(data, cb)
    TriggerServerEvent('esx_vehiclelist:transferVehicle', data.plate)
    cb({})
end)
