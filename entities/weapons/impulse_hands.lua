AddCSLuaFile()


if CLIENT then
	SWEP.PrintName = "Hands"
	SWEP.Slot = 1
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
end

SWEP.ViewModel = Model("models/weapons/v_hands.mdl")
SWEP.WorldModel	= ""

SWEP.ViewModelFOV = 0
SWEP.ViewModelFlip = false
SWEP.HoldType = "normal"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""
SWEP.IsAlwaysRaised = true

SWEP.UseHands = false

SWEP.HoldingEntity = nil
SWEP.CarryHack = nil
SWEP.Constr = nil
SWEP.PreviousOwner = nil

local THROW_VELOCITY_CAP = 150
local CARRY_FORCE_LIMIT = 40000
local CARRY_WEIGHT_LIMIT = 100
local PLAYER_PICKUP_RANGE = 200

function SWEP:Initialize()
	if SERVER then
		self.dt.carried_rag = nil
	end

	self:SetHoldType(self.HoldType)
	self.LastHand = 0
end

function SWEP:SetupDataTables()
	self:DTVar("Entity", 0, "carried_rag")
end

function SWEP:Precache()
	util.PrecacheSound("npc/vort/claw_swing1.wav")
	util.PrecacheSound("npc/vort/claw_swing2.wav")
	util.PrecacheSound("physics/plastic/plastic_box_impact_hard1.wav")	
	util.PrecacheSound("physics/plastic/plastic_box_impact_hard2.wav")	
	util.PrecacheSound("physics/plastic/plastic_box_impact_hard3.wav")	
	util.PrecacheSound("physics/plastic/plastic_box_impact_hard4.wav")
	util.PrecacheSound("physics/wood/wood_crate_impact_hard2.wav")
	util.PrecacheSound("physics/wood/wood_crate_impact_hard3.wav")
end

local player = player
local IsValid = IsValid
local CurTime = CurTime

function SWEP:Deploy()
	if not IsValid(self.Owner) then
		return
	end

	if SERVER then
		self.Owner:DrawWorldModel(false)
	end

	self:Reset()

	return true
end

function SWEP:OnRemove()
	self:Reset()
end

function SWEP:Holster()
	if not IsValid(self.Owner) then
		return
	end

	self:Reset()

    return true
end

local function SetSubPhysMotionEnabled(ent, enabled)
	if not IsValid(ent) then
		return
	end

	for i=0, ent:GetPhysicsObjectCount() - 1 do
		local subPhys = ent:GetPhysicsObjectNum(i)

		if IsValid(subPhys) then
			subPhys:EnableMotion(enabled)

			if enabled then
				subPhys:Wake()
			end
		end
	end
end

local function RemoveVelocity(ent, normalized)
	if normalized then
		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			phys:SetVelocity(Vector(0, 0, 0))
		end

		ent:SetVelocity(vector_origin)

		SetSubPhysMotionEnabled(ent, false)
		timer.Simple(0, function()
			if not IsValid(ent) then
				return
			end
			
			SetSubPhysMotionEnabled(ent, true)
		end)
	else
		local phys = ent:GetPhysicsObject()
		local velocity = IsValid(phys) and phys:GetVelocity() or ent:GetVelocity()
		local length = math.min(THROW_VELOCITY_CAP, velocity:Length2D())

		velocity:Normalize()
		velocity = velocity * length

		SetSubPhysMotionEnabled(ent, false)
		timer.Simple(0, function()
			if not IsValid(ent) then
				return
			end

			SetSubPhysMotionEnabled(ent, true)

			if IsValid(phys) then
				phys:SetVelocity(velocity)
			end

			ent:SetVelocity(velocity)
			ent:SetLocalAngularVelocity(Angle())
		end)
	end
end

local function ThrowVelocity(ent, ply, power)
	local phys = ent:GetPhysicsObject()
	local velocity = ply:GetAimVector()
	velocity = velocity * power

	SetSubPhysMotionEnabled(ent, false)
	timer.Simple(0, function()
		if IsValid(ent) then
			SetSubPhysMotionEnabled(ent, true)

			if IsValid(phys) then
				phys:SetVelocity(velocity)
			end

			ent:SetVelocity(velocity)
			ent:SetLocalAngularVelocity(Angle())
		end
	end)
end

function SWEP:Reset(throw)
	if IsValid(self.CarryHack) then
		self.CarryHack:Remove()
	end

	if IsValid(self.Constr) then
		self.Constr:Remove()
	end

	if IsValid(self.HoldingEntity) then
		if not self.HoldingEntity:IsWeapon() then
			if not IsValid(self.PreviousOwner) then
				self.HoldingEntity:SetOwner(nil)
			else
				self.HoldingEntity:SetOwner(self.PreviousOwner)
			end
		end

		local phys = self.HoldingEntity:GetPhysicsObject()

		if IsValid(phys) then
			phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
			phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
			phys:EnableCollisions(true)
			phys:EnableGravity(true)
			phys:EnableDrag(true)
			phys:EnableMotion(true)
		end

		if not throw then
			RemoveVelocity(self.HoldingEntity)
		else
			ThrowVelocity(self.HoldingEntity, self.Owner, 300)
		end

		hook.Run("GravGunOnDropped", self:GetOwner(), self.HoldingEntity, throw)
	end

	self.dt.carried_rag = nil
	self.HoldingEntity = nil
	self.CarryHack = nil
	self.Constr = nil
end

function SWEP:Drop(throw)
	if not self:CheckValidity() then return end
	if not self:AllowEntityDrop() then return end

	if SERVER then
		self.Constr:Remove()
		self.CarryHack:Remove()

		local ent = self.HoldingEntity
		local phys = ent:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableCollisions(true)
			phys:EnableGravity(true)
			phys:EnableDrag(true)
			phys:EnableMotion(true)
			phys:Wake()

			phys:ClearGameFlag(FVPHYSICS_PLAYER_HELD)
			phys:AddGameFlag(FVPHYSICS_WAS_THROWN)
		end

		if ent:GetClass() == "prop_ragdoll" then
			RemoveVelocity(ent)
		end

		ent:SetPhysicsAttacker(self:GetOwner())
		if ent.OnHandsDropped then ent.OnHandsDropped(ent, self.Owner) end
	end

	self:Reset()
end

function SWEP:CheckValidity()
	if not IsValid(self.HoldingEntity) or not IsValid(self.CarryHack) or not IsValid(self.Constr) then
		if self.HoldingEntity or self.CarryHack or self.Constr then
			self:Reset()
		end

		return false
	else
		return true
	end
end

local down = Vector(0, 0, -1)
function SWEP:AllowEntityDrop()
	local ply = self:GetOwner()
	local ent = self.CarryHack

	if not IsValid(ply) or not IsValid(ent) then return false end

	local ground = ply:GetGroundEntity()
	if ground and (ground:IsWorld() or IsValid(ground)) then return true end

	local diff = (ent:GetPos() - ply:GetShootPos()):GetNormalized()

	return down:Dot(diff) <= 0.75
end

local function IsPlayerStandsOn(ent)
	for v,ply in pairs(player.GetAll()) do
		if ply:GetGroundEntity() == ent then
			return true
		end
	end

	return false
end

if SERVER then
	local ent_diff = vector_origin
	local ent_diff_time = CurTime()

	local stand_time = 0

	function SWEP:Think()
		if not self:CheckValidity() then
			return
		end

		local curTime = CurTime()

		if curTime > ent_diff_time then
			ent_diff = self:GetPos() - self.HoldingEntity:GetPos()
			if ent_diff:Dot(ent_diff) > 40000 then
				self:Reset()
				return
			end

			ent_diff_time = curTime + 1
		end

		if curTime > stand_time then
			if IsPlayerStandsOn(self.HoldingEntity) then
				self:Reset()
				return
			end

			stand_time = curTime + 0.1
		end

		local obb = math.abs(self.HoldingEntity:GetModelBounds():Length2D())
		self.CarryHack:SetPos(self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * (35 + obb))

		local targetAng = self:GetOwner():GetAngles()

		if self.CarryHack.PreferedAngle then
			targetAng.p = 0
		end

		self.CarryHack:SetAngles(targetAng)
		self.HoldingEntity:PhysWake()
	end
end

function SWEP:CanCarry(ent)
	local phys = ent:GetPhysicsObject()

	if ent.NoCarry then
		return false
	end

	if not IsValid(phys) then
		return false
	end

	if phys:GetMass() > 100 or not phys:IsMoveable() then
		return false
	end

	if IsValid(ent.carrier) or IsValid(self.heldEntity) then
		return false
	end

	return true
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then
		return
	end

	self:SetNextPrimaryFire(CurTime() + 0.5)

	if CLIENT then return end

	if IsValid(self.HoldingEntity) then
		self:DoPickup(true)
		return
	end

	local ply = self.Owner

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = {ply, self}

	local traceEnt = util.TraceLine(trace).Entity

	if IsValid(traceEnt) then
		if traceEnt:IsDoor() then
			local doorOwners, doorGroup = traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil), traceEnt:GetSyncVar(SYNC_DOOR_GROUP, nil)

			if ply:CanLockUnlockDoor(doorOwners, doorGroup) then
				traceEnt:DoorLock()
				traceEnt:EmitSound("doors/latchunlocked1.wav")
			else
				ply:EmitSound("physics/wood/wood_crate_impact_hard3.wav", 100, math.random(90, 110))
			end
		end
	end
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() then
		return
	end
	local ply = self.Owner

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * PLAYER_PICKUP_RANGE
	trace.filter = {ply, self}

	local trace = util.TraceLine(trace)
	local traceEnt = trace.Entity

	if SERVER and IsValid(traceEnt) then
		if trace.StartPos:DistToSqr(trace.HitPos) < 86 ^ 2 then
			if traceEnt:IsDoor() then
				local doorOwners, doorGroup = traceEnt:GetSyncVar(SYNC_DOOR_OWNERS, nil), traceEnt:GetSyncVar(SYNC_DOOR_GROUP, nil)

				if ply:CanLockUnlockDoor(doorOwners, doorGroup) then
					traceEnt:DoorUnlock()
					traceEnt:EmitSound("doors/latchunlocked1.wav")
				else
					ply:EmitSound("physics/wood/wood_crate_impact_hard3.wav", 100, math.random(90, 110))
				end

				self:SetNextSecondaryFire(CurTime() + 0.5)
				return
			end
		end

		if not traceEnt:IsPlayer() and not traceEnt:IsNPC() then
			self:DoPickup()
		elseif IsValid(self.HeldEntity) and not self.HeldEntity:IsPlayerHolding() then
			self.HeldEntity = nil
		end
	else
		if IsValid(self.HoldingEntity) then
			self:DoPickup()
		end
	end
end

function SWEP:DragObject(phys, targetPos, isRagdoll)
	if not IsValid(phys) then
		return
	end

	local point = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 50
	local physDirection = targetPos - point
	local length = physDirection:Length2D()
	physDirection:Normalize()

	local mass = phys:GetMass()

	phys:SetVelocity(physDirection * math.min(length, 250))
end

function SWEP:GetRange(target)
	if IsValid(target) and target:GetClass() == "prop_ragdoll" then
		return 75
	else
		return 100
	end
end

function SWEP:AllowPickup(target)
	local phys = target:GetPhysicsObject()
	local ply = self:GetOwner()

	if IsValid(phys) and IsValid(ply) and target:GetClass() == "func_physbox" then
		return false
	end

	return (
			IsValid(phys) and IsValid(ply) and
			(not phys:HasGameFlag(FVPHYSICS_NO_PLAYER_PICKUP)) and
			phys:GetMass() <= CARRY_WEIGHT_LIMIT and
			(not IsPlayerStandsOn(target)) and
			(target.CanPickup != false) and
			hook.Run("GravGunPickupAllowed", ply, target) != false and 
			(target.GravGunPickupAllowed and (target:GravGunPickupAllowed(ply) != false) or true)
	)
end

function SWEP:DoPickup(throw)
	self.Weapon:SetNextPrimaryFire(CurTime() + .1)
	self.Weapon:SetNextSecondaryFire(CurTime() + .1)

	if IsValid(self.HoldingEntity) then
		self:Drop(throw)

		self.Weapon:SetNextSecondaryFire(CurTime() + .1)
		return
	end

	local ply = self:GetOwner()
	local trace = ply:GetEyeTrace(MASK_SHOT)

	if IsValid(trace.Entity) then
		local ent = trace.Entity
		local phys = trace.Entity:GetPhysicsObject()

		if not IsValid(phys) or not phys:IsMoveable() or phys:HasGameFlag(FVPHYSICS_PLAYER_HELD) or ent.NoCarry then
			return
		end

		-- if the client messes with phys desync will occur
		if SERVER then
			if (ply:EyePos() - trace.HitPos):Length() < self:GetRange(ent) then
				if self:AllowPickup(ent) then
					if ent.CanHandsPickup and not ent.CanHandsPickup(ent, ply) then return end
					self:Pickup()
					if ent.OnHandsPickup then ent.OnHandsPickup(ent, ply) end

					local delay = (ent:GetClass() == "prop_ragdoll") and 0.8 or 0.1

					self.Weapon:SetNextSecondaryFire(CurTime() + delay)
					return
				end
			end
		end
	end
end

function SWEP:Pickup()
	if CLIENT and IsValid(self.HoldingEntity) then return end

	local ply = self:GetOwner()
	local trace = ply:GetEyeTrace(MASK_SHOT)
	local ent = trace.Entity
	self.HoldingEntity = ent
	local entPhys = ent:GetPhysicsObject()

	if IsValid(ent) and IsValid(entPhys) then
		self.CarryHack = ents.Create("prop_physics")

		if IsValid(self.CarryHack) then
			local pos, obb = self.HoldingEntity:GetPos(), self.HoldingEntity:OBBCenter()
			pos = pos + self.HoldingEntity:GetForward() * obb.x
			pos = pos + self.HoldingEntity:GetRight() * obb.y
			pos = pos + self.HoldingEntity:GetUp() * obb.z

			self.CarryHack:SetPos(pos)
			self.CarryHack:SetModel("models/weapons/w_bugbait.mdl")
			self.CarryHack:SetColor(Color(50, 250, 50, 240))
			self.CarryHack:SetNoDraw(true)
			self.CarryHack:DrawShadow(false)

			self.CarryHack:SetHealth(999)
			self.CarryHack:SetOwner(ply)
			self.CarryHack:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			self.CarryHack:SetSolid(SOLID_NONE)

			local preferredAngles = hook.Run("GetPreferredCarryAngles", self.HoldingEntity)

			if self:GetOwner():KeyDown(IN_RELOAD) and not preferredAngles then
				preferredAngles = Angle()
			end

			if preferredAngles then
				local entAngle = self.HoldingEntity:GetAngles()
				self.CarryHack.preferredAngle = self.HoldingEntity:GetAngles()
				local grabAngle = self.HoldingEntity:GetAngles()

				grabAngle:RotateAroundAxis(entAngle:Right(), preferredAngles[1]) -- pitch
				grabAngle:RotateAroundAxis(entAngle:Up(), preferredAngles[2]) -- yaw
				grabAngle:RotateAroundAxis(entAngle:Forward(), preferredAngles[3]) -- roll

				self.CarryHack:SetAngles(grabAngle)
			else
				self.CarryHack:SetAngles(self:GetOwner():GetAngles())
			end

			self.CarryHack:Spawn()

			if not self.HoldingEntity:IsWeapon() then
				self.PreviousOwner = self.HoldingEntity:GetOwner()
				self.HoldingEntity:SetOwner(ply)
			end

			local phys = self.CarryHack:GetPhysicsObject()

			if IsValid(phys) then
				phys:SetMass(200)
				phys:SetDamping(0, 1000)
				phys:EnableGravity(false)
				phys:EnableCollisions(false)
				phys:EnableMotion(false)
				phys:AddGameFlag(FVPHYSICS_PLAYER_HELD)
			end

			entPhys:AddGameFlag(FVPHYSICS_PLAYER_HELD)

			local bone = math.Clamp(trace.PhysicsBone, 0, 1)
			local max_force = CARRY_FORCE_LIMIT

			if ent:GetClass() == "prop_ragdoll" then
				self.dt.carried_rag = ent

				bone = trace.PhysicsBone
				max_force = 0
			else
				self.dt.carried_rag = nil
			end

			self.Constr = constraint.Weld(self.CarryHack, self.HoldingEntity, 0, bone, max_force, true)
			self.Owner:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 3)..".wav", 75)

			hook.Run("GravGunOnPickedUp", self:GetOwner(), self.HoldingEntity)
		end
	end
end

function SWEP:PrintWeaponInfo(x, y, alpha)
end

function SWEP:DrawWeaponSelection()
end