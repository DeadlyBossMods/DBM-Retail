local mod	= DBM:NewMod(682, "DBM-MogushanVaults", nil, 317)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(60143)
mod:SetModelID(41256)
mod:SetZone()
mod:SetUsedIcons(5, 6, 7, 8)

-- Sometimes it fails combat detection on "combat". Use yell instead until the problem being founded.
--I'd REALLY like to see some transcriptor logs that prove your bug, i pulled this boss like 20 times, on 25 man, 100% functional engage trigger, not once did this mod fail to start, on 25 man or 10 man.
--"<102.8> [INSTANCE_ENCOUNTER_ENGAGE_UNIT] Fake Args:#1#1#Gara'jal the Spiritbinder#0xF150EAEF00000F5A#elit
--"<103.1> [CHAT_MSG_MONSTER_YELL] CHAT_MSG_MONSTER_YELL#It be dyin' time, now!#Gara'jal the Spiritbinder#####0#0##0#862##0#false#false", -- [291]
mod:RegisterCombat("yell", L.Pull)

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_SUCCESS",
	"UNIT_SPELLCAST_SUCCEEDED"
)

--NOTES
--Syncing is used for all warnings because the realms don't share combat events. You won't get warnings for other realm any other way.
--Voodoo dolls do not have a CD, they are linked to banishment, when he banishes current tank, he reapplies voodoo dolls to new tank and new players. If tank dies, he just recasts voodoo on a new current threat target.
--Latency checks are used for good reason (to prevent lagging users from sending late events and making our warnings go off again incorrectly). if you play with high latency and want to bypass latency check, do so with in game GUI option.
local warnTotem							= mod:NewSpellAnnounce(116174, 2)
local warnVoodooDolls					= mod:NewTargetAnnounce(122151, 3)
local warnSpiritualInnervation			= mod:NewTargetAnnounce(117549, 3)
local warnBanishment					= mod:NewTargetAnnounce(116272, 3)
local warnSuicide						= mod:NewPreWarnAnnounce(116325, 5, 4)--Pre warn 5 seconds before you die so you take whatever action you need to, to prevent. (this is effect that happens after 30 seconds of Soul Sever

local specWarnTotem						= mod:NewSpecialWarningSpell(116174, false)
local specWarnBanishment				= mod:NewSpecialWarningYou(116272)
local specWarnBanishmentOther			= mod:NewSpecialWarningTarget(116272, mod:IsTank())
local specWarnVoodooDolls				= mod:NewSpecialWarningSpell(122151, false)

local timerTotemCD						= mod:NewNextTimer(36, 116174)
local timerBanishmentCD					= mod:NewNextTimer(65, 116272)
local timerSoulSever					= mod:NewBuffFadesTimer(30, 116278)--Tank version of spirit realm
local timerSpiritualInnervation			= mod:NewBuffFadesTimer(30, 117549)--Dps version of spirit realm
local timerShadowyAttackCD				= mod:NewCDTimer(8, "ej6698", nil, nil, nil, 117222)

mod:AddBoolOption("SetIconOnVoodoo")

local voodooDollTargets = {}
local spiritualInnervationTargets = {}
local voodooDollTargetIcons = {}

local function warnVoodooDollTargets()
	warnVoodooDolls:Show(table.concat(voodooDollTargets, "<, >"))
	specWarnVoodooDolls:Show()
	table.wipe(voodooDollTargets)
end

local function warnSpiritualInnervationTargets()
	warnSpiritualInnervation:Show(table.concat(spiritualInnervationTargets, "<, >"))
	table.wipe(spiritualInnervationTargets)
end

local function ClearVoodooTargets()
	table.wipe(voodooDollTargetIcons)
end

do
	local function sort_by_group(v1, v2)
		return DBM:GetRaidSubgroup(UnitName(v1)) < DBM:GetRaidSubgroup(UnitName(v2))
	end
	function mod:SetVoodooIcons()
		if DBM:GetRaidRank() > 0 then
			table.sort(voodooDollTargetIcons, sort_by_group)
			local voodooIcon = 8
			for i, v in ipairs(voodooDollTargetIcons) do
				self:SetIcon(UnitName(v), voodooIcon)
				voodooIcon = voodooIcon - 1
			end
			self:Schedule(1.5, ClearVoodooTargets)--Table wipe delay so if icons go out too early do to low fps or bad latency, when they get new target on table, resort and reapplying should auto correct teh icon within .2-.4 seconds at most.
		end
	end
end

function mod:OnCombatStart(delay)
	table.wipe(voodooDollTargets)
	table.wipe(spiritualInnervationTargets)
	table.wipe(voodooDollTargetIcons)
	timerShadowyAttackCD:Start(7-delay)
	timerTotemCD:Start(-delay)
	timerBanishmentCD:Start(-delay)
end

function mod:SPELL_AURA_APPLIED(args)--We don't use spell cast success for actual debuff on >player< warnings since it has a chance to be resisted.
	if args:IsSpellID(122151) then
		self:SendSync("VoodooTargets", args.destName)
	elseif args:IsSpellID(117549) then
		if args:IsPlayer() then--no latency check for personal notice you aren't syncing.
			timerSpiritualInnervation:Start()
			warnSuicide:Schedule(25)
		end
		if self:LatencyCheck() then
			self:SendSync("SpiritualTargets", args.destName)
		end
	elseif args:IsSpellID(116278) then
		if args:IsPlayer() then--no latency check for personal notice you aren't syncing.
			timerSoulSever:Start()
			warnSuicide:Schedule(25)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)--We don't use spell cast success for actual debuff on >player< warnings since it has a chance to be resisted.
	if args:IsSpellID(117549) and args:IsPlayer() then
		timerSpiritualInnervation:Cancel()
		warnSuicide:Cancel()
	elseif args:IsSpellID(116278) and args:IsPlayer() then
		timerSoulSever:Cancel()
		warnSuicide:Cancel()
	elseif args:IsSpellID(122151) then
		self:SendSync("VoodooGoneTargets", args.destName)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(116174) and self:LatencyCheck() then
		self:SendSync("SummonTotem")
	elseif args:IsSpellID(116272) then
		if args:IsPlayer() then--no latency check for personal notice you aren't syncing.
			specWarnBanishment:Show()
		end
		if self:LatencyCheck() then
			self:SendSync("BanishmentTarget", args.destName)
		end
	end
end

function mod:OnSync(msg, target)
	if msg == "SummonTotem" then
		warnTotem:Show()
		specWarnTotem:Show()
		--How recent of logs, newer then August 1st 25 man test? I did this fight on 25 (and 10), the timer was absolutely the same in both before.
		--if they did change it to 20 sec for your testing it won't surprise me.
		--if they did, they probably changed it for ALL modes. Blizz is trying very hard to make sure mechanics are identicle in 10 and 25 man.
		--every boss i tested i tested in both and blizz goes out of their way this tier to match them up.
		--WAIT< this change BETTER not be based off LFR, cause i'll revert it immediately if it was. LFR is NOT, i repeat, NOT equal to 25 man difficulty.
		--this tier, i'd have more faith that 10 man timers are same as 25 vs LFR same as 25. If your log is from LFR, revert this asap and make your new timer LFR only.
		if self:IsDifficulty("normal10", "heroic10") then
			timerTotemCD:Start()
		else
			timerTotemCD:Start(20.5)
		end
	elseif msg == "VoodooTargets" and target then
		voodooDollTargets[#voodooDollTargets + 1] = target
		self:Unschedule(warnVoodooDollTargets)
		self:Schedule(0.3, warnVoodooDollTargets)
		if self.Options.SetIconOnVoodoo then
			table.insert(voodooDollTargetIcons, DBM:GetRaidUnitId(target))
			self:UnscheduleMethod("SetVoodooIcons")
			if self:LatencyCheck() then--lag can fail the icons so we check it before allowing.
				self:ScheduleMethod(0.5, "SetVoodooIcons")--Still seems touchy and .3 is too fast even on a 70ms connection in rare cases so back to .5
			end
		end
	elseif msg == "VoodooGoneTargets" and target then
		if self.Options.SetIconOnVoodoo then
			self:SetIcon(target, 0)
		end
	elseif msg == "SpiritualTargets" and target then
		spiritualInnervationTargets[#spiritualInnervationTargets + 1] = target
		self:Unschedule(warnSpiritualInnervationTargets)
		self:Schedule(0.3, warnSpiritualInnervationTargets)
	elseif msg == "BanishmentTarget" and target then
		warnBanishment:Show(target)
		timerBanishmentCD:Start()
		if target ~= UnitName("player") then--make sure YOU aren't target before warning "other"
			specWarnBanishmentOther:Show(target)
		end
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(uId, _, _, _, spellId)
	if (spellId == 117215 or spellId == 117218 or spellId == 117219 or spellId == 117222) and self:AntiSpam(2, 1) then--Shadowy Attacks
		timerShadowyAttackCD:Start()
	end
end
