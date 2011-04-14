local ADDON_NAME, ns = ...
local oUF = oUFTukui or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}

local T, C, L = unpack(Tukui) 
if not C.unitframes.enable or C.interface.style ~= "Tukui" == true then return end 

print("Tukui layout enabled")

local font2 = C["media"].uffont
local font1 = C["media"].font
local pixelfont = C["media"].pixelfont
local normTex = C["media"].normTex

local function Shared(self, unit)
	self.colors = T.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = T.SpawnMenu
	
	self:SetBackdrop({bgFile = C["media"].blank, insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult}})
	self:SetBackdropColor(0.1, 0.1, 0.1)
	
	local health = CreateFrame('StatusBar', nil, self)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:Height(21*C["raidlayout"].gridscale*T.raidscale)
	health:SetStatusBarTexture(normTex)
	self.Health = health
	
	if C["raidlayout"].gridhealthvertical == true then
		health:SetOrientation('VERTICAL')
	end
	
	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	health.bg:SetTexture(normTex)
	health.bg:SetTexture(0.3, 0.3, 0.3)
	health.bg.multiplier = (0.3)
	self.Health.bg = health.bg
	
	if C.unitframes.unicolor == true then
		health.colorDisconnected = false
		health.colorClass = false
		health:SetStatusBarColor(.3, .3, .3, 1)
		health.bg:SetVertexColor(.1, .1, .1, 1)		
	else
		health.colorDisconnected = true
		health.colorClass = true
		health.colorReaction = true			
	end
	
	-- border
	local Healthbg = CreateFrame("Frame", nil, self)
	Healthbg:SetPoint("TOPLEFT", self, "TOPLEFT", T.Scale(-2), T.Scale(2))
	Healthbg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", T.Scale(2), T.Scale(-3))
	T.SetTemplate(Healthbg)
	T.CreateShadow(Healthbg)
	Healthbg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
	Healthbg:SetFrameLevel(2)
	self.Healthbg = Healthbg
	-- end border	
	
	-- hydra glow
		self:HookScript("OnEnter", function(self)
			if not UnitIsConnected(self.unit) or UnitIsDead(self.unit) or UnitIsGhost(self.unit) or (not UnitInRange(self.unit) and not UnitIsPlayer(self.unit) )then return end
			local hover = RAID_CLASS_COLORS[select(2, UnitClass(self.unit))]
			health:SetStatusBarColor(hover.r, hover.g, hover.b)
			health.classcolored = true
		end)
		
		self:HookScript("OnLeave", function(self)
			if not UnitIsConnected(self.unit) or UnitIsDead(self.unit) or UnitIsGhost(self.unit) then return end
			local r, g, b = oUF.ColorGradient(UnitHealth(self.unit)/UnitHealthMax(self.unit), unpack(C["raidlayout"].gradient))
			health:SetStatusBarColor(r, g, b)
			health.classcolored = false
		end)
	-- end hydra glow
		
	local power = CreateFrame("StatusBar", nil, self)
	power:SetHeight(3*C["raidlayout"].gridscale*T.raidscale)
	power:Point("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	power:Point("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	power:SetStatusBarTexture(normTex)
	self.Power = power
	
	-- power border
	local powerborder = CreateFrame("Frame", nil, self)
	T.CreatePanel(powerborder, 1, 1, "CENTER", health, "CENTER", 0, 0)
	powerborder:ClearAllPoints()
	powerborder:SetPoint("TOPLEFT", power, T.Scale(-2), T.Scale(2))
	powerborder:SetPoint("BOTTOMRIGHT", power, T.Scale(2), T.Scale(-2))
	powerborder:SetFrameStrata("MEDIUM")
	T.SetTemplate(powerborder)
	T.CreateShadow(powerborder)
	self.powerborder = powerborder
	-- end border

	power.frequentUpdates = true
	power.colorDisconnected = true

	power.bg = power:CreateTexture(nil, "BORDER")
	power.bg:SetAllPoints(power)
	power.bg:SetTexture(normTex)
	power.bg:SetAlpha(1)
	power.bg.multiplier = 0.4
	
	if C.unitframes.unicolor == true then
		power.colorClass = true
		power.bg.multiplier = 0.1				
	else
		power.colorPower = true
	end

	local name = health:CreateFontString(nil, "OVERLAY")
    name:SetPoint("CENTER", health, "CENTER", 0, 1)
	name:SetFont(C["media"].pixelfont, 8, "MONOCHROMEOUTLINE")
	self:Tag(name, "[Tukui:getnamecolor][Tukui:nameshort]")
	self.Name = name
	
    if C["raidlayout"].aggro == true then
		table.insert(self.__elements, T.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
	end
	
	if C["raidlayout"].showsymbols == true then
		local RaidIcon = health:CreateTexture(nil, 'OVERLAY')
		RaidIcon:Height(18*T.raidscale)
		RaidIcon:Width(18*T.raidscale)
		RaidIcon:SetPoint('CENTER', self, 'TOP')
		RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
		self.RaidIcon = RaidIcon
	end
	
	local ReadyCheck = power:CreateTexture(nil, "OVERLAY")
	ReadyCheck:Height(12*C["raidlayout"].gridscale*T.raidscale)
	ReadyCheck:Width(12*C["raidlayout"].gridscale*T.raidscale)
	ReadyCheck:SetPoint('CENTER') 	
	self.ReadyCheck = ReadyCheck
	
	--local picon = self.Health:CreateTexture(nil, 'OVERLAY')
	--picon:SetPoint('CENTER', self.Health)
	--picon:SetSize(16, 16)
	--picon:SetTexture[[Interface\AddOns\Tukui\medias\textures\picon]]
	--picon.Override = T.Phasing
	--self.PhaseIcon = picon
	
	if not C["raidlayout"].raidunitdebuffwatch == true then
		self.DebuffHighlightAlpha = 1
		self.DebuffHighlightBackdrop = true
		self.DebuffHighlightFilter = true
	end
	
	if C["raidlayout"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["raidlayout"].raidalphaoor}
		self.Range = range
	end
	
	if C["unitframes"].showsmooth == true then
		health.Smooth = true
		power.Smooth = true
	end
	
	if C["raidlayout"].gradienthealth then
		if not UnitIsPlayer(unit) then return end
		local r2, g2, b2 = oUFTukui.ColorGradient(min/max, unpack(C["raidlayout"].gradient))
		health:SetStatusBarColor(r2, g2, b2)
	end
	
	if C["unitframes"].healcomm then
		local mhpb = CreateFrame('StatusBar', nil, self.Health)
		if C["raidlayout"].gridhealthvertical then
			mhpb:SetOrientation("VERTICAL")
			mhpb:SetPoint('BOTTOM', self.Health:GetStatusBarTexture(), 'TOP', 0, 0)
			mhpb:Width(66*C["raidlayout"].gridscale*T.raidscale)
			mhpb:Height(50*C["raidlayout"].gridscale*T.raidscale)		
		else
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:Width(66*C["raidlayout"].gridscale*T.raidscale)
		end				
		mhpb:SetStatusBarTexture(normTex)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

		local ohpb = CreateFrame('StatusBar', nil, self.Health)
		if C["raidlayout"].gridhealthvertical then
			ohpb:SetOrientation("VERTICAL")
			ohpb:SetPoint('BOTTOM', mhpb:GetStatusBarTexture(), 'TOP', 0, 0)
			ohpb:Width(66*C["raidlayout"].gridscale*T.raidscale)
			ohpb:Height(50*C["raidlayout"].gridscale*T.raidscale)
		else
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:Width(6*C["raidlayout"].gridscale*T.raidscale)
		end
		ohpb:SetStatusBarTexture(normTex)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)

		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
		}
	end
	
	------------------------------------------------------------------------
	--      Debuff Highlight
	------------------------------------------------------------------------
		local dbh = self.Health:CreateTexture(nil, "OVERLAY", Healthbg)
		dbh:SetAllPoints(self)
		dbh:SetTexture(TukuiCF["media"].normTex)
		dbh:SetBlendMode("ADD")
		dbh:SetVertexColor(0,0,0,0)
		self.DebuffHighlight = dbh
		self.DebuffHighlightFilter = true
		self.DebuffHighlightAlpha = 0.6
	-- end	
	
	if C["raidlayout"].raidunitdebuffwatch == true then
		-- AuraWatch (corner icon)
		T.createAuraWatch(self,unit)
		
		-- Raid Debuffs (big middle icon)
		local RaidDebuffs = CreateFrame('Frame', nil, self)
		RaidDebuffs:Height(22*C["raidlayout"].gridscale)
		RaidDebuffs:Width(22*C["raidlayout"].gridscale)
		RaidDebuffs:Point('CENTER', health, 1,0)
		RaidDebuffs:SetFrameStrata(health:GetFrameStrata())
		RaidDebuffs:SetFrameLevel(health:GetFrameLevel() + 2)
		
		RaidDebuffs:SetTemplate("Default")
		
		RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, 'OVERLAY')
		RaidDebuffs.icon:SetTexCoord(.1,.9,.1,.9)
		RaidDebuffs.icon:Point("TOPLEFT", 2, -2)
		RaidDebuffs.icon:Point("BOTTOMRIGHT", -2, 2)
		
		-- just in case someone want to add this feature, uncomment to enable it
		--[[
		if C["unitframes"].auratimer then
			RaidDebuffs.cd = CreateFrame('Cooldown', nil, RaidDebuffs)
			RaidDebuffs.cd:SetPoint("TOPLEFT", T.Scale(2), T.Scale(-2))
			RaidDebuffs.cd:SetPoint("BOTTOMRIGHT", T.Scale(-2), T.Scale(2))
			RaidDebuffs.cd.noOCC = true -- remove this line if you want cooldown number on it
		end
		--]]
		
		RaidDebuffs.count = RaidDebuffs:CreateFontString(nil, 'OVERLAY')
		RaidDebuffs.count:SetFont(C["media"].uffont, 9*C["raidlayout"].gridscale, "THINOUTLINE")
		RaidDebuffs.count:SetPoint('BOTTOMRIGHT', RaidDebuffs, 'BOTTOMRIGHT', 0, 2)
		RaidDebuffs.count:SetTextColor(1, .9, 0)
		
		self.RaidDebuffs = RaidDebuffs
    end

	return self
end

oUF:RegisterStyle('TukuiHealR25R40', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiHealR25R40")	
	if C["raidlayout"].gridonly ~= true then
		local raid = self:SpawnHeader("TukuiGrid", nil, "custom [@raid16,exists] show;hide",
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', T.Scale(76*C["raidlayout"].gridscale*T.raidscale),
			'initial-height', T.Scale(20*C["raidlayout"].gridscale*T.raidscale),	
			"showRaid", true,
			"xoffset", T.Scale(7),
			"yOffset", T.Scale(-7),
			"point", "LEFT",
			"groupFilter", "1,2,3,4,5,6,7,8",
			"groupingOrder", "1,2,3,4,5,6,7,8",
			"groupBy", "GROUP",
			"maxColumns", 5,
			"unitsPerColumn", 5,
			"columnSpacing", T.Scale(15),
			"columnAnchorPoint", "TOP"		
		)
		raid:SetPoint("BOTTOMLEFT", TukuiTabsLeftBackground, "TOPLEFT", 1, 15*T.raidscale)
	else
		local raid = self:SpawnHeader("TukuiGrid", nil, "raid,party",
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', T.Scale(76*C["raidlayout"].gridscale*T.raidscale),
			'initial-height', T.Scale(20*C["raidlayout"].gridscale*T.raidscale),
			"showParty", true,
			"showPlayer", C["raidlayout"].showplayerinparty, 
			"showRaid", true, 
			"xoffset", T.Scale(7),
			"yOffset", T.Scale(-7),
			"point", "LEFT",
			"groupFilter", "1,2,3,4,5,6,7,8",
			"groupingOrder", "1,2,3,4,5,6,7,8",
			"groupBy", "GROUP",
			"maxColumns", 5,
			"unitsPerColumn", 5,
			"columnSpacing", T.Scale(15),
			"columnAnchorPoint", "TOP"		
		)
		raid:SetPoint("BOTTOMLEFT", TukuiTabsLeftBackground, "TOPLEFT", 1, 15*T.raidscale)
		
		local pets = {} 
			pets[1] = oUF:Spawn('partypet1', 'oUF_TukuiPartyPet1') 
			pets[1]:Point('TOPLEFT', raid, 'TOPLEFT', 0, 40*C["raidlayout"].gridscale*T.raidscale + -4)
			pets[1]:Size(76*C["raidlayout"].gridscale*T.raidscale, 20*C["raidlayout"].gridscale*T.raidscale)
		for i =2, 4 do 
			pets[i] = oUF:Spawn('partypet'..i, 'oUF_TukuiPartyPet'..i) 
			pets[i]:Point('LEFT', pets[i-1], 'RIGHT', 7, 0)
			pets[i]:Size(76*C["raidlayout"].gridscale*T.raidscale, 20*C["raidlayout"].gridscale*T.raidscale)
		end
		
		local ShowPet = CreateFrame("Frame")
		ShowPet:RegisterEvent("PLAYER_ENTERING_WORLD")
		ShowPet:RegisterEvent("RAID_ROSTER_UPDATE")
		ShowPet:RegisterEvent("PARTY_LEADER_CHANGED")
		ShowPet:RegisterEvent("PARTY_MEMBERS_CHANGED")
		ShowPet:SetScript("OnEvent", function(self)
			if InCombatLockdown() then
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			else
				self:UnregisterEvent("PLAYER_REGEN_ENABLED")
				local numraid = GetNumRaidMembers()
				local numparty = GetNumPartyMembers()
				if numparty > 0 and numraid == 0 or numraid > 0 and numraid <= 5 then
					for i,v in ipairs(pets) do v:Enable() end
				else
					for i,v in ipairs(pets) do v:Disable() end
				end
			end
		end)		
	end
end)

-- only show 5 groups in raid (25 mans raid)
local MaxGroup = CreateFrame("Frame")
MaxGroup:RegisterEvent("PLAYER_ENTERING_WORLD")
MaxGroup:RegisterEvent("ZONE_CHANGED_NEW_AREA")
MaxGroup:SetScript("OnEvent", function(self)
	local inInstance, instanceType = IsInInstance()
	local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
	if inInstance and instanceType == "raid" and maxPlayers ~= 40 then
		TukuiGrid:SetAttribute("groupFilter", "1,2,3,4,5")
	else
		TukuiGrid:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")
	end
end)