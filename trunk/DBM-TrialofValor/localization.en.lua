local L

---------------
-- Odyn --
---------------
L= DBM:GetModLocalization(1819)

L:SetMiscLocalization({
	BrandYell = "{rt%d} %s {rt%d}"--Shouldn't need translating
})

---------------------------
-- Guarm --
---------------------------
L= DBM:GetModLocalization(1830)

---------------------------
-- Helya --
---------------------------
L= DBM:GetModLocalization(1829)

L:SetMiscLocalization({
	phaseThree =	"Your efforts are for naught, mortals! Odyn will NEVER be free!",
	near =			"near",
	far =			"far",
	multiple =		"Multiple"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("TrialofValorTrash")

L:SetGeneralLocalization({
	name =	"Trial of Valor Trash"
})
