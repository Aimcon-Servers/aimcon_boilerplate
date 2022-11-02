ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	for k,v in pairs(Aimcon.VehicleShops) do
		local blip = AddBlipForCoord(v.x, v.y, v.z)
		SetBlipSprite(blip,225)
		SetBlipScale (blip, 0.8)
		SetBlipAsShortRange(blip, true)
	
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName("Conseccionario")
		EndTextCommandSetBlipName(blip)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1500)
		for k,v in pairs(Aimcon.VehicleShops) do
			distance = #(GetEntityCoords(PlayerPedId()) - v)
			if distance < 10.0 then 
				actualShop = v 
				actualDst = distance
			else
				actualShop = nil
			end
		end
		
	end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if actualShop then 
			DrawMarker(21, actualShop, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0,0.8, 0, 255, 0, 100, false, true, 2, false, false,false, false)
			if actualDst < 3.0 then 
				ESX.ShowHelpNotification("Apreta ~INPUT_CONTEXT~ para ver la tienda")
				if IsControlJustPressed(0, 38) then 
					Aimcon.DrawMenu()
				end
			end
		end
	end
end)


