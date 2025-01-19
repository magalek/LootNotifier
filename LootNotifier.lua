

local PATTERN_PARSE_ITEM_LINK = "(|c(%x+)|Hitem:((%d+).-)|h%[(.-)%]|h)"
local PATTERN_ITEM_LOOT_SELF = "^You receive loot: (.+)%.$"



local strgsub, strfind, strformat, strsub = string.gsub, strfind, string.format, 
  strsub

if not SUPERWOW_VERSION then
	DEFAULT_CHAT_FRAME:AddMessage("No SuperWoW detected");
	-- this version of SuperAPI is made for SuperWoW 1.2
	-- can somebody make this warning better?
	return
else
    DEFAULT_CHAT_FRAME:AddMessage("Discord addon initialized.");
    DEFAULT_CHAT_FRAME:AddMessage(_VERSION);
end

local frame = CreateFrame("Frame")

-- Fires when an addon and its saved variables are loaded
frame:RegisterEvent("ADDON_LOADED")
-- Fires when receiving notice that the player or a member of the player’s 
-- group has looted an item.
frame:RegisterEvent("CHAT_MSG_LOOT")
-- Fires when the player receives money as loot
frame:RegisterEvent("CHAT_MSG_MONEY")
-- Fires when the player begins interaction with a lootable corpse or object
frame:RegisterEvent("LOOT_OPENED")
-- Fires when the contents of a loot slot are removed
frame:RegisterEvent("LOOT_SLOT_CLEARED")
-- Fires when the player ends interaction with a lootable corpse or object
frame:RegisterEvent("LOOT_CLOSED")

frame:SetScript("OnEvent", function()
  if event == "CHAT_MSG_LOOT" then
    
    _, _, loot_string = string.find(arg1, PATTERN_ITEM_LOOT_SELF)

    local item_link, name, id, code, color = parseItemLink(loot_string)

    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
    itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
    expacID, setID, isCraftingReagent
        = GetItemInfo(id) 

    local tabl = {
      name = itemName,
      quality = itemQuality
    }

    DEFAULT_CHAT_FRAME:AddMessage(table.concat(tabl, ' '));



    ExportFile("test", string.format('{"name":"%s","quality":%i, "id":"%i", "nick":"%s", "response_id":%i}', name, itemQuality, id, UnitName("player"), math.floor(math.random() * 1000)))

    
    

  end
end)


function table_to_string(tbl)
  local result = "{"
  for k, v in pairs(tbl) do
      -- Check the key type (ignore any numerical keys - assume its an array)
      if type(k) == "string" then
          result = result.."[\""..k.."\"]".."="
      end

      -- Check the value type
      if type(v) == "table" then
          result = result..table_to_string(v)
      elseif type(v) == "boolean" then
          result = result..tostring(v)
      else
          result = result.."\""..v.."\""
      end
      result = result..","
  end
  -- Remove leading commas from the result
  if result ~= "" then
      result = result:sub(1, result:len()-1)
  end
  return result.."}"
end


function parseItemLink(target)
    local _, _, item_link, color, code, id, name = strfind(target, 
      PATTERN_PARSE_ITEM_LINK)
    return item_link, name, tonumber(id), code, color
end