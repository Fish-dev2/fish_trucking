local trucks = LoadResourceFile(GetCurrentResourceName(), "data/trucks.txt")
local trailers = LoadResourceFile(GetCurrentResourceName(), "data/trailers.txt")

if trucks and trailers then
    print("Trucks File Content:\n" .. trucks)
    print("Trailers File Content:\n" .. trailers)
else
    print("Failed to load file!")
end


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