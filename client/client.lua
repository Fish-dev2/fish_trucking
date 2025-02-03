local trucks = LoadResourceFile(GetCurrentResourceName(), "data/trucks.txt")
local trailers = LoadResourceFile(GetCurrentResourceName(), "data/trailers.txt")

if trucks and trailers then
    print("Trucks File Content:\n" .. trucks)
    print("Trailers File Content:\n" .. trailers)
else
    print("Failed to load file!")
end



--first i should add teleporting and waypoint reading


RegisterCommand('truck', function(_,args)
    local targetId = args[1]

    

    if not targetId then
        TriggerEvent('chat:addMessage', {
            args = {'Please provide a target ID.',}
        })
        return
    end

end)
RegisterCommand('trailer', function(_,args)


end)





RegisterCommand('+teleportwaypoint', function(_,args)
    local playerped = PlayerPedId()
    local waypoint = GetFirstBlipInfoId(8) -- 8 is the ID for waypoints
    if DoesBlipExist(waypoint) then
        local x, y, z = table.unpack(GetBlipCoords(waypoint))

        local groundZ = nil
        local retval = nil
        for i=0, 1000.0, 75.0 do
            StartPlayerTeleport(PlayerId(), x, y, i, 0.0, false, false, true)

            --Wait(100)
            while IsPlayerTeleportActive() do
                Citizen.Wait(0)
            end

            retval, groundZ = GetGroundZFor_3dCoord(x, y, i, true)

            if retval then
                break
            end
        end
        --Wait(300)
        
        print(retval)
        print(groundZ)

        StartPlayerTeleport(PlayerId(), x, y, groundZ+5.0, 0.0, false, true, true)
        while IsPlayerTeleportActive() do
            Citizen.Wait(0)
        end

        TriggerEvent('chat:addMessage', {
            args = {'Waypoint Coords: ', coords}
        })

    else
        TriggerEvent('chat:addMessage', {
            args = {'No waypoint set.',}
        })
    end
end)

RegisterCommand('getcoords', function(_,args)
    local playerCoords = GetEntityCoords(PlayerPedId())
    print(playerCoords)
end)



RegisterKeyMapping('+teleportwaypoint', 'Teleport To Marked Waypoint', 'keyboard', 'PAGEUP')