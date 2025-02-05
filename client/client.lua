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

--Vector3 - cpCoords, cpNextCoords
--Number - cpType, radius, blipType, blipColor
--Boolean - setRoute
--colorTable(RGBA) - color
-- https://docs.fivem.net/docs/game-references/blips/
-- https://docs.fivem.net/docs/game-references/checkpoints/

function CreateCheckpoint(cpType, cpCoords, cpNextCoords, radius, color, blipType, blipColor, setRoute)

    -- Remove any existing checkpoint
    if checkpoint then
        DeleteCheckpoint(checkpoint)
        checkpoint = nil
    end

    checkpoint = CreateCheckpoint(
        cpType,  -- Cylinder type
        cpCoords.x, cpCoords.y, cpCoords.z,  -- Position
        cpNextCoords.x, cpNextCoords.y, cpNextCoords.z,  -- Target position
        radius,  -- Radius
        color.r, color.g, color.b, color.a,  -- RGBA
        0  -- Reserved, always 0
    )

    local blip = AddBlipForCoord(cpCoords.x, cpCoords.y, cpCoords.z)
    SetBlipSprite(blip, blipType)
    SetBlipColour(blip, blipColor) 
    SetBlipRoute(blip, setRoute)

    -- Monitor player distance to checkpoint
    Citizen.CreateThread(function()
        while checkpoint do
            Citizen.Wait(500)

            local player = PlayerPedId()
            local playerCoords = GetEntityCoords(player)

            if #(playerCoords - cpCoords) < 5.0 then
                print("Checkpoint reached!")
                DeleteCheckpoint(checkpoint)
                RemoveBlip(blip)
                checkpoint = nil
                return true
            end
        end
    end)
end


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


