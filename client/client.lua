--
-- Functions
--


function SpawnCar(args)
    local vehicleName = args[1]

    if not IsModelInCdimage(vehicleName) or not IsModelAVehicle(vehicleName) then
        TriggerEvent('chat:addMessage',{
            args = {'Uh oh, '.. (vehicleName) .. ' is not a vehicle.'}
        })

        return
    end
    
    TriggerEvent('chat:addMessage',{
        args = {'Nice, '.. (vehicleName) .. ' is a vehicle.'}
    })

    RequestModel(vehicleName)

    while not HasModelLoaded(vehicleName) do
        Wait(10)
    end

    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)

    local vehicle = CreateVehicle(
        vehicleName,
        pos,
        heading,
        true
    )

    SetPedIntoVehicle(
        playerPed,
        vehicle,
        -1
    )

    SetModelAsNoLongerNeeded(vehicleName)
end

function Contains(table, content)
    for _, value in ipairs(table) do
        if value == content then
            return true
        end
    end
    return false
end

function SplitString(data)
    a = {}
    local i = 0
    for word in string.gmatch(data, "%S+") do
        i+=1
        a[i] = word
    end

    return a, i
end




--
-- First Load In
--


local trucksData = LoadResourceFile(GetCurrentResourceName(), "data/trucks.txt")
local trailersData = LoadResourceFile(GetCurrentResourceName(), "data/trailers.txt")

if trucksData and trailersData then
    print("trucksData File Content:\n" .. trucksData)
    print("Trailers File Content:\n" .. trailersData)
    print(type(trucksData))
    local trucks, trucksSize = SplitString(trucksData)
    local trailers, trailersSize = SplitString(trailersData)
else
    print("Failed to load file!")
end


--
-- Commands
--


RegisterCommand('truck', function(_,args)

    

end)
RegisterCommand('trailer', function(_,args)


end)





RegisterCommand('+teleportwaypoint', function(_,args)

    DoScreenFadeOut(0)
    local waypointBlip = GetFirstBlipInfoId(GetWaypointBlipEnumId())
	local blipPos = GetBlipInfoIdCoord(waypointBlip) 

	local z = GetHeightmapTopZForPosition(blipPos.x, blipPos.y)
	local _, gz = GetGroundZFor_3dCoord(blipPos.x, blipPos.y, z, true)

	SetEntityCoords(PlayerPedId(), blipPos.x, blipPos.y, z, true, false, false, false)
	FreezeEntityPosition(PlayerPedId(), true)

	repeat
		Citizen.Wait(50)
		_, gz = GetGroundZFor_3dCoord(blipPos.x, blipPos.y, z, true)
	until gz ~= 0

	SetEntityCoords(PlayerPedId(), blipPos.x, blipPos.y, gz, true, false, false, false)
	FreezeEntityPosition(PlayerPedId(), false)

    local coords = string.format("X: %.2f, Y: %.2f, Z: %.2f", blipPos.x, blipPos.y, gz)
    TriggerEvent('chat:addMessage', {
        args = {'Succesful teleport to: ', coords}
    })      
    DoScreenFadeIn(100)

end)

RegisterCommand('getcoords', function(_,args)
    local playerCoords = GetEntityCoords(PlayerPedId())
    print(playerCoords)
end)





RegisterCommand('car', function(source,args)
    SpawnCar(args)
end)

--
-- KeyMappings
--

RegisterKeyMapping('+teleportwaypoint', 'Teleport To Marked Waypoint', 'keyboard', 'PAGEUP')


