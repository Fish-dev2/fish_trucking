--
-- Algorithm Functions
--

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
-- Game Function
--


function SpawnCar(args)
    local vehicleName = args[1]
    local trailerName = args[2]
    
    RequestModel(vehicleName)

    while not HasModelLoaded(vehicleName) do
        Wait(1)
    end

    RequestModel(trailerName)

    while not HasModelLoaded(trailerName) do
        Wait(1)
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

    local trailer = CreateVehicle(
        trailerName,
        pos,
        heading,
        true
    )

    AttachVehicleToTrailer(vehicle, trailer, 1.1)

    SetPedIntoVehicle(
        playerPed,
        vehicle,
        -1
    )

    SetModelAsNoLongerNeeded(vehicleName)
    SetModelAsNoLongerNeeded(trailerName)

end


--
-- First Load In
--


local trucksData = LoadResourceFile(GetCurrentResourceName(), "data/trucks.txt")
local trailersData = LoadResourceFile(GetCurrentResourceName(), "data/trailers.txt")
local trucks, trailers, trucksSize, trailersSize

if trucksData and trailersData then
    print("trucksData File Content:\n" .. trucksData)
    print("Trailers File Content:\n" .. trailersData)
    print(type(trucksData))
    trucks, trucksSize = SplitString(trucksData)
    trailers, trailersSize = SplitString(trailersData)
else
    print("Failed to load file!")
end


--
-- Commands
--


RegisterCommand('truck', function(_,args)
    local vehicleName = args[1]
    local trailerName = args[2]
    if (Contains(trucks, vehicleName) and Contains(trailers,trailerName)) then
        SpawnCar(args)
    end


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


