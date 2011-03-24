local T, C, L = unpack(select(2, ...)) 

C["interface"] = {                               -- Layouts
    ["style"]  = "Jasje",                        --  You can choose between 2 layouts #1 Tukui #2 Jasje
}	

C["general"] = {
	["autoscale"] = true,                               -- mainly enabled for users that don't want to mess with the config file
	["uiscale"] = 0.71,                                 -- set your value (between 0.64 and 1) of your uiscale if autoscale is off
	["overridelowtohigh"] = false,                      -- EXPERIMENTAL ONLY! override lower version to higher version on a lower reso.
	["multisampleprotect"] = true,                      -- i don't recommend this because of shitty border but, voila!
}

C["unitframes"] = {
	-- general options
	["enable"] = true,                                  -- do i really need to explain this?
	["enemyhcolor"] = false,                            -- enemy target (players) color by hostility, very useful for healer.
	["unitcastbar"] = true,                             -- enable tukui castbar
		["trikz"] = false,                             -- replace castbar on top of actionbars made for a friend hence the name
	["cblatency"] = true,                              -- enable castbar latency
	["cbicons"] = true,                                 -- enable icons on castbar
	["auratimer"] = true,                               -- enable timers on buffs/debuffs
	["auratextscale"] = 8,                             -- the font size of buffs/debuffs timers on unitframes
	["playerauras"] = false,                            -- enable auras
	["targetauras"] = true,                             -- enable auras on target unit frame
	["lowThreshold"] = 20,                              -- global low threshold, for low mana warning.
	["targetpowerpvponly"] = false,                      -- enable power text on pvp target only
	["totdebuffs"] = false,                             -- enable tot debuffs (high reso only)
	["showtotalhpmp"] = false,                          -- change the display of info text on player and target with XXXX/Total.
	["showsmooth"] = true,                              -- enable smooth bar
	["charportrait"] = false,                           -- do i really need to explain this?
	["maintank"] = false,                               -- enable maintank
	["mainassist"] = false,                             -- enable mainassist
	["unicolor"] = true,                               -- enable unicolor theme
	["combatfeedback"] = false,                          -- enable combattext on player and target.
	["playeraggro"] = true,                             -- color player border to red if you have aggro on current target.
	["healcomm"] = false,                               -- enable healprediction support.
	["onlyselfdebuffs"] = false,                        -- display only our own debuffs applied on target
	["showfocustarget"] = false,                         -- show focus target
	
	-- boss frames
	["showboss"] = true,                                -- enable boss unit frames for PVELOL encounters.

	-- priest only plugin
	["weakenedsoulbar"] = true,                         -- show weakened soul bar
	
	-- class bar
	["classbar"] = true,                                -- enable tukui classbar over player unit
}

	-- raid layout (if one of them is enabled)
C["raidlayout"] = {
	["showrange"] = true,                               -- show range opacity on raidframes
	["raidalphaoor"] = 0.3,                             -- alpha of unitframes when unit is out of range
	["gridonly"] = true,                               -- enable grid only mode for all healer mode raid layout.
	["showsymbols"] = true,	                            -- show symbol.
	["aggro"] = true,                                   -- show aggro on all raids layouts
	["raidunitdebuffwatch"] = true,                     -- track important spell to watch in pve for grid mode.
	["gridhealthvertical"] = true,                      -- enable vertical grow on health bar for grid mode.
	["showplayerinparty"] = true,                      -- show my player frame in party
	["gridscale"] = 1,                                  -- set the healing grid scaling
    -- only works for Jasje style
	["gridH"] = 27,                           -- Height of raidframes
	["gridW"] = 50,                           -- Width of raidframes 
	["powergridH"] = 2,                            -- Height of power 
	["powergridW"] = 40,                            -- Width of power -- always need to be 10 less then gridW
}
    -- below config only works for Jasje style
    -- unitframe posistioning, X = horizontal  Y = vertical  - = left/down + = right/up
C["unitframeJ"] = {
 	["playerX"] = 2,                      
	["playerY"] = 61,                           
 	["targetX"] = -2,                           
	["targetY"] = 61,
 	["totX"] = -0,                           
	["totY"] = 61, 
	["petX"] = -0,                           
	["petY"] = 105,
}

C["arena"] = {
	["unitframes"] = true,                              -- enable tukz arena unitframes (requirement : tukui unitframes enabled)
}

C["actionbar"] = {
	["enable"] = true,                                  -- enable tukui action bars
	["hotkey"] = true,                                 -- enable hotkey display because it was a lot requested
	["hideshapeshift"] = false,                         -- hide shapeshift or totembar because it was a lot requested.
	["showgrid"] = true,                                -- show grid on empty button
	["buttonsize"] = 27,                                -- normal buttons size
	["petbuttonsize"] = 29,                             -- pet & stance buttons size
	["buttonspacing"] = 4,                              -- buttons spacing
}

C["castbar"] = { --Thank you elv
	["classcolor"] = true, -- classcolor
	["castbarcolor"] = { 0.3, 0.3, 0.3, 1 }, -- Color of player castbar
	["nointerruptcolor"] = { 1, 0.1, 0.1, 0.5 }, -- Color of target castbar
}

C["combopointbar"] = {
    ["enable"] = true,       -- enable/disable combopoint bar (credit jasje)
}

C["saftExperienceBar"] = {
    ["enable"] = true,                       -- enable Safturento's XP/REP bar
}	

C["Interrupted"] = {
    ["enable"] = true,                     -- enable Interrupt announce by Sideshow
}	

C["bags"] = {
	["enable"] = true,                                  -- enable an all in one bag mod that fit tukui perfectly
}

C["map"] = {
	["enable"] = true,                                  -- reskin the map to fit tukui
}

C["loot"] = {
	["lootframe"] = true,                               -- reskin the loot frame to fit tukui
	["rolllootframe"] = true,                           -- reskin the roll frame to fit tukui
	["autogreed"] = true,                               -- auto-dez or auto-greed item at max level, auto-greed Frozen orb
}

C["cooldown"] = {
	["enable"] = true,                                  -- do i really need to explain this?
	["treshold"] = 2,                                   -- show decimal under X seconds and text turn red
}
                          -- 8 and 9 are only usable in Jasje layout, not in Tukui
C["datatext"] = { 
	["fps_ms"] = 5,                                     -- show fps and ms on panels
	["system"] = 0,                                     -- show total memory and others systems infos on panels
	["bags"] = 0,                                       -- show space used in bags on panels
	["gold"] = 6,                                       -- show your current gold on panels
	["wowtime"] = 1,                                    -- show time on panels
	["guild"] = 3,                                      -- show number on guildmate connected on panels
	["dur"] = 4,                                        -- show your equipment durability on panels.
	["friends"] = 2,                                    -- show number of friends connected.
	["dps_text"] = 0,                                   -- show a dps meter on panels
	["hps_text"] = 0,                                   -- show a heal meter on panels
	["power"] = 8,                                      -- show your attackpower/spellpower/healpower/rangedattackpower whatever stat is higher gets displayed
	["haste"] = 0,                                      -- show your haste rating on panels.
	["crit"] = 9,                                       -- show your crit rating on panels.
	["avd"] = 0,                                        -- show your current avoidance against the level of the mob your targeting
	["armor"] = 0,                                      -- show your armor value against the level mob you are currently targeting
	["currency"] = 0,                                   -- show your tracked currency on panels
	["hit"] = 0,
	["mastery"] = 0,
	["micromenu"] = 0,

	["battleground"] = true,                            -- enable 3 stats in battleground only that replace stat1,stat2,stat3.
	["time24"] = true,                                  -- set time to 24h format.
	["localtime"] = false,                              -- set time to local time instead of server time.
	
	-- Color Datatext
	["classcolor"] = false,                -- classcolored datatexts 
	["color"] = "|cff808080",              -- datatext color if classcolor = false

	["fontsize"] = 14,                     -- font size for panels.
	["fontflag"] = "OUTLINEMONOCHROME",             -- font ouline   
}

C["chat"] = {
	["enable"] = true,                                  -- blah
	["whispersound"] = true,                            -- play a sound when receiving whisper
	["background"] = false,                             -- chat backdrop
	["tabcolor"] = {150/255, 150/255, 150/255},              -- color of chat tabs, disabled if classcolor is true
	["tabmouseover"] = {1,1,1,1},          -- color of tabs on mouse-over
	["classcolortab"] = false,             -- color chat tabs based on class
}

C["nameplate"] = {
	["enable"] = true,                                  -- enable nice skinned nameplates that fit into tukui
	["showhealth"] = false,				                -- show health text on nameplate
	["enhancethreat"] = true,			                -- threat features based on if your a tank or not
	["overlap"] = false,				                -- allow nameplates to overlap
	["combat"] = false,					                -- only show enemy nameplates in-combat.
	["goodcolor"] = {75/255,  175/255, 76/255},	        -- good threat color (tank shows this with threat, everyone else without)
	["badcolor"] = {0.78, 0.25, 0.25},			        -- bad threat color (opposite of above)
	["transitioncolor"] = {218/255, 197/255, 92/255},	-- threat color when gaining threat
}

C["tooltip"] = {
	["enable"] = true,                                  -- true to enable this mod, false to disable
	["hidecombat"] = false,                             -- hide bottom-right tooltip when in combat
	["hidebuttons"] = false,                            -- always hide action bar buttons tooltip.
	["hideuf"] = false,                                 -- hide tooltip on unitframes
	["cursor"] = false,                                 -- tooltip via cursor only
}

C["merchant"] = {
	["sellgrays"] = true,                               -- automaticly sell grays?
	["autorepair"] = false,                              -- automaticly repair?
	["sellmisc"] = true,                                -- sell defined items automatically
}

C["error"] = {
	["enable"] = true,                                  -- true to enable this mod, false to disable
	filter = {                                          -- what messages to not hide
		[INVENTORY_FULL] = true,                        -- inventory is full will not be hidden by default
	},
}

C["invite"] = { 
	["autoaccept"] = true,                              -- auto-accept invite from guildmate and friends.
}

C["buffreminder"] = {
	["enable"] = true,                                  -- this is now the new innerfire warning script for all armor/aspect class.
	["sound"] = true,                                   -- enable warning sound notification for reminder.
}