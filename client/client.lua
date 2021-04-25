ESX = nil
local markers = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

function OpenCookingMenu()
    local elements = {}

    for k,v in pairs(Config.Recipes) do
        table.insert(elements, {label = v.label, value = k})
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cookmenu', {
        title = _U('cook_menu'),
        align = 'center',
        elements = elements
    }, function(data, menu)
            menu.close()
            DisplayIngredients(data.current.value)
    end, function(data, menu)
        menu.close()
    end)
end

function DisplayIngredients(key)
    local itemInfo = Config.Recipes[key]
    ESX.TriggerServerCallback('esx_kitchen:getLabels', function(items)
        local elements = {}
        for k,v in pairs(items) do
            table.insert(elements, {label = v.label})
        end

        table.insert(elements, {label = _U('confirm_cook'), value = 'startcook'})

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'ingredientsmenu', {
            title = _U('ingredients_menu'),
            align = 'center',
            elements = elements
        }, function(data, menu)
                if data.current.value == 'startcook' then
                    ESX.TriggerServerCallback('esx_kitchen:canCook', function(cancook)
                        if cancook then
                            StartCooking(key)     
                        end
                    end, itemInfo.itemsNeeded)
                    menu.close()
                end
        end, function(data, menu)
            menu.close()
        end)
    end, itemInfo.itemsNeeded)
end

function StartCooking(key)
    local itemInfo = Config.Recipes[key]
    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BBQ", 0, false)
    TriggerEvent("mythic_progbar:client:progress", {
        name = "cooking",
        duration = itemInfo.duration,
        label = _U('cook_progress', itemInfo.label), 
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }
    }, function(status)
        if not status then
            TriggerServerEvent('esx_kitchen:cook', itemInfo.itemsNeeded, itemInfo.item, itemInfo.count)
            ClearPedTasksImmediately(PlayerPedId())
        elseif status then
            ClearPedTasksImmediately(PlayerPedId())
        end
    end)
end

function createBlip(coords, sprite, colour, name)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 1.2)
	SetBlipColour (blip, colour)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(name)
	EndTextCommandSetBlipName(blip)
end

AddEventHandler('onClientResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for k, v in pairs(markers) do
            DeleteCheckpoint(v)
        end
    end
end)

Citizen.CreateThread(function()
    for k,v in pairs(Config.Locations) do
        local point = CreateCheckpoint(47, v.coords, 0, 0, 0, 1.5, 0, 0, 255, 127, 0)
        SetCheckpointCylinderHeight(point, 1.0, 1.0, 1.5)
        table.insert(markers, point)
        createBlip(v.coords, v.sprite, v.colour, v.name)
    end
    while true do
        Citizen.Wait(0)
        local pedCoords = GetEntityCoords(PlayerPedId())
        local letSleep = true
                
        for k, v in pairs(Config.Locations) do
            local dist = #(pedCoords - v.coords)
            if dist < 1.5 then
                letSleep = false
                ESX.ShowHelpNotification(_U('cook_prompt'))
                if IsControlJustReleased(0, 38) then
                    OpenCookingMenu()
                end
            end
        end

        if letSleep then
            Citizen.Wait(500)
        end
    end
end)

