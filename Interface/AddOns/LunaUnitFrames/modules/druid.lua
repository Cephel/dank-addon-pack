local Druid = {}
local DruidManaLib = LunaUF.DruidManaLib
local _,playerclass = UnitClass("player")
LunaUF:RegisterModule(Druid, "druidBar", LunaUF.L["Druid Bar"], true)

local function OnUpdate()
	local mana,manamax = DruidManaLib:GetMana()
	this:SetMinMaxValues(0,manamax)
	this:SetValue(mana)
end

local function OnEvent()
	Druid:FullUpdate(LunaUF.Units.unitFrames.player)
end

function Druid:OnEnable(frame)
	if playerclass ~= "DRUID" then return end
	if( not frame.druidBar ) then
		frame.druidBar = LunaUF.Units:CreateBar(frame)
		frame.fontstrings.druidBar = {
			["left"] = frame.druidBar:CreateFontString(nil, "ARTWORK"),
			["center"] = frame.druidBar:CreateFontString(nil, "ARTWORK"),
			["right"] = frame.druidBar:CreateFontString(nil, "ARTWORK"),
		}
		for align,fontstring in pairs(frame.fontstrings.druidBar) do
			fontstring:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\Luna.ttf", 14)
			fontstring:SetShadowColor(0, 0, 0, 1.0)
			fontstring:SetShadowOffset(0.80, -0.80)
			fontstring:SetJustifyH(string.upper(align))
			fontstring:SetAllPoints(frame.druidBar)
		end
	else
		frame.druidBar:Show()
	end
	frame.druidBar:RegisterEvent("UNIT_DISPLAYPOWER")
	frame.druidBar:SetScript("OnEvent", OnEvent)
	frame.druidBar:SetScript("OnUpdate", OnUpdate)
end

function Druid:OnDisable(frame)
	if frame.druidBar then
		frame.druidBar:Hide()
		frame.druidBar:SetScript("OnUpdate", nil)
		frame.druidBar:SetScript("OnEvent", nil)
		frame.druidBar:UnregisterAllEvents()
	end
end

function Druid:UpdateColor(frame)
	local color = LunaUF.db.profile.powerColors.MANA
	
	if( not LunaUF.db.profile.units.player.druidBar.invert ) then
		frame.druidBar:SetStatusBarColor(color.r, color.g, color.b, LunaUF.db.profile.bars.alpha)
		if( not frame.druidBar.background.overrideColor ) then
			frame.druidBar.background:SetVertexColor(color.r, color.g, color.b, LunaUF.db.profile.bars.backgroundAlpha)
		end
	else
		frame.druidBar.background:SetVertexColor(color.r, color.g, color.b, LunaUF.db.profile.bars.alpha)

		color = frame.druidBar.background.overrideColor
		if( not color ) then
			frame.druidBar:SetStatusBarColor(0, 0, 0, 1 - LunaUF.db.profile.bars.backgroundAlpha)
		else
			frame.druidBar:SetStatusBarColor(color.r, color.g, color.b, LunaUF.db.profile.bars.backgroundAlpha)
		end
	end
end

function Druid:FullUpdate(frame)
	if UnitPowerType(frame.unit) == 0 and not frame.druidBar.hidden then
		frame.druidBar.hidden = true
		LunaUF.Units:PositionWidgets(frame)
	elseif UnitPowerType(frame.unit) > 0 and frame.druidBar.hidden then
		frame.druidBar.hidden = nil
		LunaUF.Units:PositionWidgets(frame)
	end
	Druid:UpdateColor(frame)
	if LunaUF.db.profile.units[frame.unitGroup].druidBar.vertical then
		frame.druidBar:SetOrientation("VERTICAL")
	else
		frame.druidBar:SetOrientation("HORIZONTAL")
	end
	for align,fontstring in pairs(frame.fontstrings.druidBar) do
		fontstring:SetFont("Interface\\AddOns\\LunaUnitFrames\\media\\fonts\\"..LunaUF.db.profile.font..".ttf", LunaUF.db.profile.units[frame.unitGroup].tags.bartags["druidBar"].size)
		fontstring:ClearAllPoints()
		fontstring:SetHeight(frame.druidBar:GetHeight())
		if align == "left" then
			fontstring:SetPoint("TOPLEFT", frame.druidBar, "TOPLEFT", 2, 0)
			fontstring:SetWidth(frame.druidBar:GetWidth()/2)
		elseif align == "center" then
			fontstring:SetAllPoints(frame.druidBar)
			fontstring:SetWidth(frame.druidBar:GetWidth())
		else
			fontstring:SetPoint("TOPRIGHT", frame.druidBar, "TOPRIGHT", -2 , 0)
			fontstring:SetWidth(frame.druidBar:GetWidth()/2)
		end
	end
end

function Druid:SetBarTexture(frame,texture)
	if frame.druidBar then
		frame.druidBar:SetStatusBarTexture(texture)
		frame.druidBar.background:SetTexture(texture)
	end
end