local frame = CreateFrame("FRAME"); -- Need a frame to respond to events
frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED"); -- Fired when saved variables are loaded

local function Print(msg)
	print("|cff03C6FCGearSpecSwap|r - " ..msg)
end

function frame:OnEvent(event, ...)
	if event == "ADDON_LOADED" and select(1, ...) == "GearSpecSwap" then
		Print("AddOn loaded successfully");
	end
	if event == "ACTIVE_TALENT_GROUP_CHANGED" then
		frame.CheckFirstUse()
		local name = GearSpecSwapData[select(1, ...)..""]
		if name and C_EquipmentSet.GetEquipmentSetID(name) then 
			Print("swapping to Equipment-Set: " .. name)
			C_EquipmentSet.UseEquipmentSet(C_EquipmentSet.GetEquipmentSetID(name));
		end
	end
end

local function Tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

local function SplitString(s, delimiter)
	if s == nil then
		return nil
	end
     local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end


local function CheckFirstUse()
	if GearSpecSwapData == nil or Tablelength(GearSpecSwapData) == 0 then
		GearSpecSwapData = {}
		for i=1,2 do
			GearSpecSwapData[i..""] = nil
		end
	end
end

frame.CheckFirstUse = CheckFirstUse

local function Link(spec, set)
	CheckFirstUse()
	GearSpecSwapData[spec] = set
end

local function Unlink(spec)
	CheckFirstUse()
	GearSpecSwapData[spec] = nil
end

GameTooltip:HookScript('OnTooltipSetItem', function(self)
	if not IsAltKeyDown() then return end

	local item, link = self:GetItem()
	--make sure we have an item to work with
	if not item and not link then return end

	local owner = self:GetOwner() --get the owner of the tooltip

	--if it's the character frames <alt> equipment switch then ignore it
	if owner and owner:GetName() and strfind(string.lower(owner:GetName()), "character") and strfind(string.lower(owner:GetName()), "slot") then 
		PaperDollFrameItemFlyout_Show(self:GetOwner())
		self:Hide()
	end
end)

frame:SetScript("OnEvent", frame.OnEvent);

SLASH_GSS1 = "/gss";
SLASH_GSS2 = "/gearswap";

SlashCmdList["GSS"] = function(msg)
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

	if (cmd == "link" or cmd == "l") and args ~= "" then
		Print("link: " .. args)
		local arr = SplitString(args," ")
		Link(arr[1], arr[2])
	elseif (cmd == "unlink" or cmd == "u") and args ~= "" then
		Print("unlink: " .. args)
		Unlink(args)
	else
		print("|cff03C6FC-- GearSpecSwap help --|r")
		print("|cff00FF00/GearSpecSwap|r |cffFFA90Alink spec_num equipment_set_name|r -- create the autoequip link between the given spec and equipment set. |cffFFA90Aie. gss link 1 main|r (load set called \"main\" when swap to first spec)")
		print("|cff00FF00/GearSpecSwap|r |cffFFA90Aunlink spec_num|r -- remove the autoequip link for an spec. |cffFFA90Aie. fss unlink 1|r (remove the link for the first spec)")
	end

end