ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('drugs:SellBatch', function(data)
    local xPlayer = ESX.GetPlayerFromId(source)
    local npcData = data.npc

    if not npcData or not npcData.items then return end

    local soldSomething = false 

    for _, item in ipairs(npcData.items) do
        local count = xPlayer.getInventoryItem(item.name).count
        if count > 0 then
            soldSomething = true

            local amountToSell = math.random(item.sellAmountMin, item.sellAmountMax)
            if amountToSell > count then amountToSell = count end

            local totalPrice = 0
            for i = 1, amountToSell do
                local price = math.random(item.priceMin, item.priceMax)
                totalPrice = totalPrice + price
            end

            xPlayer.removeInventoryItem(item.name, amountToSell)
            xPlayer.addAccountMoney('black_money', totalPrice)

            if Config.NotifyType == "esx" then
                xPlayer.showNotification("Je hebt " .. amountToSell .. "x " .. item.label .. " verkocht voor €" .. totalPrice)
            end
        end
    end

    if not soldSomething and Config.NotifyType == "esx" then
        xPlayer.showNotification("Je hebt geen items om te verkopen!")
    end
end)

RegisterCommand("debug_drugs", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local discordID = nil
    for k,v in pairs(GetPlayerIdentifiers(source)) do
        if string.find(v, "discord:") then
            discordID = v
            break
        end
    end

    if not discordID then
        xPlayer.showNotification("Je hebt geen Discord gekoppeld!")
        return
    end

    local allowed = false
    for _, id in ipairs(Config.AllowedDiscord) do
        if discordID == "discord:"..id then
            allowed = true
            break
        end
    end

    if not allowed then
        xPlayer.showNotification("Je mag dit command niet uitvoeren!")
        return
    end

    local toggle = args[1]
    if toggle ~= "on" and toggle ~= "off" then
        xPlayer.showNotification("Gebruik: /debug_drugs on | off")
        return
    end

    TriggerClientEvent("nrp-selldrugs:toggleDeliveryBlips", source, toggle)
end)

RegisterNetEvent('esx_sellToPed:attemptSell', function(netPed)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local SellAmount = type(Config.Amount) == 'table' and math.random(Config.Amount[1], Config.Amount[2]) or Config.Amount
    if not xPlayer then return end

    local xPlayers = ESX.GetExtendedPlayers('job', 'police')
    if #xPlayers < Config.MinPolice then
        --Config.Notify(src, 'error', 'Er zijn niet genoeg politieagenten in dienst.')
        TriggerClientEvent('esx:showNotification', src, "Er zijn niet genoeg politieagenten in dienst.")
        return
    end

    local item = xPlayer.getInventoryItem(Config.Item)
    if not item or item.count < SellAmount then
        --Config.Notify(src, 'error', 'Je hebt geen ' .. Config.Item .. ' om te verkopen.')
        TriggerClientEvent('esx:showNotification', src, "Je hebt geen " .. Config.Item .. " om te verkopen")
        return
    end

    if math.random() <= Config.AcceptChance then
        xPlayer.removeInventoryItem(Config.Item, SellAmount)
        local pay = math.random(Config.MinPay, Config.MaxPay)

        if Config.BlackMoney then
            xPlayer.addAccountMoney('black_money', pay)
        else
            xPlayer.addMoney(pay)
        end

        --Config.Notify(src, 'success', 'De ped kocht het voor €' .. pay)
        TriggerClientEvent('esx:showNotification', src, "Je verkocht " .. item.count .. "x " .. Config.Item .. " voor €" .. pay)
        TriggerClientEvent('esx_sellToPed:clientResult', src, netPed, 'success')
    else
        --Config.Notify(src, 'error', 'De ped weigert de drugs te kopen.')
        TriggerClientEvent('esx:showNotification', src, "De ped weigert de drugs te kopen")
        TriggerClientEvent('esx_sellToPed:clientResult', src, netPed, 'refused')
        if math.random() <= Config.AlertChance then
            local pedCoords = GetEntityCoords(NetworkGetEntityFromNetworkId(netPed))
            if pedCoords then
                for _, cop in pairs(xPlayers) do
                    TriggerClientEvent('esx_sellToPed:policeAlert', cop.source, pedCoords)
                    TriggerClientEvent(Config.DispatchEvent, cop.source, {
                        title = Config.DispatchTitle,
                        coords = pedCoords,
                        description = 'Melding van een verdachte drugsdeal'
                    })
                end
                if Config.Debug then
                    print(('[DEBUG] Politie melding gestuurd voor ped bij: %s'):format(json.encode(pedCoords)))
                end
            end
        end
    end
end)



