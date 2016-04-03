simpleMinimap_Skins = simpleMinimap:NewModule("skins")
local L = AceLibrary("AceLocale-2.2"):new("simpleMinimap_Skins")
L:RegisterTranslations("enUS", function() return({
	enabled = "enabled",
		enabled_desc = "enable / disable skin module",
	border = "border",
		border_desc = "minimap border texture",
	skin = "skin",
		skin_desc = "minimap skin and shape",
	skins = "skins",
		skins_desc = "minimap skin and shape module",
	skin1 = "round (default)",
	skin2 = "square",
	skin3 = "top right corner",
	skin4 = "top left corner",
	skin5 = "bottom left corner",
	skin6 = "bottom right corner",
}) end)
--
function simpleMinimap_Skins:OnInitialize()
	self.db = simpleMinimap:AcquireDBNamespace("skins")
	self.skins = {
		{	
			shape="circle",
			texture="Interface\\Minimap\\UI-Minimap-Border",
			mask="textures\\MinimapMask"
		},{
			shape="square",
			texture="Interface\\AddOns\\simpleMinimap\\skins\\SquareMinimap",
			mask="Interface\\AddOns\\simpleMinimap\\skins\\SquareMinimapMask"
		},{
			shape="square",
			texture="Interface\\AddOns\\simpleMinimap\\skins\\dLxTopRight",
			mask="Interface\\AddOns\\simpleMinimap\\skins\\dLxTopRightMask"
		},{
-- thank you Contusion from ui.worldofwar.net for the other three corner maps
			shape="square",
			texture="Interface\\AddOns\\simpleMinimap\\skins\\dLxTopLeft",
			mask="Interface\\AddOns\\simpleMinimap\\skins\\dLxTopLeftMask"
		},{
			shape="square",
			texture="Interface\\AddOns\\simpleMinimap\\skins\\dLxBottomLeft",
			mask="Interface\\AddOns\\simpleMinimap\\skins\\dLxBottomLeftMask"
		},{
			shape="square",
			texture="Interface\\AddOns\\simpleMinimap\\skins\\dLxBottomRight",
			mask="Interface\\AddOns\\simpleMinimap\\skins\\dLxBottomRightMask"
		}
	}
	self.defaults = { enabled=true, skin=1, border=true }
	self.options = {
		type="group", name=L.skins, desc=L.skins_desc,
		args={
			title={
				type="header", order=1, name="simpleMinimap |cFFFFFFCC"..L.skins
			},
			spacer1={
				type="header", order=2
			},
			enabled={
				type="toggle", order=3, name=L.enabled, desc=L.enabled_desc,
				get=function() return(self.db.profile.enabled) end,
				set=function(x) self.db.profile.enabled=x simpleMinimap:ToggleModuleActive(self, x) end
			},
			spacer2={
				type="header", order=4, name="---"
			},
			border={
				type="toggle", order=10, name=L.border, desc=L.border_desc,
				get=function() return(self.db.profile.border) end,
				set=function(x) self.db.profile.border=x self:OnEnable() end
			},
			skin={
				type="group", order=10, name=L.skin, desc=L.skin_desc,
				args={
					["1"]={
						type="toggle", order=1, name="1 :: "..L.skin1, desc=L.skin1,
						get=function() return(self.db.profile.skin==1) end,
						set=function() self.db.profile.skin=1 self:OnEnable() end
					},
					["2"]={
						type="toggle", order=2, name="2 :: "..L.skin2, desc=L.skin2,
						get=function() return(self.db.profile.skin==2) end,
						set=function() self.db.profile.skin=2 self:OnEnable() end
					},
					["3"]={
						type="toggle", order=3, name = "3 :: "..L.skin3, desc = L.skin3,
						get=function() return(self.db.profile.skin==3) end,
						set=function() self.db.profile.skin=3 self:OnEnable() end
					},
					["4"]={
						type="toggle", order=4, name="4 :: "..L.skin4, desc=L.skin4,
						get=function() return(self.db.profile.skin==4) end,
						set=function() self.db.profile.skin=4 self:OnEnable() end
					},
					["5"]={
						type="toggle", order=5, name="5 :: "..L.skin5, desc=L.skin5,
						get=function() return(self.db.profile.skin==5) end,
						set=function() self.db.profile.skin=5 self:OnEnable() end
					},
					["6"]={
						type="toggle", order=6, name="6 :: "..L.skin6, desc=L.skin6,
						get=function() return(self.db.profile.skin==6) end,
						set=function() self.db.profile.skin=6 self:OnEnable() end
					}
				}
			}
		}
	}
	simpleMinimap.options.args.modules.args.skins = self.options
	simpleMinimap:RegisterDefaults("skins", "profile", self.defaults)
end
--
function simpleMinimap_Skins:OnEnable()
	if(self.db.profile.enabled) then
		simpleMinimap:UpdateScreen()
	else
		simpleMinimap:ToggleModuleActive(self, false)
	end
end
--
function simpleMinimap_Skins:OnDisable()
	simpleMinimap:UpdateScreen()
end
--
function simpleMinimap_Skins:GetButtonPos(vector)
	local x, y
	if(simpleMinimap:IsModuleActive(self) and self:GetShape() == "square") then
		x = math.max(-81, math.min(110 * cos(vector), 81))
		y = math.max(-81, math.min(110 * sin(vector), 81))
	else
		x = 81 * cos(vector)
		y = 81 * sin(vector)
	end
	return 52 - x, y - 54
end
--
function simpleMinimap_Skins:UpdateScreen()
	if(simpleMinimap:IsModuleActive(self)) then
		if(self.db.profile.border) then
			MinimapBorder:SetTexture(self.skins[self.db.profile.skin]["texture"])
		else
			MinimapBorder:SetTexture(nil)
		end
		Minimap:SetMaskTexture(self.skins[self.db.profile.skin]["mask"])
	else
		MinimapBorder:SetTexture("Interface\\Minimap\\UI-Minimap-Border")
		Minimap:SetMaskTexture("textures\\MinimapMask")
	end	
end
--
function simpleMinimap_Skins:GetShape()
	if(simpleMinimap:IsModuleActive(self)) then return(self.skins[self.db.profile.skin].shape) end
end