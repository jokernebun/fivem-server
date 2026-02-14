-- ============================================
-- Vehicle List UI - Server Script
-- ============================================

-- ---- Request vehicles for a player ----
RegisterServerEvent('esx_vehiclelist:requestVehicles')
AddEventHandler('esx_vehiclelist:requestVehicles', function()
    local source = source
    local identifier = GetPlayerIdentifier(source, 0)

    -- Example: Fetch from database
    -- Replace this with your actual database query (MySQL-Async, oxmysql, etc.)
    -- exports.oxmysql:execute('SELECT * FROM owned_vehicles WHERE owner = ?', { identifier }, function(result)
    --     local vehicles = {}
    --     for _, row in ipairs(result) do
    --         local vehicleProps = json.decode(row.vehicle)
    --         table.insert(vehicles, {
    --             name = row.name or 'Unknown',
    --             brand = row.brand or 'Unknown',
    --             plate = row.plate,
    --             model = row.model or vehicleProps.model,
    --             status = row.state == 0 and 'garage' or (row.state == 1 and 'out' or 'impound'),
    --             vehicle = vehicleProps
    --         })
    --     end
    --     TriggerClientEvent('esx_vehiclelist:receiveVehicles', source, vehicles)
    -- end)

    -- Demo data for testing (remove when database is connected)
    local demoVehicles = {
        {
            name = 'Zentorno',
            brand = 'Pegassi',
            plate = 'ABC 1234',
            model = 'zentorno',
            status = 'garage',
            stats = { speed = 88, acceleration = 82, traction = 70, braking = 55 },
            durability = { engine = 92, body = 78, fuel = 65, oil = 88 },
            cosmetics = {
                primaryColor = '#e74c3c',
                secondaryColor = '#2c3e50',
                mods = {
                    { name = 'Engine', value = 'Level 4' },
                    { name = 'Turbo', value = true },
                    { name = 'Xenon', value = true },
                    { name = 'Suspension', value = 'Level 3' },
                    { name = 'Armor', value = 'Level 2' }
                }
            }
        },
        {
            name = 'Elegy RH8',
            brand = 'Annis',
            plate = 'XYZ 7890',
            model = 'elegy2',
            status = 'out',
            stats = { speed = 75, acceleration = 70, traction = 80, braking = 65 },
            durability = { engine = 45, body = 30, fuel = 20, oil = 60 },
            cosmetics = {
                primaryColor = '#3498db',
                secondaryColor = '#1abc9c',
                mods = {
                    { name = 'Engine', value = 'Level 2' },
                    { name = 'Turbo', value = false },
                    { name = 'Xenon', value = true },
                    { name = 'Brakes', value = 'Level 3' }
                }
            }
        },
        {
            name = 'Sultan RS',
            brand = 'Karin',
            plate = 'IMP 4567',
            model = 'sultanrs',
            status = 'impound',
            stats = { speed = 72, acceleration = 68, traction = 75, braking = 60 },
            durability = { engine = 10, body = 15, fuel = 5, oil = 25 },
            cosmetics = {
                primaryColor = '#f39c12',
                secondaryColor = '#ecf0f1',
                mods = {
                    { name = 'Engine', value = 'Level 1' },
                    { name = 'Turbo', value = true },
                    { name = 'Xenon', value = false }
                }
            }
        },
        {
            name = 'Adder',
            brand = 'Truffade',
            plate = 'LUX 0001',
            model = 'adder',
            status = 'garage',
            stats = { speed = 95, acceleration = 90, traction = 65, braking = 50 },
            durability = { engine = 100, body = 100, fuel = 90, oil = 95 },
            cosmetics = {
                primaryColor = '#1a1a2e',
                secondaryColor = '#e94560',
                mods = {
                    { name = 'Engine', value = 'Level 4' },
                    { name = 'Turbo', value = true },
                    { name = 'Transmission', value = 'Level 3' },
                    { name = 'Xenon', value = true },
                    { name = 'Neon', value = true },
                    { name = 'Armor', value = 'Level 5' }
                }
            }
        },
        {
            name = 'T20',
            brand = 'Progen',
            plate = 'SPD 9999',
            model = 't20',
            status = 'garage',
            stats = { speed = 92, acceleration = 88, traction = 72, braking = 58 },
            durability = { engine = 85, body = 90, fuel = 40, oil = 75 },
            cosmetics = {
                primaryColor = '#ffffff',
                secondaryColor = '#333333',
                mods = {
                    { name = 'Engine', value = 'Level 3' },
                    { name = 'Turbo', value = true },
                    { name = 'Brakes', value = 'Level 2' }
                }
            }
        },
        {
            name = 'Sandking XL',
            brand = 'Vapid',
            plate = 'MUD 4X4',
            model = 'sandking',
            status = 'out',
            stats = { speed = 45, acceleration = 40, traction = 85, braking = 42 },
            durability = { engine = 60, body = 55, fuel = 30, oil = 50 },
            cosmetics = {
                primaryColor = '#2ecc71',
                secondaryColor = '#27ae60',
                mods = {
                    { name = 'Suspension', value = 'Level 4' },
                    { name = 'Armor', value = 'Level 3' }
                }
            }
        }
    }

    TriggerClientEvent('esx_vehiclelist:receiveVehicles', source, demoVehicles)
end)

-- ---- Vehicle actions (stubs - implement with your garage system) ----
RegisterServerEvent('esx_vehiclelist:selectVehicle')
AddEventHandler('esx_vehiclelist:selectVehicle', function(plate)
    local source = source
    -- Handle vehicle selection (e.g., move camera to preview room)
    print('[VehicleList] Player ' .. source .. ' selected vehicle: ' .. plate)
end)

RegisterServerEvent('esx_vehiclelist:spawnVehicle')
AddEventHandler('esx_vehiclelist:spawnVehicle', function(plate, model)
    local source = source
    -- Implement vehicle spawn logic
    print('[VehicleList] Player ' .. source .. ' spawning vehicle: ' .. model .. ' (' .. plate .. ')')
    TriggerClientEvent('esx_vehiclelist:doSpawn', source, plate, model)
end)

RegisterServerEvent('esx_vehiclelist:repairVehicle')
AddEventHandler('esx_vehiclelist:repairVehicle', function(plate)
    local source = source
    -- Implement repair logic (check money, update DB, etc.)
    print('[VehicleList] Player ' .. source .. ' repairing vehicle: ' .. plate)
end)

RegisterServerEvent('esx_vehiclelist:transferVehicle')
AddEventHandler('esx_vehiclelist:transferVehicle', function(plate)
    local source = source
    -- Implement transfer logic
    print('[VehicleList] Player ' .. source .. ' transferring vehicle: ' .. plate)
end)
