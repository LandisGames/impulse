impulse.Ops = impulse.Ops or {}
impulse.Ops.EventManager = impulse.Ops.EventManager or {}
impulse.Ops.EventManager.Sequences = impulse.Ops.EventManager.Sequences or {}
impulse.Ops.EventManager.Scenes = impulse.Ops.EventManager.Scenes or {}
impulse.Ops.EventManager.Data = impulse.Ops.EventManager.Data or {}
impulse.Ops.EventManager.Config = impulse.Ops.EventManager.Config or {}

file.CreateDir("impulse/ops/eventmanager")

hook.Run("OpsSetup")