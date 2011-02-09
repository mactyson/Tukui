local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

    _, class = UnitClass("player")
    hexa = C.datatext.color
    hexb = "|r"

if C.datatext.classcolor == true then
	if class == "DEATHKNIGHT" then
		hexa = "|cffC41F3B"
	elseif class == "DRUID" then
		hexa = "|cffFF7D0A"
	elseif class == "HUNTER" then
		hexa = "|cffABD473"
	elseif class == "MAGE" then
		hexa = "|cff69CCF0"
	elseif class == "PALADIN" then
		hexa = "|cffF58CBA"
	elseif class == "PRIEST" then
		hexa = "|cffFFFFFF"
	elseif class == "ROGUE" then
		hexa = "|cffFFF569"
	elseif class == "SHAMAN" then
		hexa = "|cff2459FF"
	elseif class == "WARLOCK" then
		hexa = "|cff9482C9"
	elseif class == "WARRIOR" then
		hexa = "|cffC79C6E"
	end
end	
--------------------------------------------------------------------
-- Crit (Spell or Melee.. or ranged)
--------------------------------------------------------------------

if C["datatext"].crit and C["datatext"].crit > 0 then
	local Stat = CreateFrame("Frame")
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	local Text  = TukuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(C.media.pixelfont2, C["datatext"].fontsize,C["datatext"].fontflag)
	T.PP(C["datatext"].crit, Text)

	local int = 1

	local function Update(self, t)
		int = int - t
		meleecrit = GetCritChance()
		spellcrit = GetSpellCritChance(1)
		rangedcrit = GetRangedCritChance()
		if spellcrit > meleecrit then
			CritChance = spellcrit
		elseif select(2, UnitClass("Player")) == "HUNTER" then    
			CritChance = rangedcrit
		else
			CritChance = meleecrit
		end
		if int < 0 then
			Text:SetText(format("%.2f", CritChance) .. "%"..hexa..L.datatext_playercrit..hexb)
			int = 1
		end     
	end

	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end