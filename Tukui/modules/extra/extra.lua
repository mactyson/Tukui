local T, C, L = unpack(select(2, ...)) 

-------------------------------------------------------------------------------------
-- Credit Alleykat 
-- Entering combat and allertrun function (can be used in anther ways)
------------------------------------------------------------------------------------
local speed = .057799924 -- how fast the text appears
local font = C.media.pixelfont -- HOOG0555.ttf 
local fontflag = "OUTLINEMONOCHROME" -- for pixelfont stick to this else OUTLINE or THINOUTLINE
local fontsize = 16 -- font size
 
local GetNextChar = function(word,num)
	local c = word:byte(num)
	local shift
	if not c then return "",num end
		if (c > 0 and c <= 127) then
			shift = 1
		elseif (c >= 192 and c <= 223) then
			shift = 2
		elseif (c >= 224 and c <= 239) then
			shift = 3
		elseif (c >= 240 and c <= 247) then
			shift = 4
		end
	return word:sub(num,num+shift-1),(num+shift)
end
 
local updaterun = CreateFrame("Frame")
 
local flowingframe = CreateFrame("Frame",nil,UIParent)
	flowingframe:SetFrameStrata("HIGH")
	flowingframe:SetPoint("CENTER",UIParent,0,-160) -- where we want the textframe
	flowingframe:SetHeight(64)
 
local flowingtext = flowingframe:CreateFontString(nil,"OVERLAY")
	flowingtext:SetFont(font,fontsize, fontflag)
	flowingtext:SetShadowOffset(1,-1)
 
local rightchar = flowingframe:CreateFontString(nil,"OVERLAY")
	rightchar:SetFont(font,60, fontflag)
	rightchar:SetShadowOffset(1,-1)
	rightchar:SetJustifyH("LEFT") -- left or right
 
local count,len,step,word,stringE,a,backstep
 
local nextstep = function()
	a,step = GetNextChar (word,step)
	flowingtext:SetText(stringE)
	stringE = stringE..a
	a = string.upper(a)
	rightchar:SetText(a)
end
 
local backrun = CreateFrame("Frame")
backrun:Hide()
 
local updatestring = function(self,t)
	count = count - t
		if count < 0 then
			count = speed
			if step > len then
				self:Hide()
				flowingtext:SetText(stringE)
				rightchar:SetText()
				flowingtext:ClearAllPoints()
				flowingtext:SetPoint("RIGHT")
				flowingtext:SetJustifyH("RIGHT")
				rightchar:ClearAllPoints()
				rightchar:SetPoint("RIGHT",flowingtext,"LEFT")
				rightchar:SetJustifyH("RIGHT")
				self:Hide()
				count = 1.456789
				backrun:Show()
			else
				nextstep()
			end
		end
end
 
updaterun:SetScript("OnUpdate",updatestring)
updaterun:Hide()
 
local backstepf = function()
	local a = backstep
	local firstchar
		local texttemp = ""
		local flagon = true
		while a <= len do
			local u
			u,a = GetNextChar(word,a)
			if flagon == true then
				backstep = a
				flagon = false
				firstchar = u
			else
				texttemp = texttemp..u
			end
		end
	flowingtext:SetText(texttemp)
	firstchar = string.upper(firstchar)
	rightchar:SetText(firstchar)
end
 
local rollback = function(self,t)
	count = count - t
		if count < 0 then
			count = speed
			if backstep > len then
				self:Hide()
				flowingtext:SetText()
				rightchar:SetText()
			else
				backstepf()
			end
		end
end
 
backrun:SetScript("OnUpdate",rollback)
 
local allertrun = function(f,r,g,b)
	flowingframe:Hide()
	updaterun:Hide()
	backrun:Hide()
 
	flowingtext:SetText(f)
	local l = flowingtext:GetWidth()
 
	local color1 = r or 1
	local color2 = g or 1
	local color3 = b or 1
 
	flowingtext:SetTextColor(color1*.95,color2*.95,color3*.95) -- color in RGB(red green blue)(alpha)
	rightchar:SetTextColor(color1,color2,color3)
 
	word = f
	len = f:len()
	step,backstep = 1,1
	count = speed
	stringE = ""
	a = ""
 
	flowingtext:SetText("")
	flowingframe:SetWidth(l)
	flowingtext:ClearAllPoints()
	flowingtext:SetPoint("LEFT")
	flowingtext:SetJustifyH("LEFT")
	rightchar:ClearAllPoints()
	rightchar:SetPoint("LEFT",flowingtext,"RIGHT")
	rightchar:SetJustifyH("LEFT")
 
	rightchar:SetText("")
	updaterun:Show()
	flowingframe:Show()
end
 
SlashCmdList.ALLEYRUN = function(lol) allertrun(lol) end
SLASH_ALLEYRUN1 = "/arn" -- /command to test the text
 
local a = CreateFrame ("Frame")
	a:RegisterEvent("PLAYER_REGEN_ENABLED")
	a:RegisterEvent("PLAYER_REGEN_DISABLED")
	a:SetScript("OnEvent", function (self,event)
		if (UnitIsDead("player")) then return end
		if event == "PLAYER_REGEN_ENABLED" then
			allertrun("LEAVING COMBAT",0.1,1,0.1)
		else
			allertrun("ENTERING COMBAT",1,0.1,0.1)
		end
	end)
	
-----------------------------------------
-- fDispelAnnounce made by Foof
-----------------------------------------
local fDispelAnnounce = CreateFrame("Frame", fDispelAnnounce)
local band = bit.band
local font = C.media.pixelfont -- HOOG0555.ttf 
local fontflag = "OUTLINEMONOCHROME" -- for pixelfont stick to this else OUTLINE or THINOUTLINE
local fontsize = 18 -- font size
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
 
-- Registered events
local events = {
	["SPELL_STOLEN"] = {
		["enabled"] = true,
		["msg"] = "Removed",
		["color"] = "69CCF0",
	},
	["SPELL_DISPEL"] = {
		["enabled"] = true,
		["msg"] = "Removed",
		["color"] = "3BFF33",
	},
	["SPELL_DISPEL_FAILED"] = {
		["enabled"] = true,
		["msg"] = "FAILED",
		["color"] = "C41F3B",
	},
	["SPELL_HEAL"] = {
		["enabled"] = false,
		["msg"] = "Healed",
		["color"] = "3BFF33",
	},
}
 
-- Frame function
local function CreateMessageFrame(name)
	local f = CreateFrame("ScrollingMessageFrame", name, UIParent)
	f:SetHeight(80)
	f:SetWidth(500)
	f:SetPoint("CENTER", 0, 150)
	f:SetFrameStrata("HIGH")
	f:SetTimeVisible(1.5)
	f:SetFadeDuration(3)
	f:SetMaxLines(3)
	f:SetFont(font, fontsize, fontflag)
	return f
end
 
-- Create messageframe
local dispelMessages = CreateMessageFrame("fDispelFrame")
 
local function OnEvent(self, event, timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	if(not events[eventType] or not events[eventType].enabled or band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= COMBATLOG_OBJECT_AFFILIATION_MINE or sourceGUID ~= UnitGUID("player")) then
		return
	end
	-- Print to partychat
	local numraid = GetNumRaidMembers()
	if (numraid > 0 and numraid < 6) then
		SendChatMessage(events[eventType].msg .. ": " .. select(5, ...), "PARTY")
	end
	-- Add to messageframe
	dispelMessages:AddMessage("|cff" .. events[eventType].color .. events[eventType].msg .. ":|r " .. select(5, ...))
end
 
-- finally
fDispelAnnounce:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
fDispelAnnounce:SetScript('OnEvent', OnEvent)

----------------------------------------------------------------------------------------------------------------
-- saftExperienceBar by Safturento
--	DL link http://www.wowinterface.com/downloads/info17672-saftExperienceBar.html#info
--	have fun
----------------------------------------------------------------------------------------------------------------
if not C["saftExperienceBar"].enable == true then return end;

-- Config ----------------
--------------------------
--Bar Height and Width
local barHeight, barWidth = 7, 410

--Where you want the fame to be anchored
--------AnchorPoint, AnchorTo, RelativePoint, xOffset, yOffset
local Anchor = { "BOTTOM", TukuiInfoRight, "BOTTOM", 0, -10}


--Fonts
local showText = false -- Set to false to hide text
local font = C.media.pixelfont -- HOOG0555.ttf 
local fontflag = "OUTLINEMONOCHROME" -- for pixelfont stick to this else OUTLINE or THINOUTLINE
local fontsize = 8 -- font size

--Texture used for bar
local barTex = C.media.normtex

-----------------------------------------------------------
-- Don't edit past here unless you know what your doing! --
-----------------------------------------------------------
-- Tables ----------------
--------------------------
local saftXPBar = {}

local FactionInfo = {
	[1] = {{ 170/255, 70/255,  70/255 }, "Hated", "FFaa4646"},
	[2] = {{ 170/255, 70/255,  70/255 }, "Hostile", "FFaa4646"},
	[3] = {{ 170/255, 70/255,  70/255 }, "Unfriendly", "FFaa4646"},
	[4] = {{ 200/255, 180/255, 100/255 }, "Neutral", "FFc8b464"},
	[5] = {{ 75/255,  175/255, 75/255 }, "Friendly", "FF4baf4b"},
	[6] = {{ 75/255,  175/255, 75/255 }, "Honored", "FF4baf4b"},
	[7] = {{ 75/255,  175/255, 75/255 }, "Revered", "FF4baf4b"},
	[8] = {{ 155/255,  255/255, 155/255 }, "Exalted","FF9bff9b"},
}
-- Functions -------------
--------------------------
local ShortValue = function(value)
	if value >= 1e6 then
		return ("%.0fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e3 or value <= -1e3 then
		return ("%.0fk"):format(value / 1e3):gsub("%.?+([km])$", "%1")
	else
		return value
	end
end

function CommaValue(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function colorize(r)
	return FactionInfo[r][3]
end

function saftXPBar:Initialize()
	local frame = self.frame
	
	--Create Background and Border
	local backdrop = CreateFrame("Frame", "saftXP_Backdrop", frame)
	backdrop:SetHeight(barHeight)
	backdrop:SetWidth(barWidth)
	backdrop:SetPoint(unpack(Anchor))
	backdrop:SetBackdrop({
		bgFile = barTex, 
		edgeFile = barTex, 
		tile = false, tileSize = 0, edgeSize = 1, 
		insets = { left = -1, right = -1, top = -1, bottom = -1}
	})
	backdrop:SetBackdropColor( .075,.075,.075,1)
	backdrop:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
	
	backdrop:SetFrameLevel(0)
	frame.backdrop = backdrop
	
	overlay = backdrop:CreateTexture(nil, "BORDER", backdrop)
	overlay:ClearAllPoints()
	overlay:SetPoint("TOPLEFT", backdrop, "TOPLEFT", 2, -2)
	overlay:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -2, 2)
	overlay:SetTexture(barTex)
	overlay:SetVertexColor( 0, 0, 0)
	
	--Create XP Status Bar
	local xpBar = CreateFrame("StatusBar", "saftXP_Bar", frame, "TextStatusBar")
	xpBar:SetWidth(barWidth-4)
	xpBar:SetHeight(barHeight-4)
	xpBar:SetPoint("TOP", backdrop,"TOP", 0, -2)
	xpBar:SetStatusBarTexture(barTex)
	xpBar:SetFrameLevel(2)
	frame.xpBar = xpBar
	
	--Create Rested XP Status Bar
	local restedxpBar = CreateFrame("StatusBar", "saftrestedXP_Bar", frame, "TextStatusBar")
	restedxpBar:SetWidth(barWidth-4)
	restedxpBar:SetHeight(barHeight-4)
	restedxpBar:SetPoint("TOP", backdrop,"TOP", 0, -2)
	restedxpBar:SetStatusBarTexture(barTex)
	restedxpBar:SetFrameLevel(1)
	restedxpBar:Hide()
	frame.restedxpBar = restedxpBar
	
	--Create Reputation Status Bar(Only used if not max level)
	local repBar = CreateFrame("StatusBar", "saftRep_Bar", frame, "TextStatusBar")
	repBar:SetWidth(barWidth-4)
	repBar:SetHeight(1)
	repBar:SetPoint("TOP",xpBar,"BOTTOM", 0, -1)
	repBar:SetStatusBarTexture(barTex)
	repBar:SetFrameLevel(1)
	repBar:Hide()
	frame.repBar = repBar
	
	--Create frame used for mouseover and dragging
	local mouseFrame = CreateFrame("Frame", "saftXP_dragFrame", frame)
	mouseFrame:SetAllPoints(backdrop)
	mouseFrame:SetFrameLevel(3)
	mouseFrame:EnableMouse(true)
	frame.mouseFrame = mouseFrame
	
	--Create XP Text
	if showText == true then
		local xpText = mouseFrame:CreateFontString("saftXP_Text", "OVERLAY")
		xpText:SetFont(font, fontsize, fontflag)
		xpText:SetPoint("CENTER", backdrop, "CENTER", 0, 0.5)

		frame.xpText = xpText
	end
	
	--Event handling
	frame:RegisterEvent("PLAYER_LEVEL_UP")
	frame:RegisterEvent("PLAYER_XP_UPDATE")
	frame:RegisterEvent("UPDATE_EXHAUSTION")
	frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
	frame:RegisterEvent("UPDATE_FACTION")
    frame:SetScript("OnEvent", function() 
		self:ShowBar() 
    end)
end

-- Setup bar info
function saftXPBar:ShowBar()
	if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
		local XP, maxXP = UnitXP("player"), UnitXPMax("player")
		local restXP = GetXPExhaustion()
		local percXP = floor(XP/maxXP*100)
		local str
		--Setup Text
		if self.frame.xpText then
			if restXP then
				str = format("%s/%s (%s%%|cffb3e1ff+%d%%|r)", ShortValue(XP), ShortValue(maxXP), percXP, restXP/maxXP*100)
			else
				str = format("%s/%s (%s%%)", ShortValue(XP), ShortValue(maxXP), percXP)
			end
			self.frame.xpText:SetText(str)
		end
		--Setup Bar
		if GetXPExhaustion() then 
			if not self.frame.restedxpBar:IsShown() then
				self.frame.restedxpBar:Show()
			end
			self.frame.restedxpBar:SetStatusBarColor(0, .4, .8)
			self.frame.restedxpBar:SetMinMaxValues(min(0, XP), maxXP)
			self.frame.restedxpBar:SetValue(XP+restXP)
		else
			if self.frame.restedxpBar:IsShown() then
				self.frame.restedxpBar:Hide()
			end
		end
		
		self.frame.xpBar:SetStatusBarColor(.5, 0, .75)
		self.frame.xpBar:SetMinMaxValues(min(0, XP), maxXP)
		self.frame.xpBar:SetValue(XP)	

		if GetWatchedFactionInfo() then
			local name, rank, min, max, value = GetWatchedFactionInfo()
			if not self.frame.repBar:IsShown() then self.frame.repBar:Show() end
			self.frame.repBar:SetStatusBarColor(unpack(FactionInfo[rank][1]))
			self.frame.repBar:SetMinMaxValues(min, max)
			self.frame.repBar:SetValue(value)
			self.frame.xpBar:SetHeight(barHeight-6)
			self.frame.restedxpBar:SetHeight(barHeight-6)
		else
			if self.frame.repBar:IsShown() then self.frame.repBar:Hide() end
			self.frame.xpBar:SetHeight(barHeight-4)
			self.frame.restedxpBar:SetHeight(barHeight-4)
		end
		
		--Setup Exp Tooltip
		self.frame.mouseFrame:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self.frame.mouseFrame, "ANCHOR_BOTTOMLEFT", -3, barHeight)
			GameTooltip:ClearLines()
			GameTooltip:AddLine("Experience:")
			GameTooltip:AddLine(string.format('XP: %s/%s (%d%%)', CommaValue(XP), CommaValue(maxXP), (XP/maxXP)*100))
			GameTooltip:AddLine(string.format('Remaining: %s', CommaValue(maxXP-XP)))	
			if restXP then
				GameTooltip:AddLine(string.format('|cffb3e1ffRested: %s (%d%%)', CommaValue(restXP), restXP/maxXP*100))
			end
			if GetWatchedFactionInfo() then
				local name, rank, min, max, value = GetWatchedFactionInfo()
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(string.format('Reputation: %s', name))
				GameTooltip:AddLine(string.format('Standing: |c'..colorize(rank)..'%s|r', FactionInfo[rank][2]))
				GameTooltip:AddLine(string.format('Rep: %s/%s (%d%%)', CommaValue(value-min), CommaValue(max-min), (value-min)/(max-min)*100))
				GameTooltip:AddLine(string.format('Remaining: %s', CommaValue(max-value)))
			end
			GameTooltip:Show()
		end)
		self.frame.mouseFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
		
		--Send experience info in chat
		self.frame.mouseFrame:SetScript("OnMouseDown", function()
			if IsShiftKeyDown() then
				if GetNumRaidMembers() > 0 then
					SendChatMessage("I'm currently at "..CommaValue(XP).."/"..CommaValue(maxXP).." ("..floor((XP/maxXP)*100).."%) experience.","RAID")
				elseif GetNumPartyMembers() > 0 then
					SendChatMessage("I'm currently at "..CommaValue(XP).."/"..CommaValue(maxXP).." ("..floor((XP/maxXP)*100).."%) experience.","PARTY")
				end
			end
			--[[if IsControlKeyDown() then
				local activeChat = ChatFrame1EditBox:GetAttribute("chatType")
				if activeChat == "WHISPER" then 
	BROKEN			local target = GetChannelName(ChatFrame1EditBox:GetAttribute("channelTarget"))
				end
				SendChatMessage("I'm currently at "..CommaValue(XP).."/"..CommaValue(maxXP).." ("..floor((XP/maxXP)*100).."%) experience.",activeChat, nil, target or nil)
			end]]--
		end)
	else
		if GetWatchedFactionInfo() then
			local name, rank, min, max, value = GetWatchedFactionInfo()
			local str
			--Setup Text
			if self.frame.xpText then
				str = format("%d / %d (%d%%)", value-min, max-min, (value-min)/(max-min)*100)
				self.frame.xpText:SetText(str)
			end
			--Setup Bar
			self.frame.xpBar:SetStatusBarColor(unpack(FactionInfo[rank][1]))
			self.frame.xpBar:SetMinMaxValues(min, max)
			self.frame.xpBar:SetValue(value)
			--Setup Exp Tooltip
			self.frame.mouseFrame:SetScript("OnEnter", function()
				GameTooltip:SetOwner(self.frame.mouseFrame, "ANCHOR_BOTTOMLEFT", -3, barHeight)
				GameTooltip:ClearLines()
				GameTooltip:AddLine(string.format('Reputation: %s', name))
				GameTooltip:AddLine(string.format('Standing: |c'..colorize(rank)..'%s|r', FactionInfo[rank][2]))
				GameTooltip:AddLine(string.format('Rep: %s/%s (%d%%)', CommaValue(value-min), CommaValue(max-min), (value-min)/(max-min)*100))
				GameTooltip:AddLine(string.format('Remaining: %s', CommaValue(max-value)))
				GameTooltip:Show()
			end)
			self.frame.mouseFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
			
			--Send reputation info in chat
			self.frame.mouseFrame:SetScript("OnMouseDown", function()
				if IsShiftKeyDown() then
					if GetNumRaidMembers() > 0 then
						SendChatMessage("I'm currently "..FactionInfo[rank][2].." with "..name.." "..(value-min).."/"..(max-min).."("..floor((((value-min)/(max-min))*100))..").","RAID")
					elseif GetNumPartyMembers() > 0 then
						SendChatMessage("I'm currently "..FactionInfo[rank][2].." with "..name.." "..(value-min).."/"..(max-min).."("..floor((((value-min)/(max-min))*100))..").","PARTY")
					end
				end
			end)

			if not self.frame:IsShown() then self.frame:Show() end
		else
			self.frame:Hide()
		end
	end
end

-- Event Stuff -----------
--------------------------
local frame = CreateFrame("Frame",nil,UIParent)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
	saftXPBar:Initialize()
	saftXPBar:ShowBar()
end)

saftXPBar.frame = frame
----------------------------------------------------------------------
if not C.chat.background then
-- Mark Bar created by Smelly
-- Credits to Hydra, Elv22, Safturento, and many more!
-- Edited by Jasje
-- Config
----------------------------------------------------------------------
font = C.media.pixelfont           	-- Font to be used for button text
fontsize = 8  -- Size of font for button text
fontflag = C["datatext"].fontflag    -- Font flag
buttonwidth = T.Scale(30)    		-- Width of menu buttons
buttonheight = T.Scale(30)   		-- Height of menu buttons
toplayout = false						-- Position of the menu
datatext = false					-- Make it into a datatext

-- Default position of toggle button and background
local anchor = {}
if toplayout == true then
	anchor = {"TOPLEFT", UIParent, "TOP", 0, -3}
else
	anchor = {"RIGHT", TukuiInfoRight, "LEFT", -3, 0}
end

--Background Frame			
local MarkBarBG = CreateFrame("Frame", "MarkBarBackground", UIParent)
T.CreatePanel(MarkBarBG, buttonwidth * 4 + T.Scale(15), buttonheight * 3, "BOTTOMLEFT", TukuiTabsRightBackground, "TOPLEFT", 0, T.Scale(3))
MarkBarBG:SetBackdropColor(unpack(C["media"].backdropcolor))
MarkBarBG:SetFrameLevel(0)
T.CreateShadow(MarkBarBG)
MarkBarBG:SetFrameStrata("HIGH")
--MarkBarBG:ClearAllPoints()
--MarkBarBG:SetPoint(unpack(anchor)) -- custom anchors
MarkBarBG:Hide()

local MarkBarBGUpdater = CreateFrame("Frame")
    local function UpdateMarkBarBG(self)
		MarkBarBG:SetPoint("BOTTOMLEFT", TukuiTabsRightBackground, "TOPLEFT", 0, 3)
	end
        MarkBarBGUpdater:SetScript("OnUpdate", UpdateMarkBarBG)
			
--Change border when mouse is inside the button
local function ButtonEnter(self)
	local color = RAID_CLASS_COLORS[T.myclass]
	self:SetBackdropBorderColor(color.r, color.g, color.b)
end
 
--Change border back to normal when mouse leaves button
local function ButtonLeave(self)
	self:SetBackdropBorderColor(unpack(C["media"].bordercolor))
end

-- Mark Button BG and icons
icon = CreateFrame("Button", "tmb_Icon", MarkBarBG)
mark = CreateFrame("Button", "tmb_Menu", MarkBarBG)
for i = 1, 8 do
	mark[i] = CreateFrame("Button", "tbm_Mark"..i, MarkBarBG)
	T.CreatePanel(mark[i], buttonwidth, buttonheight, "LEFT", MarkBarBG, "LEFT", T.Scale(3), T.Scale(-3))
	if i == 1 then
		mark[i]:SetPoint("TOPLEFT", MarkBarBG, "TOPLEFT",  T.Scale(3), T.Scale(-3))
	elseif i == 5 then
		mark[i]:SetPoint("TOP", mark[1], "BOTTOM", 0, T.Scale(-3))
	else
		mark[i]:SetPoint("LEFT", mark[i-1], "RIGHT", T.Scale(3), 0)
	end
	mark[i]:EnableMouse(true)
	mark[i]:SetScript("OnEnter", ButtonEnter)
	mark[i]:SetScript("OnLeave", ButtonLeave)
	mark[i]:RegisterForClicks("AnyUp")
	mark[i]:SetFrameStrata("HIGH")

	icon[i] = CreateFrame("Button", "icon"..i, MarkBarBG)
	icon[i]:SetNormalTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
	icon[i]:SetSize(25, 25)
	icon[i]:SetPoint("CENTER", mark[i])
	icon[i]:SetFrameStrata("HIGH")
	
	-- Set up each button
	if i == 1 then -- Skull
		mark[i]:SetScript("OnMouseUp", function() SetRaidTarget("target", 8) end)
		icon[i]:GetNormalTexture():SetTexCoord(0.75,1,0.25,0.5)
	elseif i == 2 then -- Cross
		mark[i]:SetScript("OnMouseUp", function() SetRaidTarget("target", 7) end)
		icon[i]:GetNormalTexture():SetTexCoord(0.5,0.75,0.25,0.5)
	elseif i == 3 then -- Square
		mark[i]:SetScript("OnMouseUp", function() SetRaidTarget("target", 6) end)
		icon[i]:GetNormalTexture():SetTexCoord(0.25,0.5,0.25,0.5)
	elseif i == 4 then -- Moon
		mark[i]:SetScript("OnMouseUp", function() SetRaidTarget("target", 5) end)
		icon[i]:GetNormalTexture():SetTexCoord(0,0.25,0.25,0.5)
	elseif i == 5 then -- Triangle
		mark[i]:SetScript("OnMouseUp", function() SetRaidTarget("target", 4) end)
		icon[i]:GetNormalTexture():SetTexCoord(0.75,1,0,0.25)
	elseif i == 6 then -- Diamond
		mark[i]:SetScript("OnMouseUp", function() SetRaidTarget("target", 3) end)
		icon[i]:GetNormalTexture():SetTexCoord(0.5,0.75,0,0.25)
	elseif i == 7 then -- Circle
		mark[i]:SetScript("OnMouseUp", function() SetRaidTarget("target", 2) end)
		icon[i]:GetNormalTexture():SetTexCoord(0.25,0.5,0,0.25)
	elseif i == 8 then -- Star
		mark[i]:SetScript("OnMouseUp", function() SetRaidTarget("target", 1) end)
		icon[i]:GetNormalTexture():SetTexCoord(0,0.25,0,0.25)
	end
end
 
 -- Marker Buttons, Thanks to Elv for code
local function CreateMarkerButton(name, point, relativeto, point2, x, y)
    local f = CreateFrame("Button", name, MarkBarBG, "SecureActionButtonTemplate")
    f:SetPoint(point, relativeto, point2, x, y)
    f:SetWidth(12)
    f:SetHeight(12)
	T.SetTemplate(f)
    f:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    f:SetAttribute("type", "macro")
end

--Setup Secure Buttons
CreateMarkerButton("BlueFlare", "TOPLEFT", MarkBarBG, "TOPRIGHT", 3, 0)
BlueFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button1
]])
BlueFlare:SetBackdropColor(0, 0, 1)
CreateMarkerButton("GreenFlare", "TOP", BlueFlare, "BOTTOM", 0, -4)
GreenFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button2
]])
GreenFlare:SetBackdropColor(0, 1, 0)
CreateMarkerButton("PurpleFlare", "TOP", GreenFlare, "BOTTOM", 0, -4)
PurpleFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button3
]])
PurpleFlare:SetBackdropColor(1, 0, 1)
CreateMarkerButton("RedFlare", "TOP", PurpleFlare, "BOTTOM", 0, -4)
RedFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button4
]])
RedFlare:SetBackdropColor(1, 0, 0)
CreateMarkerButton("YellowFlare", "TOP", RedFlare, "BOTTOM", 0, -4)
YellowFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button5
]])
YellowFlare:SetBackdropColor(1, 1, 0)
CreateMarkerButton("ClearFlare", "TOP", YellowFlare, "BOTTOM", 0, -4)
ClearFlare:SetAttribute("macrotext", [[
/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
/click DropDownList1Button6
]])
ClearFlare:SetBackdropColor(.075, .075, .075)
 
-- Create Button for clear target
local ClearTargetButton = CreateFrame("Button", "ClearTargetButton", MarkBarBackground)
T.CreatePanel(ClearTargetButton, (TukuiDB.Scale(buttonwidth) * 4) + 9, 18, "TOPLEFT", mark[5], "BOTTOMLEFT", 0, T.Scale(-3))
ClearTargetButton:SetScript("OnEnter", ButtonEnter)
ClearTargetButton:SetScript("OnLeave", ButtonLeave)
ClearTargetButton:SetScript("OnMouseUp", function() SetRaidTarget("target", 0) end)
ClearTargetButton:SetFrameStrata("HIGH")
T.CreateShadow(ClearTargetButton)

local ClearTargetButtonText = ClearTargetButton:CreateFontString("ClearTargetButtonText","OVERLAY", ClearTargetButton)
ClearTargetButtonText:SetFont(font,fontsize,fontflag)
ClearTargetButtonText:SetText(hexa.."Clear Target"..hexb)
ClearTargetButtonText:SetPoint("CENTER")
ClearTargetButtonText:SetJustifyH("CENTER", 1, 0)

if datatext == false then
--Create toggle button
	local ToggleButton = CreateFrame("Frame", "ToggleButton", UIParent)
	T.CreatePanel(ToggleButton, 20, 20, "CENTER", UIParent, "CENTER", 0, 0)
	ToggleButton:ClearAllPoints()    
	ToggleButton:SetFrameLevel(2)
	T.CreateShadow(ToggleButton)
    ToggleButton:SetFrameStrata("BACKGROUND")
	ToggleButton:SetPoint(unpack(anchor))
	ToggleButton:EnableMouse(true)
	ToggleButton:SetScript("OnEnter", ButtonEnter)
	ToggleButton:SetScript("OnLeave", ButtonLeave)

	local ToggleButtonText = ToggleButton:CreateFontString(nil ,"OVERLAY")
	ToggleButtonText:SetFont(font, fontsize, fontflag)
	ToggleButtonText:SetText(hexa.."M"..hexb)
	ToggleButtonText:SetPoint("CENTER", ToggleButton, "CENTER", 2, 1)
--[[ who needs a close button when you can close via togglebutton
	--Create close button
	local CloseButton = CreateFrame("Frame", "CloseButton", MarkBarBackground)
	T.CreatePanel(CloseButton, 21, 21, "BOTTOMLEFT", MarkBarBackground, "BOTTOMRIGHT", T.Scale(2), 0)
	CloseButton:EnableMouse(true)
    T.CreateShadow(CloseButton)
	CloseButton:SetScript("OnEnter", ButtonEnter)
	CloseButton:SetScript("OnLeave", ButtonLeave)
	
	local CloseButtonText = CloseButton:CreateFontString(nil, "OVERLAY")
	CloseButtonText:SetFont(font, fontsize, fontflag)
	CloseButtonText:SetText("x")
	CloseButtonText:SetPoint("CENTER", CloseButton, "CENTER")
]]--
	ToggleButton:SetScript("OnMouseDown", function()
		if MarkBarBackground:IsShown() then
			MarkBarBackground:Hide()
		else
			MarkBarBackground:Show()
		end
	end)
end	
--[[ who needs a close button when you can close via togglebutton
	CloseButton:SetScript("OnMouseDown", function()
		if MarkBarBackground:IsShown() then
			MarkBarBackground:Hide()
		else
			ToggleButton:Show()
		end
	end)
]]--

--Setup datatext position and function
if datatext == true then
	if C["datatext"].raidmarks and C["datatext"].raidmarks > 0 then
		--Create toggle button
		local ToggleButton = CreateFrame("Frame", "dToggleButton", UIParent)
		ToggleButton:EnableMouse(true)
		ToggleButton:SetWidth(80)
		T.PP(C["datatext"].raidmarks, dToggleButton)

		local ToggleButtonText = TukuiInfoLeft:CreateFontString(nil ,"OVERLAY")
		ToggleButtonText:SetFont(font, fontsize, fontflag)
		ToggleButtonText:SetText(hexa.."Mark Bar"..hexb)
		ToggleButtonText:SetPoint("CENTER", ToggleButton, "CENTER")

		dToggleButton:SetScript("OnMouseDown", function()
			if MarkBarBackground:IsShown() then
				MarkBarBackground:Hide()
			else
				MarkBarBackground:Show()
			end
		end)
	end
end

--Check if we are Raid Leader or Raid Officer
local function CheckRaidStatus()
	local inInstance, instanceType = IsInInstance()
	local partyMembers = GetNumPartyMembers()
 
	if not UnitInRaid("player") and partyMembers >= 1 then return true
	elseif UnitIsRaidOfficer("player") then return true
	elseif not inInstance or instanceType == "pvp" or instanceType == "arena" then return false
	end
end

--Automatically show/hide the frame if we have RaidLeader or RaidOfficer
local LeadershipCheck = CreateFrame("Frame")
LeadershipCheck:RegisterEvent("RAID_ROSTER_UPDATE")
LeadershipCheck:RegisterEvent("PARTY_MEMBERS_CHANGED")
LeadershipCheck:RegisterEvent("PLAYER_ENTERING_WORLD")
LeadershipCheck:SetScript("OnEvent", function(self, event)
	if CheckRaidStatus() then
		if datatext == true then
			dToggleButton:Show()
			MarkBarBackground:Hide()
		else
			ToggleButton:Show()
			MarkBarBackground:Hide()
		end
	else
		if datatext == true then
			--Hide Everything..
			dToggleButton:Hide()
			MarkBarBackground:Hide()
		else
			ToggleButton:Hide()
			MarkBarBackground:Hide()
		end
	end
   end)
end
----------------------------------------------------------------------------------------------
-- http://www.wowinterface.com/downloads/info19030-Interrupted.html#info
----------------------------------------------------------------------------------------------

if not C["Interrupted"].enable == true then return end;

--local channel = 'SAY'
--local channel = 'PARTY'
--local channel = 'RAID'
local channel = "YELL"

local Interrupted = CreateFrame('Frame')

local function OnEvent(self, event, ...)

	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 = ...

	if arg2 ~= 'SPELL_INTERRUPT' then return end
	if arg4 ~= UnitName('player') then return end
	
	SendChatMessage('Interrupted ' .. GetSpellLink(arg12), channel)

end

Interrupted:SetScript('OnEvent', OnEvent)
Interrupted:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

-------------------------------------------------------------------------------
-- GemCounter v0.1
-- Displays how many red/blue/yellow gems you have
-- Written by Killakhan
-- http://www.wowinterface.com/downloads/author-259436.html
-------------------------------------------------------------------------------

local GemCounter = {}
local addon = GemCounter
local addonName = "GC"
local redGems, blueGems, yellowGems = 0, 0, 0
local blueTexture = "Interface\\Icons\\inv_misc_cutgemsuperior2"
local redTexture =  "Interface\\Icons\\inv_misc_cutgemsuperior6"
local yellowTexture =  "Interface\\Icons\\inv_misc_cutgemsuperior"

addon.f = CreateFrame("Frame", addonName.."main", CharacterFrame)
addon.f:SetScript("OnShow", function(self)
      -- print("on show")
      addon.GetGems()
end)

addon.f:SetScript("OnEvent", function(self, event, ...) 
      if addon[event] then 
         return addon[event](addon, event, ...) 
      end 
end)

addon.f:RegisterEvent("UNIT_INVENTORY_CHANGED")
addon.f:RegisterEvent("PLAYER_LOGIN")

function addon:PLAYER_LOGIN(event, ...)
	addon.GetGems()
end
function addon:UNIT_INVENTORY_CHANGED(event, unit)
	if not unit == "player" then return end
	self:PLAYER_LOGIN()
end

for i = 1, 3 do
   addon["button"..i] = PaperDollItemsFrame:CreateTexture(addonName.."button"..i, "OVERLAY")
   local frame = addon["button"..i]
   frame:SetHeight(15)
   frame:SetWidth(15)
   frame.text = PaperDollItemsFrame:CreateFontString(addonName.."text"..i, "OVERLAY", "NumberFontNormal")
   frame.text:SetPoint("LEFT", frame, "RIGHT", 5, 0)
   frame.text:SetText("")
   if i == 1 then
      frame:SetPoint("BOTTOMLEFT", CharacterFrame, "BOTTOMLEFT", 55, 40)
   else
      frame:SetPoint("BOTTOM", addon["button"..(i-1)], "TOP")
   end
end
addon.button1:SetTexture(blueTexture)
addon.button1.text:SetTextColor(0, 0.6, 1)
addon.button2:SetTexture(redTexture)
addon.button2.text:SetTextColor(1, 0.4, 0.4)
addon.button3:SetTexture(yellowTexture)
addon.button3.text:SetTextColor(1, 1, 0)

function addon.GetGems()
   redGems, blueGems, yellowGems = 0, 0, 0
   for i = 1, 18 do
      local gem1, gem2, gem3
      gem1, gem2, gem3 = GetInventoryItemGems(i)
      if gem1 then
         addon.GetGemColors(gem1)
      end
      if gem2 then
         addon.GetGemColors(gem2)
      end
      if gem3 then
         addon.GetGemColors(gem3)
      end
   end
   addon.button1.text:SetText(blueGems) 
   addon.button2.text:SetText(redGems)
   addon.button3.text:SetText(yellowGems)
end

function addon.GetGemColors(gem)
   --print("checking .. " .. gem)
   local testGem = (select(7, GetItemInfo(gem)))
   if testGem == "Red" then
      redGems = redGems + 1
   elseif testGem == "Blue" then
      blueGems = blueGems + 1
   elseif testGem == "Yellow" then
      yellowGems = yellowGems + 1
   elseif testGem == "Green" then
      blueGems = blueGems + 1
      yellowGems = yellowGems + 1
   elseif testGem == "Purple" then
      redGems = redGems + 1
      blueGems = blueGems + 1
   elseif testGem == "Orange" then
      redGems = redGems + 1
      yellowGems = yellowGems + 1
   else
      return
   end
end