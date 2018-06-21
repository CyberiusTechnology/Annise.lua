+

--   _____      _                __          __        _     _ 
--  / ____|    | |               \ \        / /       | |   | |
-- | |    _   _| |__   ___  ___   \ \  /\  / /__  _ __| | __| |
-- | |   | | | | '_ \ / _ \/ __|   \ \/  \/ / _ \| '__| |/ _` |
-- | |___| |_| | |_) |  __/\__ \    \  /\  / (_) | |  | | (_| |
--  \_____\__, |_.__/ \___||___/     \/  \/ \___/|_|  |_|\__,_|
--         __/ |                                               
--        |___/                                      

require("Inspired.lua")

--Champion

if GetObjectName(GetMyHero()) ~= "Draven" then return end

--lib and shit
require("OpenPredict")
require("DamageLib")
function AnnieScriptPrint(msg)
	print("<font color=\ "#00ffff\">Annie Script:</font><font color =\"#ffffff\">"..msg.."</font>")
end
AnnieScriptPrint("Made by Cyberius")
--Menu
local AnnieMenu = Menu("Annie", "Simple Annie")
--Combo
AnnieMenu:SubMenu("Combo", "[Annie[ Combo Settings")
AnnieMenu.Combo:Boolean("Q", "Use Q", true)
AnnieMenu.Combo:Boolean("W", "Use W", true)
AnnieMenu.Combo:Boolean("E", "Use E", true)
AnnieMenu.Combo:Boolean("R", "Use R", true)
AnnieMenu.Combo:Slider("ME", "Minimum Enemies: R", 1, 0, 5 ,1)
AnnieMenu.Combo:Slider("HP", "HP-Manager: R", 40, 0, 100, 5)
--Harass
AnnieMenu:SubMenu("Harass", "[Annie] Harass Settings")
AnnieMenu.Harass:Boolean("Q", "Use Q", true)
AnnieMenu.Harass:Boolean("W", "Use W", true)
AnnieMenu.Harass:Slider("Mana", "Min. Mana", 50, 0, 100, 1)
--Lane Clear
AnnieMenu:SubMenu("Farm", "[Annie] Farm Settings")
AnnieMenu.Farm:Boolean("Q", "Use Q", true)
AnnieMenu.Farm:Slider("Mana", "Min. Mana", 50, 0, 100, 1)
--Kill Steal
AnnieMenu:SubMenu("KS", "[Annie] Kill Steal Settings")
AnnieMenu.KS:Boolean("Q", "Use Q", true)
AnnieMenu.KS:Boolean("W", "Use W", true)
AnnieMenu.KS:Boolean("R", "Use R", true)
--Prediction
AnnieMenu:SubMenu("Prediction", "[Annie] W & R Prediction")
AnnieMenu.Prediction:DropDown("PredQ", "Prediction Q:", 2, {"OpenPredict", "GoSPred"})
AnnieMenu.Prediction:DropDown("PredR", "Prediction R:", 2, {"OpenPredict", "GoSPred"})
--AutoLvl
AnnieMenu:SubMenu("AutoLevel", "[Annie] Autolevel")
AnnieMenu.AutoLevel:Boolean("DisableAUTOMAX", "Auto max abilites R>Q>W>E", false)
--draw
AnnieMenu:SubMenu("Draw", "[Annie] Drawing Settings")
AnnieMenu.Draw:Boolean("Q", "Draw Q", false)
AnnieMenu.Draw:Boolean("W", "Draw W", false)
AnnieMenu.Draw:Boolean("E", "Draw E", false)
AnnieMenu.Draw:Boolean("R", "Draw R", false)
AnnieMenu.Draw:Boolean("Disable", "Disable all drawings", false)
--AutoLevel
local levelsc = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _ R, _E , _E}

--SpellDetails
local Spells = {
	Q = {range = 625, delay = 0.25, speed = 1700 width = 100}
	W = {range = 625, delay = 0.25, speed = 1400 width = 200}
	E = {}
	R = {range = 600}
}

--orbwalker
function Mode()
		if _G.IOW_Loaded and IOW:Mode() then
				return IOW:Mode()
			elseif _G.PW_Loaded and PW:Mode() then
				return PW:Mode()
			elseif _G.DAC_Loaded and DAC:Mode() then
				return DAC:Mode()
			elseif _G.AutoCarry_Loaded and DACR:Mode() then
				return DACR:Mode()
			elseif _G.SLW_Loaded and SLW:Mode() then
				return SLW:Mode()
			end
end
--tick
OnTick(function()
		KS()
		AutoLevel()
		target = GetCurrentTarget()
						Combo()
						Harass()
						Farm()
					end)
--AutoLevel
function AutoLevel()
		if AnnieMenu.AutoLevel.DisableAUTOMAX:Value() then return end
		if GetLevelPoints(myHero) > 0 then
			DelayAction(function() LevelSpell(levelsc[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
		end
end
--Annie Q
function AnnieQ()
		CastTargetSpell(target, _Q)
end
--Annie W
function AnnieW()
		if AnnieMenu.Prediction.PredW:Value() == 1 then
			local WPred = GetLinearAOEPrediction(target, Spells.W)
			if WPred.hitChance > 0.9 then
				CastSkillShot(_W, WPred.castPos)
			end
		elseif AnnieMenu.Prediction.PredW:Value() == 2 then
			local PredW = GetPredictionForPlayer(GetOrigin(myHero), target, GetMoveSpeed(target), Spells.W.speed, Spells.W.delay*1000, Spells.W.range, Spells.W.width, false, true)
				if PredW.hitChance == 1 then
					CastSkillShot(_Q, QPred.PredPos)
				end
			end
		end
--Annie R
function AnnieR()
	CastTargetSpell(target, R)
end
--Combo
function Combo()
		if Mode() == "Combo" then
		--Use R
		if AnnieMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, Spells.R.Range) then
				AnnieR()
				end
		--Use W
		if AnnieMenu.Combo.W:Value() and Ready(_R) and ValidTarget(target, Spells.W.Range) then
				AnnieW()
				end
		--Use Q
		if AnnieMenu.Combo.Q:Value() and Ready(_R) and ValidTarget(target, Spells.Q.Range) then
				AnnieQ()
				end
end
--Harass
function Harass()
	if Mode() == "Harass" then
		if(myHero.mana/myHero.maxMana >= AnnieMenu.Harass.Mana.Value() /100) then
		--Use Q
		if AnnieMenu.Harass:Q.Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
				AnnieQ()
				end
		--Use W
		if AnnieMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
				AnnieW()
				end
			end
		end
--LaneClear
function Farm()
	if Mode() == "LaneClear" then
		if AnnieMenu.Farm.Q:Value() then
			for _, minions in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > AnnieMenu.Farm.Mana:Value then
						if ValidTarget(minion, Spells.Q.range) then
						if CanUseSpell(myHero, _Q) == READY then
							CastSkillShot(_Q, GetOrigin(minion))
						end
					end
				end
			end
		end
	end
end
end

--Killsteals
function KS()
	for _, enemy in pairs(GetEnemyHeroes()) do
		--useQ
		if AnnieMenu.KS.Q:Value() and Ready (_Q) and ValidTarget(enemy, Spells.Q.range) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
				AnnieQ()
				end
			end
		--useW
		if AnnieMenu.KS.Q:Value() and Ready(_W) and ValidTarget (enemy, Spells.W.range) then
			if GetCurrentHP(enemy) < getdmg("W", enemy, myHouse) then
				AnnieW()
			end
		end
	end
end

--Drawings
OnDraw(function(myHero)
	if myHero.dead or AnnieMenu.Draw.Disable:Value() then return end
	local pos = GetOrigin(myHero)
	--DrawQ
	if AnnieMenu.Draw.Q:Value() then DrawCircle(pos, Spells.Q.range, 1, 25, 0xC822D04A) end
	--DrawW
	if AnnieMenu.Draw.W:Value() then DrawCircle(pos, Spells.W.range, 1, 25, 0xFF007FAD) end
	--DrawR
	if AnnieMenu.Draw.E:Value() then DrawCircle(pos, Spells.R.range, 1, 25, 0xFF91C9DD) end
end)
