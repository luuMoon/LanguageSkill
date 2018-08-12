local Cmd = Cmd

local CmdFollow = class("CmdFollow",Cmd)
CmdFollow.useFollow = true
function CmdFollow:ctor(target,range)
    self.target = target
    self.range = range
end
function CmdFollow:Start()
    self.owner.actor:Run()
    self.owner:StartFollowEntity(self.target,self.range)
end
function CmdFollow:OnFollowEnd()
    self.isFinished = true
end
function CmdFollow:Cancel()
    self.owner:CancelFollow()
end

local CmdPick = class("CmdPick",Cmd)
function CmdPick:ctor(useTarget)
    self.useTarget = useTarget
end
function CmdPick:Start()
    self.leftTime = 1
    self.owner.actor:Pick()
end
function CmdPick:OnUpdate(deltaTime)
    self.leftTime = self.leftTime - deltaTime
    if self.leftTime <= 0 then
        self.useTarget:DropTo(self.owner)
        SceneItemManger:Remove(self.useTarget)
        self.isFinished = true
    end
end
function CmdPick:GetCmdDist()
    return 1
end
function CmdPick:CanCancel()
    return false
end

local CmdOpen = class("CmdOpen",Cmd)
function CmdOpen:ctor(target)
    self.openTarget = target
end
function CmdOpen:Start()
    self.leftTime = 1
    self.owner.actor:Open()
end
function CmdOpen:OnUpdate(deltaTime)
    self.leftTime = self.leftTime - deltaTime
    if self.leftTime <= 0 then
        ViewMenu.OpenBox(self.openTarget)
        self.isFinished = true
    end
end
function CmdOpen:GetCmdDist()
    return 1
end
function CmdOpen:CanCancel()
    return false
end

local CmdOpenDoor = class("CmdOpenDoor",Cmd)
function CmdOpenDoor:ctor(target)
    self.openTarget = target
end
function CmdOpenDoor:Start()
    --self.owner.actor:Open()
end
function CmdOpenDoor:OnUpdate(deltaTime)
    self.isFinished = true
    self.openTarget:SetDoorOpened()
    self.openTarget:OnDeadBy(self.owner)
    self.openTarget:Dead()
    self.owner.actor:Idle()
end
function CmdOpenDoor:GetCmdDist()
    return 1
end
function CmdOpenDoor:CanCancel()
    return false
end


local CmdOperateItem = class("CmdOperateItem",Cmd)
function CmdOperateItem:ctor(target)
    self.operateTarget = target
end
function CmdOperateItem:Start()
    self.owner.actor:Pick()
    self.leftTime = 1
end
function CmdOperateItem:OnUpdate(deltaTime)
    self.leftTime = self.leftTime - deltaTime
    if self.leftTime <= 0 then
        self.isFinished = true
        self.operateTarget:FeedBack(self.owner)
        self.owner.actor:Idle()
    end
end
function CmdOperateItem:GetCmdDist()
    return 1
end
function CmdOperateItem:CanCancel()
    return false
end

local CmdSkill = class("CmdSkill",Cmd)
function CmdSkill:ctor(skill,target)
    self.skill = skill
    self.target = target
end
function CmdSkill:Start()
    self.owner:CastSkill(self.skill,self.target)
end
function CmdSkill:OnUpdate(deltaTime)
    if not self.skill:IsPerform() then
        self.isFinished = true
    end
end
function CmdSkill:GetCmdDist()
    return self.skill:GetPerformMaxRange()
end
function CmdSkill:CanCancel()
    return false
end

return {CmdFollow = CmdFollow,CmdPick=CmdPick,CmdOpen = CmdOpen, CmdSkill=CmdSkill,CmdOpenDoor = CmdOpenDoor,CmdOperateItem=CmdOperateItem}
