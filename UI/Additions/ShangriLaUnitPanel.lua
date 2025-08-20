-- ShangriLaUnitPanel
-- Author: HSbF6HSO3F
-- DateCreated: 2025/8/19 8:10:20
--------------------------------------------------------------
--||=======================include========================||--
include('EagleCore')
include('EagleResources')

Resources = EagleResources:new(true)
ActReason = DB.MakeHash('SHANGRI_LA_RECORD')

--||===================local variables====================||--

local key_1 = 'ShangriLaResource'
local key_2 = 'ShangriLaResCount'

--||======================MetaTable=======================||--

ShangriLaPanel = {}

-- 获取细节
function ShangriLaPanel.GetDetails(pUnit)
    local details, player = {
        Disable = true,
        Index = -1,
        Reason = ''
    }, Players[pUnit:GetOwner()]
    -- 单位是否拥有移动力
    if pUnit:GetMovesRemaining() < 1 then
        details.Reason = Locale.Lookup('LOC_EAGLE_ACTION_REASON_NO_MOVEMENT')
        return details
    end

    local count = player:GetProperty(key_1) or {}
    local resourceData = player:GetResources()
    -- 单位是否相邻或位于资源单元格
    local tplots = Map.GetNeighborPlots(pUnit:GetX(), pUnit:GetY(), 1)
    for _, plot in ipairs(tplots) do
        local resource = plot:GetResourceType()
        if resource ~= -1 and resourceData:IsResourceVisible(resource) then
            details.Index = resource
            if count[resource] ~= true then break end
        end
    end
    -- 是否拥有资源
    if details.Index == -1 then
        details.Reason = Locale.Lookup('LOC_EAGLE_ACTION_REASON_NO_ON_OR_ADJACENT_RESOURCES')
        return details
    end
    -- 资源是否已经被记录
    if count[details.Index] == true then
        details.Reason = Locale.Lookup('LOC_EAGLE_ACTION_REASON_RESOURCES_RECORDED')
    else
        details.Disable = false
    end
    return details
end

-- 重设按钮
function ShangriLaPanel:Refresh()
    local unit = UI.GetHeadSelectedUnit()
    if unit == nil then return end
    -- 检查是否是香格里拉
    if EagleCore.CheckLeaderMatched(
            unit:GetOwner(), 'LEADER_SHANGRI_LA_CV38'
        ) then
        -- 显示按钮
        Controls.ShangriLaGrid:SetHide(false)
        -- 获取细节
        local detail = self.GetDetails(unit)
        local disable = detail.Disable
        -- 设置按钮状态
        Controls.Record:SetDisabled(disable)
        Controls.Record:SetAlpha((disable and 0.7) or 1)
        -- 功能提示文本
        local tooltip = Locale.Lookup('LOC_SHANGRI_LA_RECORD_TITLE') ..
            '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_SHANGRI_LA_RECORD_DESC')
        -- 记录资源总结
        local player = Players[unit:GetOwner()]
        local count = player:GetProperty(key_1) or {}
        local datas = player:GetProperty(key_2) or {}
        if datas.Count and datas.Count > 0 then
            tooltip = tooltip .. '[NEWLINE][NEWLINE]' ..
                Locale.Lookup('LOC_SHANGRI_LA_RECORDED', datas.Count)
                .. '[NEWLINE][ICON_Bullet]'
            local tab = Locale.Lookup('LOC_SHANGRI_LA_RECORD_TAB')
            local first = true
            for index, _ in pairs(count) do
                local resource = Resources:GetResource(index)
                if resource ~= nil then
                    if not first then
                        tooltip = tooltip .. tab
                    end
                    tooltip = tooltip .. Locale.Lookup('LOC_SHANGRI_LA_RECORD_RESOURCE', resource.Icon, resource.Name)
                    first = false
                end
            end
        end
        -- 记录产出总结
        local total, yields = '', datas.Yields or {}
        for key, val in pairs(yields) do
            local tip = 'LOC_SHANGRI_LA_' .. key
            total = total .. Locale.Lookup(tip, val)
        end
        if total ~= '' then
            tooltip = tooltip .. '[NEWLINE][NEWLINE]' ..
                Locale.Lookup('LOC_SHANGRI_LA_RECORD_YIELD') .. total
        end
        -- 其他
        if disable then
            tooltip = tooltip .. '[NEWLINE][NEWLINE]' .. detail.Reason
        else
            local resource = Resources:GetResource(detail.Index)
            if resource ~= nil then
                tooltip = tooltip .. '[NEWLINE][NEWLINE]' ..
                    Locale.Lookup('LOC_SHANGRI_LA_RECORD_DETAIL', resource.Icon, resource.Name)
                    .. '[NEWLINE]' .. resource:GetChangeYieldsTooltip()
            else
                print('Error: Resource not found.')
            end
        end
        -- 设置提示文本
        Controls.Record:SetToolTipString(tooltip)
    else
        -- 隐藏按钮
        Controls.ShangriLaGrid:SetHide(true)
    end
    -- 刷新
    ContextPtr:LookUpControl("/InGame/UnitPanel"):RequestRefresh()
end

-- 回调函数
function ShangriLaPanel:Callback()
    -- 获取单位
    local unit = UI.GetHeadSelectedUnit()
    if unit == nil then return end
    -- 获取细节
    local detail = self.GetDetails(unit)
    if detail.Disable then return end
    -- 请求玩家操作
    UI.RequestPlayerOperation(Game.GetLocalPlayer(),
        PlayerOperations.EXECUTE_SCRIPT, {
            UnitID  = unit:GetID(),
            Index   = detail.Index,
            OnStart = 'ShangriLaRecord',
        }
    ); Network.BroadcastPlayerInfo()
end

-- 注册函数
function ShangriLaPanel:Register()
    Controls.Record:RegisterCallback(Mouse.eLClick, function() self:Callback() end)
    Controls.Record:RegisterCallback(Mouse.eMouseEnter, EagleUnionEnter)
end

-- 初始化
function ShangriLaPanel:Init()
    local context = ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
    if context then
        -- 更改父控件
        Controls.ShangriLaGrid:ChangeParent(context)
        -- 注册并刷新
        self:Register(); self:Refresh()
    end
end

--||===================Events functions===================||--

-- 刷新按钮
function ShangriLaRefresh()
    ShangriLaPanel:Refresh()
end

-- 单位选择
function ShangriLaUnitSelectedChanged(playerId, unitId, locationX, locationY, locationZ, isSelected, isEditable)
    if isSelected and playerId == Game.GetLocalPlayer() then ShangriLaPanel:Refresh() end
end

--On Unit Active
function ShangriLaUnitActive(owner, unitID, x, y, eReason)
    local pUnit = UnitManager.GetUnit(owner, unitID)
    if eReason == ActReason then
        -- SimUnitSystem.SetAnimationState(pUnit, "SPAWN", "IDLE")
        --get the unit x and y
        -- local uX, uY = pUnit:GetX(), pUnit:GetY()
        --play the effect
        -- WorldView.PlayEffectAtXY("ENTERPRISE_RECOVER", uX, uY)
        --refersh the panel
        ShangriLaPanel:Refresh()
    end
end

-- 添加按钮
function ShangriLaAddButton()
    ShangriLaPanel:Init()
end

function ShangriLaReinit()
    Resources = EagleResources:new(true)
end

--||======================initialize======================||--

--Initialize
function Initialize()
    Events.LoadGameViewStateDone.Add(ShangriLaAddButton)
    Events.LoadGameViewStateDone.Add(ShangriLaReinit)
    Events.UnitSelectionChanged.Add(ShangriLaUnitSelectedChanged)
    Events.UnitActivate.Add(ShangriLaUnitActive)
    ------------------------------------------
    Events.UnitAddedToMap.Add(ShangriLaRefresh)
    Events.UnitOperationSegmentComplete.Add(ShangriLaRefresh)
    Events.UnitCommandStarted.Add(ShangriLaRefresh)
    Events.UnitDamageChanged.Add(ShangriLaRefresh)
    Events.UnitMoveComplete.Add(ShangriLaRefresh)
    Events.UnitChargesChanged.Add(ShangriLaRefresh)
    Events.UnitPromoted.Add(ShangriLaRefresh)
    Events.UnitOperationsCleared.Add(ShangriLaRefresh)
    Events.UnitOperationAdded.Add(ShangriLaRefresh)
    Events.UnitOperationDeactivated.Add(ShangriLaRefresh)
    Events.UnitMovementPointsChanged.Add(ShangriLaRefresh)
    Events.UnitMovementPointsCleared.Add(ShangriLaRefresh)
    Events.UnitMovementPointsRestored.Add(ShangriLaRefresh)
    Events.UnitAbilityLost.Add(ShangriLaRefresh)
    Events.UnitRemovedFromMap.Add(ShangriLaRefresh)
    ------------------------------------------
    Events.ResourceAddedToMap.Add(ShangriLaRefresh)
    Events.PlayerResourceChanged.Add(ShangriLaRefresh)
    Events.ResourceRemovedFromMap.Add(ShangriLaRefresh)
    ------------------------------------------
    Events.PhaseBegin.Add(ShangriLaRefresh)
    ------------------------------------------
    print('Initial success!')
end

include('ShangriLaUnitPanel_', true)

Initialize()
