-- Room access, mirroring the entrance rules in the apworld's rules.py (set_rules).
-- Locations use these as "$can_reach_<room>" in their access_rules, then add whatever
-- that one location needs on top.

function has(code)
    local obj = Tracker:FindObjectForCode(code)
    return obj ~= nil and obj.Active
end

-- rules.py can_enter_basement: needed to go through either door into the Foyer
function can_enter_foyer_doors()
    return has("tooth_brush") and has("mug") and has("suit_drake")
end

function can_reach_kitchen()
    -- Living Room -> Kitchen, or Living Room -> Foyer -> Kitchen
    return has("lr_kitchen_key")
        or (can_enter_foyer_doors() and has("lr_foyer_key") and has("kitchen_foyer_key"))
end

function can_reach_drain()
    return can_reach_kitchen()
end

function can_reach_foyer()
    -- Living Room -> Foyer, or Living Room -> Kitchen -> Foyer
    return can_enter_foyer_doors()
        and (has("lr_foyer_key") or (has("lr_kitchen_key") and has("kitchen_foyer_key")))
end

function can_reach_backyard()
    return has("lr_backyard_key")
end

function can_reach_basement()
    return can_reach_foyer() and has("foyer_basement_key")
end

-- rules.py reach_second_floor: Foyer Ladder + Copter, or the Foyer Teleport.
-- With the Open Upstairs option the stairs replace those; the Basement Key is still needed
-- for the story event that opens the second floor.
-- The open_upstairs toggle is set from slot_data on connect, or by hand when not connected.
function can_reach_foyer_upstairs()
    if has("open_upstairs") then
        return can_reach_foyer() and has("foyer_basement_key")
    end
    return can_reach_foyer() and has("foyer_basement_key")
        and ((has("foyer_ladder") and has("copter")) or has("foyer_teleport"))
end

function can_reach_jennys_room()
    return can_reach_foyer_upstairs() and has("foyer_jennyroom_key")
end

function can_reach_bedroom()
    return can_reach_foyer_upstairs() and has("foyer_bedroom_key")
end

function has_all(codes)
    for _, code in ipairs(codes) do
        if not has(code) then
            return false
        end
    end
    return true
end

-- rules.py mother_spider_rule. SLOT_DATA is set by the clear handler in archipelago.lua;
-- without it (not connected) this uses the default goal's rule.
local VICTORY_GOAL_STICKERS = 2
local VICTORY_GOAL_DIVORCE = 3

function can_reach_mother_spider()
    local goal = SLOT_DATA and SLOT_DATA["victory_goal"]
    if goal == VICTORY_GOAL_DIVORCE then
        return has_all({"tooth_brush", "mug", "copter", "foyer_teleport", "suit_drake",
                        "foyer_basement_key", "lr_kitchen_key", "lr_foyer_key",
                        "kitchen_foyer_key", "foyer_bedroom_key", "toy_receipt"})
    end
    if not has_all({"tooth_brush", "blaster", "charge_chip", "squirter", "mug", "spoon",
                    "ear_chip", "giga_battery", "dads_wedding_band", "radar", "copter", "dog_bone",
                    "foyer_ladder", "foyer_teleport", "suit_drake", "suit_frog", "suit_trama",
                    "old_clothes", "foyer_basement_key", "lr_backyard_key", "lr_kitchen_key",
                    "lr_foyer_key", "kitchen_foyer_key", "foyer_jennyroom_key",
                    "foyer_bedroom_key", "dinah_teeth", "passed_out_frog", "toy_receipt"}) then
        return false
    end
    if goal == VICTORY_GOAL_STICKERS then
        for _, sticker in ipairs(SLOT_DATA["_chibi_stickers"] or {}) do
            if sticker == "Frog Ring" then
                return Tracker:ProviderCountForCode("frog_rings") >= 10
            end
        end
    end
    return true
end
