--Mini Dragon <流浪者酒馆-Brilla@金色平原> 20211201

if GetLocale() ~= "zhCN" then return end
local L

---------------------------
--  Solitary Guardian -- 孤生护卫
---------------------------
--L= DBM:GetModLocalization(2458)

--L:SetOptionLocalization({

--})

--L:SetMiscLocalization({

--})

---------------------------
--  Dausegne, the Fallen Oracle -- 道茜歌妮，堕落先知
---------------------------
--L= DBM:GetModLocalization(2459)

---------------------------
--  Artificer Xy'mox -- 圣物匠赛·墨克斯
---------------------------
--L= DBM:GetModLocalization(2470)

---------------------------
--  Prototype Pantheon -- 万神殿原型
---------------------------
L= DBM:GetModLocalization(2460)

L:SetMiscLocalization({h
	Deathtouch		= "死亡之触",
	Dispel			= "驱散",
	Sin				= "罪孽",
	Stacks			= "层"
})

---------------------------
--  Lihuvim, Principal Architect -- 首席建筑师利胡威姆
---------------------------
--L= DBM:GetModLocalization(2461)

---------------------------
--  Skolex, the Insatiable Ravener -- 司垢莱克斯，无穷噬灭者
---------------------------
--L= DBM:GetModLocalization(2465)

---------------------------
--  Halondrus the Reclaimer -- 回收者黑伦度斯
---------------------------
--L= DBM:GetModLocalization(2463)

---------------------------
--  Anduin Wrynn -- 安度因·乌瑞恩
---------------------------
L= DBM:GetModLocalization(2469)

L:SetOptionLocalization({
	PairingBehavior		= "设置渎神（光明与黑暗）的模组行为。队长设置覆盖全队。",
	Auto				= "点你提示，自动分配相反标记玩家，聊天说话符号提示该配对",
	Generic				= "点你提示，不分配相反标记玩家，聊天说话只符号提示光明或者黑暗的buff",--Default
	None				= "点你提示，不分配，没有聊天说话"
})

---------------------------
--  Lords of Dread -- 恐惧魔王
---------------------------
--L= DBM:GetModLocalization(2457)

---------------------------
--  Rygelon -- 莱葛隆
---------------------------
--L= DBM:GetModLocalization(2467)

---------------------------
--  The Jailer -- 典狱长
---------------------------
--L= DBM:GetModLocalization(2464)

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("SepulcherTrash")

L:SetGeneralLocalization({
	name =	"初诞者圣墓小怪"
})
