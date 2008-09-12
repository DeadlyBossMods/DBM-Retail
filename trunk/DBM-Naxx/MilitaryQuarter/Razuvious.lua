local mod = DBM:NewMod("Razuvious", "DBM-Naxx", 4)
local L = mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(16061)
mod:SetZone(GetAddOnMetadata("DBM-Naxx", "X-DBM-Mod-LoadZone"))

mod:RegisterCombat("yell", L.Yell1, L.Yell2, L.Yell3, L.Yell4)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS"
)

local warnShoutNow	= mod:NewAnnounce("WarningShoutNow", 1, 55543)
local warnShoutSoon	= mod:NewAnnounce("WarningShoutSoon", 3, 55543)

local timerShout	= mod:NewTimer(16, "TimerShout", 55543)

function mod:OnCombatStart(delay)
	timerShout:Start(16 - delay)
	warnShoutSoon:Schedule(11 - delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 55543       -- Disrupting Shout (10)
	or args.spellId == 29107 then  -- Disrupting Shout (25)
		timerShout:Start()
		warnShoutNow:Show()
		warnShoutSoon:Schedule(11)
	end
end
