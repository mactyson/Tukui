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
	flowingframe:SetPoint("CENTER",UIParent,0, 170) -- where we want the textframe
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

--Bar Height and Width
local barHeight, barWidth = 5, 370

--Where you want the fame to be anchored
--------AnchorPoint, AnchorTo, RelativePoint, xOffset, yOffset
local Anchor = { "BOTTOM", TukuiInfoRight, "BOTTOM", 0, -6}
--local Anchor = { "TOP", Minimap, "BOTTOM", 0, -7 }

--Fonts
local showText = false -- Set to false to hide text
local mouseoverText = true -- Set to true to only show text on mouseover
local font = C.media.pixelfont -- HOOG0555.ttf 
local flags = "OUTLINEMONOCHROME" -- for pixelfont stick to this else OUTLINE or THINOUTLINE
local fontsize = 8 -- font size

--Texture used for bar
local barTex = C.media.flat
local flatTex = C.media.flat

-- Tables ----------------
--------------------------
st = {}

st.FactionInfo = {
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
function st.ShortValue(value)
	if value >= 1e6 then
		return ("%.2fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e3 or value <= -1e3 then
		return ("%.1fk"):format(value / 1e3):gsub("%.?+([km])$", "%1")
	else
		return value
	end
end

function st.CommaValue(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function st.Colorize(r)
	return st.FactionInfo[r][3]
end

function st.IsMaxLevel()
	if UnitLevel("player") == MAX_PLAYER_LEVEL then
		return true
	end
end

function st.GuildIsMaxLevel()
	if GetGuildLevel() == MAX_GUILD_LEVEL then
		return true
	end
end

-----------------------------------------------------------
-- Don't edit past here unless you know what your doing! --
-----------------------------------------------------------

--Prefix for naming frames
local aName = "stExperienceBar_"

--Create Background and Border
local Frame = CreateFrame("frame", aName.."Frame", UIParent)
Frame:SetHeight(barHeight)
Frame:SetWidth(barWidth)
Frame:SetPoint(unpack(Anchor))

local xpBorder = CreateFrame("frame", aName.."xpBorder", Frame)
xpBorder:SetHeight(barHeight)
xpBorder:SetWidth(barWidth)
xpBorder:SetPoint("TOP", Frame, "TOP", 0, 0)
xpBorder:SetBackdrop({
	bgFile = barTex, 
	edgeFile = barTex, 
	tile = false, tileSize = 0, edgeSize = 1, 
	insets = { left = -1, right = -1, top = -1, bottom = -1}
})
xpBorder:SetBackdropColor(0, 0, 0)
xpBorder:SetBackdropBorderColor(.2, .2, .2, 1)

local xpOverlay = xpBorder:CreateTexture(nil, "BORDER", xpBorder)
xpOverlay:ClearAllPoints()
xpOverlay:SetPoint("TOPLEFT", xpBorder, "TOPLEFT", 2, -2)
xpOverlay:SetPoint("BOTTOMRIGHT", xpBorder, "BOTTOMRIGHT", -2, 2)
xpOverlay:SetTexture(barTex)
xpOverlay:SetVertexColor(.1,.1,.1)

--Create xp status bar
local xpBar = CreateFrame("StatusBar",  aName.."xpBar", xpBorder, "TextStatusBar")
--xpBar:SetWidth(barWidth-4)
--xpBar:SetHeight(GetWatchedFactionInfo() and (barHeight-7) or barHeight-4)
xpBar:SetPoint("TOPRIGHT", xpBorder, "TOPRIGHT", -2, -2)
xpBar:SetPoint("BOTTOMLEFT", xpBorder, "BOTTOMLEFT", 2, 2)
xpBar:SetStatusBarTexture(barTex)
xpBar:SetStatusBarColor(.5, 0, .75)

--Create Rested XP Status Bar
local restedxpBar = CreateFrame("StatusBar", aName.."restedxpBar", xpBorder, "TextStatusBar")
--restedxpBar:SetWidth(barWidth-4)
--restedxpBar:SetHeight(GetWatchedFactionInfo() and (barHeight-7) or barHeight-4)
restedxpBar:SetPoint("TOPRIGHT", xpBorder, "TOPRIGHT", -2, -2)
restedxpBar:SetPoint("BOTTOMLEFT", xpBorder, "BOTTOMLEFT", 2, 2)
restedxpBar:SetStatusBarTexture(barTex)
restedxpBar:Hide()

--Create reputation status bar
local repBorder = CreateFrame("frame", aName.."repBorder", Frame)
repBorder:SetHeight(5)
repBorder:SetWidth(Frame:GetWidth())
repBorder:SetPoint("BOTTOM", Frame, "BOTTOM", 0, 0)
repBorder:SetBackdrop({
	bgFile = barTex, 
	edgeFile = barTex, 
	tile = false, tileSize = 0, edgeSize = 1, 
	insets = { left = -1, right = -1, top = -1, bottom = -1}
})
repBorder:SetBackdropColor(0, 0, 0)
repBorder:SetBackdropBorderColor(.2, .2, .2, 1)

local repOverlay = repBorder:CreateTexture(nil, "BORDER", Frame)
repOverlay:ClearAllPoints()
repOverlay:SetPoint("TOPLEFT", repBorder, "TOPLEFT", 2, -2)
repOverlay:SetPoint("BOTTOMRIGHT", repBorder, "BOTTOMRIGHT", -2, 2)
repOverlay:SetTexture(barTex)
repOverlay:SetVertexColor(.1,.1,.1)

local repBar = CreateFrame("StatusBar", aName.."repBar", repBorder, "TextStatusBar")
--repBar:SetWidth(barWidth-4)
--repBar:SetHeight(st.IsMaxLevel() and barHeight-4 or 2)
repBar:SetPoint("TOPRIGHT", repBorder, "TOPRIGHT", -2, -2)
repBar:SetPoint("BOTTOMLEFT", repBorder, "BOTTOMLEFT", 2, 2)
repBar:SetStatusBarTexture(barTex)

--Create frame used for mouseover, clicks, and text
local mouseFrame = CreateFrame("Frame", aName.."mouseFrame", Frame)
mouseFrame:SetAllPoints(Frame)
mouseFrame:EnableMouse(true)
	
--Create XP Text
local Text = mouseFrame:CreateFontString(aName.."Text", "OVERLAY")
Text:SetFont(font, fontsize, flags)
Text:SetPoint("CENTER", xpBorder, "CENTER", 0, 1)
if mouseoverText == true then
	Text:SetAlpha(0)
end

--Set all frame levels (easier to see if organized this way)
Frame:SetFrameLevel(0)
xpBorder:SetFrameLevel(0)
repBorder:SetFrameLevel(0)
restedxpBar:SetFrameLevel(1)
repBar:SetFrameLevel(2)
xpBar:SetFrameLevel(2)
mouseFrame:SetFrameLevel(3)

local function updateStatus()
	local XP, maxXP = UnitXP("player"), UnitXPMax("player")
	local restXP = GetXPExhaustion()
	local percXP = floor(XP/maxXP*100)
	
	if st.IsMaxLevel() then
		xpBorder:Hide()
		repBorder:SetHeight(barHeight)
		if not GetWatchedFactionInfo() then
			Frame:Hide()
		else
			Frame:Show()
		end
		
		local name, rank, minRep, maxRep, value = GetWatchedFactionInfo()
		Text:SetText(format("%d / %d (%d%%)", value-minRep, maxRep-minRep, (value-minRep)/(maxRep-minRep)*100))
	else		
		xpBar:SetMinMaxValues(min(0, XP), maxXP)
		xpBar:SetValue(XP)
			
		if restXP then
			Text:SetText(format("%s/%s (%s%%|cffb3e1ff+%d%%|r)", st.ShortValue(XP), st.ShortValue(maxXP), percXP, restXP/maxXP*100))
			restedxpBar:Show()
			restedxpBar:SetStatusBarColor(0, .4, .8)
			restedxpBar:SetMinMaxValues(min(0, XP), maxXP)
			restedxpBar:SetValue(XP+restXP)
		else
			restedxpBar:Hide()
			Text:SetText(format("%s/%s (%s%%)", st.ShortValue(XP), st.ShortValue(maxXP), percXP))
		end
		
		if GetWatchedFactionInfo() then
			xpBorder:SetHeight(barHeight-(repBorder:GetHeight()-1))
			repBorder:Show()
		else
			xpBorder:SetHeight(barHeight)
			repBorder:Hide()
		end
	end
	
	if GetWatchedFactionInfo() then
		local name, rank, minRep, maxRep, value = GetWatchedFactionInfo()
		repBar:SetMinMaxValues(minRep, maxRep)
		repBar:SetValue(value)
		repBar:SetStatusBarColor(unpack(st.FactionInfo[rank][1]))
	end
	
	--Setup Exp Tooltip
	mouseFrame:SetScript("OnEnter", function()
		if mouseoverText == true then
			Text:SetAlpha(1)
		end
		--[[GameTooltip:SetBackdrop({
			bgFile = flatTex, 
			edgeFile = flatTex, 
			tile = false, tileSize = 0, edgeSize = 1, 
			insets = { left = -1, right = -1, top = -1, bottom = -1}
		})
		GameTooltip:SetBackdropColor(0, 0, 0)
		GameTooltip:SetBackdropBorderColor(.2, .2, .2, 1)
		if not gtOverlay then
			local gtOverlay = GameTooltip:CreateTexture(nil, "BORDER", GameTooltip)
			gtOverlay:ClearAllPoints()
			gtOverlay:SetPoint("TOPLEFT", GameTooltip, "TOPLEFT", 2, -2)
			gtOverlay:SetPoint("BOTTOMRIGHT", GameTooltip, "BOTTOMRIGHT", -2, 2)
			gtOverlay:SetTexture(barTex)
			gtOverlay:SetVertexColor(.1,.1,.1)
		end]]
		GameTooltip:SetOwner(mouseFrame, "ANCHOR_BOTTOMLEFT", -3, barHeight)
		GameTooltip:ClearLines()
		if not st.IsMaxLevel() then
			GameTooltip:AddLine(hexa.."Experience:"..hexb)
			GameTooltip:AddLine(string.format(hexa..'XP:'..hexb..' %s/%s (%d%%)', st.ShortValue(XP), st.ShortValue(maxXP), (XP/maxXP)*100))
			GameTooltip:AddLine(string.format(hexa..'Remaining:'..hexb..' %s', st.ShortValue(maxXP-XP)))
			if restXP then
				GameTooltip:AddLine(string.format(hexa..'Rested:'..hexb..' %s (%d%%)', st.ShortValue(restXP), restXP/maxXP*100))
			end
		end
		if GetWatchedFactionInfo() then
			local name, rank, min, max, value = GetWatchedFactionInfo()
			if not st.IsMaxLevel() then GameTooltip:AddLine(" ") end
			GameTooltip:AddLine(string.format(hexa..'Reputation:'..hexb..' %s', name))
			GameTooltip:AddLine(string.format(hexa..'Standing:'..hexb..' |c'..st.Colorize(rank)..'%s|r', st.FactionInfo[rank][2]))
			GameTooltip:AddLine(string.format(hexa..'Rep:'..hexb..' %s/%s (%d%%)', st.CommaValue(value-min), st.CommaValue(max-min), (value-min)/(max-min)*100))
			GameTooltip:AddLine(string.format(hexa..'Remaining:'..hexb..' %s', st.CommaValue(max-value)))
		end
		GameTooltip:Show()
	end)
	mouseFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
		if mouseoverText == true then
			Text:SetAlpha(0)
		end
	end)
	
	-- Right click menu
	local function sendReport(dest, rep)--Destination, if Reputation rep = true
		if rep == true then 
			local name, rank, min, max, value = GetWatchedFactionInfo()
			SendChatMessage("I'm currently "..st.FactionInfo[rank][2].." with "..name.." "..(value-min).."/"..(max-min).." ("..floor((((value-min)/(max-min))*100)).."%).",dest)
		else
			local XP, maxXP = UnitXP("player"), UnitXPMax("player")
			SendChatMessage("I'm currently at "..st.CommaValue(XP).."/"..st.CommaValue(maxXP).." ("..floor((XP/maxXP)*100).."%) experience.",dest)
		end
	end
			
	local reportFrame = CreateFrame("Frame", "stExperienceReportMenu", UIParent)
	if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
		local reportList = {
			{text = hexa.."Sent Experience to:"..hexb,
				isTitle = true, notCheckable = true, notClickable = true,
				func = function()  end},
			{text = hexa.."Party"..hexb,
				func = function() 
					if GetNumPartyMembers() > 0 then
						sendReport("PARTY")
					else
						print(hexa.."[stExp] Must be in a group to report to party."..hexb)
					end
				end},
			{text = hexa.."Guild"..hexb,
				func = function()
					if IsInGuild() then
						sendReport("GUILD")
					else
						print(hexa.."[stExp] Must be in a guild to report to guild."..hexb)
					end
				end},
			{text = hexa.."Raid"..hexb,
				func = function() 
					if GetNumRaidMembers() > 0 then
						sendReport("RAID")
					elseif GetNumPartyMembers() > 0 then
						sendReport("PARTY")
					else
						print(hexa.."[stExp] Must be in a group to report to party/raid."..hexb)
					end
				end},
			{text = hexa.."Target"..hexb,
				func = function()
					if UnitName("target") then 
						local XP, maxXP = UnitXP("player"), UnitXPMax("player")
						SendChatMessage("I'm currently at "..st.CommaValue(XP).."/"..st.CommaValue(maxXP).." ("..floor((XP/maxXP)*100).."%) experience.","WHISPER",nil,UnitName("target"))
					end
				end},
			{text = "Sent Reputation to:",
				isTitle = true, notCheckable = true, notClickable = true,
				func = function()  end},
			{text = hexa.."Party"..hexb,
				func = function() 
					if GetNumPartyMembers() > 0 then
						sendReport("PARTY", true)
					else
						print(hexa.."[stExp] Must be in a group to report to party."..hexb)
					end
				end},
			{text = hexa.."Guild"..hexb,
				func = function()
					if IsInGuild() then
						sendReport("GUILD", true)
					else
						print(hexa.."[stExp] Must be in a guild to report to guild."..hexb)
					end
				end},
			{text = hexa.."Raid"..hexb,
				func = function() 
					if GetNumRaidMembers() > 0 then
						sendReport("RAID", true)
					elseif GetNumPartyMembers() > 0 then
						sendReport("PARTY", true)
					else
						print(hexa.."[stExp] Must be in a group to report to party/raid."..hexb)
					end
				end},
			{text = hexa.."Target"..hexb,
				func = function() 
					if UnitName("target") then 
						local name, rank, min, max, value = GetWatchedFactionInfo()
						SendChatMessage("I'm currently "..st.FactionInfo[rank][2].." with "..name.." "..(value-min).."/"..(max-min).." ("..floor((((value-min)/(max-min))*100)).."%).","WHISPER",nil,UnitName("target"))
					end
				end},
			}
			mouseFrame:SetScript("OnMouseUp", function(self, btn)
			if btn == "RightButton" then
				EasyMenu(reportList, reportFrame, self, 0, 0, "menu", 2)
			end
		end)
	else
		local reportList = {
			{text = "Sent Reputation to:",
				isTitle = true, notCheckable = true, notClickable = true,
				func = function()  end},
			{text = hexa.."Party"..hexb,
				func = function() 
					if GetNumPartyMembers() > 0 then
						sendReport("PARTY", true)
					else
						print(hexa.."[stExp] Must be in a group to report to party."..hexb)
					end
				end},
			{text = hexa.."Guild"..hexb,
				func = function()
					if IsInGuild() then
						sendReport("GUILD", true)
					else
						print(hexa.."[stExp] Must be in a guild to report to guild."..hexb)
					end
				end},
			{text = hexa.."Raid"..hexb,
				func = function() 
					if GetNumRaidMembers() > 0 then
						sendReport("RAID", true)
					elseif GetNumPartyMembers() > 0 then
						sendReport("PARTY", true)
					else
						print(hexa.."[stExp] Must be in a group to report to party/raid."..hexb)
					end
				end},
			{text = hexa.."Target"..hexb,
				func = function() 
					if UnitName("target") then 
						local name, rank, min, max, value = GetWatchedFactionInfo()
						SendChatMessage("I'm currently "..st.FactionInfo[rank][2].." with "..name.." "..(value-min).."/"..(max-min).." ("..floor((((value-min)/(max-min))*100)).."%).","WHISPER",nil,UnitName("target"))
					end
				end},
			}
			mouseFrame:SetScript("OnMouseUp", function(self, btn)
			if btn == "RightButton" then
				EasyMenu(reportList, reportFrame, self, 0, 0, "menu", 2)
			end
		end)
	end
end

-- Event Stuff -----------
--------------------------
local frame = CreateFrame("Frame",nil,UIParent)
--Event handling
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("UPDATE_EXHAUSTION")
frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
frame:RegisterEvent("UPDATE_FACTION")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", updateStatus)

----------------------------------------------------------------------
-- Mark Bar created by Smelly
-- Credits to Hydra, Elv22, Safturento, and many more!
-- Edited by Jasje
-- Config
----------------------------------------------------------------------
font = C.media.pixelfont           	-- Font to be used for button text
fontsize = 8  -- Size of font for button text
fontflag = C.datatext.fontflag    -- Font flag
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
T.CreatePanel(MarkBarBG, buttonwidth * 4 + T.Scale(15), buttonheight * 3, "BOTTOMLEFT", TukuiInfoRight, "TOPLEFT", 0, T.Scale(3))
MarkBarBG:SetBackdropColor(unpack(C["media"].backdropcolor))
MarkBarBG:SetFrameLevel(0)
T.CreateShadow(MarkBarBG)
MarkBarBG:SetFrameStrata("HIGH")
MarkBarBG:Hide()

local MarkBarBGUpdater = CreateFrame("Frame")
    local function UpdateMarkBarBG(self)
		MarkBarBG:SetPoint("BOTTOMLEFT", ChatFrame4, "TOPLEFT", 0, 5)
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
T.CreatePanel(ClearTargetButton, (TukuiDB.Scale(buttonwidth) * 4) + 9, 18, "TOPLEFT", mark[5], "BOTTOMLEFT", 0, T.Scale(-2))
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

	ToggleButton:SetScript("OnMouseDown", function()
		if MarkBarBackground:IsShown() then
			MarkBarBackground:Hide()
		else
			MarkBarBackground:Show()
		end
	end)
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
----------------------------------------------------------------------------------------------------------------------------------------------------
-- xanAutoMail
-- http://www.wowinterface.com/downloads/info18868-xanAutoMail.html
---------------------------------------------------------------------------------------------------------------------------------------------------
--This mod expands the functionality of the auto-name generation of blizzards in game mail system.
--Typically it will only auto-fill for names of players in your guild.
--This mod will expand it to include all your toons you've logged in as, B.Net Friends, and last 10 recently mailed individuals

local DB_PLAYER
local DB_RECENT
local currentPlayer
local currentRealm
local inboxAllButton
local old_InboxFrame_OnClick
local triggerStop = false
local numInboxItems = 0
local timeChk, timeDelay = 0, 1
local stopLoop = 10
local loopChk = 0
local skipCount = 0
local moneyCount = 0

local origHook = {}

local xanAutoMail = CreateFrame("frame","xanAutoMailFrame",UIParent)
xanAutoMail:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

--[[------------------------
	CORE
--------------------------]]

function xanAutoMail:PLAYER_LOGIN()
	
	currentPlayer = UnitName('player')
	currentRealm = GetRealmName()
	
	--do the db initialization
	self:StartupDB()
	
	--increase the mailbox history lines to 15
	SendMailNameEditBox:SetHistoryLines(15)
	
	--do the hooks
	origHook["SendMailFrame_Reset"] = SendMailFrame_Reset
	SendMailFrame_Reset = self.SendMailFrame_Reset
	
	origHook["MailFrameTab_OnClick"] = MailFrameTab_OnClick
	MailFrameTab_OnClick = self.MailFrameTab_OnClick
	
	origHook["AutoComplete_Update"] = AutoComplete_Update
	AutoComplete_Update = self.AutoComplete_Update
	
	origHook[SendMailNameEditBox] = origHook[SendMailNameEditBox] or {}
	origHook[SendMailNameEditBox]["OnEditFocusGained"] = SendMailNameEditBox:GetScript("OnEditFocusGained")
	origHook[SendMailNameEditBox]["OnChar"] = SendMailNameEditBox:GetScript("OnChar")
	SendMailNameEditBox:SetScript("OnEditFocusGained", self.OnEditFocusGained)
	SendMailNameEditBox:SetScript("OnChar", self.OnChar)
	
	--make the open all button
	inboxAllButton = CreateFrame("Button", "xanAutoMail_OpenAllBTN", InboxFrame, "UIPanelButtonTemplate")
	inboxAllButton:SetWidth(100)
	inboxAllButton:SetHeight(20)
	inboxAllButton:SetPoint("CENTER", InboxFrame, "TOP", 0, -55)
	inboxAllButton:SetText("Open All")
	inboxAllButton:SetScript("OnClick", function() xanAutoMail.GetMail() end)

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

function xanAutoMail:StartupDB()
	xanAutoMailDB = xanAutoMailDB or {}
	xanAutoMailDB[currentRealm] = xanAutoMailDB[currentRealm] or {}

	--player list
	xanAutoMailDB[currentRealm]["player"] = xanAutoMailDB[currentRealm]["player"] or {}
	DB_PLAYER = xanAutoMailDB[currentRealm]["player"]
	
	--recent list
	xanAutoMailDB[currentRealm]["recent"] = xanAutoMailDB[currentRealm]["recent"] or {}
	DB_RECENT = xanAutoMailDB[currentRealm]["recent"]
	
	--check for current user
	if DB_PLAYER[currentPlayer] == nil then DB_PLAYER[currentPlayer] = true end
end

--This is called when mailed is sent
function xanAutoMail:SendMailFrame_Reset()

	--first lets get the playername
	local playerName = strtrim(SendMailNameEditBox:GetText())
	
	--if we don't have something to work with then call original function
	if string.len(playerName) < 1 then
		return origHook["SendMailFrame_Reset"]()
	end
	
	--add the name to the history
	SendMailNameEditBox:AddHistoryLine(playerName)

	--add the name to our recent DB, first check to see if it's already there
	--if so then remove it, otherwise add it to the top of the list and remove the 11 entry from the table.
	--afterwards call the original function
	for k = 1, #DB_RECENT do
		if playerName == DB_RECENT[k] then
			tremove(DB_RECENT, k)
			break
		end
	end
	tinsert(DB_RECENT, 1, playerName)
	for k = #DB_RECENT, 11, -1 do
		tremove(DB_RECENT, k)
	end
	origHook["SendMailFrame_Reset"]()
	
	-- set the name to the auto fill
	SendMailNameEditBox:SetText(playerName)
	SendMailNameEditBox:HighlightText()
end

--this is called when one of the mailtabs is clicked
--we have to autofill the name when the tabs are clicked
function xanAutoMail:MailFrameTab_OnClick(tab)
	origHook["MailFrameTab_OnClick"](self, tab)
	if tab == 2 then
		local playerName = DB_RECENT[1]
		if playerName and SendMailNameEditBox:GetText() == "" then
			SendMailNameEditBox:SetText(playerName)
			SendMailNameEditBox:HighlightText()
		end
	end
end

--this function is called each time a character is pressed in the playername field of the mail window
function xanAutoMail:OnChar(...)
	if self:GetUTF8CursorPosition() ~= strlenutf8(self:GetText()) then return end
	local text = strupper(self:GetText())
	local textlen = strlen(text)
	local foundName

	--check player toons
	for k, v in pairs(DB_PLAYER) do
		if strfind(strupper(k), text, 1, 1) == 1 then
			foundName = k
			break
		end
	end

	--check our recent list
	if not foundName then
		for k = 1, #DB_RECENT do
			local playerName = DB_RECENT[k]
			if strfind(strupper(playerName), text, 1, 1) == 1 then
				foundName = playerName
				break
			end
		end
	end

	--Check our RealID friends
	if not foundName then
		local numBNetTotal, numBNetOnline = BNGetNumFriends()
		for i = 1, numBNetOnline do
			local presenceID, givenName, surname, toonName, toonID, client = BNGetFriendInfo(i)
			if (toonName and client == BNET_CLIENT_WOW and CanCooperateWithToon(toonID)) then
				if strfind(strupper(toonName), text, 1, 1) == 1 then
					foundName = toonName
					break
				end
			end
		end
	end

	--call the original onChar to display the dropdown
	origHook[SendMailNameEditBox]["OnChar"](self, ...)
	
	--if we found a name then override the one in the editbox
	if foundName then
		self:SetText(foundName)
		self:HighlightText(textlen, -1)
		self:SetCursorPosition(textlen)
	end

end

function xanAutoMail:OnEditFocusGained(...)
	SendMailNameEditBox:HighlightText()
end

function xanAutoMail:AutoComplete_Update(editBoxText, utf8Position, ...)
	if self ~= SendMailNameEditBox then
		origHook["AutoComplete_Update"](self, editBoxText, utf8Position, ...)
	end
end

--[[------------------------
	OPEN ALL MAIL
--------------------------]]

xanAutoMail:RegisterEvent("MAIL_INBOX_UPDATE")
xanAutoMail:RegisterEvent("MAIL_SHOW")

local function colorMoneyText(value)
	if not value then return "" end
	local gold = abs(value / 10000)
	local silver = abs(mod(value / 100, 100))
	local copper = abs(mod(value, 100))
	
	local GOLD_ABRV = "g"
	local SILVER_ABRV = "s"
	local COPPER_ABRV = "c"
	
	local WHITE = "ffffff"
	local COLOR_COPPER = "eda55f"
	local COLOR_SILVER = "c7c7cf"
	local COLOR_GOLD = "ffd700"

	if value >= 10000 or value <= -10000 then
		return format("|cff%s%d|r|cff%s%s|r |cff%s%d|r|cff%s%s|r |cff%s%d|r|cff%s%s|r", WHITE, gold, COLOR_GOLD, GOLD_ABRV, WHITE, silver, COLOR_SILVER, SILVER_ABRV, WHITE, copper, COLOR_COPPER, COPPER_ABRV)
	elseif value >= 100 or value <= -100 then
		return format("|cff%s%d|r|cff%s%s|r |cff%s%d|r|cff%s%s|r", WHITE, silver, COLOR_SILVER, SILVER_ABRV, WHITE, copper, COLOR_COPPER, COPPER_ABRV)
	else
		return format("|cff%s%d|r|cff%s%s|r", WHITE, copper, COLOR_COPPER, COPPER_ABRV)
	end
end

local function bagCheck()
	local totalFree = 0
	for i=0, NUM_BAG_SLOTS do
		local numberOfFreeSlots = GetContainerNumFreeSlots(i)
		totalFree = totalFree + numberOfFreeSlots
	end
	return totalFree
end

local function mailLoop(this, arg1)
	timeChk = timeChk + arg1
	if triggerStop then return end
	
	if (timeChk > timeDelay) then
		timeChk = 0
		
		--check for last or no messages
		if numInboxItems <= 0 then
			--double check that there aren't anymore mail items
			--we use a loop check just in case to prevent infinite loops
			if GetInboxNumItems() > 0 and skipCount ~= GetInboxNumItems() and loopChk < stopLoop then
				loopChk = loopChk + 1
				numInboxItems = GetInboxNumItems()
			else
				triggerStop = true
				xanAutoMail:StopMail()
				return
			end
		end

		--lets get the mail
		local _, _, _, _, money, COD, _, numItems, wasRead, _, _, _, isGM = GetInboxHeaderInfo(numInboxItems)
		
		if money > 0 or (numItems and numItems > 0) and COD <= 0 and not isGM then
			--stop the loop if the mail was already read
			if wasRead and loopChk > 0 then
				triggerStop = true
				xanAutoMail:StopMail()
				return
			elseif bagCheck() < 1 then
				triggerStop = true
				xanAutoMail:StopMail()
				DEFAULT_CHAT_FRAME:AddMessage(hexa.."xanAutoMail: Your bags are full"..hexb)
			else
				if money > 0 then moneyCount = moneyCount + money end
				AutoLootMailItem(numInboxItems)
			end
		else
			skipCount = skipCount + 1
		end
		
		--decrease count
		numInboxItems = numInboxItems - 1
	end
end

function xanAutoMail:GetMail()
	if GetInboxNumItems() == 0 then return end
	
	xanAutoMail_OpenAllBTN:Disable() --disable the button to prevent further clicks
	triggerStop = false
	timeChk, timeDelay = 0, 0.5
	loopChk = 0
	skipCount = 0
	moneyCount = 0
	numInboxItems = GetInboxNumItems()
	
	old_InboxFrame_OnClick = InboxFrame_OnClick
	InboxFrame_OnClick = function() end
	
	--register for inventory full error
	xanAutoMail:RegisterEvent("UI_ERROR_MESSAGE")
	
	--initiate the loop
	xanAutoMail:SetScript("OnUpdate", mailLoop)
end

function xanAutoMail:StopMail()
	xanAutoMail_OpenAllBTN:Enable() --enable the button again
	if old_InboxFrame_OnClick then
		InboxFrame_OnClick = old_InboxFrame_OnClick
		old_InboxFrame_OnClick = nil
	end
	xanAutoMail:UnregisterEvent("UI_ERROR_MESSAGE")
	xanAutoMail:SetScript("OnUpdate", nil)
	--check for money output
	if moneyCount > 0 then
		DEFAULT_CHAT_FRAME:AddMessage(hexa.."xanAutoMail: Total money from mailbox"..hexb.."["..colorMoneyText(moneyCount).."]")
	end
end

--this is to stop the loop if our bags are filled
function xanAutoMail:UI_ERROR_MESSAGE(event, arg1)
	if arg1 == ERR_INV_FULL then
		triggerStop = true
		xanAutoMail:StopMail()
		DEFAULT_CHAT_FRAME:AddMessage(hexa.."xanAutoMail: Your bags are full"..hexb)
	end
end

--sometimes the mailbox is full, if this happens we have to make changes to the button position
local function inboxFullCheck()
	local nItem, nTotal = GetInboxNumItems()
	if nItem and nTotal then
		if ( nTotal > nItem) or InboxTooMuchMail:IsVisible() and not inboxAllButton.movedBottom then
			inboxAllButton:ClearAllPoints()
			inboxAllButton:SetPoint("CENTER", InboxFrame, "BOTTOM", -10, 100)
			inboxAllButton.movedBottom = true
		elseif (( nTotal < nItem) or not InboxTooMuchMail:IsVisible()) and inboxAllButton.movedBottom then
			inboxAllButton.movedBottom = nil
			inboxAllButton:ClearAllPoints()
			inboxAllButton:SetPoint("CENTER", InboxFrame, "TOP", 0, -55)
		end 
	end
end

function xanAutoMail:MAIL_INBOX_UPDATE()
	inboxFullCheck()
end

function xanAutoMail:MAIL_SHOW()
	inboxFullCheck()
end

if IsLoggedIn() then xanAutoMail:PLAYER_LOGIN() else xanAutoMail:RegisterEvent("PLAYER_LOGIN") end

---------------------------------------------------------------------------------------------------------------------------------
-- tekKompare by Tekkub found at http://www.wowinterface.com/downloads/info6837-tekKompare.html
-- only used Hoverlinks
---------------------------------------------------------------------------------------------------------------------------------

local orig1, orig2 = {}, {}
local GameTooltip = GameTooltip

local linktypes = {item = true, enchant = true, spell = true, quest = true, unit = true, talent = true, achievement = true, glyph = true, instancelock = true}


local function OnHyperlinkEnter(frame, link, ...)
	local linktype = link:match("^([^:]+)")
	if linktype and linktypes[linktype] then
		GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end

	if orig1[frame] then return orig1[frame](frame, link, ...) end
end

local function OnHyperlinkLeave(frame, ...)
	GameTooltip:Hide()
	if orig2[frame] then return orig2[frame](frame, ...) end
end


local _G = getfenv(0)
for i=1, NUM_CHAT_WINDOWS do
	local frame = _G["ChatFrame"..i]
	orig1[frame] = frame:GetScript("OnHyperlinkEnter")
	frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)

	orig2[frame] = frame:GetScript("OnHyperlinkLeave")
	frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
end	