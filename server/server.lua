ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_kitchen:canCook', function(source, cb, recipe)
    local xPlayer = ESX.GetPlayerFromId(source)
    local cancook = true

    for k,v in pairs(recipe) do
        if not (xPlayer.getInventoryItem(v.item).count > 0) then
            cancook = false
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('not_enough_ingredients'))
            break
        end
    end

    cb(cancook)
end)

ESX.RegisterServerCallback('esx_kitchen:getLabels', function(source, cb, items)
    local labels = {}
    for k,v in pairs(items) do
        local label = ESX.GetItemLabel(v.item)
        table.insert(labels, {label = label})
    end

    cb(labels)
end)

RegisterNetEvent('esx_kitchen:cook')
AddEventHandler('esx_kitchen:cook', function(recipe, result, count)
    local xPlayer = ESX.GetPlayerFromId(source)

    if Config.WeightESX then
        if xPlayer.canCarryItem(result, count) then
            for k,v in pairs(recipe) do
                xPlayer.removeInventoryItem(v.item, v.count)
            end

            xPlayer.addInventoryItem(result, count)
            xPlayer.showNotification(_U('cooked', ESX.GetItemLabel(result)))
        else
            xPlayer.showNotification(_U('inventory_full'))
        end
    else
        local sourceItem = xPlayer.getInventoryItem(item)

        if sourceItem.limit ~= nil and not ((sourceItem.count + count) > sourceItem.limit) or sourceItem.limit == -1 then
            for k,v in pairs(recipe) do
                xPlayer.removeInventoryItem(v.item, v.count)
            end

            xPlayer.addInventoryItem(result, count)
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('cooked', ESX.GetItemLabel(result)))
        else
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('inventory_full'))
        end
    end
end)