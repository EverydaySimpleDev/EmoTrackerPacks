Tracker:AddItems("items/items.json")

Tracker:AddMaps("maps/maps.json")

Tracker:AddLocations("locations/locations.json")

Tracker:AddLayouts("layouts/tracker.json")
Tracker:AddLayouts("layouts/broadcast.json")

if PopVersion then
    -- load AP autotracker
    if PopVersion >= "0.18.0" then
        ScriptHost:LoadScript("scripts/pop_tracker_ap_autotracking/archipelago.lua")

        ScriptHost:AddMemoryWatch("Chibi Robo Item Data", 0x80396576, 8, updateItems)
    end
end