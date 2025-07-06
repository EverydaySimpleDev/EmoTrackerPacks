
-- Configuration --------------------------------------
AUTOTRACKER_ENABLE_DEBUG_LOGGING = true
AUTOTRACKER_ENABLE_ITEM_TRACKING = true
AUTOTRACKER_ENABLE_LOCATION_TRACKING = true

mainModuleIdx = AutoTracker:ReadU8(0x8026644C, 4)
-------------------------------------------------------


print("")
print("Active Auto-Tracker Configuration")
print("---------------------------------------------------------------------")
print("Enable Item Tracking:        ", AUTOTRACKER_ENABLE_ITEM_TRACKING)
if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
    print("Enable Debug Logging:        ", "true")
end
print("---------------------------------------------------------------------")
print("")

function InvalidateReadCaches()
    U8_READ_CACHE_ADDRESS = 0
    U16_READ_CACHE_ADDRESS = 0
end

function ReadU8(segment, address)
    if U8_READ_CACHE_ADDRESS ~= address then
        U8_READ_CACHE = segment:ReadUInt8(address)
        U8_READ_CACHE_ADDRESS = address
    end

    return U8_READ_CACHE
end

function ReadU16(segment, address)
    if U16_READ_CACHE_ADDRESS ~= address then
        U16_READ_CACHE = segment:ReadUInt16(address)
        U16_READ_CACHE_ADDRESS = address
    end

    return U16_READ_CACHE
end

function isInGame()

    local inGame = ((mainModuleIdx == 0x0e) or (mainModuleIdx == 0x01) or (mainModuleIdx == 0x02) or (mainModuleIdx == 0x03) or (mainModuleIdx == 0x04) or (mainModuleIdx == 0x05) or (mainModuleIdx == 0x06) or (mainModuleIdx == 0x07) or (mainModuleIdx == 0x08) or (mainModuleIdx == 0x09) or (mainModuleIdx == 0x0a) or (mainModuleIdx == 0x0b) or (mainModuleIdx == 0x10) or (mainModuleIdx == 0x12) or (mainModuleIdx == 0x16))

    if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("*** In-game Status: ", '0x8026644C', string.format('0x%x', mainModuleIdx), inGame)
    end
    return inGame
end

function updateToggleItemFromByteAndFlag(segment, code, address, flag)
    local item = Tracker:FindObjectForCode(code)
    if item then
        local value = ReadU8(segment, address)

        local flagTest = value & flag

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print("Item:", item.Name, string.format("0x%x", address), string.format("0x%x", value),
                    string.format("0x%x", flag), flagTest ~= 0)
        end

        if flagTest ~= 0 then
            item.Active = true
        else
            item.Active = false
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("***ERROR*** Couldn't find item: ", code)
    end
end



function updateItems(segment)

    if AUTOTRACKER_ENABLE_ITEM_TRACKING then
        local address = mainModuleIdx
    end
    return true
end

ScriptHost:AddMemoryWatch("Chibi Robo Item Data", 0x80396576, 8, updateItems)

