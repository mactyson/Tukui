	local T, C, L = unpack(select(2, ...)) 
	------------------------------------------------------------------------------------
	-- Shaman Weapon Enchant reminder made by Fugg and edited by me
	------------------------------------------------------------------------------------
	if (T.myclass == "SHAMAN") and (unit == "player") and C.buffreminder.enable ~= true then return end

	local spid = 51730
	local EarthlivingWeapon = CreateFrame("Frame", _, UIParent)
	EarthlivingWeapon:CreatePanel("Default", 40, 40, "CENTER", UIParent, "CENTER", 35, 200)

	EarthlivingWeapon.icon = EarthlivingWeapon:CreateTexture(nil, "OVERLAY")
	EarthlivingWeapon.icon:SetTexture(select(3, GetSpellInfo(spid)))
	EarthlivingWeapon.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	EarthlivingWeapon.icon:SetPoint("CENTER")
	EarthlivingWeapon.icon:Size(36)

	local function EarthlivingWeaponCheck(self, event, unit, spell)
	local hasMainHandEnchant = GetWeaponEnchantInfo()
		if not hasMainHandEnchant and not UnitInVehicle("player") and InCombatLockdown() then
			self:Show()
		else
		    self:Hide()
		end
	end

	EarthlivingWeapon:RegisterEvent("UNIT_INVENTORY_CHANGED")
	EarthlivingWeapon:RegisterEvent("PLAYER_ENTERING_WORLD")
	EarthlivingWeapon:RegisterEvent("PLAYER_REGEN_ENABLED")
	EarthlivingWeapon:RegisterEvent("PLAYER_REGEN_DISABLED")
	EarthlivingWeapon:RegisterEvent("UNIT_ENTERING_VEHICLE")
	EarthlivingWeapon:RegisterEvent("UNIT_ENTERED_VEHICLE")
	EarthlivingWeapon:RegisterEvent("UNIT_EXITING_VEHICLE")
	EarthlivingWeapon:RegisterEvent("UNIT_EXITED_VEHICLE")
	
	EarthlivingWeapon:SetScript("OnEvent", EarthlivingWeaponCheck)