-- ShangriLaUnitPanel
-- Author: HSbF6HSO3F
-- DateCreated: 2025/8/19 8:10:20
--------------------------------------------------------------
--||=======================include========================||--
include('EagleCore')
include('EagleResources')

Resources = EagleResources:new(true)

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
    local count = player:GetProperty(key_1) or {}
    local resourceData = player:GetResources()
    -- 单位是否相邻或位于资源单元格
    local tplots = Map.GetAdjacentPlots(pUnit:GetX(), pUnit:GetY())
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
    else
        -- 资源是否已经被记录
        if count[details.Index] == true then
            details.Reason = Locale.Lookup('LOC_EAGLE_ACTION_REASON_RESOURCES_RECORDED')
        else
            details.Disable = false
        end
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
        EagleDebug:printd(detail, '', 'Details')
        local disable = detail.Disable
        -- 设置按钮状态
        Controls.Record:SetDisabled(disable)
        Controls.Record:SetAlpha((disable and 0.7) or 1)
        -- 功能提示文本
        local tooltip = Locale.Lookup('LOC_SHANGRI_LA_RECORD_TITLE') ..
            '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_SHANGRI_LA_RECORD_DESC')
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

-- 初始化
function ShangriLaPanel:Init()
    local context = ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
    if context then
        -- 更改父控件
        Controls.ShangriLaGrid:ChangeParent(context)
        -- 刷新
        self:Refresh()
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
    --Events.UnitActivate.Add(StLouisUnitActive)
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
