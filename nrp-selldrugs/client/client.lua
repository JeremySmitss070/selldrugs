ESX = exports['es_extended']:getSharedObject()

local selling = false
local currentNPCData = nil
local currentDeliveryLocation = nil
local deliveryPed = nil
local deliveryBlip = nil
local sellCooldown = 5000
local tempBlips = {}
local blipsVisible = false
local lastSell = 0
local soldPeds = {}
local trackedPeds = {}
local inNoSellZone = false
local inCity = false

CreateThread(function()
    for _, zone in pairs(Config.NoSellZones) do
        lib.zones.sphere({
            coords = zone.coords,
            radius = zone.radius,
            debug = false,
            inside = function()
                inNoSellZone = true
            end,
            onExit = function()
                inNoSellZone = false
            end
        })
    end
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - Config.CityRestriction.center)

        inCity = (dist <= Config.CityRestriction.radius)
        Wait(1000)
    end
end)

local function PlayKnockAnim()
    local playerPed = PlayerPedId()
    local dict = "anim@mp_player_intmenu@key_fob@"
    local anim = "fob_click"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Citizen.Wait(10) end
    TaskPlayAnim(playerPed, dict, anim, 8.0, -8.0, -1, 49, 0, false, false, false)
end

local function DeleteDeliveryPed()
    if deliveryPed then
        DeleteEntity(deliveryPed)
        deliveryPed = nil
    end
end

local function StopSellingAnim()
    ClearPedTasks(PlayerPedId())
end

--- @param location vector3 
--- @param heading number|nil 
local function SpawnDeliveryPed(location, heading)
    RequestModel(GetHashKey("a_m_m_farmer_01"))
    while not HasModelLoaded(GetHashKey("a_m_m_farmer_01")) do Citizen.Wait(10) end

    deliveryPed = CreatePed(4, GetHashKey("a_m_m_farmer_01"), location.x, location.y, location.z - 1.0, heading or 0.0, false, true)
    SetEntityInvincible(deliveryPed, true)
    SetBlockingOfNonTemporaryEvents(deliveryPed, true)
    FreezeEntityPosition(deliveryPed, true)

    exports.ox_target:addLocalEntity(deliveryPed, {
        {
            name = 'delivery_sell',
            icon = 'fas fa-hand-holding-dollar',
            label = 'Verkoop je drugs',
            onSelect = function()

                PlayKnockAnim()
                if deliveryBlip then RemoveBlip(deliveryBlip) deliveryBlip = nil end
                DeleteDeliveryPed()
                Citizen.SetTimeout(sellCooldown, function()
                    TriggerServerEvent('drugs:SellBatch', { npc = currentNPCData })
                    ESX.ShowNotification("Je hebt je items verkocht!")
                    StartNextDelivery()
                    StopSellingAnim()
                end)
            end
        }
    })
end

--- @param npcData table
function StartSelling(npcData)
    if selling then return end
    selling = true
    currentNPCData = npcData
    StartNextDelivery()

    Citizen.CreateThread(function()
        while selling do
            Citizen.Wait(0)
            if IsControlJustReleased(0, 73) then
                DeleteDeliveryPed()
                if deliveryBlip then RemoveBlip(deliveryBlip) deliveryBlip = nil end
                StopSelling()
                ESX.ShowNotification("Je bent gestopt met verkopen")
            end
        end
    end)
end

function StartNextDelivery()
    if not currentNPCData then return end

    currentDeliveryLocation = currentNPCData.deliveryLocations[math.random(1, #currentNPCData.deliveryLocations)]

    if deliveryBlip then RemoveBlip(deliveryBlip) end
    deliveryBlip = AddBlipForCoord(currentDeliveryLocation.x, currentDeliveryLocation.y, currentDeliveryLocation.z)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipColour(deliveryBlip, 5)
    SetBlipRoute(deliveryBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Delivery locatie")
    EndTextCommandSetBlipName(deliveryBlip)

    SpawnDeliveryPed(currentDeliveryLocation, currentDeliveryLocation.heading)
end

function StopSelling()
    selling = false
    currentNPCData = nil
    currentDeliveryLocation = nil
    StopSellingAnim()
end

Citizen.CreateThread(function()
    for i, npcData in ipairs(Config.Drugs) do
        RequestModel(GetHashKey(npcData.npcModel))
        while not HasModelLoaded(GetHashKey(npcData.npcModel)) do Citizen.Wait(10) end

        local npc = CreatePed(4, GetHashKey(npcData.npcModel), npcData.sellLocation.x, npcData.sellLocation.y, npcData.sellLocation.z - 1.0, npcData.heading or 0.0, false, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        FreezeEntityPosition(npc, true)

        exports.ox_target:addLocalEntity(npc, {
            {
                name = 'sell_npc_' .. i,
                icon = 'fas fa-hand-holding-dollar',
                label = 'Start verkoop ' .. (npcData.label or "drugs"),
                onSelect = function(entity)
                    if not selling then
                        StartSelling(npcData)
                        ESX.ShowNotification("Je bent gestart met het verkopen")
                        ESX.ShowNotification("Rijd naar het punt om je spullen te verkopen!")
                    else
                        DeleteDeliveryPed()
                        if deliveryBlip then RemoveBlip(deliveryBlip) deliveryBlip = nil end
                        StopSelling()
                        ESX.ShowNotification("Je bent gestopt met verkopen")
                    end
                end
            }
        })
    end
end)

--- @param toggle string
RegisterNetEvent("nrp-selldrugs:toggleDeliveryBlips", function(toggle)
    if toggle == "on" then
        if blipsVisible then
            ESX.ShowNotification("Blips zijn al zichtbaar!")
            return
        end

        blipsVisible = true

        for _, npcData in ipairs(Config.Drugs) do
            if npcData.deliveryLocations then
                for _, loc in ipairs(npcData.deliveryLocations) do
                    local blip = AddBlipForCoord(loc.x, loc.y, loc.z)
                    SetBlipSprite(blip, 1)
                    SetBlipColour(blip, 5)
                    SetBlipScale(blip, 0.8)
                    SetBlipAsShortRange(blip, false)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Delivery locatie")
                    EndTextCommandSetBlipName(blip)
                    table.insert(tempBlips, blip)
                end
            end
        end

        ESX.ShowNotification("Delivery-locaties zichtbaar op de map!")

    elseif toggle == "off" then
        if not blipsVisible then
            ESX.ShowNotification("Blips zijn al uitgeschakeld!")
            return
        end

        for _, blip in ipairs(tempBlips) do
            if DoesBlipExist(blip) then RemoveBlip(blip) end
        end
        tempBlips = {}
        blipsVisible = false
        ESX.ShowNotification("Delivery-locaties verborgen!")
    end
end)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/debug_drugs', 'Zet de drugs locaties aan/uit (Alleen developers)', {
        { name = 'on/off', help = 'Gebruik "on" om blips te tonen, "off" om te verbergen' }
    })
end)

local function isValidPed(ped)
    if not DoesEntityExist(ped) then return false end
    if IsPedAPlayer(ped) then return false end
    if IsEntityDead(ped) then return false end
    if IsPedInAnyVehicle(ped, false) then return false end
    if soldPeds[ped] then return false end
    for _, model in pairs(Config.IgnorePedTypes) do
        if GetEntityModel(ped) == model then
            return false
        end
    end
    return true
end

local function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

local function playSellAnimation(ped)
    local playerPed = PlayerPedId()
    TaskTurnPedToFaceEntity(playerPed, ped, 1000)
    TaskTurnPedToFaceEntity(ped, playerPed, 1000)
    Wait(600)

    LoadAnimDict('mp_common')
    TaskPlayAnim(playerPed, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 0, 0, false, false, false)
    TaskPlayAnim(ped, 'mp_common', 'givetake1_b', 8.0, -8.0, -1, 0, 0, false, false, false)

    Wait(2000)

    ClearPedTasks(playerPed)
    ClearPedTasks(ped)
end

local function makePedWalkAway(ped, angry)
    if not DoesEntityExist(ped) or IsPedDeadOrDying(ped) then return end
    local playerPed = PlayerPedId()
    local pCoords = GetEntityCoords(playerPed)
    local pedCoords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local offset = pedCoords + (pedCoords - pCoords) * 2.0
    ClearPedTasks(ped)

    if angry then
        TaskSmartFleePed(ped, playerPed, 25.0, -1, false, false)
        PlayPain(ped, 6, 0)
    else
        TaskGoStraightToCoord(ped, offset.x, offset.y, offset.z, 1.0, -1, heading, 0.0)
    end

    SetPedKeepTask(ped, true)
    SetEntityAsNoLongerNeeded(ped)
end

local function registerPedTarget(ped)
    if trackedPeds[ped] or soldPeds[ped] then return end
    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'sell_drugs_ped',
            icon = 'fa-solid fa-hand-holding-droplet',
            label = 'Verkoop drugs',
            distance = Config.SellDistance,
            onSelect = function()
                if inNoSellZone then
                    ESX.ShowNotification("Je kunt hier geen drugs verkopen")
                    return
                end
                if inCity then
                    ESX.ShowNotification("Je kunt geen drugs verkopen binnen de stad")
                    return
                end
                local now = GetGameTimer()
                if now - lastSell < Config.SellCooldown then
                    --Config.Notify(nil, 'inform', 'Je moet even wachten...')
                    ESX.ShowNotification('Je moet even wachten')
                    return
                end
                lastSell = now

                if not isValidPed(ped) then
                    --Config.Notify(nil, 'error', 'Deze persoon ziet er niet geïnteresseerd uit.')
                    ESX.ShowNotification('Deze persoon ziet er niet geÏnteresseerd uit')
                    return
                end

                TaskTurnPedToFaceEntity(PlayerPedId(), ped, 1000)
                FreezeEntityPosition(ped, true)
                Wait(800)
                local success = lib.progressCircle({
                    duration = math.random(3000, 5000),
                    label = 'Verkoop drugs...',
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {car = true, move = true, combat = true},
                })
                ESX.ShowNotification('Je bent gestart met het verkopen', 3000)
                playSellAnimation(ped)

                soldPeds[ped] = true
                exports.ox_target:removeLocalEntity(ped, 'sell_drugs_ped')
                FreezeEntityPosition(ped, false)
                if not success then
                    --Config.Notify(nil, 'error', 'Verkoop geannuleerd.')
                    FreezeEntityPosition(ped, false)
                    ESX.ShowNotification('Verkoop geannuleerd')
                    return
                end

                TriggerServerEvent('esx_sellToPed:attemptSell', NetworkGetNetworkIdFromEntity(ped))
            end
        }
    })
    trackedPeds[ped] = true
end

RegisterNetEvent('esx_sellToPed:clientResult', function(netPed, result)
    local ped = NetworkGetEntityFromNetworkId(netPed)
    if not DoesEntityExist(ped) then return end

    if result == 'success' then
        makePedWalkAway(ped, false)
    elseif result == 'refused' then
        makePedWalkAway(ped, true)
    end
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local handle, ped = FindFirstPed()
        local success
        repeat
            if isValidPed(ped) then
                local dist = #(playerCoords - GetEntityCoords(ped))
                if dist <= 30.0 then
                    registerPedTarget(ped)
                end
            end
            success, ped = FindNextPed(handle)
        until not success
        EndFindPed(handle)
        Wait(Config.ScanInterval)
    end
end)

RegisterNetEvent('esx_sellToPed:policeAlert', function(coords)
    local blip = AddBlipForRadius(coords.x, coords.y, coords.z, 40.0)
    SetBlipSprite(blip, 161)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 200)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Mogelijke drugsdeal')
    EndTextCommandSetBlipName(blip)
    Wait(15000)
    RemoveBlip(blip)
end)