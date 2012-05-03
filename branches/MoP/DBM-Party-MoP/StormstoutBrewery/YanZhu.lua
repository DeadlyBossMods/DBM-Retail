local mod	= DBM:NewMod(670, "DBM-Party-MoP", 2, 302)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))
mod:SetCreatureID(59479)
mod:SetModelID(42969)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_CAST_START"
)


local warnBlackoutBrew		= mod:NewSpellAnnounce(106851, 2)--Applies 3 stacks of debuff to everyone, these 3 stacks will add to current stacks if you still have them (if you do, you're doing it wrong)

local specWarnBlackoutBrew	= mod:NewSpecialWarningMove(106851)--Moving clears this debuff, it should never increase unless you're doing fight wrong (think Hodir)

local timerBlackoutBrewCD	= mod:NewNextTimer(10.5, 106851)

function mod:OnCombatStart(delay)
	timerBlackoutBrewCD:Start(7-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(106651) and args:IsPlayer() and (args.amount or 3) >= 3 and self:AntiSpam() then
		specWarnBlackoutBrew:Show()--Basically special warn any time you gain a stack over 3, if stack is nil, then it's initial application and stack count is 3.
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(106851) then
		warnBlackoutBrew:Show()
		timerBlackoutBrewCD:Start()
	end
end

--[[
Notes:
1. His phase changes don't seem detectable in chat log or combat log, yet another boss incomplete without transcriptor data.
2. His bear wall abilities aren't detectable either. Again, transcriptor needed i guess.

3a. It seems all the bosses in this instance do this ability, i'm not sure what it's related to yet
3b. none of EJ's covery this ability. But I do have logs of Yan and Hop both using this
5/2 14:00:52.255  SPELL_CAST_SUCCESS,0x01000000000126AF,"Shiramune",0x512,0x0,0xF150E85700006763,"Yan-Zhu the Uncasked",0x10a48,0x0,56222,"Dark Command",0x1
5/2 14:01:42.061  SPELL_SUMMON,0xF130E86600007FED,"Yeasty Brew Alemental",0xa48,0x0,0xF130E85600008220,"Void Tendril",0xa28,0x0,114403,"Void Tendrils",0x20
5/2 14:01:42.061  SPELL_SUMMON,0xF150E85700006763,"Yan-Zhu the Uncasked",0xa48,0x0,0xF130E85600008221,"Void Tendril",0xa28,0x0,114403,"Void Tendrils",0x20
5/2 14:02:38.455  SPELL_SUMMON,0xF130E86600008336,"Yeasty Brew Alemental",0xa48,0x40,0xF130E85600008350,"Void Tendril",0xa28,0x0,114403,"Void Tendrils",0x20
5/2 14:02:38.455  SPELL_SUMMON,0xF150E85700006763,"Yan-Zhu the Uncasked",0x10a48,0x0,0xF130E85600008351,"Void Tendril",0xa28,0x0,114403,"Void Tendrils",0x20
5/2 14:04:32.924  SPELL_SUMMON,0xF130E8490000684A,"Brew Alemental",0xa28,0x0,0xF130E8560000891E,"Void Tendril",0xa28,0x0,114403,"Void Tendrils",0x20
5/2 14:04:32.924  SPELL_SUMMON,0xF150E85700006763,"Yan-Zhu the Uncasked",0x10a48,0x0,0xF130E8560000891F,"Void Tendril",0xa28,0x0,114403,"Void Tendrils",0x20
5/2 14:04:45.309  UNIT_DIED,0x0000000000000000,nil,0x80000000,0x80000000,0xF150E85700006763,"Yan-Zhu the Uncasked",0x10a48,0x0
--]]
