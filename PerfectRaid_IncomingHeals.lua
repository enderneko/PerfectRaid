--[[-------------------------------------------------------------------------
  *
  * IncomingHeals module for PerfectRaid addon.
  *
  * Written by: Panoramix
  * Version: 1.0
  *   
---------------------------------------------------------------------------]]


local IncomingHeals = PerfectRaid:NewModule("PerfectRaid-IncomingHeals")
-- local HealComm = LibStub("LibHealComm-4.0")

local L = PerfectRaidLocals
local utils, frames

function IncomingHeals:Initialize()
	
	frames = PerfectRaid.frames
	utils = PerfectRaid.utils
	
	self:RegisterMessage("DONGLE_PROFILE_CHANGED")
	self:RegisterMessage("PERFECTRAID_CONFIG_CHANGED")	
end


function IncomingHeals:DONGLE_PROFILE_CHANGED(event, addon, svname, name)
	if svname == "PerfectRaidDB" then
		IncomingHeals:EnableIncomingHeals(PerfectRaid.db.profile.showincomingheals)
	end
end

function IncomingHeals:PERFECTRAID_CONFIG_CHANGED(event, addon, svname, name)
	IncomingHeals:EnableIncomingHeals(PerfectRaid.db.profile.showincomingheals)	
end

function IncomingHeals:Enable()
	IncomingHeals:EnableIncomingHeals(PerfectRaid.db.profile.showincomingheals)	
end

function IncomingHeals:EnableIncomingHeals(value)
	if value then
		self:RegisterEvent("UNIT_HEAL_PREDICTION", "UpdateIncomingHeals")
		-- self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", "UpdateIncomingHeals")
		-- HealComm.RegisterCallback(PerfectRaid.HealComm, "HealComm_HealStarted", "HealComm_UpdateHealPrediction")
		-- HealComm.RegisterCallback(PerfectRaid.HealComm, "HealComm_HealUpdated", "HealComm_UpdateHealPrediction")
		-- HealComm.RegisterCallback(PerfectRaid.HealComm, "HealComm_HealStopped", "HealComm_UpdateHealPrediction")
		-- HealComm.RegisterCallback(PerfectRaid.HealComm, "HealComm_HealDelayed", "HealComm_UpdateHealPrediction")
		-- HealComm.RegisterCallback(PerfectRaid.HealComm, "HealComm_ModifierChanged", "HealComm_UpdateHealPrediction")
		-- HealComm.RegisterCallback(PerfectRaid.HealComm, "HealComm_GUIDDisappeared", "HealComm_UpdateHealPrediction")
	else
		self:UnregisterEvent("UNIT_HEAL_PREDICTION", "UpdateIncomingHeals")
		-- self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", "UpdateIncomingHeals")
		-- HealComm.UnregisterAllCallbacks(PerfectRaid.HealComm)
	end	
end


function IncomingHeals:ConfigureButton( button )

	local inchealbar = CreateFrame("StatusBar", nil, button)
	button.incominghealsbar = inchealbar	
	
	-- local absorbbar = CreateFrame("StatusBar", nil, button)
	-- button.absorbbar = absorbbar 
end

function IncomingHeals:UpdateButtonLayout( button )
	
	button.incominghealsbar:ClearAllPoints()
	button.incominghealsbar:SetPoint("TOPLEFT", button.leftbox, "TOPRIGHT", 0, -1)
	button.incominghealsbar:SetPoint("BOTTOMRIGHT", button.rightbox, "BOTTOMLEFT", 0, 1)
	button.incominghealsbar:SetStatusBarTexture("Interface\\AddOns\\PerfectRaid\\images\\smooth")
	button.incominghealsbar:SetFrameLevel( button.healthbar:GetFrameLevel()-1 )
	button.incominghealsbar:SetStatusBarColor( 0.3, 0.5, 0.3 )
	button.incominghealsbar:Hide()
	
	-- button.absorbbar:ClearAllPoints()
	-- button.absorbbar:SetPoint("TOPLEFT", button.leftbox, "TOPRIGHT", 0, -1)
	-- button.absorbbar:SetPoint("BOTTOMRIGHT", button.rightbox, "BOTTOMLEFT", 0, 1)
	-- button.absorbbar:SetStatusBarTexture("Interface\\AddOns\\PerfectRaid\\images\\smooth")
	-- button.absorbbar:SetFrameLevel( button.healthbar:GetFrameLevel()-2 )
	-- button.absorbbar:SetStatusBarColor( 0, 0.651, 0.871 )
	-- button.absorbbar:Hide()
	
end

function IncomingHeals:UpdateIncomingHeals( event, target )
	local health = UnitHealth(target)
	local maxhealth = UnitHealthMax(target)
	local healinc = UnitGetIncomingHeals(target)
	
	if not health then return end

	local healthincsum = health + healinc
	
	-- adjust healthsum to maxhealth
	if healthincsum > maxhealth then healthincsum = maxhealth end
	
	for unit, tbl in pairs(frames) do
		if UnitIsUnit( target, unit ) then
			for frame in pairs(frames[unit]) do	
				-- heal inc
				if healinc == 0 or health == maxhealth then				
					frame.incominghealsbar:Hide()
				else
					frame.incominghealsbar:SetMinMaxValues(0, maxhealth)
					frame.incominghealsbar:SetValue(healthincsum)
					frame.incominghealsbar:Show()
				end
			end
			
		end			
	end
end

-- function IncomingHeals:UpdateIncomingHeals( event, target, guid)

-- 	if UnitGUID(target) ~= guid then return end
	
-- 	local health = UnitHealth(target)
-- 	local maxhealth = UnitHealthMax(target)
-- 	local healinc = 0
	
-- 	-- not correct healinc or health
-- 	if not health then return end

-- 	local modifier = HealComm:GetHealModifier(guid) or 1
-- 	healinc = (HealComm:GetHealAmount(guid, HealComm.CASTED_HEALS) or 0) * modifier
-- 	-- NOTE: hots within 3 seconds
-- 	hot = (HealComm:GetHealAmount(guid, HealComm.OVERTIME_AND_BOMB_HEALS, GetTime()+3) or 0) * modifier
-- 	healinc = healinc + hot
	
-- 	local healthincsum = health + healinc
	
-- 	-- adjust healthsum to maxhealth
-- 	if healthincsum > maxhealth then healthincsum = maxhealth end
	
-- 	for unit, tbl in pairs(frames) do
-- 		if UnitIsUnit( target, unit ) then
-- 			for frame in pairs(frames[unit]) do	
-- 				-- heal inc
-- 				if healinc == 0 or health == maxhealth then				
-- 					frame.incominghealsbar:Hide()
-- 				else
-- 					frame.incominghealsbar:SetMinMaxValues(0, maxhealth)
-- 					frame.incominghealsbar:SetValue(healthincsum)
-- 					frame.incominghealsbar:Show()
-- 				end
-- 			end
			
-- 		end			
-- 	end
	
	
-- end

-------------------------------------------------
-- LibHealComm
-------------------------------------------------
-- PerfectRaid.HealComm = {}
-- local function HealComm_UpdateHealPrediction(_, event, casterGUID, spellID, healType, endTime, ...)
--     -- update incomingHeal
--     for i = 1, select("#", ...) do
-- 		local guid = select(i, ...)
--         local unit = PerfectRaid.guidToUnit[guid]
--         if unit then
-- 			-- print(event, casterGUID, spellID, healType, endTime, ...)
--             IncomingHeals:UpdateIncomingHeals(event, unit, guid)
--         end
--     end
-- end
-- PerfectRaid.HealComm.HealComm_UpdateHealPrediction = HealComm_UpdateHealPrediction