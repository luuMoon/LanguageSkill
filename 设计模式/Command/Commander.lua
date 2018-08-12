---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by wangliang.
--- DateTime: 2018/3/22 下午3:18
---
local Cmd = class("Cmd")
function Cmd:Start()
end
function Cmd:OnUpdate(deltaTime)
end
function Cmd:Over()
end
function Cmd:Cancel()
end
function Cmd:CanCancel()
    return true
end
function Cmd:CanTransTo(otherCmd)
end
_G.Cmd = Cmd

--只有2个命令的命令队列，定制化
local CmdD = class("CmdD",Cmd)

function CmdD:Start()
    self:NextCmd()
end
function CmdD:PushCmd(cmd)
    cmd.owner = self.owner
    if self.first then
        self.second = self.first
        self.first = cmd
    else
        self.first = cmd
    end
end
function CmdD:OnUpdate(deltaTime)
    if self.curCmd then
        self.curCmd:OnUpdate(deltaTime)
        if self.curCmd.isFinished then
            self:NextCmd()
        end
    end
end

function CmdD:NextCmd()
    self.runIndex = (self.runIndex or 0) + 1
    if self.curCmd then
        self.curCmd:Over()
    end
    if self.runIndex == 1 then
        self.curCmd = self.first
    elseif self.runIndex == 2 then
        self.curCmd = self.second
    else
        self.curCmd = nil
    end
    if self.curCmd then
        self.curCmd:Start()
    else
        self.isFinished = true
    end
end

function CmdD:Cancel()
    if self.curCmd then
        self.curCmd:Cancel()
        self.curCmd = nil
        self.runIndex = nil
    end
end

function CmdD:CanCancel()
    if self.curCmd then
        return self.curCmd:CanCancel()
    end
    return true
end

function CmdD:CanTransTo(otherCmd)
    if self.curCmd then
        return self.curCmd:CanTransTo(otherCmd)
    else
        return true
    end
end
_G.CmdD = CmdD

--命令执行器，只执行单一命令
local Commander = class("Commander")

function Commander:ctor(owner)
    self.owner = owner
end

--执行命令，nextCmd用于存后续的一个
function Commander:ExecCmd(cmd,nextCmd)
    if not self.currentCmd or self.currentCmd:CanTransTo(cmd) then
        if self.currentCmd then
            self.currentCmd:Cancel()
        end
        self.nextCmd = nextCmd
        self:_StartCmd(cmd)
    end
end

function Commander:_StartCmd(cmd)
    cmd.owner = self.owner
    self.currentCmd = cmd
    cmd.isFinished = false
    cmd:Start()
end

function Commander:OnUpdate(deltaTime)
    if self.currentCmd then
        self.currentCmd:OnUpdate(deltaTime)
        if self.currentCmd.isFinished then
            local nowCmd = self.currentCmd
            self.currentCmd = nil
            nowCmd:Over()
            local cmd = self.nextCmd
            if cmd then
                self.nextCmd = nil
                self:_StartCmd(cmd)
            end
        end
    end
end

function Commander:Cancel()
    if self.currentCmd then
        self.currentCmd:Cancel()
        self.currentCmd = nil
    end
    if self.nextCmd then
        self.nextCmd = nil
    end
end

function Commander:CanCancel()
    if self.currentCmd then
        return self.currentCmd:CanCancel()
    end
    return true
end

_G.Commander = Commander