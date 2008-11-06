

local Alterac = DBM:NewMod("Alterac", "DBM-Battlegrounds")
local L = Alterac:GetLocalizedStrings()

Alterac:RegisterEvents(
	"ZONE_CHANGED_NEW_AREA", 	-- Required for BG start
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_BG_SYSTEM_ALLIANCE",
	"CHAT_MSG_BG_SYSTEM_HORDE",
	"CHAT_MSG_BG_SYSTEM_NEUTRAL"
)

local allyTowerIcon = "Interface\\AddOns\\DBM-Battlegrounds\\Textures\\GuardTower"
local allyColor = {
	r = 0,
	g = 0,
	b = 1,
}

local hordeTowerIcon = "Interface\\AddOns\\DBM-Battlegrounds\\Textures\\OrcTower"
local hordeColor = {
	r = 1,
	g = 0,
	b = 0,
}

local startTimer = Alterac:NewTimer(62, "TimerStart")
local towerTimer = Alterac:NewTimer(243, "TimerTower")
local gyTimer = Alterac:NewTimer(243, "TimerGY", "Interface\\Icons\\Spell_Shadow_AnimateDead")

-- http://www.wowwiki.com/API_GetMapLandmarkInfo

graveyards = {}
local function is_graveyard(id)
	return id == 15 or id == 4 or id == 13 or id == 14 or id == 8 
end
local function gy_state(id)
	if id == 15 then	return 1	-- if gy_state(id) > 2 then .. conflict state ...
	elseif id == 13 then 	return 2
	elseif id == 4 then	return 3	-- if gy_state(id) == 3 then --- alliance takes gy from horde
	elseif id == 14 then	return 4	-- if gy_state(id) == 4 then --- horde takes gy from alliance
	elseif id == 8 then	return 5	-- if gy_state(id) == 5 then --- untaken
	else return 0
	end
end
--[[
    15 Graveyard, held by Alliance 
    04 Graveyard, assaulted by Alliance 
    13 Graveyard, held by Horde 
    14 Graveyard, assaulted by Horde 
--]]

towers = {}
local function is_tower(id)
	return id == 10 or id == 12 or id == 11 or id == 9 or id == 6
end
local function tower_state(id)
	if id == 11 then	return 1	-- if tower_state(id) > 2 then .. conflict state ...
	elseif id == 10 then	return 2
	elseif id == 9 then	return 3	-- if tower_state(id) == 3 then --- alliance trys to destroy the tower
	elseif id == 12 then	return 4	-- if tower_state(id) == 4 then --- horde trys to destroy the tower
	elseif id == 6 then	return 5	-- if tower_state(id) == 5 then --- destroyed
	else return 0
	end
end
--[[
    10 Tower, held by Horde 
    12 Tower, assaulted by Horde 
    11 Tower, held by Alliance 
    09 Tower, assaulted by Alliance 
--]]

local bgzone = false
do
	local function AV_Initialize()
		if select(2, IsInInstance()) == "pvp" and GetRealZoneText() == L.ZoneName then
			bgzone = true
			for i=1, GetNumMapLandmarks(), 1 do
				local name, _, textureIndex = GetMapLandmarkInfo(i)
				if name and textureIndex then
					if is_graveyard(textureIndex) then
						graveyards[i] = textureIndex
					elseif is_tower(textureIndex) then
						towers[i] = textureIndex
					end
				end
			end

		elseif bgzone then
			bgzone = false
		end
	end
	function Alterac:OnInitialize()
		AV_Initialize()
	end
	function Alterac:ZONE_CHANGED_NEW_AREA()
		AV_Initialize()
	end
end

local schedule_check

function Alterac:CHAT_MSG_BG_SYSTEM_NEUTRAL(arg1)
	if not bgzone then return end
	if arg1 == L.BgStart60 then
		startTimer:Start()
	elseif arg1 == L.BgStart30  then		
		startTimer:Update(31, 62)
	end
	schedule_check()
end

local function check_for_updates()
	if not bgzone then return end
	for k,v in pairs(graveyards) do
		local name, _, textureIndex = GetMapLandmarkInfo(k)
		if name and textureIndex then
			if gy_state(v) <= 2 and gy_state(textureIndex) > 2 then
				-- gy is now in conflict, we have to start a bar :)
				gyTimer:Start(nil, name)

				if gy_state(textureIndex) == 3 then
					gyTimer:SetColor(allyColor, name)
				else
					gyTimer:SetColor(hordeColor, name)
				end
				
			elseif gy_state(textureIndex) <= 2 then
				-- gy is now longer under conflict, remove the bars
				gyTimer:Stop(name)
			end
			graveyards[k] = textureIndex
		end		 
	end
	for k,v in pairs(towers) do
		local name, _, textureIndex = GetMapLandmarkInfo(k)
		if name and textureIndex then
			if tower_state(v) <= 2 and tower_state(textureIndex) > 2 then
				-- Tower is now in conflict, we have to start a bar :)
				towerTimer:Start(nil, name)

				if tower_state(textureIndex) == 3 then
					towerTimer:SetColor(allyColor, name)
					towerTimer:UpdateIcon(allyTowerIcon, name)
				else
					towerTimer:SetColor(hordeColor, name)
					towerTimer:UpdateIcon(hordeTowerIcon, name)
				end

			elseif tower_state(textureIndex) <= 2 then
				-- Tower is now longer under conflict, remove the bars
				towerTimer:Stop(name)
			end
			towers[k] = textureIndex
		end		 
	end
end

function schedule_check()
	DBM:Schedule(1, check_for_updates)
end


Alterac.CHAT_MSG_MONSTER_YELL = schedule_check
Alterac.CHAT_MSG_BG_SYSTEM_ALLIANCE = schedule_check
Alterac.CHAT_MSG_BG_SYSTEM_HORDE = schedule_check

