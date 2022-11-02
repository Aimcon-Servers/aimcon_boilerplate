ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local function getIdentifiers(id)

    local steam_d  = 0

    for k,v in pairs(GetPlayerIdentifiers(id))do

        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            steam_d = v
        end

    end
    return(steam_d)
end

ESX.RegisterServerCallback("aimcon_vehicleshop:getVehicles", function(source, cb)
    MySQL.Async.fetchAll("SELECT * FROM vehicles ", {}, function(vehicles)
        MySQL.Async.fetchAll("SELECT * FROM vehicle_categories ", {}, function(categories)
            cb({vehicles = vehicles, categories = categories})
        end)
    end)
end)

ESX.RegisterServerCallback("aimcon_vehicleshop:canBuy", function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    local steamid = getIdentifiers(source)
    print(json.encode(data))
    MySQL.Async.fetchAll("SELECT * FROM vehicles WHERE model = @model",{["model"] = data.vehicle}, function(results)
        print(xPlayer.getAccount('bank').money)
        if xPlayer.getMoney() >= results[1].price then 
            xPlayer.removeAccountMoney('money', results[1].price)
            
            MySQL.Async.execute("INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)",{
                ["@owner"] = steamid,
                ["@plate"] = data.plate, 
                ["@vehicle"] = json.encode(data.vehicleProps)
            })
            cb({money=true,label=results[1].name})
        elseif xPlayer.getAccount('bank').money >= results[1].price then 
            xPlayer.removeAccountMoney('bank', results[1].price)
            
            MySQL.Async.execute("INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)",{
                ["@owner"] = steamid,
                ["@plate"] = data.plate, 
                ["@vehicle"] = json.encode(data.vehicleProps)
            })
            cb({money=true,label=results[1].name})
        else
            cb({money=false,label=false})
        end
    end)
end)