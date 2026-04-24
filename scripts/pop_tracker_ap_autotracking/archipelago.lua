AUTOTRACKER_ENABLE_ITEM_TRACKING = true
AUTOTRACKER_ENABLE_LOCATION_TRACKING = true
AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP = false

ScriptHost:LoadScript("scripts/pop_tracker_ap_autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/pop_tracker_ap_autotracking/location_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

function onClear(slot_data)
    print("starting onClear")
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
    end
    SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    for _, v in pairs(LOCATION_MAPPING) do
        if v[1] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing location %s", v[1]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[1]:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.ChestCount
                else
                    obj.Active = false
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    -- reset items
    for _, v in pairs(ITEM_MAPPING) do
        if v[1] and v[2] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing item %s of type %s", v[1], v[2]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    obj.CurrentStage = 0
                    obj.Active = false
                elseif v[2] == "consumable" then
                    obj.AcquiredCount = 0
                -- elseif v[2] == "toggle_badged" then

                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: unknown item type %s for code %s", v[2], v[1]))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    LOCAL_ITEMS = {}
    GLOBAL_ITEMS = {}

    print('getting slot options')
    print('contents of slot_data')
    for key,value in pairs(slot_data) do
        print(key, value)
    end

end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)

    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
    end

    if not AUTOTRACKER_ENABLE_ITEM_TRACKING then
        return
    end

    if index <= CUR_INDEX then
        return
    end

    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;

    local v = ITEM_MAPPING[item_id]

    if not v then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: could not find item mapping for id %s", item_name))
        end
        return
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: code: %s, type %s", v[1], v[2]))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])

    if obj then
        if v[2] == "toggle" then
            obj.Active = true
        elseif v[2] == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif v[2] == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: unknown item type %s for code %s", v[2], v[1]))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: could not find object for code %s", v[1]))
    end
    -- if a letter is recieved, increment letters
    if string.find(item_name, "Letter to") then
        local obj = Tracker:FindObjectForCode("letters")
        if obj and obj.AcquiredCount < 3 then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        end
    end
    -- track local items via snes interface
    if is_local then
        if LOCAL_ITEMS[v[1]] then
            LOCAL_ITEMS[v[1]] = LOCAL_ITEMS[v[1]] + 1
        else
            LOCAL_ITEMS[v[1]] = 1
        end
    else
        if GLOBAL_ITEMS[v[1]] then
            GLOBAL_ITEMS[v[1]] = GLOBAL_ITEMS[v[1]] + 1
        else
            GLOBAL_ITEMS[v[1]] = 1
        end
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        -- print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
        -- print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
    end
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        
    end
end

-- called when a location gets cleared
function onLocation(location_id, location_name)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onLocation: %s, %s", location_id, location_name))
    end
    if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
        return
    end
    local v = LOCATION_MAPPING[location_id]
    if not v and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
    end
    if not v[1] then
        return
    end


	for _, w in ipairs(v) do

        w = w .. "/Item"
		local obj = Tracker:FindObjectForCode(w)
		if obj then
			if w:sub(1, 1) == "@" then
                obj.AvailableChestCount = 0
				-- obj.AvailableChestCount = obj.AvailableChestCount - 1
			elseif obj.Type == "progressive" then
				obj.CurrentStage = obj.CurrentStage + 1
			else
				obj.Active = true
			end
		elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("onLocation: could not find object for code %s", v[1]))
		end
	end
end


local _STAGE_MAPPING = {
    {
        "Living Room",
        {
            {"Living Room", "livingroommap"},
        }
    },
    {
        "Kitchen",
        {
            {"Kitchen", "kitchenmap" },
        }
    },
    {
        "Drain",
        {
            {"Sink Drain", "drainmap" },
        }
    },
    {
        "Backyard",
        {
            { "Backyard", "backyardmap"},
        }
    },
    {
        "Foyer",
        {
            {"Foyer", "foyermap" },
        }
    },
    {
        "Basement",
        {
            { "Basement", "basementmap"},
        }
    },
    {
        "Jenny's Room",
        {
            {"Jenny's Room", "jennysroommap" },
        }
    },
    {
        "Bedroom",
        {
            {"Bedroom", "bedroommap"},
        }
    },
   
}
local STAGE_NAME_TO_TAB_NAME = {}
local STAGE_NAME_TO_EXIT_NAME = {}
for _, pair in ipairs(_STAGE_MAPPING) do

    local tab_name = pair[1]
    local stage_list = pair[2]
    for _, stage_data in ipairs(stage_list) do
        local stage_name = stage_data[1]
        STAGE_NAME_TO_TAB_NAME[stage_name] = tab_name

        local exit_name = stage_data[2]
        if exit_name then
            STAGE_NAME_TO_EXIT_NAME[stage_name] = exit_name

        end
    end
end
_STAGE_MAPPING = nil

_last_activated_tab = ""
function onMap(stage_name)
    if not stage_name then
        return
    end

    print(stage_name)

    
    local tab_name = STAGE_NAME_TO_TAB_NAME[stage_name]

    if tab_name and tab_name ~= _last_activated_tab then
            
        Tracker:UiHint("ActivateTab", tab_name)

        -- Always set the last activated tab, so that if the player has the setting on that only switches when
         -- entering a dungeon, enters a dungeon, leaves, and then re-enters, the map will switch to the dungeon
        -- again.
        last_activated_tab = tab_name
            
    end


    -- Assign the current stage_name to its entrance as read from slot_data
    -- if ENTRANCE_RANDO_ENABLED then
    --     entranceRandoAssignEntranceFromVisitedStage(stage_name, false)
    -- end
end

function entranceRandoAssignEntranceFromVisitedStage(stage_name, prevent_logic_update)
    local exit_name = STAGE_NAME_TO_EXIT_NAME[stage_name]
    if not exit_name then
        print("Could not find an exit_name for "..stage_name)
        return
    end

    local exit = EXITS_BY_NAME[exit_name]
    if not exit then
        print("Could not find an exit with the name "..exit_name)
        return
    end

    local entrance_name = SLOT_DATA_EXIT_TO_ENTRANCE[exit_name]
    if not entrance_name then
        print("Could not find an entrance_name for "..exit_name)
        return
    end

    local entrance = ENTRANCE_BY_NAME[entrance_name]
    if not entrance then
        print("Could not find an entrance with the name "..entrance_name)
        return
    end

    -- Do not replace an existing assignment.
    local set_correctly = entrance:Assign(exit, false, prevent_logic_update)
    if not set_correctly then
        print("Warning: Failed to assign entrance mapping "..entrance_name.." -> "..exit_name..".")
    end
end

-- called when a bounce message is received 
function onBounced(value)
    local slots = value["slots"]
    -- Lua does not support `slots ~= {Archipelago.PlayerNumber}`, so check the first and second values in the table.
    if not slots or not (slots[1] == Archipelago.PlayerNumber and slots[2] == nil) then
        -- All Bounced messages to be processed by this tracker are expected to target the player's slot specifically.
        return
    end

    local data = value["data"]
    if not data then
        return
    end

    -- The key is specified in the AP client.
    onMap(data["chibi_robo_stage_name"])
end


Archipelago:AddBouncedHandler("bounced handler", onBounced)

-- add AP callbacks
-- Archipelago:AddClearHandler("clear handler", onClear)

if AUTOTRACKER_ENABLE_ITEM_TRACKING then
    Archipelago:AddItemHandler("item handler", onItem)
end

if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    Archipelago:AddLocationHandler("location handler", onLocation)
end