-------------------------------------------------------------------------------
-- Locals                                                                    --
-------------------------------------------------------------------------------

local L = AceLibrary("AceLocale-2.2"):new("ClosetGnome")
local gratuity = AceLibrary("Gratuity-2.0")
local dewdrop = AceLibrary("Dewdrop-2.0")
local tablet = AceLibrary("Tablet-2.0")
local compost = AceLibrary("Compost-2.0")

local deequipQueue = nil
local queuedSet = nil
local lastEquippedSet = nil
local slotLocks = nil

local _G = getfenv(0)

local slots = {
	{slot = "Head"},
	{slot = "Shoulder"},
	{slot = "Chest"},
	{slot = "Waist"},
	{slot = "Legs"},
	{slot = "Feet"},
	{slot = "Wrist"},
	{slot = "Hands"},
	{slot = "MainHand"},
	{slot = "SecondaryHand"},
	{slot = "Ranged"},
	{slot = "Ammo"},
	{slot = "Neck"},
	{slot = "Back"},
	{slot = "Finger0"},
	{slot = "Finger1"},
	{slot = "Trinket0"},
	{slot = "Trinket1"},
	{slot = "Relic"},
}

-------------------------------------------------------------------------------
-- Localization                                                              --
-------------------------------------------------------------------------------

L:RegisterTranslations("enUS", function() return {
	["ClosetGnome"] = true,
	["ClosetGnome options."] = true,
	["Enable or disable the slots you want in this set by clicking the items in your character frame. Green slots are enabled, red are disabled. Type in the set name below, and click Add."] = true,
	["Add"] = true,
	["Creates a new set."] = true,
	["Wear"] = true,
	["Change equipment set."] = true,
	["Cancel"] = true,
	["Always equip weapons"] = true,
	["Equip weapons in sets even if you are in combat."] = true,
	["Equip %s."] = true,
	["Delete"] = true,
	["Deletes the equipment set %s."] = true,
	["Delete a set."] = true,
	["<set name>"] = true,
	["Couldn't find %s in your inventory."] = true,

	["In combat: %s queued for swap."] = true,
	["Added set: %s."] = true,
	["Deleted set: %s."] = true,
	["Updating set: %s."] = true,
	["Please use a proper name for your set."] = true,

	["Available sets"] = true,
	["Click a set above to change your equipment. The last equipped set is indicated by a star."] = true,
	["You have not created any equipment sets yet, please right-click the icon and click 'Add' to create a set."] = true,

	-- This is what a normal bag is called, as returned from GetItemInfo's
	-- subType
	["Bag"] = true,

	["Cute"] = true,
	["Toggle off if you're a gnome hater."] = true,

	-- Random quips when you equip a set.
	[1] = "Your ClosetGnome rapidly dresses you up in %s before he runs off with another sock.",
	[2] = "Once in a blue moon your ClosetGnome will equip you with an Artifact item. Not today, however, you'll have to settle for %s.",
	[3] = "ClosetGnomes are tidy creatures. Not yours, though, as he equips %s he just piles your old outfit in the corner.",
	[4] = "It's almost as if he dances around you while he dresses you up in %s. Although it's a very ugly dance.",
	[5] = "Since you forgot to feed your ClosetGnome today, he expresses his anger by equipping your %s backwards.",
	[6] = "Never let your ClosetGnome tend to other needs than %s.",
	[7] = "%s looks good on you today, at least compared to how it looked on your ClosetGnome when you caught him wearing it.",
	[8] = "ClosetGnome equips %s.",
	[9] = "Your ClosetGnome flinches in disgust as he equips %s. You're not sure why, but what's that smell ...",
	[10] = "Is that a whirlwind?! No, it's ClosetGnome dressing you in %s!",
	[11] = "Recently returned from the ClosetGnome convention, he's got a lot to talk about while dressing you in %s.",
	[12] = "Noone knows if ClosetGnomes party, but you do. This is how it looked last time you dressed yourself in %s after a party.",
	[13] = "'Getting Jiggy With It' was never your favorite, but you have to admit that it fits nicely with %s.",
	[14] = "Even though your washer is clearly labeled 'Certified by ClosetGnomes, Inc.', it's clear that %s has not been cleaned in a while.",
	[15] = "%s has the same color socks as your last set, and the one before that, and before that.",
	[16] = "Instead of equipping %s, your ClosetGnome starts gnawing on your leg. You shake him off and do it yourself.",
	[17] = "Noone has ever suspected you of having a ClosetGnome. Most of them are actually good at equipping things like %s.",
	[18] = "What kind of person are you that dresses up in %s so often? Your ClosetGnome eyes you up and down. He looks .. hungry.",
	[19] = "Your ClosetGnome is hungry and scavenges the pockets of %s for food, but finds nothing. Do you ever feed him?",
	[20] = "The first rule of the ClosetGnomes is that they do not talk about %s.",
	[21] = "%s seems different somehow.",
	[22] = "There is no %s.",
	[23] = "You feel the need - the need for %s!",
	[24] = "Your ClosetGnome equips %s. Shaken, not stirred.",
	[25] = "ClosetGnome puts %s in a corner. Then comes back and equips it.",
	[26] = "Hasta la vista, %s.",
	[27] = "Keep your %s close, but your ClosetGnome closer.",
	[28] = "A boy's best friend is a ClosetGnome that comes with %s.",
	[29] = "You love the smell of %s in the morning.",
	[30] = "May your ClosetGnome be with you. And may he bring %s.",
	[31] = "You make your ClosetGnome an offer he can't refuse, and so he equips %s.",
} end)

L:RegisterTranslations("koKR", function() return {
--	["ClosetGnome"] = true,
	["ClosetGnome options."] = "ClosetGnome 설정.",
	["Enable or disable the slots you want in this set by clicking the items in your character frame. Green slots are enabled, red are disabled. Type in the set name below, and click Add."] = "이 세트에 케릭터 창의 아이템을 클릭해서 원하는 슬롯을 활성화 하거나 비활성화 합니다. 활성화 된 슬롯은 녹색, 비활성화 된 것은 붉은색입니다. 세트명을 입력하고 추가를 클릭하세요.",
	["Add"] = "추가",
	["Creates a new set."] = "새로운 세트를 생성합니다.",
	["Wear"] = "착용",
	["Change equipment set."] = "착용장비 세트를 변경합니다.",
	["Cancel"] = "취소",
	["Always equip weapons"] = "항상 무기 착용",
	["Equip weapons in sets even if you are in combat."] = "전투중에도 세트에 속하는 무기를 착용합니다.",
	["Equip %s."] = "%s|1을;를; 착용합니다.",
	["Delete"] = "삭제",
	["Enter the set name to delete it."] = "삭제를 세트명을 입력하세요.",
	["<set name>"] = "<세트명>",
	["Couldn't find %s in your inventory."] = "인벤토리에서 %s|1을;를; 찾을 수 없습니다.",

	["In combat: %s queued for swap."] = "전투중: %s|1이;가; 스왑을 위해 대기합니다.",
	["Added set: %s."] = "세트 추가: %s.",
	["Deleted set: %s."] = "세트 삭제: %s.",
	["Updating set: %s."] = "세트 갱신: %s.",

	["Available sets"] = "이용가능한 세트",
	--["Click a set above to change your equipment."] = "착용장비 변경을 위해 아래 세트를 클릭하세요.",
	["You have not created any equipment sets yet, please right-click the icon and click 'Add' to create a set."] = "아직 생성된 장비 세트가 없습니다, 아이콘을 우클릭 한 후 '추가'를 클릭해서 세트를 생성하세요.",

	-- This is what a normal bag is called, as returned from GetItemInfo's
	-- subType
	["Bag"] = "가방",

	["Cute"] = "메세지",
	["Toggle off if you're a gnome hater."] = "놈을 싫어하시는 분은 이 설정을 끄세요.",

	-- Random quips when you equip a set.
	[1] = "그가 다른 신발을 신고 도망치기 전에 ClosetGnome 은 %s 세트를 신속히 착용합니다.",
	[2] = "Once in a blue moon your ClosetGnome will equip you with an Artifact item. Not today, however, you'll have to settle for %s.",
	[3] = "ClosetGnomes are tidy creatures. Not yours, though, as he equips %s he just piles your old outfit in the corner.",
	[4] = "It's almost as if he dances around you while he dresses you up in %s. Although it's a very ugly dance.",
	[5] = "Since you forgot to feed your ClosetGnome today, he expresses his anger by equipping your %s backwards.",
	[6] = "Never let your ClosetGnome tend to other needs than %s.",
	[7] = "%s looks good on you today, at least compared to how it looked on your ClosetGnome when you caught him wearing it.",
	[8] = "ClosetGnome이 %s 세트를 착용합니다.",
	[9] = "Your ClosetGnome flinches in disgust as he equips %s. You're not sure why, but what's that smell ...",
	[10] = "Is that a whirlwind?! No, it's ClosetGnome dressing you in %s!",
	[11] = "Recently returned from the ClosetGnome convention, he's got a lot to talk about while dressing you in %s.",
	[12] = "Noone knows if ClosetGnomes party, but you do. This is how it looked last time you dressed yourself in %s after a party.",
	[13] = "'Getting Jiggy With It' was never your favorite, but you have to admit that it fits nicely with %s.",
	[14] = "Even though your washer is clearly labeled 'Certified by ClosetGnomes, Inc.', it's clear that %s has not been cleaned in a while.",
	[15] = "%s has the same color socks as your last set, and the one before that, and before that.",
	[16] = "Instead of equipping %s, your ClosetGnome starts gnawing on your leg. You shake him off and do it yourself.",
	[17] = "Noone has ever suspected you of having a ClosetGnome. Most of them are actually good at equipping things like %s.",
	[18] = "%s 세트를 자주 입는 당신은 뭐하는 사람이에요? 당신의 ClosetGnome이 당신을 위아래로 훌터봅니다. 그는 굶주린것 같습니다...",
	[19] = "당신의 ClosetGnome이 굶주려 %s 세트를 뒤지지만 아무것도 찾지 못했습니다. 그에게 먹을것 좀 주시겠습니까?",
} end)

L:RegisterTranslations("deDE", function() return {
	["ClosetGnome options."] = "ClosetGnome Optionen",
	["Enable or disable the slots you want in this set by clicking the items in your character frame. Green slots are enabled, red are disabled. Type in the set name below, and click Add."] = "Aktiviere und deaktiviere die einzelnen Slots f\195\188r dieses Set durch klicken im Charakterbildschirm. Gr\195\188n bedeutet aktiviert, rot deaktiviert. Gebe einen Namen f\195\188r das set ein und dr\195\188cke Hinzuf\195\188gen",
	["Add"] = "Hinzuf\195\188gen",
	["Creates a new set."] = "Legt ein neues Set an.",
	["Wear"] = "Anziehen",
	["Change equipment set."] = "Wechsle Set",
	["Cancel"] = "Abbrechen",
	["Always equip weapons"] = "Waffen immer anlegen",
	["Equip weapons in sets even if you are in combat."] = "Waffen schon im Kampf wechseln",
	["Equip %s."] = "Trage %s",
	["Delete"] = "L\195\182schen",
	["Enter the set name to delete it."] = "Gib den Namen des zu l\195\182schemdem Sets ein",
	["<set name>"] = "<Name des Sets>",
	["Couldn't find %s in your inventory."] = "Konnte %s nicht im Inventar finden",

	["In combat: %s queued for swap."] = "Kampf: %s in der Warteschlange",
	["Added set: %s."] = "Set hinzugef\195\188gt: %s",
	["Deleted set: %s."] = "Set gel\195\182scht: %s",
	["Updating set: %s."] = "Set upgedatet: %s",

	["Last equipped:"] = "Zuletzt angelegt:",
	["Available sets"] = "Verf\195\188gbare Sets:",
	["Click a set above to change your equipment."] = "Klicke auf ein Set um es anzulegen",
	["You have not created any equipment sets yet, please right-click the icon and click 'Add' to create a set."] = "Es wurden noch keine Ausr\195\188stungssets erstellt, Klicke mit der rechten Maustaste auf das Icon, dann 'Hinzuf\195\188gen' um ein Set zu erstellen",

	-- This is what a normal bag is called, as returned from GetItemInfo's
	-- subType
	["Bag"] = "Beh\195\164lter",

	["Cute"] = "Niedlich",
	["Toggle off if you're a gnome hater."] = "Gnomhasser schalten dies aus",

	-- Random quips when you equip a set.
	[1] = "Your ClosetGnome rapidly dresses you up in %s before he runs off with another sock.",
	[2] = "Once in a blue moon your ClosetGnome will equip you with an Artifact item. Not today, however, you'll have to settle for %s.",
	[3] = "ClosetGnomes are tidy creatures. Not yours, though, as he equips %s he just piles your old outfit in the corner.",
	[4] = "It's almost as if he dances around you while he dresses you up in %s. Although it's a very ugly dance.",
	[5] = "Since you forgot to feed your ClosetGnome today, he expresses his anger by equipping your %s backwards.",
	[6] = "Never let your ClosetGnome tend to other needs than %s.",
	[7] = "%s looks good on you today, at least compared to how it looked on your ClosetGnome when you caught him wearing it.",
	[8] = "ClosetGnome equips %s.",
	[9] = "Your ClosetGnome flinches in disgust as he equips %s. You're not sure why, but what's that smell ...",
	[10] = "Is that a whirlwind?! No, it's ClosetGnome dressing you in %s!",
	[11] = "Recently returned from the ClosetGnome convention, he's got a lot to talk about while dressing you in %s.",
	[12] = "Noone knows if ClosetGnomes party, but you do. This is how it looked last time you dressed yourself in %s after a party.",
	[13] = "'Getting Jiggy With It' was never your favorite, but you have to admit that it fits nicely with %s.",
	[14] = "Even though your washer is clearly labeled 'Certified by ClosetGnomes, Inc.', it's clear that %s has not been cleaned in a while.",
	[15] = "%s has the same color socks as your last set, and the one before that, and before that.",
	[16] = "Instead of equipping %s, your ClosetGnome starts gnawing on your leg. You shake him off and do it yourself.",
	[17] = "Noone has ever suspected you of having a ClosetGnome. Most of them are actually good at equipping things like %s.",
	[18] = "What kind of person are you that dresses up in %s so often? Your ClosetGnome eyes you up and down. He looks .. hungry.",
	[19] = "Your ClosetGnome is hungry and scavenges the pockets of %s for food, but finds nothing. Do you ever feed him?",
} end)

-------------------------------------------------------------------------------
-- Addon declaration                                                         --
-------------------------------------------------------------------------------

ClosetGnome = AceLibrary("AceAddon-2.0"):new("AceHook-2.1", "AceConsole-2.0", "AceDB-2.0", "AceEvent-2.0", "FuBarPlugin-2.0")
ClosetGnome:RegisterDB("ClosetGnomeDB", "ClosetGnomePerCharDB")
ClosetGnome:RegisterDefaults("profile", {
	iHateCuteAndFunnyThings = false,
})
ClosetGnome:RegisterDefaults("char", {
	set = {},
	icons = {},
	alwaysWeapons = true,
})
ClosetGnome.OnMenuRequest = {
	type = "group",
	name = L["ClosetGnome"],
	desc = L["ClosetGnome options."],
	args = {
		add = {
			type = "execute",
			name = L["Add"],
			desc = L["Creates a new set."],
			func = function() ClosetGnome:CreateSet() end,
			order = 101,
		},
		wear = {
			type = "group",
			name = L["Wear"],
			desc = L["Change equipment set."],
			args = {},
			order = 102,
			disabled = function() return next(ClosetGnome.OnMenuRequest.args.wear.args) == nil end
		},
		spacer = { type = "header", order = 103 },
		alwaysweapons = {
			type = "toggle",
			name = L["Always equip weapons"],
			desc = L["Equip weapons in sets even if you are in combat."],
			get = function() return ClosetGnome.db.char.alwaysWeapons end,
			set = function(v) ClosetGnome.db.char.alwaysWeapons = v end,
			order = 104,
		},
		delete = {
			type = "group",
			name = L["Delete"],
			desc = L["Delete a set."],
			args = {},
			order = 105,
			disabled = function() return next(ClosetGnome.OnMenuRequest.args.wear.args) == nil end
		},
	},
}
ClosetGnome:RegisterChatCommand({"/closetgnome", "/cg"}, ClosetGnome.OnMenuRequest)
ClosetGnome:RegisterChatCommand({"/cghater"}, {
	type = "toggle",
	name = L["Cute"],
	desc = L["Toggle off if you're a gnome hater."],
	get = function() return ClosetGnome.db.profile.iHateCuteAndFunnyThings end,
	set = function(v) ClosetGnome.db.profile.iHateCuteAndFunnyThings = v end,
})

-- FuBar stuff.
--ClosetGnome.name = L["ClosetGnome"]
ClosetGnome.hideWithoutStandby = true
local defaultIcon = "Interface\\Icons\\INV_Chest_Cloth_17"
ClosetGnome.hasIcon = defaultIcon
ClosetGnome.defaultMinimapPosition = 240
ClosetGnome.clickableTooltip  = true

-------------------------------------------------------------------------------
-- Initialization                                                            --
-------------------------------------------------------------------------------

function ClosetGnome:OnEnable()
	StaticPopupDialogs["ClosetGnomeAdd"] = {
		text = L["Enable or disable the slots you want in this set by clicking the items in your character frame. Green slots are enabled, red are disabled. Type in the set name below, and click Add."],
		button1 = L["Add"],
		button2 = L["Cancel"],
		OnCancel = function() self:CancelCreateSet() end,
		sound = "levelup2",
		whileDead = 1,
		hideOnEscape = 1,
		timeout = 0,
		OnShow = function()
			-- We have to do this onshow to reset the previous text
			getglobal(this:GetName().."EditBox"):SetText("")
		end,
		OnAccept = function()
			local name = getglobal(this:GetParent():GetName().."EditBox"):GetText()
			self:AddSetFromDoll(name)
		end,
		hasEditBox = 1,
	}

	-- Temporary table for which slots to use when adding a new set.
	self.activeSlots = compost:Acquire()

	-- Create the paper doll slot overlays, most of the code credit to Fizzle.
	for _, item in ipairs(slots) do
		local gslot = _G["Character" .. item.slot .. "Slot"]
		if gslot and not item.frame then
			local border = gslot:CreateTexture(gslot:GetName() .. "ClosetGnome", "OVERLAY")
			border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
			border:SetVertexColor(0, 255, 0)
			border:SetBlendMode("ADD")
			border:SetAlpha(0.75)
			border:SetHeight(68)
			border:SetWidth(68)
			border:SetPoint("CENTER", gslot, "CENTER", 0, 1)
			border:Hide()
			item.frame = border
		end
	end

	self:RegisterEvent("AceEvent_FullyInitialized")

	self:UpdateSetMenu()
end

function ClosetGnome:OnDisable()
	compost:Reclaim(self.activeSlots)
	self.activeSlots = nil
	if slotLocks then
		compost:Reclaim(slotLocks, 1)
		slotLocks = nil
	end
end

-------------------------------------------------------------------------------
-- Menu                                                                      --
-------------------------------------------------------------------------------

function ClosetGnome:UpdateSetMenu()
	compost:Reclaim(self.OnMenuRequest.args.wear.args, 1)
	self.OnMenuRequest.args.wear.args = compost:Acquire()
	for k, v in pairs(self.db.char.set) do
		local set = k
		local menuKey = string.gsub(k, " ", "")
		self.OnMenuRequest.args.wear.args[menuKey] = compost:Acquire()
		self.OnMenuRequest.args.wear.args[menuKey].type = "execute"
		self.OnMenuRequest.args.wear.args[menuKey].name = set
		self.OnMenuRequest.args.wear.args[menuKey].desc = string.format(L["Equip %s."], set)
		self.OnMenuRequest.args.wear.args[menuKey].func = function() ClosetGnome:WearSet(set) end
		if self.db.char.icons[set] then
			self.OnMenuRequest.args.wear.args[menuKey].icon = self.db.char.icons[set]
		end
	end

	compost:Reclaim(self.OnMenuRequest.args.delete.args, 1)
	self.OnMenuRequest.args.delete.args = compost:Acquire()
	for k, v in pairs(self.db.char.set) do
		local set = k
		local menuKey = string.gsub(k, " ", "")
		self.OnMenuRequest.args.delete.args[menuKey] = compost:Acquire()
		self.OnMenuRequest.args.delete.args[menuKey].type = "execute"
		self.OnMenuRequest.args.delete.args[menuKey].name = set
		self.OnMenuRequest.args.delete.args[menuKey].desc = string.format(L["Deletes the equipment set %s."], set)
		self.OnMenuRequest.args.delete.args[menuKey].func = function() ClosetGnome:DeleteSet(set) end
		if self.db.char.icons[set] then
			self.OnMenuRequest.args.delete.args[menuKey].icon = self.db.char.icons[set]
		end
	end

end

-------------------------------------------------------------------------------
-- Addon methods                                                             --
-------------------------------------------------------------------------------

-- Opens the character frame and lets the user uncheck the items he doesn't
-- want.
function ClosetGnome:CreateSet()
	self.activeSlots = compost:Acquire()
	for _, item in ipairs(slots) do
		if item.frame then
			item.frame:SetVertexColor(0, 255, 0)
			item.frame:Show()
			local gslot = _G["Character" .. item.slot .. "Slot"]
			self.activeSlots[gslot:GetName()] = true
			item.script = gslot:GetScript("OnClick")
			gslot:SetScript("OnClick", function()
				local slot = this:GetName()
				if IsControlKeyDown() then
					-- Don't want an empty slot as icon.
					local id = GetInventorySlotInfo(string.sub(slot, 10))
					local currentItem = ClosetGnome:ItemNameFromSlot(id)
					if currentItem == false then return end

					if ClosetGnome.activeSlots["icon"] then
						local oldSlot = ClosetGnome.activeSlots["icon"]
						ClosetGnome.activeSlots[oldSlot] = true
						getglobal(oldSlot.."ClosetGnome"):SetVertexColor(0, 255, 0)
					end
					ClosetGnome.activeSlots["icon"] = slot
					ClosetGnome.activeSlots[slot] = true
					getglobal(slot.."ClosetGnome"):SetVertexColor(0, 0, 255)
				else
					ClosetGnome.activeSlots[slot] = not ClosetGnome.activeSlots[slot]
					if ClosetGnome.activeSlots[slot] then
						getglobal(slot.."ClosetGnome"):SetVertexColor(0, 255, 0)
					else
						getglobal(slot.."ClosetGnome"):SetVertexColor(255, 0, 0)
					end
				end
			end)
		end
	end
	ShowUIPanel(CharacterFrame)
	CharacterFrame_ShowSubFrame("PaperDollFrame")
	OpenAllBags()
	self:Hook("CharacterFrame_OnHide", true)
	self:Hook("CharacterFrameTab_OnClick", true)

	dewdrop:Close()
	StaticPopup_Show("ClosetGnomeAdd")
end

function ClosetGnome:CancelCreateSet()
	HideUIPanel(CharacterFrame)
	if self:IsHooked("CharacterFrame_OnHide") then
		self:Unhook("CharacterFrame_OnHide")
	end
end

function ClosetGnome:AddSetFromDoll(name)
	local slots = compost:Acquire()
	local icon = nil
	for slot, active in pairs(self.activeSlots) do
		if slot == "icon" then
			icon = string.sub(active, 10)
		elseif active then
			table.insert(slots, string.sub(slot, 10))
		end
	end
	self:AddSet(name, slots, icon)
	compost:Reclaim(slots)
	slots = nil
	icon = nil

	HideUIPanel(CharacterFrame)
	self:CharacterFrame_OnHide()
end

function ClosetGnome:AddSet(name, activeSlots, iconSlot)
	local concatedName = string.gsub(name, " ", "")
	if not name or name == "" or concatedName == "" then
		self:Print(L["Please use a proper name for your set."])
		return
	end
	if self:HasSet(concatedName) then name = concatedName end

	local text = string.format(L["Added set: %s."], name)
	local event = "ClosetGnome_AddSet"
	if self:HasSet(name) then
		text = string.format(L["Updating set: %s."], name)
		event = "ClosetGnome_UpdateSet"
	end

	for i, slot in pairs(activeSlots) do
		local id = GetInventorySlotInfo(slot)
		if not id then self.error("The given slot %q does not exist.", slot) end
		local currentItem = self:ItemNameFromSlot(id)
		if not self.db.char.set[name] then self.db.char.set[name] = {} end
		self.db.char.set[name][id] = currentItem
	end

	if iconSlot then
		local slotId = GetInventorySlotInfo(iconSlot)
		if not slotId then self.error("The given icon slot %q does not exist.", iconSlot) end
		self.db.char.icons[name] = GetInventoryItemTexture("player", slotId)
	end

	lastEquippedSet = name
	self:TriggerEvent(event, name)
	self:Print(text)

	self:UpdateSetMenu()
	self:UpdateTooltip()
end

function ClosetGnome:DeleteSet(name)
	if self.db.char.set[name] then
		for i in pairs(self.db.char.set[name]) do
			self.db.char.set[name][i] = nil
		end
		set = nil
		self.db.char.set[name] = nil
		self.db.char.icons[name] = nil

		self:TriggerEvent("ClosetGnome_DeleteSet", name)
		self:Print(string.format(L["Deleted set: %s."], name))
		self:UpdateSetMenu()
		self:UpdateTooltip()
	end
end

function ClosetGnome:WearSet(name)
	if CursorHasItem() then return end

	local set = self.db.char.set[name]
	if not set then return end

	dewdrop:Close()

	if self:IsSetFullyEquipped(name) then
		lastEquippedSet = name
		return
	end

	if UnitAffectingCombat("player") and not self:IsEventRegistered("PLAYER_REGEN_ENABLED") then
		if self.db.char.alwaysWeapons then
			if deequipQueue then
				compost:Reclaim(deequipQueue)
				deequipQueue = nil
			end
			for slot, item in pairs(set) do
				if slot == 16 or slot == 17 or slot == 18 then
					local currentItem = self:ItemNameFromSlot(slot)
					if item ~= currentItem then
						self:EquipItem(slot, item)
					end
				end
			end
			self:ProcessDeequipQueue()
			lastEquippedSet = name

			self:UpdateTooltip()
			self:UpdateText()

			if self:IsSetFullyEquipped(name) then
				self:TriggerEvent("ClosetGnome_WearSet", name)
				return
			else
				self:TriggerEvent("ClosetGnome_PartlyWearSet", name)
			end
		end
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:Print(string.format(L["In combat: %s queued for swap."], name))
		queuedSet = name
		return
	end
	if self:IsEventRegistered("PLAYER_REGEN_ENABLED") then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	queuedSet = nil

	if not self.db.profile.iHateCuteAndFunnyThings then
		local rand = math.random(1, 31)
		-- I don't want the addon name in front for this one.
		-- Thanks to MrPlow for the color :)
		if L[rand] ~= nil then
			DEFAULT_CHAT_FRAME:AddMessage("|cffeda55f"..string.format(L[rand], "|cffd9d919"..name.."|cffeda55f").."|r")
		end
	end

	if deequipQueue then
		compost:Reclaim(deequipQueue)
		deequipQueue = nil
	end
	for slot, item in pairs(set) do
		local currentItem = self:ItemNameFromSlot(slot)
		if item ~= currentItem then
			self:EquipItem(slot, item)
		end
	end
	self:ProcessDeequipQueue()
	lastEquippedSet = name
	self:TriggerEvent("ClosetGnome_WearSet", name)

	self:UpdateTooltip()
	self:UpdateText()
end

-- fizzle

-------------------------------------------------------------------------------
-- Utility                                                                   --
-------------------------------------------------------------------------------

function ClosetGnome:ItemNameFromSlot(slot)
	local slotId = tonumber(slot)
	if not slotId then slotId = GetInventorySlotInfo(slot) end
	if not slotId then self.error("Unknown inventory slot %q.", slot) end
	local hasItem = gratuity:SetInventoryItem("player", slotId)
	if not hasItem then return false end
	local currentItem = gratuity:GetLine(1)
	if not currentItem then currentItem = false end
	return currentItem
end

function ClosetGnome:IsSetFullyEquipped(name)
	local set = self.db.char.set[name]
	if not set or not name then return false end
	for slot, item in pairs(set) do
		local currentItem = self:ItemNameFromSlot(slot)
		if item ~= currentItem then
			return false
		end
	end
	return true
end

function ClosetGnome:IsNormalBag(bagId)
	if bagId == 0 or bagId == -1 then return true end
	local _, _, linkId = string.find(GetInventoryItemLink("player", ContainerIDToInventoryID(bagId)), "item:(%d+)")
	if not linkId then return false end
	local _, _, _, _, _, bagType = GetItemInfo(linkId)
	if bagType and bagType == L["Bag"] then return true end
	return false
end

function ClosetGnome:LocateFreeSlot()
	for theBag = 0, NUM_BAG_FRAMES, 1 do
		if self:IsNormalBag(theBag) then
			if not slotLocks[theBag] then slotLocks[theBag] = compost:Acquire() end
			local numSlot = GetContainerNumSlots(theBag)
			for theSlot = 1, numSlot, 1 do
				if not slotLocks[theBag][theSlot] then
					local texture = GetContainerItemInfo(theBag, theSlot)
					if not texture then
						return theBag, theSlot
					end
				end
			end
		end
	end
	return nil
end

function ClosetGnome:ProcessDeequipQueue()
	if not deequipQueue then return end
	if not slotLocks then slotLocks = compost:Acquire() end
	for i, slot in pairs(deequipQueue) do
		PickupInventoryItem(slot)
		local toBag, toSlot = self:LocateFreeSlot()
		if toBag ~= nil then
			slotLocks[toBag][toSlot] = true
			PickupContainerItem(toBag, toSlot)
		else
			AutoEquipCursorItem()
			break
		end
	end
	compost:Reclaim(deequipQueue)
	deequipQueue = nil
	if slotLocks then
		compost:Reclaim(slotLocks, 1)
		slotLocks = nil
	end
end

function ClosetGnome:EquipItem(slot, item, secondTry)
	if item == false then
		-- We need to find a free slot in the inventory for this item.
		-- If there's anything in the slot.
		local hasItem = self:ItemNameFromSlot(slot)
		if hasItem ~= false then
			if not deequipQueue then deequipQueue = compost:Acquire() end
			table.insert(deequipQueue, slot)
		end
	else
		local bagNum, slotNum = self:FindItem(item)
		if bagNum > -1 then
			PickupContainerItem(bagNum, slotNum)
			if slot < 11 or slot == 15 or slot == 19 then
				AutoEquipCursorItem()
			else
				EquipCursorItem(slot)
			end
		else
			if not secondTry then
				self:ScheduleEvent("cg"..slot..item, self.EquipItem, 0.1, self, slot, item, true)
			else
				self:Print(string.format(L["Couldn't find %s in your inventory."], item))
			end
		end
	end
end

function ClosetGnome:HasSet(name)
	return self.db.char.set[name] ~= nil
end

function ClosetGnome:FindItem(item)
	for i = NUM_BAG_FRAMES, 0, -1 do
		for j = GetContainerNumSlots(i), 1, -1 do
			gratuity:SetBagItem(i, j)
			local bagItem = gratuity:GetLine(1)
			if bagItem == item then return i, j end
		end
	end
	return -1
end

-------------------------------------------------------------------------------
-- Hooks                                                                     --
-------------------------------------------------------------------------------

-- Only hooked if we are showing the paper doll frame with set adding
function ClosetGnome:CharacterFrame_OnHide()
	for _, item in ipairs(slots) do
		if item.frame then
			item.frame:Hide()
			local gslot = _G["Character" .. item.slot .. "Slot"]
			self.activeSlots[gslot:GetName()] = nil
			gslot:SetScript("OnClick", item.script)
		end
	end

	StaticPopup_Hide("ClosetGnomeAdd")
	if self:IsHooked("CharacterFrame_OnHide") then
		self:Unhook("CharacterFrame_OnHide")
	end
	if self:IsHooked("CharacterFrameTab_OnClick") then
		self:Unhook("CharacterFrameTab_OnClick")
	end
end

function ClosetGnome:CharacterFrameTab_OnClick() --[[ noop ]] end

-------------------------------------------------------------------------------
-- Events                                                                    --
-------------------------------------------------------------------------------

function ClosetGnome:AceEvent_FullyInitialized()
	-- Loop through the current sets and check if we have any of them equipped.
	for k,v in pairs(self.db.char.set) do
		if self:IsSetFullyEquipped(k) then
			lastEquippedSet = k
			self:TriggerEvent("ClosetGnome_WearSet", k)
			break
		end
	end
	self:UpdateText()
	self:UpdateTooltip()
	self:Print("|cffff0000ClosetGnome is NOT RELEASED YET. If you're using it despite this fact, you may NOT post about it on the forums. Please contact me on IRC if you want to report a bug or ask questions about it.|r")
end

function ClosetGnome:PLAYER_REGEN_ENABLED()
	if not queuedSet then return end
	self:WearSet(queuedSet)
end

-------------------------------------------------------------------------------
-- FuBarPlugin                                                               --
-------------------------------------------------------------------------------

function ClosetGnome:OnTextUpdate()
	if lastEquippedSet then
		self:SetText(lastEquippedSet)
	else
		self:SetText(L["ClosetGnome"])
	end
	if self.db.char.icons[lastEquippedSet] then
		self:SetIcon(self.db.char.icons[lastEquippedSet])
	else
		self:SetIcon(defaultIcon)
	end
end

function ClosetGnome:OnTooltipUpdate()
	local cat = nil

	local sets = compost:Acquire()
	for k in pairs(self.db.char.set) do table.insert(sets, k) end

	table.sort(sets)
	for i,k in ipairs(sets) do
		if not cat then
			cat = tablet:AddCategory("columns", 1, "text", L["Available sets"], "showWithoutChildren", false)
		end
		local set = k
		if lastEquippedSet == set then set = set .. "*" end
		cat:AddLine("text", set, "func", function(set) ClosetGnome:WearSet(set) end, "arg1", set, "justify", "LEFT", "hasCheck", true, "checked", true, "checkIcon", self.db.char.icons[k] or "")
	end
	compost:Reclaim(sets)
	sets = nil

	if cat ~= nil then
		tablet:SetHint(L["Click a set above to change your equipment. The last equipped set is indicated by a star."])
	else
		tablet:SetHint(L["You have not created any equipment sets yet, please right-click the icon and click 'Add' to create a set."])
	end
end

