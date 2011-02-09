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
-- FPS
--------------------------------------------------------------------

if C["datatext"].fps_ms and C["datatext"].fps_ms > 0 then
	local Stat = CreateFrame("Frame")
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	local Text  = TukuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(C.media.pixelfont2, C["datatext"].fontsize,C["datatext"].fontflag)
	T.PP(C["datatext"].fps_ms, Text)

	local int = 1
	local function Update(self, t)
		int = int - t
		if int < 0 then
			Text:SetText(floor(GetFramerate())..hexa..tukuilocal.datatext_fps..hexb..select(3, GetNetStats())..hexa..tukuilocal.datatext_ms..hexb)
			int = 1
		end	
	end

	Stat:SetScript("OnUpdate", Update) 
	Update(Stat, 10)
end