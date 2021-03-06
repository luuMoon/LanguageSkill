local _G = _G
local CfgData = _G.CfgData
local metaCmds = require("app.object.controller.player.PlayerMetaCmd")
local CmdFollow,CmdPick,CmdOpen,CmdOpenDoor,CmdOperateItem,CmdSkill = metaCmds.CmdFollow,metaCmds.CmdPick,metaCmds.CmdOpen,metaCmds.CmdOpenDoor,metaCmds.CmdOperateItem, metaCmds.CmdSkill
local CmdD = CmdD

local CmdUse = class("CmdUse",CmdD)
CmdUse.useFollow = true

function CmdUse.CanUse(player,target)
    if target.isMonster then return true end
    local produceSkillIds = target.dataModel:GetProduceSkillId()
    if not produceSkillIds then return true end
    if target.dataModel:CanProduceWithoutSkills() then return true end
    local skill = player.dataModel:GetProduceSkillFor(target.dataModel)
    if not skill then
        --print("need weapon",valStr(produceSkillIds))
        _G.Pop:Warning(CfgData:GetText("you need weapon"))
        return false
    end
    if not skill:CanPerform() then
        --_G.Pop:Warning(CfgData:GetTextq("skill cannot perform"))
        return false
    end
    return true,skill
end

function CmdUse.CreateUseCmd(target,skill)
    if target.isMonster then
        return CmdOpen.new(target)
    end
    local targetData = target.dataModel
    if skill then
        return CmdSkill.new(skill,target)
    elseif targetData:IsPickable() then
        return CmdPick.new(target)
    elseif targetData:IsSearchable() then
        return CmdOpen.new(target)
    elseif targetData:IsOpenDoor() then
        return CmdOpenDoor.new(target)
    elseif targetData:IsOperateItem() then
        return CmdOperateItem.new(target)
    end
end

function CmdUse:ctor(target,skill)
    self.target = target
    self.skill = skill
end

function CmdUse:Start()
    local useCmd = CmdUse.CreateUseCmd(self.target,self.skill)
    self:PushCmd(useCmd)
    local dist = self.owner:DistNH(self.target)
    local useDist = useCmd:GetCmdDist()
    if (dist > useDist) or (not self.owner:IsLookAt(self.target)) then
        self:PushCmd(CmdFollow.new(self.target,useDist))
    end
    CmdUse.super.Start(self)
end

function CmdUse:OnFollowEnd()
    if self.curCmd and self.curCmd.useFollow then
        self.curCmd:OnFollowEnd()
    end
end

local CmdAttack = class("CmdAttack",CmdD)
CmdAttack.useFollow = true

function CmdAttack.CanAttack(player)
    local skill = player.dataModel:GetAtkSkill()
    if not skill then return false end
    if not skill:CanPerform() then
        _G.Pop:Warning(CfgData:GetText("skill cannot perform"))
        return false
    end
    return true,skill
end

function CmdAttack:ctor(target,skill)
    self.target = target
    self.skill = skill
end

function CmdAttack:Start()
    local atkCmd = CmdSkill.new(self.skill,self.target)
    self:PushCmd(atkCmd)
    if self.target then
        local dist = self.owner:DistNH(self.target)
        local atkDist = atkCmd:GetCmdDist()
        if (dist > atkDist) or (not self.owner:IsLookAt(self.target)) then
            self:PushCmd(CmdFollow.new(self.target,atkDist))
        end
    end
    CmdAttack.super.Start(self)
end

function CmdAttack:OnFollowEnd()
    if self.curCmd and self.curCmd.useFollow then
        self.curCmd:OnFollowEnd()
    end
end

return {CmdUse = CmdUse,CmdAttack = CmdAttack}
