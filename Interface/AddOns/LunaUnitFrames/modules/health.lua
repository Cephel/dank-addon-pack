local Health = {}
LunaUF:RegisterModule(Health, "healthBar", LunaUF.L["Health bar"], true)

local function OnEvent()
	if arg1 ~= this:GetParent().unit then return end
	if event == "UNIT_FACTION" or event == "UNIT_HAPPINESS" then
		Health:UpdateColor(this:GetParent())
	else
		Health:Update(this:GetParent())
	end
end

local function getGradientColor(unit)
	local percent = UnitHealth(unit) / UnitHealthMax(unit)
	if( percent >= 1 ) then return LunaUF.db.profile.healthColors.green.r, LunaUF.db.profile.healthColors.green.g, LunaUF.db.profile.healthColors.green.b end
	if( percent == 0 ) then return LunaUF.db.profile.healthColors.red.r, LunaUF.db.profile.healthColors.red.g, LunaUF.db.profile.healthColors.red.b end
	
	local sR, sG, sB, eR, eG, eB = 0, 0, 0, 0, 0, 0
	local modifier, inverseModifier = percent * 2, 0
	if( percent > 0.50 ) then
		sR, sG, sB = LunaUF.db.profile.healthColors.green.r, LunaUF.db.profile.healthColors.green.g, LunaUF.db.profile.healthColors.green.b
		eR, eG, eB = LunaUF.db.profile.healthColors.yellow.r, LunaUF.db.profile.healthColors.yellow.g, LunaUF.db.profile.healthColors.yellow.b

		modifier = modifier - 1
	else
		sR, sG, sB = LunaUF.db.profile.healthColors.yellow.r, LunaUF.db.profile.healthColors.yellow.g, LunaUF.db.profile.healthColors.yellow.b
		eR, eG, eB = LunaUF.db.profile.healthColors.red.r, LunaUF.db.profile.healthColors.red.g, LunaUF.db.profile.healthColors.red.b
	end
	
	inverseModifier = 1 - modifier
	return eR * inverseModifier + sR * modifier, eG * inverseModifier + sG * modifier, eB * inverseModifier + sB * modifier
end

Health.getGradientColor = getGradientColor

-- Not doing full health update, because other checks can lag behind without much issue
local function updateTimer()
	local frame = this:GetParent()
	local currentHealth = UnitHealth(frame.unit)
	if( currentHealth == this.currentHealth ) then return end
	this.currentHealth = currentHealth
	this:SetValue(currentHealth)

	-- Update incoming heal number
	if LunaUF.db.profile.units[frame.unitGroup].incheal.enabled and frame.incheal then
		LunaUF.modules.incheal:FullUpdate(frame)
	end
	
	-- The target is not offline, and we have a health percentage so update the gradient
	if( not this.wasOffline and this.hasPercent ) then
		Health:SetBarColor(this, LunaUF.db.profile.units[frame.unitGroup].healthBar.invert, getGradientColor(frame.unit))
	end
end

function Health:OnEnable(frame)
	if( not frame.healthBar ) then
		frame.healthBar = LunaUF.Units:CreateBar(frame)
		frame.fontstrings["healthBar"] = {
			["left"] = frame.healthBar:CreateFontString(nil, "ARTWORK"),
			["center"] = frame.healthBar:CreateFontString(nil, "ARTWORK"),
			["right"] = frame.healthBar:CreateFontString(nil, "ARTWORK"),
		}
		for align,fontstring in pairs(frame.fontstrings["healthBar"]) do
			fontstring:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", 14)
			fontstring:SetShadowColor(0, 0, 0, 1.0)
			fontstring:SetShadowOffset(0.80, -0.80)
			fontstring:SetJustifyH(string.upper(align))
			fontstring:SetAllPoints(frame.healthBar)
		end
	else
		frame.healthBar:Show()
	end
	
	frame.healthBar:RegisterEvent("UNIT_FACTION")
	frame.healthBar:RegisterEvent("UNIT_HEALTH")
	frame.healthBar:RegisterEvent("UNIT_MAXHEALTH")
	
	if( UnitIsUnit(frame.unit,"pet") ) then
		frame.healthBar:RegisterEvent("UNIT_HAPPINESS")
	end
	
	frame.healthBar:SetScript("OnEvent", OnEvent)
	frame.healthBar:SetScript("OnUpdate", updateTimer)
end

function Health:OnDisable(frame)
	if frame.healthBar then
		frame.healthBar:UnregisterAllEvents()
		frame.healthBar:SetScript("OnEvent", nil)
		frame.healthBar:SetScript("OnUpdate", nil)
		frame.healthBar:Hide()
	end
end

function Health:SetBarColor(bar, invert, r, g, b)
	if( not invert ) then
		bar:SetStatusBarColor(r, g, b, LunaUF.db.profile.bars.alpha)
		if( not bar.background.overrideColor ) then
			bar.background:SetVertexColor(r, g, b, LunaUF.db.profile.bars.backgroundAlpha)
		end
	else
		bar.background:SetVertexColor(r, g, b, LunaUF.db.profile.bars.alpha)
		if( not bar.background.overrideColor ) then
			bar:SetStatusBarColor(0, 0, 0, 1 - LunaUF.db.profile.bars.backgroundAlpha)
		else
			bar:SetStatusBarColor(bar.background.overrideColor.r, bar.background.overrideColor.g, bar.background.overrideColor.b, 1 - LunaUF.db.profile.bars.backgroundAlpha)
		end
	end
end

function Health:UpdateColor(frame)
	frame.healthBar.hasReaction = nil
	frame.healthBar.hasPercent = nil
	frame.healthBar.wasOffline = nil
	
	local color
	local unit = frame.unit
	local reactionType = LunaUF.db.profile.units[frame.unitGroup].healthBar.reactionType
	if( not UnitIsConnected(unit) ) then
		frame.healthBar.wasOffline = true
		self:SetBarColor(frame.healthBar, LunaUF.db.profile.units[frame.unitGroup].healthBar.invert, LunaUF.db.profile.healthColors.offline.r, LunaUF.db.profile.healthColors.offline.g, LunaUF.db.profile.healthColors.offline.b)
		return
	elseif( LunaUF.db.profile.units[frame.unitGroup].healthBar.colorAggro and UnitThreatSituation(frame.unit) == 3 ) then
		self:SetBarColor(frame.healthBar, LunaUF.db.profile.units[frame.unitGroup].healthBar.invert, LunaUF.db.profile.healthColors.hostile.r, LunaUF.db.profile.healthColors.hostile.g, LunaUF.db.profile.healthColors.hostile.b)
		return
	elseif( not UnitIsTappedByPlayer(unit) and UnitIsTapped(unit) and UnitCanAttack("player", unit) ) then
		color = LunaUF.db.profile.healthColors.tapped
	elseif( unit == "pet" and reactionType == "happiness" and GetPetHappiness() ) then
		local happiness = GetPetHappiness()
		if( happiness == 3 ) then
			color = LunaUF.db.profile.healthColors.friendly
		elseif( happiness == 2 ) then
			color = LunaUF.db.profile.healthColors.neutral
		elseif( happiness == 1 ) then
			color = LunaUF.db.profile.healthColors.hostile
		end
	elseif( not UnitPlayerOrPetInRaid(unit) and not UnitPlayerOrPetInParty(unit) and ( ( ( reactionType == "player" or reactionType == "both" ) and UnitIsPlayer(unit) and not UnitIsFriend(unit, "player") ) or ( ( reactionType == "npc" or reactionType == "both" )  and not UnitIsPlayer(unit) ) ) ) then
		if( not UnitIsFriend(unit, "player") and UnitPlayerControlled(unit) ) then
			if( UnitCanAttack("player", unit) ) then
				color = LunaUF.db.profile.healthColors.hostile
			else
				color = LunaUF.db.profile.healthColors.enemyUnattack
			end
		elseif( UnitReaction(unit, "player") ) then
			local reaction = UnitReaction(unit, "player")
			if( reaction > 4 ) then
				color = LunaUF.db.profile.healthColors.friendly
			elseif( reaction == 4 ) then
				color = LunaUF.db.profile.healthColors.neutral
			elseif( reaction < 4 ) then
				color = LunaUF.db.profile.healthColors.hostile
			end
		end
	elseif( LunaUF.db.profile.units[frame.unitGroup].healthBar.colorType == "class" and ( UnitIsPlayer(unit) or UnitCreatureFamily(unit) ) ) then
		local _,tempclass = UnitClass(frame.unit)
		local class = UnitCreatureFamily(frame.unit) or tempclass
		color = class and LunaUF.db.profile.classColors[class]
	elseif( LunaUF.db.profile.units[frame.unitGroup].healthBar.colorType == "static" ) then
		color = LunaUF.db.profile.healthColors.static
	end
	
	if( color ) then
		self:SetBarColor(frame.healthBar, LunaUF.db.profile.units[frame.unitGroup].healthBar.invert, color.r, color.g, color.b)
	else
		frame.healthBar.hasPercent = true
		self:SetBarColor(frame.healthBar, LunaUF.db.profile.units[frame.unitGroup].healthBar.invert, getGradientColor(unit))
	end
end

function Health:Update(frame)
	local isOffline = not UnitIsConnected(frame.unit)
	frame.isDead = UnitIsDeadOrGhost(frame.unit)
	frame.healthBar.currentHealth = UnitHealth(frame.unit)
	frame.healthBar:SetMinMaxValues(0, UnitHealthMax(frame.unit))
	frame.healthBar:SetValue(isOffline and UnitHealthMax(frame.unit) or frame.isDead and 0 or frame.healthBar.currentHealth)
	
	-- Unit is offline, fill bar up + grey it
	if( isOffline ) then
		frame.healthBar.wasOffline = true
		frame.unitIsOnline = nil
		self:SetBarColor(frame.healthBar, LunaUF.db.profile.units[frame.unitGroup].healthBar.invert, LunaUF.db.profile.healthColors.offline.r, LunaUF.db.profile.healthColors.offline.g, LunaUF.db.profile.healthColors.offline.b)
	-- The unit was offline, but they no longer are so we need to do a forced color update
	elseif( frame.healthBar.wasOffline ) then
		frame.healthBar.wasOffline = nil
		self:UpdateColor(frame)
	-- Color health by percentage
	elseif( frame.healthBar.hasPercent ) then
		self:SetBarColor(frame.healthBar, LunaUF.db.profile.units[frame.unitGroup].healthBar.invert, getGradientColor(frame.unit))
	end
	
	if LunaUF.db.profile.units[frame.unitGroup].incheal.enabled and frame.incheal then
		LunaUF.modules.incheal:FullUpdate(frame)
	end
end

function Health:FullUpdate(frame)
	if LunaUF.db.profile.units[frame.unitGroup].healthBar.vertical then
		frame.healthBar:SetOrientation("VERTICAL")
	else
		frame.healthBar:SetOrientation("HORIZONTAL")
	end
	for align,fontstring in pairs(frame.fontstrings["healthBar"]) do
		fontstring:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\"..LunaUF.db.profile.font..".ttf", LunaUF.db.profile.units[frame.unitGroup].tags.bartags["healthBar"].size)
		fontstring:ClearAllPoints()
		fontstring:SetHeight(frame.healthBar:GetHeight())
		if align == "left" then
			fontstring:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT", 2, 0)
			fontstring:SetWidth(frame.healthBar:GetWidth()-4)
		elseif align == "center" then
			fontstring:SetAllPoints(frame.healthBar)
			fontstring:SetWidth(frame.healthBar:GetWidth())
		else
			fontstring:SetPoint("TOPRIGHT", frame.healthBar, "TOPRIGHT", -2 , 0)
			fontstring:SetWidth(frame.healthBar:GetWidth()-4)
		end
	end
	Health:Update(frame)
	Health:UpdateColor(frame)
end

function Health:SetBarTexture(frame,texture)
	if frame.healthBar then
		frame.healthBar:SetStatusBarTexture(texture)
		frame.healthBar.background:SetTexture(texture)
	end
end