AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/Humans/Group02/Female_02.mdl")
    self:SetUseType(SIMPLE_USE)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BBOX)
    self:PhysicsInit(SOLID_BBOX)
    self:DrawShadow(false)
    local physObj = self:GetPhysicsObject()

    if (IsValid(physObj)) then
        physObj:EnableMotion(false)
        physObj:Sleep()
    end

    timer.Simple(1, function()
        if IsValid(self) then
            self:DoAnimation()
        end
    end)
end

function ENT:SpawnFunction(ply, trace, class)
    local angles = (trace.HitPos - ply:GetPos()):Angle()
    angles.r = 0
    angles.p = 0
    angles.y = angles.y + 180

    local entity = ents.Create(class)
    entity:SetPos(trace.HitPos)
    entity:SetAngles(angles)
    entity:Spawn()

    return entity
end

function ENT:Use(activator, caller)
    if activator:Team() == impulse.Config.DefaultTeam then
        activator.currentCosmeticEditor = self
        net.Start("impulseCharacterEditorOpen")
        net.Send(activator)
    else
        activator:Notify("You must be in the "..team.GetName(impulse.Config.DefaultTeam).." team to change your appearance.")
    end
end