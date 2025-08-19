-- EagleUnionShangri-La
-- Author: HSbF6HSO3F
-- DateCreated: 2025/8/19 20:03:34
--------------------------------------------------------------
--||=======================include========================||--
include('EagleCore')
include('EagleResources')

--||==================global variables====================||--

YieldTable = {
    YIELD_FOOD       = 'SHANGRI_LA_FOOD_YIELD_FROM_RECORD',
    YIELD_PRODUCTION = 'SHANGRI_LA_PRODUCTION_YIELD_FROM_RECORD',
    YIELD_GOLD       = 'SHANGRI_LA_GOLD_YIELD_FROM_RECORD',
    YIELD_SCIENCE    = 'SHANGRI_LA_SCIENCE_YIELD_FROM_RECORD',
    YIELD_CULTURE    = 'SHANGRI_LA_CULTURE_YIELD_FROM_RECORD',
    YIELD_FAITH      = 'SHANGRI_LA_FAITH_YIELD_FROM_RECORD'
}

--||===================local variables====================||--

local resources = EagleResources:new(true)

local key_1 = 'ShangriLaResource'
local key_2 = 'ShangriLaResCount'

--||===================Events functions===================||--

function ShangriLaReinitResource()
    resources = EagleResources:new(true)
end

--||=================GameEvents functions=================||--

function ShangriLaRecord(playerID, param)
    -- 获取玩家
    local player = Players[playerID]
    if player == nil then return end
    -- 获取资源
    local resource = resources:GetResource(param.Index)
    if resource == nil then return end
    -- 记录资源
    local count = player:GetProperty(key_1) or {}
    local datas = player:GetProperty(key_2) or {}
    -- 资源已被记录
    count[param.Index] = true
    player:SetProperty(key_1, count)
    -- 记录资源数目
    datas.Count = (datas.Count or 0) + 1
    -- 初始化产出列表
    datas.Yields = datas.Yields or {}
    -- 资源产出
    for yield, change in pairs(resource.Yields) do
        local modifier = YieldTable[yield]
        -- 记录产出
        datas.Yields[yield] = (datas.Yields[yield] or 0) + change
        -- 添加产出
        for i = 1, change do player:AttachModifierByID(modifier) end
    end
    player:SetProperty(key_2, datas)
end

--||======================initialize======================||--

--initialization function
function Initialize()
    -----------------------Events-----------------------
    Events.LoadGameViewStateDone.Add(ShangriLaReinitResource)
    ---------------------GameEvents---------------------
    GameEvents.ShangriLaRecord.Add(ShangriLaRecord)
    ----------------------------------------------------
    ----------------------------------------------------
    print('Initial success!')
end

include('EagleUnionShangri-La_', true)

Initialize()
