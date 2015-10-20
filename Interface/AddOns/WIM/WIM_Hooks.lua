WIM_ButtonsHooked = false;
WIM_TradeSkillIsHooked = false;
WIM_CraftSkillIsHooked = false;
WIM_InspectIsHooked = false;



function WIM_FriendsFrame_SendMessage()
	local name = GetFriendInfo(FriendsFrame.selectedFriend);
	WIM_PostMessage(name, "", 5, "", "");
end

function WIM_ChatEdit_ExtractTellTarget(editBox, msg)
	-- Grab the first "word" in the string
	local target = gsub(msg, "(%s*)([^%s]+)(.*)", "%2", 1);
	if ( (strlen(target) <= 0) or (strsub(target, 1, 1) == "|") ) then
		return;
	end
	
	if(WIM_Data.hookWispParse) then
		target = string.gsub(target, "^%l", string.upper)
		WIM_PostMessage(target, "", 5, "", "");
		editBox:SetText("");
		editBox:Hide();
	else
		WIM_ChatEdit_ExtractTellTarget_orig(editBox, msg);
	end
end


function WIM_HookInspect()
	if(WIM_InspectIsHooked) then
		return;
	end
	
	if(InspectPaperDollFrame) then
		WIM_InspectPaperDollItemSlotButton_OnClick_orig = InspectPaperDollItemSlotButton_OnClick;
		InspectPaperDollItemSlotButton_OnClick = WIM_InspectPaperDollItemSlotButton_OnClick;
		WIM_InspectIsHooked = true;
	elseif(SuperInspectFrame) then
		WIM_SuperInspect_InspectPaperDollItemSlotButton_OnClick_orig = SuperInspect_InspectPaperDollItemSlotButton_OnClick;
		SuperInspect_InspectPaperDollItemSlotButton_OnClick = WIM_SuperInspect_InspectPaperDollItemSlotButton_OnClick;
		WIM_InspectIsHooked = true;
	end
	
	DEFAULT_CHAT_FRAME:AddMessage("Hooking Complete.");
end

function WIM_AtlasLootItem_OnClick(arg1)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			local color = strsub(getglobal("AtlasLootItem_"..this:GetID().."_Name"):GetText(), 1, 10);
			local name = strsub(getglobal("AtlasLootItem_"..this:GetID().."_Name"):GetText(), 11);
			WIM_EditBoxInFocus:Insert(color.."|Hitem:"..this.itemID..":0:0:0|h["..name.."]|h|r");
		end
	end
	WIM_AtlasLootItem_OnClick_orig(arg1);
end

function WIM_InspectPaperDollItemSlotButton_OnClick(arg1)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			WIM_EditBoxInFocus:Insert(GetInventoryItemLink(InspectFrame.unit, this:GetID()));
		end
	end
	WIM_InspectPaperDollItemSlotButton_OnClick_orig(arg1);
end

function WIM_AllInOneInventoryFrameItemButton_OnClick(button, ignShift)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			local bag, slot = AllInOneInventory_GetIdAsBagSlot(this:GetID());
			WIM_EditBoxInFocus:Insert(GetContainerItemLink(bag, slot));
		end
	end
	WIM_AllInOneInventoryFrameItemButton_OnClick_orig(button, ignShift);
end

function WIM_LootFrameItem_OnClick(arg1)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			WIM_EditBoxInFocus:Insert(GetLootSlotLink(this.slot));
		end
	end
	WIM_LootFrameItem_OnClick_orig(arg1);
end

function WIM_SuperInspect_InspectPaperDollItemSlotButton_OnClick(button, ignoreModifiers)
	local itemLink = this.link;
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			local link = "|c"..this.c.."|H"..itemLink.."|h["..GetItemInfo(itemLink).."]|h|r";
			WIM_EditBoxInFocus:Insert(link);
		end
	end
	WIM_SuperInspect_InspectPaperDollItemSlotButton_OnClick_orig(button, ignoreModifiers);
end

function WIM_HookTradeSkill()
	if(WIM_TradeSkillIsHooked == true and WIM_CraftSkillIsHooked == true) then
		return;
	end
	
	if(WIM_TradeSkillIsHooked == false and TradeSkillFrame ~= nil) then
		WIM_TradeSkillSkillIcon_OnClick_orig = TradeSkillSkillIcon:GetScript("OnClick");
		TradeSkillSkillIcon:SetScript("OnClick", function() WIM_TradeSkillSkillIcon_OnClick_orig(); WIM_TradeSkillSkillIcon_OnClick(); end);
		
		for i=1, 8 do 
			WIM_TradeSkillReagent_OnClick_orig = getglobal("TradeSkillReagent"..i):GetScript("OnClick");
			getglobal("TradeSkillReagent"..i):SetScript("OnClick", function() WIM_TradeSkillReagent_OnClick_orig(); WIM_TradeSkillReagent_OnClick(); end);
		end
		WIM_TradeSkillIsHooked = true;
	end
	
	if(WIM_CraftSkillIsHooked == false and CraftFrame ~= nil) then
		WIM_CraftIcon_OnClick_orig = CraftIcon:GetScript("OnClick");
		CraftIcon:SetScript("OnClick", function() WIM_CraftIcon_OnClick_orig(); WIM_CraftIcon_OnClick(); end);
		
		for i=1, 8 do 
			WIM_CraftReagent_OnClick_orig = getglobal("CraftReagent"..i):GetScript("OnClick");
			getglobal("CraftReagent"..i):SetScript("OnClick", function() WIM_CraftReagent_OnClick_orig(); WIM_CraftReagent_OnClick(); end);
		end
		
		WIM_CraftSkillIsHooked = true;
	end
end

function WIM_CraftIcon_OnClick(arg1)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			WIM_EditBoxInFocus:Insert(GetCraftItemLink(GetCraftSelectionIndex()));
		end
	end
end

function WIM_CraftReagent_OnClick(arg1)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			WIM_EditBoxInFocus:Insert(GetCraftReagentItemLink(GetCraftSelectionIndex(), this:GetID()));
		end
	end
end


function WIM_TradeSkillSkillIcon_OnClick(agr1)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			WIM_EditBoxInFocus:Insert(GetTradeSkillItemLink(TradeSkillFrame.selectedSkill));
		end
	end
end

function WIM_TradeSkillReagent_OnClick(arg1)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			WIM_EditBoxInFocus:Insert(GetTradeSkillReagentItemLink(TradeSkillFrame.selectedSkill, this:GetID()));
		end
	end
end


function WIM_PaperDollItemSlotButton_OnClick(arg1)
	if(arg1 == "LeftButton" and IsShiftKeyDown()) then
		if(WIM_EditBoxInFocus) then
			WIM_EditBoxInFocus:Insert(GetInventoryItemLink("player", this:GetID()));
		end
	end
	WIM_PaperDollItemSlotButton_OnClick_orig(arg1);
end

function WIM_LootLinkItemButton_OnClick(arg1)
	if(arg1 == "LeftButton" and IsShiftKeyDown()) then
		if(WIM_EditBoxInFocus) then
			WIM_EditBoxInFocus:Insert(WIM_LootLink_GetLink(this:GetText()));
		end
	end
	WIM_LootLinkItemButton_OnClick_orig(arg1);
end

-- copy of Lootlink's local function - modified
function WIM_LootLink_GetHyperlink(name)
	local itemLink = ItemLinks[name];
	DEFAULT_CHAT_FRAME:AddMessage("LootLink_GetHyperlink: "..name);
	if( itemLink and itemLink.i ) then
		-- Remove instance-specific data that we captured from the link we return
		local item = string.gsub(itemLink.i, "(%d+):(%d+):(%d+):(%d+)", "%1:0:%3:%4");
		return "item:"..item;
	end
	return nil;
end

-- copy of Lootlink's local function - modified
function WIM_LootLink_GetLink(name)
	local itemLink = ItemLinks[name];
	if( itemLink and itemLink.c and itemLink.i ) then
		local link = "|c"..itemLink.c.."|H"..WIM_LootLink_GetHyperlink(name).."|h["..name.."]|h|r";
		return link;
	end
	return nil;
end



function WIM_EngInventory_ItemButton_OnClick()
	if(arg1 == "LeftButton" and IsShiftKeyDown()) then
		if(WIM_EditBoxInFocus) then
			local bar, position, itm, bagnum, slotnum;

			if (EngInventory_buttons[this:GetName()] ~= nil) then
                bar = EngInventory_buttons[this:GetName()]["bar"];
                position = EngInventory_buttons[this:GetName()]["position"];

				bagnum = EngInventory_bar_positions[bar][position]["bagnum"];
				slotnum = EngInventory_bar_positions[bar][position]["slotnum"];

                itm = EngInventory_item_cache[bagnum][slotnum];

				if(itm) then
					WIM_EditBoxInFocus:Insert(GetContainerItemLink(itm["bagnum"], itm["slotnum"]));
				end
			end
		end
	end
	WIM_EngInventory_ItemButton_OnClick_orig(arg1, arg2);
end


function WIM_FriendsFrame_OnEvent()
  if(event == "WHO_LIST_UPDATE") then
	local numWhos, totalCount = GetNumWhoResults();
	if(numWhos > 0) then
		for i=1, numWhos do 
			local name, guild, level, race, class, zone = GetWhoInfo(i);
			if(WIM_Windows[name] and name ~= "" and name ~= nil) then
				if(WIM_Windows[name].waiting_who) then
					WIM_Windows[name].waiting_who = false;
					WIM_Windows[name].class = class;
					WIM_Windows[name].level = level;
					WIM_Windows[name].race = race;
					WIM_Windows[name].guild = guild;
					WIM_SetWhoInfo(name);
					SetWhoToUI(0);
					return;
				end
			end
		end
	else
		SetWhoToUI(0);
		return;
	end
  end
  WIM_FriendsFrame_OnEvent_orig(event);
end


function WIM_SetItemRef (link, text, button)
	if (WIM_isLinkURL(link)) then
		WIM_DisplayURL(link);
		return;
	end
	if (strsub(link, 1, 6) ~= "player") and ( IsShiftKeyDown() ) and ( not ChatFrameEditBox:IsVisible() ) then
		local itemName = gsub(text, ".*%[(.*)%].*", "%1");
		if(WIM_EditBoxInFocus) then
			WIM_EditBoxInFocus:Insert(text);
		end
	end
end

function WIM_ItemButton_OnClick(button, ignoreModifiers)
	if ( button == "LeftButton" ) and (not ignoreModifiers) and ( IsShiftKeyDown() ) and ( not ChatFrameEditBox:IsVisible() ) and (GameTooltipTextLeft1:GetText()) then
		if(WIM_EditBoxInFocus) then
			WIM_EditBoxInFocus:Insert(GetContainerItemLink(this:GetParent():GetID(), this:GetID()));
		end
	end
end

function WIM_SetUpHooks()
	if(WIM_ButtonsHooked) then
		return;
	end

	--Hook Friends Frame Send Message Button
	FriendsFrame_SendMessage = WIM_FriendsFrame_SendMessage;
	
	--Hook Chat Frame Whisper Parse
	WIM_ChatEdit_ExtractTellTarget_orig = ChatEdit_ExtractTellTarget;
	ChatEdit_ExtractTellTarget = WIM_ChatEdit_ExtractTellTarget;
	
	--Hook FriendsFrame_OnEvent
	WIM_FriendsFrame_OnEvent_orig = FriendsFrame_OnEvent;
	FriendsFrame_OnEvent = WIM_FriendsFrame_OnEvent;
	
	--Hook ChatFrame_OnEvent
	WIM_ChatFrame_OnEvent_orig = ChatFrame_OnEvent;
	ChatFrame_OnEvent = function(event) if(WIM_ChatFrameSupressor_OnEvent(event)) then WIM_ChatFrame_OnEvent_orig(event); end; end;
	
	--Hook SetItemRef
	WIM_SetItemRef_orig = SetItemRef;
	SetItemRef = function(link, text, button) if(not WIM_isLinkURL(link)) then WIM_SetItemRef_orig(link, text, button); end; WIM_SetItemRef(link, text, button); end;

	--Hook Paper Doll Button
	WIM_PaperDollItemSlotButton_OnClick_orig = PaperDollItemSlotButton_OnClick;
	PaperDollItemSlotButton_OnClick = WIM_PaperDollItemSlotButton_OnClick;
	
	--Hook Loot Frame 
	WIM_LootFrameItem_OnClick_orig = LootFrameItem_OnClick;
	LootFrameItem_OnClick = WIM_LootFrameItem_OnClick;
	
	
	--Hook ContainerFrameItemButton_OnClick
	WIM_ContainerFrameItemButton_OnClick_orig = ContainerFrameItemButton_OnClick;
	ContainerFrameItemButton_OnClick = function(button, ignoreModifiers) WIM_ContainerFrameItemButton_OnClick_orig(button, ignoreModifiers); WIM_ItemButton_OnClick(button, ignoreModifiers); end;
	
	if (AllInOneInventoryFrameItemButton_OnClick) then
		--Hook ContainerFrameItemButton_OnClick
		WIM_AllInOneInventoryFrameItemButton_OnClick_orig = AllInOneInventoryFrameItemButton_OnClick;
		AllInOneInventoryFrameItemButton_OnClick = function(button, ignoreModifiers) WIM_AllInOneInventoryFrameItemButton_OnClick_orig(button, ignoreModifiers); WIM_ItemButton_OnClick(button, ignoreModifiers); end;
	end
	
	if (EngInventory_ItemButton_OnClick) then
		--Hook ContainerFrameItemButton_OnClick
		WIM_EngInventory_ItemButton_OnClick_orig = EngInventory_ItemButton_OnClick;
		EngInventory_ItemButton_OnClick = function(button, ignoreModifiers) WIM_EngInventory_ItemButton_OnClick_orig(button, ignoreModifiers); WIM_ItemButton_OnClick(button, ignoreModifiers); end;
	end
	
	if (BrowseButton) then
		--Hook BrowseButtons
		for i=1, 8 do
			local frame = getglobal("BrowseButton"..i.."Item");
			local oldFunc = frame:GetScript("OnClick");
			frame:SetScript("OnClick", function() oldFunc(); WIM_ItemButton_OnClick(arg1); end);
		end
	end
	WIM_ButtonsHooked = true;
end


function WIM_AddonDetectToHook(theAddon)
	if(theAddon == "SuperInspect_UI") then
		WIM_HookInspect();
	elseif(theAddon == "AtlasLoot") then
		WIM_AtlasLootItem_OnClick_orig = AtlasLootItem_OnClick;
		AtlasLootItem_OnClick = WIM_AtlasLootItem_OnClick;
	elseif(theAddon == "AllInOneInventory") then
		WIM_AllInOneInventoryFrameItemButton_OnClick_orig = AllInOneInventoryFrameItemButton_OnClick;
		AllInOneInventoryFrameItemButton_OnClick = WIM_AllInOneInventoryFrameItemButton_OnClick;
	elseif(theAddon == "EngInventory") then
		WIM_EngInventory_ItemButton_OnClick_orig = EngInventory_ItemButton_OnClick;
		EngInventory_ItemButton_OnClick = WIM_EngInventory_ItemButton_OnClick;
	elseif(theAddon == "LootLink") then
		WIM_LootLinkItemButton_OnClick_orig = LootLinkItemButton_OnClick;
		LootLinkItemButton_OnClick = WIM_LootLinkItemButton_OnClick;
	end
end
