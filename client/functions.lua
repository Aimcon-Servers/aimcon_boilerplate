local spawnedVehicle

Aimcon.LoadVehicle = function()
	modelHash = GetHashKey(modelHash)

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyspinnerOn('STRING')
		AddTextComponentSubstringPlayerName("El vehiculo esta cargando...")
		EndTextCommandBusyspinnerOn(4)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)
			DisableAllControlActions(0)
		end
	end
end

RegisterCommand("pp", function()
    Aimcon.RandomPlate()
end)

Aimcon.RandomPlate = function()
    local plate = ""
    local numbers = {1,2,3,4,5,6,7,8,9}
    local dict = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
    for i = 1,3,1 do 
        local randomLetter = dict[math.random(1, #dict)]
        plate = plate ..randomLetter
    end

    for i=1, 3, 1 do
        local randomNumber = numbers[math.random(1, #numbers)]
        plate = plate..randomNumber
    end
    return(plate)
end

Aimcon.Map = function(tbl, f)
    local t = {}
    local res
    for k,v in pairs(tbl) do
        res = f(v)
        if res then 
            table.insert(t, res)
        end
    end
    return t
end

Aimcon.BuyVehicle = function(vehicle)
    local plate = Aimcon.RandomPlate()
    local vehicleProps = ESX.Game.GetVehicleProperties(spawnedVehicle)
    local playerPed = PlayerPedId()
    ESX.TriggerServerCallback("aimcon_vehicleshop:canBuy", function(cb) 
        if cb.money ~= false and cb.label ~= nil then 
            ESX.UI.Menu.CloseAll()
            SetVehicleNumberPlateText(spawnedVehicle, plate)
            SetEntityCoords(spawnedVehicle,234.76,-783.84,30.62)
            FreezeEntityPosition(spawnedVehicle, false)
            FreezeEntityPosition(playerPed, false)
            SetEntityVisible(playerPed, true)
            ESX.ShowAdvancedNotification('Concesionario', '', "~g~Compraste un ".. cb.label , "CHAR_BANK_MAZE", 3)
        else
            ESX.ShowAdvancedNotification('Concesionario', '', "~r~No tenes el dinero suficiente para comprar esto", "CHAR_BANK_MAZE", 3)
        end
    end, {vehicleProps=vehicleProps,vehicle=vehicle, plate=plate})
end

Aimcon.TestVehicle = function(vehicletoSpawn)
    DeleteEntity(spawnedVehicle)
    local counter = -1
    local vehicleSpawned = nil
    local playerPed = PlayerPedId()
    

    ESX.ShowAdvancedNotification('Test Drive', '', "Tenes ".. Aimcon.TestDriveTime.. " segundos para probar el vehiculo", "CHAR_BANK_MAZE", 3)

    ESX.Game.SpawnLocalVehicle(vehicletoSpawn, Aimcon.TestDriveLoad, 100.0, function(vehicle)
        vehicleSpawned = vehicle
        counter = Aimcon.TestDriveTime
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
        SetEntityCoords(vehicleSpawned, Aimcon.TestDrive)
    end)

    


    EnableAllControlActions(0)
    
    FreezeEntityPosition(playerPed, false)
    SetEntityVisible(playerPed, true)

    
    while true do 
        Citizen.Wait(1000)
        if counter > 0 then 
            counter = counter - 1
        elseif counter == 0 then
            SetModelAsNoLongerNeeded(vehicleSpawned)
            DeleteEntity(vehicleSpawned)
            SetEntityCoords(playerPed, Aimcon.ReturnZone)
            vehicleSpawned = nil
            counter = -1
        end
    end

end

function DeleteDisplayVehicleInsideShop()
	local attempt = 0

	if spawnedVehicle and DoesEntityExist(spawnedVehicle) then
		while DoesEntityExist(spawnedVehicle) and not NetworkHasControlOfEntity(spawnedVehicle) and attempt < 100 do
			Citizen.Wait(100)
			NetworkRequestControlOfEntity(spawnedVehicle)
			attempt = attempt + 1
		end

		if DoesEntityExist(spawnedVehicle) and NetworkHasControlOfEntity(spawnedVehicle) then
			ESX.Game.DeleteVehicle(spawnedVehicle)
		end
	end
end

Aimcon.View = function()

    local elements = {
    }
    
    ESX.TriggerServerCallback("aimcon_vehicleshop:getVehicles", function(cb)  
        for k,v in pairs(cb.categories) do 
            print(v.label, v.name)
            table.insert(elements, {label = v.label, value = v.name})
        end



        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu_selectvehicle', {
            title = 'Categorias',
            align = 'right',
            elements = elements
            }, function(data, menu)
                if data.current then 
                    local vehicleCategory = Aimcon.Map(cb.vehicles, function(item)
                        if item.category == data.current.value then 
                            return item
                        end
                    end)

                    local elements = {}

                    for k,v in pairs(vehicleCategory) do 
                        table.insert(elements, {label = v.name, value = v.model})
                    end
                
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'aaaaaa', {
                        title = data.current.label,
                        align = 'right',
                        elements = elements
                        }, function(data2, menu2)
                            local model = data2.current.value

                            local elements = {
                                {label = "Comprar", value = "buy"},
                                {label = "Test drive", value = "test"}
                            }
                        
                            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'buyOrTest', {
                                title = 'Que queres hacer?',
                                align = 'right',
                                elements = elements
                                }, function(data3, menu3)
                                    local opt = data3.current.value
                        
                                    if opt == "buy" then
                                        Aimcon.BuyVehicle(model)
                                    elseif opt == "test" then
                                        ESX.UI.Menu.CloseAll()
                                        Aimcon.TestVehicle(model)
                                    end
                                end, function(data3, menu3)
                                menu3.close()
                                --local playerPed = PlayerPedId()
                        --
                                --FreezeEntityPosition(playerPed, false)
                                --SetEntityVisible(playerPed, true)
                                --SetEntityCoords(playerPed, Aimcon.ReturnZone)
                            end)
                

                        end, function(data2, menu2)
                            ESX.UI.Menu.CloseAll()
                            DeleteDisplayVehicleInsideShop()
                            local playerPed = PlayerPedId()
                    
                            FreezeEntityPosition(playerPed, false)
                            SetEntityVisible(playerPed, true)
                            SetEntityCoords(playerPed, Aimcon.ReturnZone)
                        end, function(data2, menu2)
                            
                            local actualVehicle = data2.current.value
                            DeleteDisplayVehicleInsideShop(spawnedVehicle)
                            EndTextCommandBusyspinnerOn(3)
                            while not HasModelLoaded(GetHashKey(actualVehicle)) do 
                                Citizen.Wait(0)
                                DisableAllControlActions(0)
                                RequestModel(actualVehicle)
                                BeginTextCommandBusyspinnerOn('STRING')
                                AddTextComponentSubstringPlayerName("El vehiculo esta cargando...")
                            end
                    
                            BusyspinnerOff()
                    
                            ESX.Game.SpawnLocalVehicle(actualVehicle, Aimcon.ZoneToViewVehicles, 100.0, function(vehicle)
                                spawnedVehicle = vehicle
                                TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                                FreezeEntityPosition(vehicle, true)
                              --  SetModelAsNoLongerNeeded(actualVehicle)
                            end)

                    end)
                end
            end, function(data, menu)
                ESX.UI.Menu.CloseAll()
        end)
    end)

end


Aimcon.DrawMenu = function()
    local elements = {
        {label = "Ver Tienda", value = "view"},
    }

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'menu_vehicleshop', {
        title = 'Menu de tienda',
        align = 'right',
        elements = elements
        }, function(data, menu)
            local v = data.current.value

            if v == "view" then
                Aimcon.View()
            end
        end, function(data, menu)
        menu.close()
    end)
end