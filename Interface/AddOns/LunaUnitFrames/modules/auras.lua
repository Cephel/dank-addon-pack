local L = LunaUF.L
local Auras = {}
LunaUF:RegisterModule(Auras, "auras", L["Auras"])

-- Thanks schaka! :D
local function firstToUpper(str)
	if (str~=nil) then
		return (string.gsub(str, "^%l", string.upper));
	else
		return nil;
	end
end

local function showTooltip()
	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT")
	if( this.filter == "TEMP" ) then
		GameTooltip:SetInventoryItem("player", this.auraID)
	elseif this.filter == "HELPFUL" then
		GameTooltip:SetUnitBuff(this:GetParent():GetParent().unit, this.auraID)
	else
		GameTooltip:SetUnitDebuff(this:GetParent():GetParent().unit, this.auraID)
	end
end

local function hideTooltip()
	GameTooltip:Hide()
end

local function BuffUpdate(frame)
	local auraframe = frame or this
	local unit = auraframe:GetParent().unit
	local config = LunaUF.db.profile.units[auraframe:GetParent().unitGroup].auras
	local numBuffs = 0
	while UnitBuff(unit, numBuffs+1) do
		numBuffs = numBuffs + 1
	end
	local rows = math.ceil(numBuffs/config.AurasPerRow)
	local height = rows*auraframe.buffbuttons[1]:GetHeight()+rows
	auraframe:SetHeight(height == 0 and 1 or height)
	local texture,stacks
	for i,button in ipairs(auraframe.buffbuttons) do
		texture,stacks = UnitBuff(unit,i)
		if texture then
			button.icon:SetTexture(texture)
			button.stack:SetText(stacks == 1 and "" or stacks)
			button.filter = "HELPFUL"
			button.auraID = i
			button:Show()
		else
			button:Hide()
		end
	end
	for i,button in ipairs(auraframe.debuffbuttons) do
		texture,stacks = UnitDebuff(unit,i)
		if texture then
			button.icon:SetTexture(texture)
			button.stack:SetText(stacks == 1 and "" or stacks)
			button.filter = "HARMFUL"
			button.auraID = i
			button:Show()
		else
			button:Hide()
		end
	end
end

local function OnEvent()
	if arg1 == this:GetParent().unit then
		BuffUpdate(this)
	end
end	

function Auras:OnEnable(frame)
	local isPlayer = frame.unitGroup == "player"
	if not frame.auras then
		frame.auras = CreateFrame("Frame", nil, frame)
		frame.auras.buffbuttons = {}
		frame.auras.debuffbuttons = {}
		for i=1, (isPlayer and 34 or 32) do
			local button = CreateFrame("Button", "Luna"..firstToUpper(frame.trueunit or frame:GetName()).."BuffFrame"..i, frame.auras)
			button:SetScript("OnEnter", showTooltip)
			button:SetScript("OnLeave", hideTooltip)
			if isPlayer then
				button:SetScript("OnClick", cancelBuff)
				button:RegisterForClicks("RightButtonUp")
				button.cooldown = CreateFrame("Model", button:GetName().."CD", button, "CooldownFrameTemplate")		
				button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT")
				button.cooldown:SetHeight(36)
				button.cooldown:SetWidth(36)
		--		button.cooldown:SetReverse(true)
				button.cooldown:SetFrameLevel(7)
				button.cooldown:Hide()
			end
			
			button.stack = button:CreateFontString(nil, "OVERLAY")
			button.stack:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", 10, "OUTLINE")
			button.stack:SetShadowColor(0, 0, 0, 1.0)
			button.stack:SetShadowOffset(0.50, -0.50)
			button.stack:SetHeight(1)
			button.stack:SetWidth(1)
			button.stack:SetAllPoints(button)
			button.stack:SetJustifyV("BOTTOM")
			button.stack:SetJustifyH("RIGHT")

			button.border = button:CreateTexture(nil, "OVERLAY")
			button.border:SetPoint("CENTER", button)		
			
			button.icon = button:CreateTexture(nil, "BACKGROUND")
			button.icon:SetAllPoints(button)
			button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			
			frame.auras.buffbuttons[i] = button
		end
		for i=1, 16 do
			local button = CreateFrame("Button", "Luna"..firstToUpper(frame.trueunit or frame:GetName()).."DebuffFrame"..i, frame.auras)
			button:SetScript("OnEnter", showTooltip)
			button:SetScript("OnLeave", hideTooltip)
			if isPlayer then
				button.cooldown = CreateFrame("Model", button:GetName().."CD", button, "CooldownFrameTemplate")		
				button.cooldown:SetPoint("TOPLEFT", button, "TOPLEFT")
				button.cooldown:SetHeight(36)
				button.cooldown:SetWidth(36)
		--		button.cooldown:SetReverse(true)
				button.cooldown:SetFrameLevel(7)
				button.cooldown:Hide()
			end
			
			button.stack = button:CreateFontString(nil, "OVERLAY")
			button.stack:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", 10, "OUTLINE")
			button.stack:SetShadowColor(0, 0, 0, 1.0)
			button.stack:SetShadowOffset(0.50, -0.50)
			button.stack:SetHeight(1)
			button.stack:SetWidth(1)
			button.stack:SetAllPoints(button)
			button.stack:SetJustifyV("BOTTOM")
			button.stack:SetJustifyH("RIGHT")

			button.border = button:CreateTexture(nil, "OVERLAY")
			button.border:SetPoint("CENTER", button)		
			
			button.icon = button:CreateTexture(nil, "BACKGROUND")
			button.icon:SetAllPoints(button)
			button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			
			frame.auras.debuffbuttons[i] = button
		end
	end
	for num,button in pairs(frame.auras.buffbuttons) do
		if( LunaUF.db.profile.auraborderType == L["none"] ) then
			button.border:Hide()
		elseif( LunaUF.db.profile.auraborderType == "blizzard" ) then
			button.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
			button.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
			button.border:Show()
		else
			button.border:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\borders\\border-" .. LunaUF.db.profile.auraborderType)
			button.border:SetTexCoord(0, 1, 0, 1)
			button.border:Show()
		end
	end
	for num,button in pairs(frame.auras.debuffbuttons) do
		if( LunaUF.db.profile.auraborderType == L["none"] ) then
			button.border:Hide()
		elseif( LunaUF.db.profile.auraborderType == "blizzard" ) then
			button.border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
			button.border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
			button.border:Show()
		else
			button.border:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\borders\\border-" .. LunaUF.db.profile.auraborderType)
			button.border:SetTexCoord(0, 1, 0, 1)
			button.border:Show()
		end
	end
	frame.auras:Show()
	frame.auras:RegisterEvent("UNIT_AURA")
	frame.auras:SetScript("OnEvent", OnEvent)
	frame.auras:SetScript("OnUpdate", OnUpdate)
end

function Auras:OnDisable(frame)
	if frame.auras then
		frame.auras:UnregisterAllEvents()
		frame.auras:SetScript("OnEvent", nil)
		frame.auras:SetScript("OnUpdate", nil)
		frame.auras:Hide()
	end
end

function Auras:FullUpdate(frame)
	local config = LunaUF.db.profile.units[frame.unitGroup].auras
	local framelength = frame:GetWidth()
	local frameheight = frame:GetHeight()
	local buttonsize = ((framelength-config.AurasPerRow-1)/config.AurasPerRow)
	local row = 1
	frame.auras:ClearAllPoints()
	frame.auras:SetWidth(1)
	frame.auras:SetHeight(1)
	if config.position == "TOP" then
		frame.auras:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 3)
		for i,button in ipairs(frame.auras.buffbuttons) do
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.border:SetHeight(buttonsize+1)
			button.border:SetWidth(buttonsize+1)
			button.stack:SetText(i)
			button:SetPoint("BOTTOMLEFT", frame.auras, "BOTTOMLEFT", (i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1)), (math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
		end
		for i,button in ipairs(frame.auras.debuffbuttons) do
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.border:SetHeight(buttonsize+1)
			button.border:SetWidth(buttonsize+1)
			button.stack:SetText(i)
			button:SetPoint("BOTTOMLEFT", frame.auras, "TOPLEFT", (i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1)), (math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
		end
	elseif config.position == "LEFT" then
		frame.auras:SetPoint("TOPRIGHT", frame, "TOPLEFT", -3, 0)
		for i,button in ipairs(frame.auras.buffbuttons) do
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.border:SetHeight(buttonsize+1)
			button.border:SetWidth(buttonsize+1)
			button.stack:SetText(i)
			button:SetPoint("TOPRIGHT", frame.auras, "TOPRIGHT", -((i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1))), -(math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
		end
		for i,button in ipairs(frame.auras.debuffbuttons) do
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.border:SetHeight(buttonsize+1)
			button.border:SetWidth(buttonsize+1)
			button.stack:SetText(i)
			button:SetPoint("TOPRIGHT", frame.auras, "BOTTOMRIGHT", -((i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1))), -(math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
		end
	else
		if config.position == "BOTTOM" then
			frame.auras:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -3)
		else
			frame.auras:SetPoint("TOPLEFT", frame, "TOPRIGHT", 3, 0)
		end
		for i,button in ipairs(frame.auras.buffbuttons) do
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.border:SetHeight(buttonsize+1)
			button.border:SetWidth(buttonsize+1)
			button.stack:SetText(i)
			button:SetPoint("TOPLEFT", frame.auras, "TOPLEFT", (i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1)), -(math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
		end
		for i,button in ipairs(frame.auras.debuffbuttons) do
			button:ClearAllPoints()
			button:SetHeight(buttonsize)
			button:SetWidth(buttonsize)
			button.border:SetHeight(buttonsize+1)
			button.border:SetWidth(buttonsize+1)
			button.stack:SetText(i)
			button:SetPoint("TOPLEFT", frame.auras, "BOTTOMLEFT", (i-1)*(buttonsize+1)-((math.ceil(i/config.AurasPerRow)-1)*(config.AurasPerRow)*(buttonsize+1)), -(math.ceil(i/config.AurasPerRow)-1)*(buttonsize+1))
		end
	end
	BuffUpdate(frame.auras)
end