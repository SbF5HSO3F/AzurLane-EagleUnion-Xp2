-- EagleUnionPoint_Shangri-La
-- Author: HSbF6HSO3F
-- DateCreated: 2025/8/16 23:59:32
--------------------------------------------------------------
--||=======================include========================||--
include('EagleCore')

--||===================local variables====================||--

local shangriLaPercent = 1
local key = 'ShangriLaResCount'
local modifierPerRecord = 5

--||====================base functions====================||--

EaglePointManager.Points.Extra.ShangriLaScience = {
    Tooltip = 'LOC_EAGLE_POINT_FROM_SHANGRI_LA_TECHS',
    GetPointYield = function(playerID)
        local point = 0
        --是否是香格里拉
        if EagleCore.CheckLeaderMatched(playerID, 'LEADER_SHANGRI_LA_CV38') then
            --获取玩家科技
            local techs = Players[playerID]:GetTechs()
            for row in GameInfo.Technologies() do
                if techs:HasTech(row.Index) then
                    point = point + techs:GetResearchCost(row.Index)
                end
            end
        end
        return EagleMath:ModifyByPercent(point, shangriLaPercent, true)
    end,
    GetTooltip = function(self, playerID)
        local yield = self.GetPointYield(playerID)
        return yield ~= 0 and Locale.Lookup(self.Tooltip, yield) or ''
    end
}

EaglePointManager.Points.Extra.ShangriLaCulture = {
    Tooltip = 'LOC_EAGLE_POINT_FROM_SHANGRI_LA_CIVICS',
    GetPointYield = function(playerID)
        local point = 0
        --是否是香格里拉
        if EagleCore.CheckLeaderMatched(playerID, 'LEADER_SHANGRI_LA_CV38') then
            --获取玩家文化
            local civic = Players[playerID]:GetCulture()
            for row in GameInfo.Civics() do
                if civic:HasCivic(row.Index) then
                    point = point + civic:GetCultureCost(row.Index)
                end
            end
        end
        return EagleMath:ModifyByPercent(point, shangriLaPercent, true)
    end,
    GetTooltip = function(self, playerID)
        local yield = self.GetPointYield(playerID)
        return yield ~= 0 and Locale.Lookup(self.Tooltip, yield) or ''
    end
}

EaglePointManager.Points.Modifier.ShangriLa = {
    Tooltip = 'LOC_EAGLE_POINT_MODIFIER_SHANGRI_LA',
    GetModifier = function(playerID)
        --获取数量
        local datas = Players[playerID]:GetProperty(key)
        local count = datas and datas.Count or 0
        --获取点数减免
        local modifier = count * modifierPerRecord
        return EagleMath.Round(modifier)
    end,
    GetTooltip = function(self, playerID)
        local modifier = self.GetModifier(playerID)
        return modifier ~= 0 and Locale.Lookup(self.Tooltip, modifier) or ''
    end
}

--||=======================include========================||--

include('EagleUnionPoint_Shangri-La_', true)
