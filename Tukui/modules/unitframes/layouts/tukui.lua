local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
if not C["unitframes"].enable == true then return end

local ADDON_NAME, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}

------------------------------------------------------------------------
--	local variables
------------------------------------------------------------------------

local font1 = C["media"].uffont
local font2 = C["media"].font
local pixelfont = C["media"].pixelfont
local normTex = C["media"].normTex
local glowTex = C["media"].glowTex
local bubbleTex = C["media"].bubbleTex

local backdrop = {
	bgFile = C["media"].blank,
	insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult},
}

------------------------------------------------------------------------
--	Layout
------------------------------------------------------------------------

local function Shared(self, unit)
	-- set our own colors
	self.colors = T.oUF_colors
	
	-- register click
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	-- menu? lol
	self.menu = T.SpawnMenu

	-- backdrop for every units
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0)

	-- this is the glow border
	self:CreateShadow("Default")
	
	------------------------------------------------------------------------
	--	Features we want for all units at the same time
	------------------------------------------------------------------------
	
	-- here we create an invisible frame for all element we want to show over health/power.
	local InvFrame = CreateFrame("Frame", nil, self)
	InvFrame:SetFrameStrata("HIGH")
	InvFrame:SetFrameLevel(5)
	InvFrame:SetAllPoints()
	
	-- symbols, now put the symbol on the frame we created above.
	local RaidIcon = InvFrame:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
	RaidIcon:SetHeight(20)
	RaidIcon:SetWidth(20)
	RaidIcon:SetPoint("TOP", 0, 11)
	self.RaidIcon = RaidIcon
	
	------------------------------------------------------------------------
	--	Player and Target units layout (mostly mirror'd)
	------------------------------------------------------------------------
	
	if (unit == "player" or unit == "target") then
		-- create a panel
		local panel = CreateFrame("Frame", nil, self)
		panel:CreatePanel("Default", 250, 15, "BOTTOM", self, "BOTTOM", 0, -3)
		panel:SetFrameLevel(2)
		panel:SetFrameStrata("MEDIUM")
		panel:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		self.panel = panel
		self.panel:Hide()
	
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(26)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		
		-- border
		local Healthbg = CreateFrame("Frame", nil, self)
	    Healthbg:SetPoint("TOPLEFT", self, "TOPLEFT", T.Scale(-2), T.Scale(2))
	    Healthbg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", T.Scale(2), T.Scale(-8))
	    T.SetTemplate(Healthbg)
		T.CreateShadow(Healthbg)
	    Healthbg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
	    Healthbg:SetFrameLevel(2)
	    self.Healthbg = Healthbg
				
		-- health bar background
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
	
		health.value = T.SetFontString(health, pixelfont, 8, "MONOCHROMEOUTLINE")
		health.value:Point("RIGHT", health, "RIGHT", T.Scale(-2), T.Scale(-2))
		health.PostUpdate = T.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG

		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorTapping = false
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorTapping = true	
			health.colorClass = true
			health.colorReaction = true			
		end

		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Height(5)
		power:Point("TOPLEFT", health, "BOTTOMLEFT", 0, -6)
		power:Point("TOPRIGHT", health, "BOTTOMRIGHT", 0, -6)
		power:SetStatusBarTexture(normTex)
		
		-- power border
		local powerborder = CreateFrame("Frame", nil, self)
		T.CreatePanel(powerborder, 1, 1, "CENTER", health, "CENTER", 0, 0)
		powerborder:ClearAllPoints()
		powerborder:SetPoint("TOPLEFT", power, T.Scale(-2), T.Scale(2))
		powerborder:SetPoint("BOTTOMRIGHT", power, T.Scale(2), T.Scale(-2))
		powerborder:SetFrameStrata("MEDIUM")
		T.CreateShadow(powerborder)
		self.powerborder = powerborder
		
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		power.value = T.SetFontString(health, pixelfont, 8, "MONOCHROMEOUTLINE")
		power.value:Point("LEFT", health, "LEFT", T.Scale(2), T.Scale(-2))
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
				
		self.Power = power
		self.Power.bg = powerBG
		
		power.frequentUpdates = true
		power.colorDisconnected = true

		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			power.colorTapping = true
			power.colorClass = true
			powerBG.multiplier = 0.1				
		else
			power.colorPower = true
		end

		------------------------------------------------------------------------
	    --  Debuff Highlight
	    ------------------------------------------------------------------------
	   if unit == "player" then
		local dbh = self.Health:CreateTexture(nil, "OVERLAY", health)
		dbh:SetAllPoints(health)
		dbh:SetTexture(C["media"].normTex)
		dbh:SetBlendMode("ADD")
		dbh:SetVertexColor(0,0,0,0)
		self.DebuffHighlight = dbh
		self.DebuffHighlightFilter = true
		self.DebuffHighlightAlpha = 0.6
	    end
		
		-- portraits
		if (C["unitframes"].charportrait == true) then
			local portrait = CreateFrame("PlayerModel", self:GetName().."_Portrait", self)
			portrait:SetFrameLevel(1)
			portrait:SetHeight(70)
			portrait:SetWidth(55)
			portrait:SetAlpha(1)
			if unit == "player" then
				portrait:SetPoint("TOPRIGHT", health, "TOPLEFT", -7,0)
				portrait:SetPoint("BOTTOMRIGHT", power, "BOTTOMLEFT", -7,0)
			elseif unit == "target" then
				portrait:SetPoint("TOPLEFT", health, "TOPRIGHT", 7,0)
				portrait:SetPoint("BOTTOMLEFT", power, "BOTTOMRIGHT", 7,0)
			end
			-- table.insert(self.__elements, TukuiDB.HidePortrait)
			self.Portrait = portrait
			
			-- Portrait Border
			portrait.bg = CreateFrame("Frame",nil,portrait)
			portrait.bg:SetPoint("BOTTOMLEFT",portrait,"BOTTOMLEFT",T.Scale(-2),T.Scale(-2))
			portrait.bg:SetPoint("TOPRIGHT",portrait,"TOPRIGHT",T.Scale(2),T.Scale(2))
			T.SetTemplate(portrait.bg)
			portrait.bg:SetFrameStrata("BACKGROUND")
		end
		
		if T.myclass == "PRIEST" and C["unitframes"].weakenedsoulbar then
			local ws = CreateFrame("StatusBar", self:GetName().."_WeakenedSoul", power)
			ws:SetAllPoints(power)
			ws:SetStatusBarTexture(C.media.normTex)
			ws:GetStatusBarTexture():SetHorizTile(false)
			ws:SetBackdrop(backdrop)
			ws:SetBackdropColor(unpack(C.media.backdropcolor))
			ws:SetStatusBarColor(191/255, 10/255, 10/255)
			
			self.WeakenedSoul = ws
		end
		
		--[[ leaving here just in case someone want to use it, we now use our own Alt Power Bar.
		-- alt power bar
		local AltPowerBar = CreateFrame("StatusBar", self:GetName().."_AltPowerBar", self.Health)
		AltPowerBar:SetFrameLevel(0)
		AltPowerBar:SetFrameStrata("LOW")
		AltPowerBar:SetHeight(5)
		AltPowerBar:SetStatusBarTexture(C.media.normTex)
		AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
		AltPowerBar:SetStatusBarColor(163/255,  24/255,  24/255)
		AltPowerBar:EnableMouse(true)

		AltPowerBar:Point("LEFT", TukuiInfoLeft, 2, -2)
		AltPowerBar:Point("RIGHT", TukuiInfoLeft, -2, 2)
		AltPowerBar:Point("TOP", TukuiInfoLeft, 2, -2)
		AltPowerBar:Point("BOTTOM", TukuiInfoLeft, -2, 2)
		
		AltPowerBar:SetBackdrop({
			bgFile = C["media"].blank, 
			edgeFile = C["media"].blank, 
			tile = false, tileSize = 0, edgeSize = 1, 
			insets = { left = 0, right = 0, top = 0, bottom = T.Scale(-1)}
		})
		AltPowerBar:SetBackdropColor(0, 0, 0)

		self.AltPowerBar = AltPowerBar
		--]]
			
		if (unit == "player") then

			-- custom info (low mana warning)
			FlashInfo = CreateFrame("Frame", "TukuiFlashInfo", self)
			FlashInfo:SetScript("OnUpdate", T.UpdateManaLevel)
			FlashInfo.parent = self
			FlashInfo:SetAllPoints(panel)
			FlashInfo.ManaLevel = T.SetFontString(FlashInfo, pixelfont, 8, "OUTLINEMONOCHROME")
			FlashInfo.ManaLevel:SetPoint("CENTER", panel, "CENTER", 0, 0)
			self.FlashInfo = FlashInfo
			
			-- pvp status text
			local status = T.SetFontString(panel, pixelfont, 8, "OUTLINEMONOCHROME")
			status:SetPoint("CENTER", panel, "CENTER", 0, 0)
			status:SetTextColor(0.69, 0.31, 0.31)
			self.Status = status
			self:Tag(status, "[pvp]")
			
			-- leader icon
			local Leader = InvFrame:CreateTexture(nil, "OVERLAY")
			Leader:Height(14)
			Leader:Width(14)
			Leader:Point("TOPLEFT", 2, 8)
			self.Leader = Leader
			
			-- master looter
			local MasterLooter = InvFrame:CreateTexture(nil, "OVERLAY")
			MasterLooter:Height(14)
			MasterLooter:Width(14)
			self.MasterLooter = MasterLooter
			self:RegisterEvent("PARTY_LEADER_CHANGED", T.MLAnchorUpdate)
			self:RegisterEvent("PARTY_MEMBERS_CHANGED", T.MLAnchorUpdate)
			
			-- show druid mana when shapeshifted in bear, cat or whatever
			if T.myclass == "DRUID" then
				CreateFrame("Frame"):SetScript("OnUpdate", function() T.UpdateDruidMana(self) end)
				local DruidMana = T.SetFontString(health, pixelfont, 8, "OUTLINEMONOCHROME")
				DruidMana:SetTextColor(1, 0.49, 0.04)
				self.DruidMana = DruidMana
			end
			
			if C["unitframes"].classbar then
				if T.myclass == "DRUID" then							
				local eclipseBar = CreateFrame('Frame', nil, self)
				eclipseBar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, T.Scale(1))
				eclipseBar:SetSize(T.Scale(250), T.Scale(8))
				eclipseBar:SetFrameStrata("MEDIUM")
				eclipseBar:SetFrameLevel(8)
				T.SetTemplate(eclipseBar)
				eclipseBar:SetBackdropBorderColor(0,0,0,0)
				eclipseBar:SetBackdropColor(0,0,0,1)
				eclipseBar:SetScript("OnShow", function() T.EclipseDisplay(self, false) end)
				eclipseBar:SetScript("OnUpdate", function() T.EclipseDisplay(self, true) end) -- just forcing 1 update on login for buffs/shadow/etc.
				eclipseBar:SetScript("OnHide", function() T.EclipseDisplay(self, false) end)
				
				local lunarBar = CreateFrame('StatusBar', nil, eclipseBar)
				lunarBar:SetPoint('LEFT', eclipseBar, 'LEFT', 0, 0)
				lunarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
				lunarBar:SetStatusBarTexture(normTex)
				lunarBar:SetStatusBarColor(.30, .52, .90)
				eclipseBar.LunarBar = lunarBar

				local solarBar = CreateFrame('StatusBar', nil, eclipseBar)
				solarBar:SetPoint('LEFT', lunarBar:GetStatusBarTexture(), 'RIGHT', 0, 0)
				solarBar:SetSize(eclipseBar:GetWidth(), eclipseBar:GetHeight())
				solarBar:SetStatusBarTexture(normTex)
				solarBar:SetStatusBarColor(.80, .82,  .60)
				eclipseBar.SolarBar = solarBar

				local eclipseBarText = solarBar:CreateFontString(nil, 'OVERLAY')
				eclipseBarText:SetPoint('TOP', panel)
				eclipseBarText:SetPoint('BOTTOM', panel)
				eclipseBarText:SetFont(pixelfont, 8, "OUTLINEMONOCHROME")
				eclipseBar.Text = eclipseBarText
				
				-- border 
				eclipseBar.border = CreateFrame("Frame", nil,eclipseBar)
				eclipseBar.border:SetPoint("TOPLEFT", eclipseBar, "TOPLEFT", T.Scale(-2), T.Scale(2))
				eclipseBar.border:SetPoint("BOTTOMRIGHT", eclipseBar, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
				eclipseBar.border:SetFrameStrata("BACKGROUND")
				T.SetTemplate(eclipseBar.border)

				-- hide "low mana" text on load if eclipseBar is show
				if eclipseBar and eclipseBar:IsShown() then FlashInfo.ManaLevel:SetAlpha(0) end
				
				self.EclipseBar = eclipseBar
				end
			


				-- set holy power bar or shard bar
				if (T.myclass == "WARLOCK" or T.myclass == "PALADIN") then

					local bars = CreateFrame("Frame", nil, self)
					bars:SetPoint("BOTTOMLEFT", self, "TOPLEFT", T.Scale(0), T.Scale(5))
					bars:Width(T.Scale(234))
					bars:Height(T.Scale(8))
					
					for i = 1, 3 do					
						bars[i]=CreateFrame("StatusBar", self:GetName().."_Shard"..i, self)
						bars[i]:Height(6)					
						bars[i]:SetStatusBarTexture(normTex)
						bars[i]:GetStatusBarTexture():SetHorizTile(false)

						if T.myclass == "WARLOCK" then
							bars[i]:SetStatusBarColor(255/255,101/255,101/255)
						elseif T.myclass == "PALADIN" then
							bars[i]:SetStatusBarColor(228/255,225/255,16/255)
						end
						
						if i == 1 then
							bars[i]:SetPoint("LEFT", bars)
							bars[i]:SetWidth(T.Scale(234 /3)) 
						else
							bars[i]:Point("LEFT", bars[i-1], "RIGHT", T.Scale(8), 0)
							bars[i]:SetWidth(T.Scale(234 /3))
						end
						
					    bars[i].border = CreateFrame("Frame", nil, bars)
					    bars[i].border:SetPoint("TOPLEFT", bars[i], "TOPLEFT", T.Scale(-2), T.Scale(2))
					    bars[i].border:SetPoint("BOTTOMRIGHT", bars[i], "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
					    bars[i].border:SetFrameStrata("BACKGROUND")
					    T.SetTemplate(bars[i].border)
					    T.CreateShadow(bars[i].border)
					    bars[i].border:SetBackdropColor( 0,0,0)
					end
					
					if T.myclass == "WARLOCK" then
						bars.Override = T.UpdateShards				
						self.SoulShards = bars
					elseif T.myclass == "PALADIN" then
						bars.Override = T.UpdateHoly
						self.HolyPower = bars
					end
				end

				-- deathknight runes
				if T.myclass == "DEATHKNIGHT" then
			
				local Runes = CreateFrame("Frame", nil, self)
                Runes:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, T.Scale(6))
                Runes:SetWidth(T.Scale(210))
                Runes:SetHeight(T.Scale(8))

                for i = 1, 6 do
                    Runes[i] = CreateFrame("StatusBar", self:GetName().."_Runes"..i, self)
                    Runes[i]:SetHeight(T.Scale(8))

					
                    if i == 1 then
                        Runes[i]:SetPoint("LEFT", Runes, "LEFT", 0, 0)
						Runes[i]:SetWidth(T.Scale(210 /6))
                    else
                        Runes[i]:SetPoint("LEFT", Runes[i-1], "RIGHT", T.Scale(8), 0)
						Runes[i]:SetWidth(T.Scale(210 /6))
                    end
                    Runes[i]:SetStatusBarTexture(normTex)
                    Runes[i]:GetStatusBarTexture():SetHorizTile(false)
					Runes[i]:SetBackdrop(backdrop)
                    Runes[i]:SetBackdropColor(0,0,0)
                    Runes[i]:SetFrameLevel(20)
                    
                    Runes[i].bg = Runes[i]:CreateTexture(nil, "BORDER")
                    Runes[i].bg:SetAllPoints(Runes[i])
                    Runes[i].bg:SetTexture(normTex)
                    Runes[i].bg.multiplier = 0.3
					
					
					Runes[i].border = CreateFrame("Frame", nil, Runes[i])
					Runes[i].border:SetPoint("TOPLEFT", Runes[i], "TOPLEFT", T.Scale(-2), T.Scale(2))
					Runes[i].border:SetPoint("BOTTOMRIGHT", Runes[i], "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
					Runes[i].border:SetFrameStrata("BACKGROUND")
					T.SetTemplate(Runes[i].border)
					Runes[i].border:SetBackdropColor( 0,0,0,1 )
					TukuiDB.CreateShadow(Runes[i].border)
					
                end

                    self.Runes = Runes
                end
				
				-- shaman totem bar
		    if T.myclass == "SHAMAN" then
			local TotemBar = {}
				TotemBar.Destroy = true
				for i = 1, 4 do
					TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
					if (i == 1) then
						TotemBar[i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, TukuiDB.Scale(6))
					else
					   TotemBar[i]:SetPoint("TOPLEFT", TotemBar[i-1], "TOPRIGHT", TukuiDB.Scale(7), 0)
					end
					TotemBar[i]:SetStatusBarTexture(normTex)
					TotemBar[i]:SetHeight(T.Scale(5))
					TotemBar[i]:SetWidth(T.Scale(229) / 4)
				
					TotemBar[i]:SetBackdrop(backdrop)
					TotemBar[i]:SetBackdropColor(0, 0, 0, 1)
					TotemBar[i]:SetMinMaxValues(0, 1)

					TotemBar[i].bg = TotemBar[i]:CreateTexture(nil, "BORDER")
					TotemBar[i].bg:SetAllPoints(TotemBar[i])
					TotemBar[i].bg:SetTexture(normTex)
					TotemBar[i].bg.multiplier = 0.2
					
					TotemBar[i].border = CreateFrame("Frame", nil, TotemBar[i])
					TotemBar[i].border:SetPoint("TOPLEFT", TotemBar[i], "TOPLEFT", T.Scale(-2), T.Scale(2))
					TotemBar[i].border:SetPoint("BOTTOMRIGHT", TotemBar[i], "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
					TotemBar[i].border:SetFrameStrata("BACKGROUND")
					T.SetTemplate(TotemBar[i].border)
					TotemBar[i].border:SetBackdropColor( 0,0,0,1 )
					T.CreateShadow(TotemBar[i].border)
				end
				self.TotemBar = TotemBar
			end
		end	
			-- script for pvp status and low mana
			self:SetScript("OnEnter", function(self)
				if self.EclipseBar and self.EclipseBar:IsShown() then 
					self.EclipseBar.Text:Hide()
				end
				FlashInfo.ManaLevel:Hide() 
				status:Show()
				UnitFrame_OnEnter(self) 
			end)
			self:SetScript("OnLeave", function(self) 
				if self.EclipseBar and self.EclipseBar:IsShown() then 
					self.EclipseBar.Text:Show()
				end
				FlashInfo.ManaLevel:Show() 
				status:Hide()
				UnitFrame_OnLeave(self) 
			end)
		end
		
		if (unit == "target") then			
			-- Unit name on target
			local Name = health:CreateFontString(nil, "OVERLAY")
			Name:Point("LEFT", panel, "LEFT", 4, 0)
			Name:SetJustifyH("LEFT")
			Name:SetFont(pixelfont, 8, "OUTLINEMONOCHROME")

			self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong] [Tukui:diffcolor][level] [shortclassification]')
			self.Name = Name
			
			-- combobar edit by jasje
        if C["combopointbar"].enable == true then
			local CPoints = {}
			CPoints.unit = PlayerFrame.unit
			for i = 1, 5 do
				CPoints[i] = CreateFrame('StatusBar', "ComboPoint"..i, self)
				CPoints[i]:SetHeight(13)
				CPoints[i]:SetWidth(230/ 5)
				CPoints[i]:SetStatusBarTexture(C["media"].normTex)
				CPoints[i]:GetStatusBarTexture():SetHorizTile(false)
				CPoints[i]:SetFrameLevel(20)
				if i == 1 then
					CPoints[i]:SetPoint("BOTTOMLEFT", TukuiPlayer, "TOPLEFT", 0, 6)
				else
					CPoints[i]:SetPoint("LEFT", CPoints[i-1], "RIGHT", T.Scale(5), 0)
				end
					
				local border = CreateFrame("Frame", "ComboPoint"..i.."Border", CPoints[i])
				T.CreatePanel(border,1,1, "CENTER", panel, "CENTER" ,0,0)
				border:SetPoint("TOPLEFT", T.Scale(-2), T.Scale(2))
				border:SetPoint("BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
				border:SetBackdropColor(0,0,0)
				border:SetFrameStrata("MEDIUM")
				border:SetFrameLevel(19)
			end
			
			CPoints[1]:SetStatusBarColor(225, 0, 0)    -- red
			CPoints[2]:SetStatusBarColor(225, 0, 0)   -- red
			CPoints[3]:SetStatusBarColor(225, 225, 0)   -- yellow
			CPoints[4]:SetStatusBarColor(225, 225, 0)   -- yellow
			CPoints[5]:SetStatusBarColor(0, 225, 0)   -- green
			
			self.CPoints = CPoints
		end
    end

		if (unit == "target" and C["unitframes"].targetauras) or (unit == "player" and C["unitframes"].playerauras) then
			local buffs = CreateFrame("Frame", nil, self)
			local debuffs = CreateFrame("Frame", nil, self)
			
			if (T.myclass == "SHAMAN" or T.myclass == "DEATHKNIGHT" or T.myclass == "PALADIN" or T.myclass == "WARLOCK") and (C["unitframes"].playerauras) and (unit == "player") then
				buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 38)
			else
				buffs:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 30)
			end
			
			buffs:SetHeight(26)
			buffs:SetWidth(252)
			buffs.size = 26
			buffs.num = 9
				
			debuffs:SetHeight(26)
			debuffs:SetWidth(252)
			debuffs:SetPoint("BOTTOMLEFT", buffs, "TOPLEFT", 2, 2)
			debuffs.size = 26
			debuffs.num = 9
						
			buffs.spacing = 2.5
			buffs.initialAnchor = 'TOPLEFT'
			buffs.PostCreateIcon = T.PostCreateAura
			buffs.PostUpdateIcon = T.PostUpdateAura
			self.Buffs = buffs	
						
			debuffs.spacing = 2
			debuffs.initialAnchor = 'TOPRIGHT'
			debuffs["growth-y"] = "UP"
			debuffs["growth-x"] = "LEFT"
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			
			-- an option to show only our debuffs on target
			if unit == "target" then
				debuffs.onlyShowPlayer = C.unitframes.onlyselfdebuffs
			end
			
			self.Debuffs = debuffs
		end
		
		if C["unitframes"].unitcastbar then
			-- castbar of player and target
			local castbar = CreateFrame("StatusBar", self:GetName().."_Castbar", self)
			castbar:SetStatusBarTexture(normTex)
			castbar:SetFrameLevel(6)
			T.CreateShadow(castbar)
			if C["unitframes"].trikz then
				if unit == "player" then
					castbar:SetPoint("BOTTOM", InvTukuiActionBarBackground, "CENTER", 14,38)
					castbar:SetHeight(T.Scale(22))
					castbar:SetWidth(T.Scale(344))
				elseif unit == "target" then
					castbar:SetPoint("CENTER", UIParent,"CENTER", 0, 250)
					castbar:SetHeight(T.Scale(20))
					castbar:SetWidth(T.Scale(250))
				end
			else
				if unit == "player" then
					castbar:SetPoint("BOTTOM", InvTukuiActionBarBackground, "CENTER", 0,240)
					castbar:SetHeight(T.Scale(20))
					castbar:SetWidth(T.Scale(230))
				elseif unit == "target" then
					castbar:SetPoint("BOTTOM", TukuiTarget, "TOP", 0, 70)
					castbar:SetHeight(T.Scale(18))
					castbar:SetWidth(T.Scale(250))
				end
			end	
			
			castbar.bg = CreateFrame("Frame", nil, castbar)
			T.SetTemplate(castbar.bg)
			T.CreateShadow(castbar.bg)
			castbar.bg:SetPoint("TOPLEFT", T.Scale(-2), T.Scale(2))
			castbar.bg:SetPoint("BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
			castbar.bg:SetFrameLevel(5)
			
			castbar.CustomTimeText = T.CustomCastTimeText
			castbar.CustomDelayText = T.CustomCastDelayText
            castbar.PostCastStart = T.PostCastStart
            castbar.PostChannelStart = T.PostCastStart
			
			castbar.time = T.SetFontString(castbar, pixelfont, 8, "MONOCHROMEOUTLINE")
			castbar.time:SetPoint("RIGHT", castbar, "RIGHT", T.Scale(-4), T.Scale(1))
			castbar.time:SetTextColor(0.84, 0.75, 0.65)
			castbar.time:SetJustifyH("RIGHT")

			castbar.Text = T.SetFontString(castbar, pixelfont, 8, "MONOCHROMEOUTLINE")
			castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 1)
			castbar.Text:SetTextColor(0.84, 0.75, 0.65)
			
			if C["unitframes"].cbicons == true then
				castbar.button = CreateFrame("Frame", nil, castbar)

				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, T.Scale(2), T.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, T.Scale(-2), T.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				
			if unit == "target" or unit == "player" then
				castbar.button = CreateFrame("Frame", nil, castbar)
				
			if C["unitframes"].trikz then
			    if unit == "player" then -- sloppy but it works
				    castbar.button:SetPoint("LEFT", -30, T.Scale(0))
				    castbar.button:SetHeight(T.Scale(25))
				    castbar.button:SetWidth(T.Scale(25))
				    T.SetTemplate(castbar.button)
				    T.CreateShadow(castbar.button)
			elseif unit == "target" then
				    castbar.button:SetPoint("CENTER", castbar, 0, T.Scale(40))
				    castbar.button:SetHeight(T.Scale(40))
				    castbar.button:SetWidth(T.Scale(40))
				    T.SetTemplate(castbar.button)
				    T.CreateShadow(castbar.button)
              end	
		else		
			if unit == "player" then
				castbar.button:SetPoint("LEFT", -52, T.Scale(11.2))
				castbar.button:SetHeight(T.Scale(46))
				castbar.button:SetWidth(T.Scale(46))
				T.SetTemplate(castbar.button)
				T.CreateShadow(castbar.button)
			elseif unit == "target" then
				castbar.button:SetPoint("CENTER", 0, T.Scale(28))
				castbar.button:SetHeight(T.Scale(26))
				castbar.button:SetWidth(T.Scale(26))
				T.SetTemplate(castbar.button)
				T.CreateShadow(castbar.button)
			end	
		end	
				castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
				castbar.icon:SetPoint("TOPLEFT", castbar.button, T.Scale(2), T.Scale(-2))
				castbar.icon:SetPoint("BOTTOMRIGHT", castbar.button, T.Scale(-2), T.Scale(2))
				castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)
				
				castbar.IconBackdrop = CreateFrame("Frame", nil, self)
				castbar.IconBackdrop:SetPoint("TOPLEFT", castbar.button, "TOPLEFT", T.Scale(-4), T.Scale(4))
				castbar.IconBackdrop:SetPoint("BOTTOMRIGHT", castbar.button, "BOTTOMRIGHT", T.Scale(4), T.Scale(-4))
				castbar.IconBackdrop:SetParent(castbar)
				castbar.IconBackdrop:SetBackdrop({
					edgeFile = glowTex, edgeSize = 4,
					insets = {left = 3, right = 3, top = 3, bottom = 3}
				})
				castbar.IconBackdrop:SetBackdropColor(0, 0, 0, 0)
				castbar.IconBackdrop:SetBackdropBorderColor(0, 0, 0, 0.7)
		end		
	end
			
			-- cast bar latency on player
			if unit == "player" and C["unitframes"].cblatency == true then
				castbar.safezone = castbar:CreateTexture(nil, "ARTWORK")
				castbar.safezone:SetTexture(normTex)
				castbar.safezone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
				castbar.SafeZone = castbar.safezone
			end
					
			self.Castbar = castbar
			self.Castbar.Time = castbar.time
			self.Castbar.Icon = castbar.icon
		end
		
		-- add combat feedback support
		if C["unitframes"].combatfeedback == true then
			local CombatFeedbackText 
			if T.lowversion then
				CombatFeedbackText = T.SetFontString(health, C.media.pixelfont, 8, "MONOCHROMEOUTLINE")
			else
				CombatFeedbackText = T.SetFontString(health, C.media.pixelfont, 8, "MONOCHROMEOUTLINE")
			end
			CombatFeedbackText:SetPoint("CENTER", 0, 1)
			CombatFeedbackText.colors = {
				DAMAGE = {0.69, 0.31, 0.31},
				CRUSHING = {0.69, 0.31, 0.31},
				CRITICAL = {0.69, 0.31, 0.31},
				GLANCING = {0.69, 0.31, 0.31},
				STANDARD = {0.84, 0.75, 0.65},
				IMMUNE = {0.84, 0.75, 0.65},
				ABSORB = {0.84, 0.75, 0.65},
				BLOCK = {0.84, 0.75, 0.65},
				RESIST = {0.84, 0.75, 0.65},
				MISS = {0.84, 0.75, 0.65},
				HEAL = {0.33, 0.59, 0.33},
				CRITHEAL = {0.33, 0.59, 0.33},
				ENERGIZE = {0.31, 0.45, 0.63},
				CRITENERGIZE = {0.31, 0.45, 0.63},
			}
			self.CombatFeedbackText = CombatFeedbackText
		end
		
		if C["unitframes"].healcomm then
			local mhpb = CreateFrame('StatusBar', nil, self.Health)
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			if T.lowversion then
				mhpb:SetWidth(186)
			else
				mhpb:SetWidth(250)
			end
			mhpb:SetStatusBarTexture(normTex)
			mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
			mhpb:SetMinMaxValues(0,1)

			local ohpb = CreateFrame('StatusBar', nil, self.Health)
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:SetWidth(250)
			ohpb:SetStatusBarTexture(normTex)
			ohpb:SetStatusBarColor(0, 1, 0, 0.25)

			self.HealPrediction = {
				myBar = mhpb,
				otherBar = ohpb,
				maxOverflow = 1,
			}
		end
		
		-- player aggro
		if C["unitframes"].playeraggro == true then
			table.insert(self.__elements, T.UpdateThreat)
			self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
			self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
		end
	end
	
	------------------------------------------------------------------------
	--	Target of Target unit layout
	------------------------------------------------------------------------
	
	if (unit == "targettarget") then
		-- create panel if higher version
		local panel = CreateFrame("Frame", nil, self)
		if not T.lowversion then
			panel:CreatePanel("Default", 129, 17, "BOTTOM", self, "BOTTOM", 0, T.Scale(0))
			panel:SetFrameLevel(2)
			panel:SetFrameStrata("MEDIUM")
			panel:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			self.panel = panel
			self.panel:Hide()
		end
		
		-- border 
	    local Healthbg = CreateFrame("Frame", nil, self)
	    Healthbg:SetPoint("TOPLEFT", self, "TOPLEFT", T.Scale(-2), T.Scale(2))
	    Healthbg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
	    T.SetTemplate(Healthbg)
		T.CreateShadow(Healthbg)
	    Healthbg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
	    Healthbg:SetFrameLevel(2)
	    self.Healthbg = Healthbg
		
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(20)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true			
		end
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetHeight(T.Scale(5))
		power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -6)
		power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -6)
		power:SetStatusBarTexture(normTex)
		
		-- power border 
		local powerborder = CreateFrame("Frame", nil, self)
		T.CreatePanel(powerborder, 1, 1, "CENTER", health, "CENTER", 0, 0)
		powerborder:ClearAllPoints()
		powerborder:SetPoint("TOPLEFT", power, T.Scale(-2), T.Scale(2))
		powerborder:SetPoint("BOTTOMRIGHT", power, T.Scale(2), T.Scale(-2))
		powerborder:SetFrameStrata("MEDIUM")
		T.CreateShadow(powerborder)
		
		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		self.Power = power
		self.Power.bg = powerBG
		
		power.frequentUpdates = true
		power.colorDisconnected = true

		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			power.colorTapping = true
			power.colorClass = true
			powerBG.multiplier = 0.1				
		else
			power.colorPower = true
		end
		
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetFont(pixelfont, 8, "OUTLINEMONOCHROME")
		Name:SetJustifyH("CENTER")

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium]')
		self.Name = Name
		
		if C["unitframes"].totdebuffs == true and T.lowversion ~= true then
			local debuffs = CreateFrame("Frame", nil, health)
			debuffs:SetHeight(20)
			debuffs:SetWidth(127)
			debuffs.size = 20
			debuffs.spacing = 2
			debuffs.num = 6

			debuffs:SetPoint("TOPLEFT", health, "TOPLEFT", -0.5, 24)
			debuffs.initialAnchor = "TOPLEFT"
			debuffs["growth-y"] = "UP"
			debuffs.PostCreateIcon = T.PostCreateAura
			debuffs.PostUpdateIcon = T.PostUpdateAura
			self.Debuffs = debuffs
		end
	end
	
	------------------------------------------------------------------------
	--	Pet unit layout
	------------------------------------------------------------------------
	
	if (unit == "pet") then
		-- create panel if higher version
		local panel = CreateFrame("Frame", nil, self)
		if not T.lowversion then
			panel:CreatePanel("Default", 129, 17, "BOTTOM", self, "BOTTOM", 0, 0)
			panel:SetFrameLevel(2)
			panel:SetFrameStrata("MEDIUM")
			panel:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
			self.panel = panel
			self.panel:Hide()
		end
		
		-- border 
	    local Healthbg = CreateFrame("Frame", nil, self)
	    Healthbg:SetPoint("TOPLEFT", self, "TOPLEFT", T.Scale(-2), T.Scale(2))
	    Healthbg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", T.Scale(2), T.Scale(-4))
	    T.SetTemplate(Healthbg)
		T.CreateShadow(Healthbg)
	    Healthbg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
	    Healthbg:SetFrameLevel(2)
	    self.Healthbg = Healthbg
		
		-- health bar
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(T.Scale(22))
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		
		health.PostUpdate = T.PostUpdatePetColor
				
		self.Health = health
		self.Health.bg = healthBG
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true	
			health.colorClass = true
			health.colorReaction = true	
			if T.myclass == "HUNTER" then
				health.colorHappiness = true
			end
		end
		
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:SetHeight(T.Scale(5))
		power:Point("TOPLEFT", health, "BOTTOMLEFT", 0, -6)
		power:Point("TOPRIGHT", health, "BOTTOMRIGHT", 0, -6)
		power:SetStatusBarTexture(normTex)
		
		-- power border 
		local powerborder = CreateFrame("Frame", nil, self)
		T.CreatePanel(powerborder, 1, 1, "CENTER", health, "CENTER", 0, 0)
		powerborder:ClearAllPoints()
		powerborder:SetPoint("TOPLEFT", power, T.Scale(-2), T.Scale(2))
		powerborder:SetPoint("BOTTOMRIGHT", power, T.Scale(2), T.Scale(-2))
		powerborder:SetFrameStrata("MEDIUM")
		T.CreateShadow(powerborder)
		
		power.frequentUpdates = true
		power.colorPower = true
		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end

		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
				
		self.Power = power
		self.Power.bg = powerBG
				
		-- Unit name
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetFont(pixelfont, 8, "OUTLINEMONOCHROME")
		Name:SetJustifyH("CENTER")

		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium] [Tukui:diffcolor][level]')
		self.Name = Name
		
		if (C["unitframes"].unitcastbar == true) then
			local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
			castbar:SetStatusBarTexture(normTex)
			self.Castbar = castbar
			
			if not T.lowversion then
				castbar.bg = castbar:CreateTexture(nil, "BORDER")
				castbar.bg:SetAllPoints(castbar)
				castbar.bg:SetTexture(normTex)
				castbar.bg:SetVertexColor(0.15, 0.15, 0.15)
				castbar:SetFrameLevel(3)
				castbar:SetAlpha(0.8)
				castbar:SetPoint("TOPLEFT", powerborder, T.Scale(2), T.Scale(-2))
				castbar:SetPoint("BOTTOMRIGHT", powerborder, T.Scale(-2), T.Scale(2))
				
				castbar.CustomTimeText = T.CustomCastTimeText
				castbar.CustomDelayText = T.CustomCastDelayText
				castbar.PostCastStart = T.CheckCast
				castbar.PostChannelStart = T.CheckChannel

				castbar.time = T.SetFontString(castbar, pixelfont, 8, "MONOCHROMEOUTLINE")
				castbar.time:SetPoint("RIGHT", power, "RIGHT", T.Scale(-0), T.Scale(-0))
				castbar.time:SetTextColor(0.84, 0.75, 0.65)
				castbar.time:SetJustifyH("RIGHT")

				castbar.Text = T.SetFontString(castbar, pixelfont, 8, "MONOCHROMEOUTLINE")
				castbar.Text:Point("LEFT", power, "LEFT", 4, 0)
				castbar.Text:SetTextColor(0.84, 0.75, 0.65)
				
				self.Castbar.Time = castbar.time
			end
		end
		
		-- update pet name, this should fix "UNKNOWN" pet names on pet unit, health and bar color sometime being "grayish".
		self:RegisterEvent("UNIT_PET", T.updateAllElements)
	end


	------------------------------------------------------------------------
	--	Focus unit layout
	------------------------------------------------------------------------
	
	if (unit == "focus") then
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(12)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		
		-- border 
	    local Healthbg = CreateFrame("Frame", nil, self)
	    Healthbg:SetPoint("TOPLEFT", self, "TOPLEFT", T.Scale(-2), T.Scale(2))
	    Healthbg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
	    T.SetTemplate(Healthbg)
		T.CreateShadow(Healthbg)
	    Healthbg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
	    Healthbg:SetFrameLevel(2)
	    self.Healthbg = Healthbg

		health.frequentUpdates = true
		health.colorDisconnected = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		health.colorClass = true
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)

		health.value = T.SetFontString(health, pixelfont,8, "MONOCHROMEOUTLINE")
		health.value:Point("RIGHT", -2, 0)
		health.PostUpdate = T.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(pixelfont, 8, "OUTLINEMONOCHROME")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong]')
		self.Name = Name

		-- create debuff for arena units
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight(18)
		debuffs:SetWidth(200)
		debuffs:Point('RIGHT', self, 'LEFT', -4, 0)
		debuffs.size = 18
		debuffs.num = 1
		debuffs.spacing = 2
		debuffs.initialAnchor = 'RIGHT'
		debuffs["growth-x"] = "LEFT"
		debuffs.PostCreateIcon = T.PostCreateAura
		debuffs.PostUpdateIcon = T.PostUpdateAura
		self.Debuffs = debuffs
		
		local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
		castbar:SetPoint("LEFT", -0, 0)
		castbar:SetPoint("RIGHT", 0, 0)
		castbar:SetPoint("BOTTOM", 0, -16)
		
		castbar:SetHeight(8)
		castbar:SetStatusBarTexture(normTex)
		castbar:SetFrameLevel(6)
		
		castbar.bg = CreateFrame("Frame", nil, castbar)
		T.SetTemplate(castbar.bg)
		T.CreateShadow(castbar.bg)
		castbar.bg:SetTemplate("Hydra")
		castbar.bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		castbar.bg:Point("TOPLEFT", -2, 2)
		castbar.bg:Point("BOTTOMRIGHT", 2, -2)
		castbar.bg:SetFrameLevel(5)
		
		castbar.time = T.SetFontString(castbar, pixelfont, 8, "OUTLINEMONOCHROME")
		castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
		castbar.time:SetTextColor(0.84, 0.75, 0.65)
		castbar.time:SetJustifyH("RIGHT")
		castbar.CustomTimeText = T.CustomCastTimeText

		castbar.Text = T.SetFontString(castbar, pixelfont, 8, "OUTLINEMONOCHROME")
		castbar.Text:SetPoint("LEFT", castbar, "LEFT", 4, 0)
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		
		castbar.CustomDelayText = T.CustomCastDelayText
		castbar.PostCastStart = T.CheckCast
		castbar.PostChannelStart = T.CheckChannel

		self.Castbar = castbar
		self.Castbar.Time = castbar.time
	end
	
	------------------------------------------------------------------------
	--	Focus target unit layout
	------------------------------------------------------------------------

	if (unit == "focustarget") then
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(12)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		
		-- border 
	    local Healthbg = CreateFrame("Frame", nil, self)
    	Healthbg:SetPoint("TOPLEFT", self, "TOPLEFT", T.Scale(-2), T.Scale(2))
    	Healthbg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
    	T.SetTemplate(Healthbg)
		T.CreateShadow(Healthbg)
	    Healthbg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
    	Healthbg:SetFrameLevel(2)
    	self.Healthbg = Healthbg

		health.frequentUpdates = true
		health.colorDisconnected = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		health.colorClass = true
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)

		health.value = T.SetFontString(health, pixelfont, 8, "OUTLINEMONOCHROME")
		health.value:Point("RIGHT", -2, 0)
		health.PostUpdate = T.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end

		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(pixelfont, 8, "OUTLINEMONOCRHOME")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namelong]')
		self.Name = Name

		-- create debuff for arena units
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight(18)
		debuffs:SetWidth(200)
		debuffs:Point('LEFT', self, 'RIGHT', 4, 0)
		debuffs.size = 18
		debuffs.num = 1
		debuffs.spacing = 2
		debuffs.initialAnchor = 'LEFT'
		debuffs["growth-x"] = "RIGHT"
		debuffs.PostCreateIcon = T.PostCreateAura
		debuffs.PostUpdateIcon = T.PostUpdateAura
		self.Debuffs = debuffs
		
		local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
		castbar:SetPoint("LEFT", -0, 0)
		castbar:SetPoint("RIGHT", 0, 0)
		castbar:SetPoint("BOTTOM", 0, -16)
		
		castbar:SetHeight(8)
		castbar:SetStatusBarTexture(normTex)
		castbar:SetFrameLevel(6)
		
		castbar.bg = CreateFrame("Frame", nil, castbar)
		castbar.bg:SetTemplate("Hydra")
		castbar.bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		castbar.bg:Point("TOPLEFT", -2, 2)
		castbar.bg:Point("BOTTOMRIGHT", 2, -2)
		castbar.bg:SetFrameLevel(5)
		
		castbar.time = T.SetFontString(castbar, pixelfont, 8, "OUTLINEMONOCHROME")
		castbar.time:Point("RIGHT", castbar, "RIGHT", -4, 0)
		castbar.time:SetTextColor(0.84, 0.75, 0.65)
		castbar.time:SetJustifyH("RIGHT")
		castbar.CustomTimeText = T.CustomCastTimeText

		castbar.Text = T.SetFontString(castbar, pixelfont, 8, "OUTLINEMONOCHROME")
		castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		
		castbar.CustomDelayText = T.CustomCastDelayText
		castbar.PostCastStart = T.CheckCast
		castbar.PostChannelStart = T.CheckChannel

		self.Castbar = castbar
		self.Castbar.Time = castbar.time
	end

	------------------------------------------------------------------------
	--	Arena or boss units layout (both mirror'd)
	------------------------------------------------------------------------
	
	if (unit and unit:find("arena%d") and C["arena"].unitframes == true) or (unit and unit:find("boss%d") and C["unitframes"].showboss == true) then
		-- Right-click focus on arena or boss units
		self:SetAttribute("type2", "focus")
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(30)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		
		-- border 
	    local Healthbg = CreateFrame("Frame", nil, self)
	    Healthbg:SetPoint("TOPLEFT", self, "TOPLEFT", T.Scale(-2), T.Scale(2))
	    Healthbg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
	    T.SetTemplate(Healthbg)
		T.CreateShadow(Healthbg)
	    Healthbg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
	    Healthbg:SetFrameLevel(2)
	    self.Healthbg = Healthbg

		health.frequentUpdates = true
		health.colorDisconnected = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		health.colorClass = true
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)

		health.value = T.SetFontString(health, pixelfont, 8, "OUTLINEMONOCHROME")
		health.value:Point("RIGHT", -2, 0)
		health.PostUpdate = T.PostUpdateHealth
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)		
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
	
		-- power
		local power = CreateFrame('StatusBar', nil, self)
		power:Height(6)
		power:Point("TOPLEFT", health, "BOTTOMLEFT", 0, -6)
		power:Point("TOPRIGHT", health, "BOTTOMRIGHT", 0, -6)
		power:SetStatusBarTexture(normTex)
		
		-- power border 
		local powerborder = CreateFrame("Frame", nil, self)
		T.CreatePanel(powerborder, 1, 1, "CENTER", health, "CENTER", 0, 0)
		powerborder:ClearAllPoints()
		powerborder:SetPoint("TOPLEFT", power, T.Scale(-2), T.Scale(2))
		powerborder:SetPoint("BOTTOMRIGHT", power, T.Scale(2), T.Scale(-2))
		powerborder:SetFrameStrata("MEDIUM")
		T.CreateShadow(powerborder)
		
		power.frequentUpdates = true
		power.colorPower = true
		if C["unitframes"].showsmooth == true then
			power.Smooth = true
		end

		local powerBG = power:CreateTexture(nil, 'BORDER')
		powerBG:SetAllPoints(power)
		powerBG:SetTexture(normTex)
		powerBG.multiplier = 0.3
		
		power.value = T.SetFontString(health, pixelfont, 8, "OUTLINEMONOCHROME")
		power.value:Point("LEFT", 2, 0)
		power.PreUpdate = T.PreUpdatePower
		power.PostUpdate = T.PostUpdatePower
				
		self.Power = power
		self.Power.bg = powerBG
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(pixelfont, 8, "OUTLINEMONOCHROME")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		Name.frequentUpdates = 0.2
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:namemedium]')
		self.Name = Name
		
		if (unit and unit:find("boss%d")) then
			-- alt power bar
			local AltPowerBar = CreateFrame("StatusBar", nil, self.Health)
			AltPowerBar:SetFrameLevel(self.Health:GetFrameLevel() + 1)
			AltPowerBar:Height(4)
			AltPowerBar:SetStatusBarTexture(C.media.normTex)
			AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
			AltPowerBar:SetStatusBarColor(1, 0, 0)

			AltPowerBar:SetPoint("LEFT")
			AltPowerBar:SetPoint("RIGHT")
			AltPowerBar:SetPoint("TOP", self.Health, "TOP")
			
			AltPowerBar:SetBackdrop({
			  bgFile = C["media"].blank, 
			  edgeFile = C["media"].blank, 
			  tile = false, tileSize = 0, edgeSize = T.Scale(1), 
			  insets = { left = 0, right = 0, top = 0, bottom = T.Scale(-1)}
			})
			AltPowerBar:SetBackdropColor(0, 0, 0)

			self.AltPowerBar = AltPowerBar
			
			-- create buff at left of unit if they are boss units
			local buffs = CreateFrame("Frame", nil, self)
			buffs:SetHeight(34)
			buffs:SetWidth(252)
			buffs:Point("LEFT", self, "RIGHT", T.Scale(4), 0)
			buffs.size = 34
			buffs.num = 2
			buffs.spacing = 2
			buffs.initialAnchor = 'LEFT'
			buffs["growth-x"] = "RIGHT"
			buffs.PostCreateIcon = T.PostCreateAura
			buffs.PostUpdateIcon = T.PostUpdateAura
			self.Buffs = buffs
			
			-- because it appear that sometime elements are not correct.
			self:HookScript("OnShow", T.updateAllElements)
		end

		-- create debuff for arena units
		local debuffs = CreateFrame("Frame", nil, self)
		debuffs:SetHeight(34)
		debuffs:SetWidth(200)
		debuffs:SetPoint('LEFT', self, 'RIGHT', T.Scale(4), 0)
		debuffs.size = 34
		debuffs.num = 2
		debuffs.spacing = 2
		debuffs.initialAnchor = 'LEFT'
		debuffs["growth-x"] = "RIGHT"
		debuffs.PostCreateIcon = T.PostCreateAura
		debuffs.PostUpdateIcon = T.PostUpdateAura
		self.Debuffs = debuffs
				
		-- trinket feature via trinket plugin
		if (C.arena.unitframes) and (unit and unit:find('arena%d')) then
			local Trinketbg = CreateFrame("Frame", nil, self)
			Trinketbg:SetHeight(26)
			Trinketbg:SetWidth(26)
			Trinketbg:SetPoint("RIGHT", self, "LEFT", -6, 0)				
			Trinketbg:SetTemplate("Default")
			Trinketbg:SetFrameLevel(0)
			self.Trinketbg = Trinketbg
			
			local Trinket = CreateFrame("Frame", nil, Trinketbg)
			Trinket:SetAllPoints(Trinketbg)
			Trinket:SetPoint("TOPLEFT", Trinketbg, T.Scale(2), T.Scale(-2))
			Trinket:SetPoint("BOTTOMRIGHT", Trinketbg, T.Scale(-2), T.Scale(2))
			Trinket:SetFrameLevel(1)
			Trinket.trinketUseAnnounce = true
			self.Trinket = Trinket
		end
		
		-- boss & arena frames cast bar!
		local castbar = CreateFrame("StatusBar", self:GetName().."CastBar", self)
		castbar:SetPoint("LEFT", 21, 0)
		castbar:SetPoint("RIGHT", 0, 0)
		castbar:SetPoint("BOTTOM", 0, -35)
		
		castbar:SetHeight(15)
		castbar:SetStatusBarTexture(normTex)
		castbar:SetFrameLevel(6)
		
		castbar.bg = CreateFrame("Frame", nil, castbar)
		T.SetTemplate(castbar.bg)
		T.CreateShadow(castbar.bg)
		castbar.bg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		castbar.bg:SetPoint("TOPLEFT", T.Scale(-2), T.Scale(2))
		castbar.bg:SetPoint("BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
		castbar.bg:SetFrameLevel(5)
		
		castbar.time = T.SetFontString(castbar, pixelfont, 8, "OUTLINEMONOCHROME")
		castbar.time:SetPoint("RIGHT", castbar, "RIGHT", T.Scale(-4), 0)
		castbar.time:SetTextColor(0.84, 0.75, 0.65)
		castbar.time:SetJustifyH("RIGHT")
		castbar.CustomTimeText = T.CustomCastTimeText

		castbar.Text = T.SetFontString(castbar, pixelfont, 8, "OUTLINEMONOCHROME")
		castbar.Text:Point("LEFT", castbar, "LEFT", 4, 0)
		castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		
		castbar.CustomDelayText = T.CustomCastDelayText
		castbar.PostCastStart = T.CheckCast
		castbar.PostChannelStart = T.CheckChannel
								
		castbar.button = CreateFrame("Frame", nil, castbar)
		castbar.button:Height(castbar:GetHeight()+4)
		castbar.button:Width(castbar:GetHeight()+4)
		castbar.button:Point("RIGHT", castbar, "LEFT",-4, 0)
		T.SetTemplate(castbar.button)
		T.CreateShadow(castbar.button)
		castbar.button:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
		castbar.icon = castbar.button:CreateTexture(nil, "ARTWORK")
		castbar.icon:Point("TOPLEFT", castbar.button, T.Scale(2), T.Scale(-2))
		castbar.icon:Point("BOTTOMRIGHT", castbar.button, -2, 2)
		castbar.icon:SetTexCoord(0.08, 0.92, 0.08, .92)

		self.Castbar = castbar
		self.Castbar.Time = castbar.time
		self.Castbar.Icon = castbar.icon
	end

	------------------------------------------------------------------------
	--	Main tanks and Main Assists layout (both mirror'd)
	------------------------------------------------------------------------
	
	if(self:GetParent():GetName():match"TukuiMainTank" or self:GetParent():GetName():match"TukuiMainAssist") then
		-- Right-click focus on maintank or mainassist units
		self:SetAttribute("type2", "focus")
		
		-- health 
		local health = CreateFrame('StatusBar', nil, self)
		health:Height(20)
		health:SetPoint("TOPLEFT")
		health:SetPoint("TOPRIGHT")
		health:SetStatusBarTexture(normTex)
		
		-- border 
	    local Healthbg = CreateFrame("Frame", nil, self)
    	Healthbg:SetPoint("TOPLEFT", self, "TOPLEFT", T.Scale(-2), T.Scale(2))
    	Healthbg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
    	T.SetTemplate(Healthbg)
		T.CreateShadow(Healthbg)
	    Healthbg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
    	Healthbg:SetFrameLevel(2)
    	self.Healthbg = Healthbg
		
		local healthBG = health:CreateTexture(nil, 'BORDER')
		healthBG:SetAllPoints()
		healthBG:SetTexture(.1, .1, .1)
				
		self.Health = health
		self.Health.bg = healthBG
		
		health.frequentUpdates = true
		if C["unitframes"].showsmooth == true then
			health.Smooth = true
		end
		
		if C["unitframes"].unicolor == true then
			health.colorDisconnected = false
			health.colorClass = false
			health:SetStatusBarColor(.3, .3, .3, 1)
			healthBG:SetVertexColor(.1, .1, .1, 1)
		else
			health.colorDisconnected = true
			health.colorClass = true
			health.colorReaction = true	
		end
		
		-- names
		local Name = health:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("CENTER", health, "CENTER", 0, 0)
		Name:SetJustifyH("CENTER")
		Name:SetFont(pixelfont, 8, "OUTLINEMONOCHROME")
		Name:SetShadowColor(0, 0, 0)
		Name:SetShadowOffset(1.25, -1.25)
		
		self:Tag(Name, '[Tukui:getnamecolor][Tukui:nameshort]')
		self.Name = Name
	end
	
	return self
end

------------------------------------------------------------------------
--	Default position of Tukui unitframes
------------------------------------------------------------------------

oUF:RegisterStyle('Tukui', Shared)

-- player
local player = oUF:Spawn('player', "TukuiPlayer")
player:SetPoint("BOTTOMLEFT", InvTukuiActionBarBackground, "TOPLEFT", 2, 61)
	player:Size(250, 20)


-- focus
local focus = oUF:Spawn('focus', "TukuiFocus")
focus:SetPoint("BOTTOMLEFT", TukuiPlayer, "TOPLEFT", 0, -58)
    focus:Size(185, 12)

-- target
local target = oUF:Spawn('target', "TukuiTarget")
target:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "TOPRIGHT", -2 ,61)
	target:Size(250, 20)

-- tot
local tot = oUF:Spawn('targettarget', "TukuiTargetTarget")
tot:SetPoint("BOTTOM", InvTukuiActionBarBackground, "TOP", 0,61)
	tot:Size(130, 20)

-- pet
local pet = oUF:Spawn('pet', "oUF_Tukz_pet")
pet:SetPoint("BOTTOM", InvTukuiActionBarBackground, "TOP", 0,105)
	pet:SetSize(T.Scale(130), T.Scale(20))

-- focus target
if C.unitframes.showfocustarget then	
local focustarget = oUF:Spawn("focustarget", "TukuiFocusTarget")
focustarget:SetPoint("BOTTOMRIGHT", TukuiTarget, "TOPRIGHT", 0, -58)
    focustarget:Size(185, 12)
end

if C.arena.unitframes then
	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "TukuiArena"..i)
		if i == 1 then
			arena[i]:SetPoint("RIGHT", UIParent, "RIGHT", -220, -209)
		else
			arena[i]:SetPoint("BOTTOM", arena[i-1], "TOP", 0, 45)
		end
		arena[i]:SetSize(T.Scale(200), T.Scale(30))
	end
end

if C["unitframes"].showboss then
	for i = 1,MAX_BOSS_FRAMES do
		local t_boss = _G["Boss"..i.."TargetFrame"]
		t_boss:UnregisterAllEvents()
		t_boss.Show = T.dummy
		t_boss:Hide()
		_G["Boss"..i.."TargetFrame".."HealthBar"]:UnregisterAllEvents()
		_G["Boss"..i.."TargetFrame".."ManaBar"]:UnregisterAllEvents()
	end

	local boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		boss[i] = oUF:Spawn("boss"..i, "TukuiBoss"..i)
		if i == 1 then
			boss[i]:SetPoint("RIGHT", UIParent, "RIGHT", -220, -209)
		else
			boss[i]:SetPoint('BOTTOM', boss[i-1], 'TOP', 0, 45)             
		end
		boss[i]:SetSize(T.Scale(200), T.Scale(30))
	end
end

local assisttank_width = 100
local assisttank_height  = 20
if C["unitframes"].maintank == true then
	local tank = oUF:SpawnHeader('TukuiMainTank', nil, 'raid',
		'oUF-initialConfigFunction', ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(assisttank_width, assisttank_height),
		'showRaid', true,
		'groupFilter', 'MAINTANK',
		'yOffset', 7,
		'point' , 'BOTTOM',
		'template', 'oUF_TukuiMtt'
	)
	tank:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
end
 
if C["unitframes"].mainassist == true then
	local assist = oUF:SpawnHeader("TukuiMainAssist", nil, 'raid',
		'oUF-initialConfigFunction', ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(assisttank_width, assisttank_height),
		'showRaid', true,
		'groupFilter', 'MAINASSIST',
		'yOffset', 7,
		'point' , 'BOTTOM',
		'template', 'oUF_TukuiMtt'
	)
	if C["unitframes"].maintank == true then
		assist:SetPoint("TOPLEFT", TukuiMainTank, "BOTTOMLEFT", 2, -50)
	else
		assist:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end
end

-- this is just a fake party to hide Blizzard frame if no Tukui raid layout are loaded.
local party = oUF:SpawnHeader("oUF_noParty", nil, "party", "showParty", true)

------------------------------------------------------------------------
-- Right-Click on unit frames menu. 
-- Doing this to remove SET_FOCUS eveywhere.
-- SET_FOCUS work only on default unitframes.
-- Main Tank and Main Assist, use /maintank and /mainassist commands.
------------------------------------------------------------------------

do
	UnitPopupMenus["SELF"] = { "PVP_FLAG", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RAID_TARGET_ICON", "SELECT_ROLE", "CONVERT_TO_PARTY", "CONVERT_TO_RAID", "LEAVE", "CANCEL" };
	UnitPopupMenus["PET"] = { "PET_PAPERDOLL", "PET_RENAME", "PET_ABANDON", "PET_DISMISS", "CANCEL" };
	UnitPopupMenus["PARTY"] = { "MUTE", "UNMUTE", "PARTY_SILENCE", "PARTY_UNSILENCE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "PROMOTE", "PROMOTE_GUIDE", "LOOT_PROMOTE", "VOTE_TO_KICK", "UNINVITE", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["PLAYER"] = { "WHISPER", "INSPECT", "INVITE", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" }
	UnitPopupMenus["RAID_PLAYER"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "RAID_TARGET_ICON", "SELECT_ROLE", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "RAF_SUMMON", "RAF_GRANT_LEVEL", "CANCEL" };
	UnitPopupMenus["RAID"] = { "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "RAID_LEADER", "RAID_PROMOTE", "RAID_MAINTANK", "RAID_MAINASSIST", "RAID_TARGET_ICON", "LOOT_PROMOTE", "RAID_DEMOTE", "RAID_REMOVE", "PVP_REPORT_AFK", "CANCEL" };
	UnitPopupMenus["VEHICLE"] = { "RAID_TARGET_ICON", "VEHICLE_LEAVE", "CANCEL" }
	UnitPopupMenus["TARGET"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["ARENAENEMY"] = { "CANCEL" }
	UnitPopupMenus["FOCUS"] = { "RAID_TARGET_ICON", "CANCEL" }
	UnitPopupMenus["BOSS"] = { "RAID_TARGET_ICON", "CANCEL" }
end