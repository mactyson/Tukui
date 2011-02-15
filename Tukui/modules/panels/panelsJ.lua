local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
if C["interface"].style ~= "Jasje" then return end

local TukuiBar1 = CreateFrame("Frame", "TukuiBar1", UIParent, "SecureHandlerStateTemplate")
TukuiBar1:CreatePanel("Hydra", 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, 7)
TukuiBar1:SetWidth((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar1:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))
TukuiBar1:SetFrameStrata("BACKGROUND")
TukuiBar1:SetFrameLevel(1)
T.CreateShadow(TukuiBar1)

local TukuiBar2 = CreateFrame("Frame", "TukuiBar2", UIParent)
TukuiBar2:CreatePanel("Hydra", 1, 1, "BOTTOMRIGHT", TukuiBar1, "BOTTOMLEFT", -10, 0)
TukuiBar2:SetWidth((T.buttonsize * 3) + (T.buttonspacing * 4))
TukuiBar2:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))
TukuiBar2:SetFrameStrata("BACKGROUND")
TukuiBar2:SetFrameLevel(2)
T.CreateShadow(TukuiBar2)

local TukuiBar3 = CreateFrame("Frame", "TukuiBar3", UIParent)
TukuiBar3:CreatePanel("Hydra", 1, 1, "BOTTOMLEFT", TukuiBar1, "BOTTOMRIGHT", 10, 0)
TukuiBar3:SetWidth((T.buttonsize * 3) + (T.buttonspacing * 4))
TukuiBar3:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))
TukuiBar3:SetFrameStrata("BACKGROUND")
TukuiBar3:SetFrameLevel(2)
T.CreateShadow(TukuiBar3)

local TukuiBar4 = CreateFrame("Frame", "TukuiBar4", UIParent)
TukuiBar4:CreatePanel("Hydra", 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, 7)
TukuiBar4:SetWidth((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar4:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))
TukuiBar4:SetFrameStrata("BACKGROUND")
TukuiBar4:SetFrameLevel(2)

local TukuiBar5 = CreateFrame("Frame", "TukuiBar5", UIParent)
TukuiBar5:CreatePanel("Hydra", 1, (T.buttonsize * 12) + (T.buttonspacing * 13), "RIGHT", UIParent, "RIGHT", -10, -10)
TukuiBar5:SetWidth((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar5:SetFrameStrata("BACKGROUND")
TukuiBar5:SetFrameLevel(2)
T.CreateShadow(TukuiBar5)

local TukuiBar6 = CreateFrame("Frame", "TukuiBar6", UIParent)
TukuiBar6:SetWidth((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar6:SetHeight((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar6:SetPoint("LEFT", TukuiBar5, "LEFT", 0, 0)
TukuiBar6:SetFrameStrata("BACKGROUND")
TukuiBar6:SetFrameLevel(2)

local TukuiBar7 = CreateFrame("Frame", "TukuiBar7", UIParent)
TukuiBar7:SetWidth((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar7:SetHeight((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar7:SetPoint("TOP", TukuiBar5, "TOP", 0 , 0)
TukuiBar7:SetFrameStrata("BACKGROUND")
TukuiBar7:SetFrameLevel(2)

local petbg = CreateFrame("Frame", "TukuiPetBar", UIParent, "SecureHandlerStateTemplate")
petbg:CreatePanel("Hydra", T.petbuttonsize + (T.petbuttonspacing * 2), (T.petbuttonsize * 10) + (T.petbuttonspacing * 11), "RIGHT", TukuiBar5, "LEFT", -6, 0)

local ltpetbg1 = CreateFrame("Frame", "TukuiLineToPetActionBarBackground", petbg)
ltpetbg1:CreatePanel("Hydra", 24, 265, "LEFT", petbg, "RIGHT", 0, 0)
ltpetbg1:SetParent(petbg)
ltpetbg1:SetFrameStrata("BACKGROUND")
ltpetbg1:SetFrameLevel(0)
ltpetbg1:SetAlpha(.8)

-- INVISIBLE FRAME COVERING BOTTOM ACTIONBARS JUST TO PARENT UF CORRECTLY
local invbarbg = CreateFrame("Frame", "InvTukuiActionBarBackground", UIParent)
	invbarbg:SetPoint("TOPLEFT", TukuiBar2)
	invbarbg:SetPoint("BOTTOMRIGHT", TukuiBar3)

-- INFO LEFT (FOR STATS)
local ileft = CreateFrame("Frame", "TukuiInfoLeft", TukuiBar1)
ileft:CreatePanel("Hydra", T.InfoLeftRightWidth, 20, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", T.Scale(10), T.Scale(7))
ileft:SetFrameLevel(2)
ileft:SetFrameStrata("BACKGROUND")
T.CreateShadow(ileft)

-- INFO RIGHT (FOR STATS)
local iright = CreateFrame("Frame", "TukuiInfoRight", TukuiBar1)
iright:CreatePanel("Hydra", T.InfoLeftRightWidth, 20, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", T.Scale(-10), T.Scale(7))
iright:SetFrameLevel(2)
iright:SetFrameStrata("BACKGROUND")
T.CreateShadow(iright)

-- BOTTOM BAR
local tbottombar = CreateFrame("Frame", "TukuiBottomBar", UIParent)
T.CreatePanel(tbottombar, 1, 22, "TOP", UIParent, "TOP", 0, 0)
tbottombar:ClearAllPoints()
tbottombar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", T.Scale(-6), T.Scale(-6))
tbottombar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", T.Scale(6), T.Scale(-6))
tbottombar:SetFrameStrata("BACKGROUND")
tbottombar:SetFrameLevel(0)
T.CreateShadow(tbottombar)

--BATTLEGROUND STATS FRAME
if C["datatext"].battleground == true then
	local bgframe = CreateFrame("Frame", "TukuiInfoLeftBattleGround", UIParent)
	bgframe:CreatePanel("Hydra", 1, 1, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	bgframe:SetAllPoints(ileft)
	bgframe:SetFrameStrata("LOW")
	bgframe:SetFrameLevel(0)
	bgframe:EnableMouse(true)
end