local T, C, L = unpack(select(2, ...)) 
------------------------------------------------------------------------------------
-- cTotems by Author:  Celebrindal
-- http://www.wowinterface.com/downloads/info19725-cTotems.html
-------------------------------------------------------------------------------------

enable = 1
if UnitClass("player") ~= "Shaman" then enable = 0 end
if enable ~= 1 then return end
local _, L = ...;
CreateFrame("Frame", "cTot", UIParent)
local self = cTot
self:SetWidth(20)
self:SetHeight(20)


-- CONFIG SECTION
-- position
local align = "LEFT"
local x = -10 -- left/right
local y = -0 -- up/down
local scale = 1.5

-- font
local font = C.media.pixelfont2 -- HOOG0555.ttf 
local fontflag = "OUTLINEMONOCHROME" -- for pixelfont stick to this else OUTLINE or THINOUTLINE
local fontsize = 8 -- font size

-- hide when theres no totems? 
self.hide = true -- true or false

-- fade long duration totems?
self.fadeTotems = true -- true or false
self.fadeNoTotem = false -- true or false (TRUE fades missing totems like long duration ones, FALSE won't) This only applies if your not hiding missing totems.

-- alphas for fading long duration totems/highlighting totems that are about to run out
self.alphaLow = 0.5
self.alphaHigh = 0.8

--time to highlight (sec)
self.highlightTime = 10

--totem placement 1 = fire, 2 = earth, 3 = water, 4 = air
self.order = {1,4,3,2}	--fire, earth, water, air
--self.order = {2,1,4,3}	--earth, fire, air, water

--guess you can figure it out :p


-- CONFIG END
self:SetPoint(align,TukuiPlayer,x,y)
self:SetScale(scale)

self.orderR = {}
for i,v in pairs(self.order) do
	self.orderR[v] = i
end
self.order, self.orderR = self.orderR, self.order
self.f_t = {}
local f_t = self.f_t
self.b_t = {}
local b_t = self.b_t
self.f_f = {}
local f_f = self.f_f
self.f_time = {}
self.red, self.green, self.blue = {},{},{}
local red, green, blue = self.red, self.green, self.blue
local function GetTotemName(id)
	name, _ = GetSpellInfo(id)
	return name
end

-- Colors

red[1],green[1],blue[1] = 1,0.4,0
red[2],green[2],blue[2] = 1,0.8,0.2
red[3],green[3],blue[3] = 0,1,1
red[4],green[4],blue[4] = 0.8,1,1

-- Totems
self.totems = {}
local totems = self.totems
totems[GetTotemName(2062)] = L['EEle']
totems[GetTotemName(2484)] = L['EBind']
totems[GetTotemName(8184)] = L['Resist']
totems[GetTotemName(2894)] = L['FEle']
totems[GetTotemName(8227)] = L['FT']
totems[GetTotemName(8177)] = L['Ground']
totems[GetTotemName(5394)] = L['Heal']
totems[GetTotemName(8190)] = L['Magma']
totems[GetTotemName(5675)] = L['Mana']
totems[GetTotemName(3599)] = L['Sear']
totems[GetTotemName(5730)] = L['SClaw']
totems[GetTotemName(8071)] = L['SSkin']
totems[GetTotemName(8075)] = L['SoE']
totems[GetTotemName(87718)] = L['Tranq']
totems[GetTotemName(8143)] = L['Tremor']
totems[GetTotemName(8512)] = L['WF']
totems[GetTotemName(3738)] = L['WoA']
totems[GetTotemName(2062)] = L['Tide']



cTot:RegisterEvent("PLAYER_TOTEM_UPDATE")
cTot:RegisterEvent("PLAYER_ENTERING_WORLD")
local function cTot_eventHandler(self,event,...)
	if event == "PLAYER_ENTERING_WORLD" then
		cTot_OnLoad()
	else
		local slot = ...
		local arg1, name = GetTotemInfo(slot)
		local slot2 = slot
		slot = self.order[slot]
		--print(slot, self.order[slot])
		if name ~= '' then
			if self.hide then
				self.b_t[slot]:Show()
			end
			self.b_t[slot].texture:SetTexture(self.red[slot2],self.green[slot2],self.blue[slot2])
			self.f_f[slot]:SetText(self.totems[name])
			local dur = GetTotemTimeLeft(slot)
			local min = floor(dur/60)
			local sec = dur-60*min
			if sec < self.highlightTime and min == 0  and self.fadeTotems then
				self.b_t[slot]:SetAlpha(self.alphaHigh)
				self.f_f[slot]:SetAlpha(self.alphaHigh)
				self.f_time[slot]:SetAlpha(self.alphaHigh)
			elseif self.fadeTotems then
				self.b_t[slot]:SetAlpha(self.alphaLow)
				self.f_f[slot]:SetAlpha(self.alphaLow)
				self.f_time[slot]:SetAlpha(self.alphaLow)
			end
			if sec < 10 then
				sec = "0" .. sec
			end
			self.f_time[slot]:SetText(min .. ":" .. sec)
		else
			if self.hide then
				self.b_t[slot]:Hide()
				self.f_f[slot]:SetText('')
			else
				self.f_f[slot]:SetText('N')
				if self.fadeTotems then self.f_f[slot]:SetAlpha((self.fadeNoTotem) and self.alphaLow or self.alphaHigh) end
			end
			self.b_t[slot].texture:SetTexture(0,0,0)
			if self.fadeTotems then self.b_t[slot]:SetAlpha((self.fadeNoTotem) and self.alphaLow or self.alphaHigh) end
			self.f_time[slot]:SetText('')
		end
	end
end
cTot.UpdateInterval = 1.0
cTot.TimeSinceLastUpdate = 0

local function cTot_onUpdateEvent(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed; 	
	while (self.TimeSinceLastUpdate > self.UpdateInterval) do
		for i=1,4 do
			local arg1, name = GetTotemInfo(i)
			if name ~= '' then
				local dur = GetTotemTimeLeft(i)
				local min = floor(dur/60)
				local sec = dur-60*min
				i = self.order[i]
				if sec < self.highlightTime and min == 0 and self.fadeTotems then
					self.b_t[i]:SetAlpha(self.alphaHigh)
					self.f_f[i]:SetAlpha(self.alphaHigh)
					self.f_time[i]:SetAlpha(self.alphaHigh)
				elseif self.fadeTotems then
					self.b_t[i]:SetAlpha(self.alphaLow)
					self.f_f[i]:SetAlpha(self.alphaLow)
					self.f_time[i]:SetAlpha(self.alphaLow)
				end
				if sec < 10 then
					sec = "0" .. sec
				end
				self.f_time[i]:SetText(min .. ":" .. sec)
			else
				i = self.order[i]
				self.f_time[i]:SetText('')
			end
		end
		self.TimeSinceLastUpdate = self.TimeSinceLastUpdate - self.UpdateInterval;
	end
end

function cTot_OnLoad()
	for i=1,4 do
		local arg1, name = GetTotemInfo(i)
		local i2 = i
		if name ~= '' then
			local dur = GetTotemTimeLeft(i)
			local min = floor(dur/60)
			local sec = dur-60*min
			i = self.order[i]
			self.b_t[i].texture:SetTexture(red[i2],green[i2],blue[i2])
			self.f_f[i]:SetText(self.totems[name])
			if sec < self.highlightTime and min == 0 and self.fadeTotems then
				self.b_t[i]:SetAlpha(self.alphaHigh)
				self.f_f[i]:SetAlpha(self.alphaHigh)
				self.f_time[i]:SetAlpha(self.alphaHigh)
			elseif self.fadeTotems then
				self.b_t[i]:SetAlpha(self.alphaLow)
				self.f_f[i]:SetAlpha(self.alphaLow)
				self.f_time[i]:SetAlpha(self.alphaLow)
			end
			if sec < 10 then
				sec = "0" .. sec
			end
			self.f_time[i]:SetText(min .. ":" .. sec)
		else
			i = self.order[i]
			if self.hide then
				self.b_t[i]:Hide()
				self.f_f[i]:SetText('')
			else
				self.f_f[i]:SetText('N')
			if self.fadeTotems then self.f_f[i]:SetAlpha((self.fadeNoTotem) and self.alphaLow or self.alphaHigh) end
			end
			self.b_t[i].texture:SetTexture(0,0,0)
			if self.fadeTotems then self.b_t[i]:SetAlpha((self.fadeNoTotem) and self.alphaLow or self.alphaHigh) end
			self.f_time[i]:SetText('')
		end
	end
end

cTot:SetScript("OnEvent", cTot_eventHandler)
cTot:SetScript("OnUpdate", cTot_onUpdateEvent)

-- Frames

for i=1,4 do
	self.f_t[i] = CreateFrame("Frame", nil, cTot)
	self.f_t[i]:SetFrameStrata("LOW")
	self.f_t[i]:SetWidth(20)
	self.f_t[i]:SetHeight(10)
	self.f_f[i] = f_t[i]:CreateFontString("totemname" .. i)
	self.f_time[i] = f_t[i]:CreateFontString("totemtime" .. i)
	self.f_f[i]:SetFont(font, fontsize, fontflag)
	self.f_time[i]:SetFont(font, fontsize, fontflag)
end
self.f_t[1]:SetPoint("TOPLEFT",0,0)
for i=2,4 do
	self.f_t[i]:SetPoint("TOPLEFT",f_t[i-1],"BOTTOMLEFT",0,2.5)
end
for i=1,4 do
	self.f_t[i]:Show()
end

-- Buttons

for i=1,4 do
	self.b_t[i] = CreateFrame("Button", nil, cTot)
	self.b_t[i]:SetFrameStrata("BACKGROUND")
	self.b_t[i]:SetTemplate("Hydra")	
	self.b_t[i]:SetWidth(5)
	self.b_t[i]:SetHeight(5)

	self.b_t[i].texture = b_t[i]:CreateTexture()
	self.b_t[i].texture:SetAllPoints(b_t[i])
	self.b_t[i].texture:SetTexture(0,0,0)
	if self.fadeTotems then self.b_t[i]:SetAlpha((self.fadeNoTotem) and self.alphaLow or self.alphaHigh) end
	
	self.b_t[i]:SetPoint("TOPLEFT",f_t[i],"TOPLEFT",1,-1)
	self.b_t[i]:Show()
	self.b_t[i]:RegisterForClicks("AnyUp")
	self.b_t[i]:SetScript("OnClick", function (self, button, down)
		DestroyTotem(cTot.orderR[i])
	end)
end

-- Names+times

for i=1,4 do
	self.f_f[i]:SetWidth(28)
	self.f_f[i]:SetHeight(8)
	self.f_f[i]:SetJustifyH("RIGHT")
	self.f_f[i]:SetPoint("TOPRIGHT",b_t[i],"TOPLEFT",14,1)
	if self.hide then
		self.f_f[i]:SetText('')
	else
		self.f_f[i]:SetText("N")
		if self.fadeTotems then self.f_f[i]:SetAlpha((self.fadeNoTotem) and self.alphaLow or self.alphaHigh) end
	end
	self.f_f[i]:Show()
	self.f_time[i]:SetWidth(20)
	self.f_time[i]:SetHeight(8)
	self.f_time[i]:SetJustifyH("RIGHT")
	self.f_time[i]:SetPoint("TOPRIGHT",f_f[i],"TOPLEFT",14,1)
	self.f_time[i]:Show()
end

cTot_OnLoad()