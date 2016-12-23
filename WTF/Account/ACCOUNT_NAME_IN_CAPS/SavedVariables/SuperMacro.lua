
SM_VARS = {
	["macroTip1"] = 0,
	["printColor"] = {
		["r"] = 1,
		["g"] = 1,
		["b"] = 1,
	},
	["showMenu"] = 1,
	["minimap"] = 0,
	["hideAction"] = 0,
	["checkCooldown"] = 1,
	["wordWrap"] = 0,
	["replaceIcon"] = 0,
	["tabShown"] = "super",
	["macroTip2"] = 0,
}
SM_EXTEND = {
}
SM_ACTION_SUPER = {
	["Cephel of Nostalrius PvP"] = {
	},
	["You of Nostalrius PvE"] = {
	},
	["Cephell of Nostalrius PvP"] = {
		[97] = "DPS",
		[98] = "AOE",
	},
	["Ycbcuckone of Player Test Realm"] = {
	},
	["Ycbcuckthree of Player Test Realm"] = {
	},
	["Cephi of Nostalrius PvP"] = {
	},
	["Cephii of Nostalrius PvP"] = {
	},
	["Cephell of Player Test Realm"] = {
		[98] = "AOE",
		[97] = "DPS",
		[69] = "spam TP",
	},
	["Cepheii of Nostalrius Begins PvP"] = {
	},
	["Cephii of Nostalrius Begins PvP"] = {
	},
	["Popblues of Nostalrius Begins PvP"] = {
	},
	["Cephel of Nostalrius Begins PvP"] = {
		[21] = "Devilsaur Tagger",
	},
	["Awdaw of Player Test Realm"] = {
	},
	["Cepheil of Nostalrius Begins PvP"] = {
	},
	["Ycbcucktwo of Player Test Realm"] = {
	},
	["Cephell of Nostalrius Begins PvP"] = {
		[98] = "AOE",
		[97] = "DPS",
		[55] = "spam TP",
	},
	["Cepheli of Nostalrius Begins PvP"] = {
	},
	["Cuck of Nostalrius PvE"] = {
	},
	["Cephi of Nostalrius Begins PvP"] = {
		[82] = "spam TP",
	},
}
SM_SUPER = {
	["Gratz"] = {
		[1] = "Gratz",
		[2] = "Interface\\Icons\\Ability_Hunter_Pet_Raptor",
		[3] = "/w Cephel  ____",
	},
	["AOE"] = {
		[1] = "AOE",
		[2] = "Interface\\ICONS\\Ability_Whirlwind",
		[3] = "/run if not IsCurrentAction(108) then UseAction(108) end\n/run CastSpellByName(\"Bloodrage\");\n/run local i, shout = 1, 0; while UnitBuff(\"player\", i) do local name = UnitBuff(\"player\", i); if name == \"Interface\\\\Icons\\\\Ability_Warrior_BattleShout\" then shout = 1; end i = i + 1; end if shout == 0 then CastSpellByName(\"Battle Shout\"); end\n/run CastSpellByName(\"Whirlwind\");\n/run local rage = UnitMana(\"player\"); if rage >= 45 then CastSpellByName(\"Cleave\"); end\n/run local rage = UnitMana(\"player\"); if rage >= 75 then CastSpellByName(\"Bloodthirst\"); end\n/run local rage = UnitMana(\"player\"); if rage >= 85 then CastSpellByName(\"Hamstring\"); end",
	},
	["DPS"] = {
		[1] = "DPS",
		[2] = "Interface\\Icons\\Spell_Nature_BloodLust",
		[3] = "/run if not IsCurrentAction(108) then UseAction(108) end\n/run CastSpellByName(\"Bloodrage\");\n/run local i, shout = 1, 0; while UnitBuff(\"player\", i) do local name = UnitBuff(\"player\", i); if name == \"Interface\\\\Icons\\\\Ability_Warrior_BattleShout\" then shout = 1; end i = i + 1; end if shout == 0 then CastSpellByName(\"Battle Shout\"); end\n/run CastSpellByName(\"Bloodthirst\");\n/run CastSpellByName(\"Whirlwind\");\n/run local rage = UnitMana(\"player\"); if rage >= 65 then CastSpellByName(\"Hamstring\"); end",
	},
	["Devilsaur Tagger"] = {
		[1] = "Devilsaur Tagger",
		[2] = "Interface\\Icons\\Ability_Creature_Cursed_03",
		[3] = "/script local tar = {\"Devilsaur\", \"Ironhide Devilsaur\", \"Tyrant Devilsaur\"}; for i=1, table.getn(tar), 1 do TargetByName(tar[i], true); if UnitName(\"target\") == tar[i] and not UnitIsDeadOrGhost(\"target\") and not UnitPlayerControlled(\"target\") then CastSpellByName(\"Holy Nova(Rank 1)\"); end end",
	},
	["shackel"] = {
		[1] = "shackel",
		[2] = "Interface\\Icons\\Ability_Creature_Disease_04",
		[3] = "/script if UnitCreatureType(\"target\") == \"Undead\" then local unitname = UnitName(\"target\"); local symbol = \"\"; if GetRaidTargetIndex(\"target\") == 1 then symbol = \"Star\"; elseif GetRaidTargetIndex(\"target\") == 2 then symbol = \"Circle\"; elseif GetRaidTargetIndex(\"target\") == 3 then symbol = \"Diamond\"; elseif GetRaidTargetIndex(\"target\") == 4 then symbol = \"Triangle\"; elseif GetRaidTargetIndex(\"target\") == 5 then symbol = \"Moon\"; elseif GetRaidTargetIndex(\"target\") == 6 then symbol = \"Square\"; elseif GetRaidTargetIndex(\"target\") == 7 then symbol = \"Cross\"; elseif GetRaidTargetIndex(\"target\") == 8 then symbol = \"Skull\"; end local message = \"Shackling \" .. unitname; if symbol ~= \"\" then message = message .. \" (\" .. symbol .. \")\"; end message = message .. \".\"; SendChatMessage(message, \"PARTY\"); SendChatMessage(message, \"RAID\"); CastSpellByName(\"Shackle Undead\"); end",
	},
	["lalalal"] = {
		[1] = "lalalal",
		[2] = "Interface\\Icons\\Ability_Warrior_Charge",
		[3] = "/run local d1, d2, d3 = \"Swine\", \"Cephel\", \"Elder Mottled Boar\"; if UnitName(\"target\") == d1 or UnitName(\"target\") == d2 or UnitName(\"target\") == d3 then local message = UnitName(\"target\") .. \"isasdasdasds\"; SendChatMessage(message, \"WHISPER\", nil, \"Holow\"); end",
	},
	["spam TP"] = {
		[1] = "spam TP",
		[2] = "Interface\\Icons\\Ability_TrueShot",
		[3] = "/ra  ____     ______ ______ \n/ra ||_      ||   ||__        ||__        ||\n/ra  _||     ||_ ||        __||__        ||\n/ra ||______||______||______||",
	},
}
