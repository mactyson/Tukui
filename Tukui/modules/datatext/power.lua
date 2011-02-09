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
-- player power (attackpower or power depending on what you have more of)
--------------------------------------------------------------------

if C["datatext"].power and C["datatext"].power > 0 then
	local Stat = CreateFrame("Frame")
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	local Text  = TukuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(C.media.pixelfont2, C["datatext"].fontsize,C["datatext"].fontflag)
	T.PP(C["datatext"].power, Text)

	local int = 1

	local function Update(self, t)
		int = int - t
		local base, posBuff, negBuff = UnitAttackPower("player")
		local effective = base + posBuff + negBuff
		local Rbase, RposBuff, RnegBuff = UnitRangedAttackPower("player")
		local Reffective = Rbase + RposBuff + RnegBuff


		healpwr = GetSpellBonusHealing()

		Rattackpwr = Reffective
		spellpwr2 = GetSpellBonusDamage(7)
		attackpwr = effective

		if healpwr > spellpwr2 then
			spellpwr = healpwr
		else
			spellpwr = spellpwr2
		end

		if attackpwr > spellpwr and select(2, UnitClass("Player")) ~= "HUNTER" then
			pwr = attackpwr
			tp_pwr = L.datatext_playerap
		elseif select(2, UnitClass("Player")) == "HUNTER" then
			pwr = Reffective
			tp_pwr = L.datatext_playerap
		else
			pwr = spellpwr
			tp_pwr = L.datatext_playersp
		end
		if int < 0 then
			Text:SetText(pwr.." "..hexa.. tp_pwr..hexb)      
			int = 1
		end
	end

	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end