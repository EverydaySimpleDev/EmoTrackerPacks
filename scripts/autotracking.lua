local onRetrieved = function(key, val)
    local o = Tracker:FindObjectForCode(key)
    -- a is toggle, b is consumable, c is progressive toggle
    ---@cast o JsonItem
    if key == "a" then
        if type(val) == "number" then; o.Active = val > 0
        elseif type(val) == "string" then; o.Active = val ~= ""
        else; o.Active = not(not val)
        end
        print(key .. " = " .. tostring(val) .. " -> " .. tostring(o.Active))
    elseif key == "b" then
        if type(val) == "number" then; o.AcquiredCount = val
        else; o.AcquiredCount = 0
        end
        print(key .. " = " .. tostring(val) .. " -> " .. o.AcquiredCount)
    elseif key == "c" then
        if type(val) == "table" and type(val[2]) == "number" then
            if type(val[1]) == "number" then; o.Active = val[1]>0
            else; o.Active = not(not val[1])
            end
            o.CurrentStage = val[2]
        else
            o.Active = false
        end
        print(key .. " = " .. tostring(val) .. " -> " .. tostring(o.Active) .. "," .. o.CurrentStage)
    else
        print(key .. " = " .. tostring(val))
    end
end


local onClear = function()
    Archipelago:SetNotify({"a", "b", "c"}) -- listen for changes
    Archipelago:Get({"a", "b", "c"}) -- ask for current values
end


Archipelago:AddClearHandler("Clear", onClear) -- called when connecting
Archipelago:AddRetrievedHandler("Retrieved", onRetrieved) -- called when doing Get
Archipelago:AddSetReplyHandler("Retrieved", onRetrieved) -- called when a watched value got updated
print("running!")