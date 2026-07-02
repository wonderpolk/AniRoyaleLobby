local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local LOCK_ACTION_NAME = "LobbyMovementLock"
local LOCK_PRIORITY = 3000

local function sinkMovement()
	return Enum.ContextActionResult.Sink
end

local function lockHumanoid(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
	if not humanoid then
		return
	end

	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.AutoRotate = false
end

local function disablePlayerModuleControls()
	local playerScripts = player:WaitForChild("PlayerScripts")
	local playerModule = playerScripts:WaitForChild("PlayerModule")
	local controls = require(playerModule):GetControls()
	controls:Disable()
end

ContextActionService:BindActionAtPriority(
	LOCK_ACTION_NAME,
	sinkMovement,
	false,
	LOCK_PRIORITY,
	Enum.PlayerActions.CharacterForward,
	Enum.PlayerActions.CharacterBackward,
	Enum.PlayerActions.CharacterLeft,
	Enum.PlayerActions.CharacterRight,
	Enum.PlayerActions.CharacterJump
)

player.CharacterAdded:Connect(lockHumanoid)

if player.Character then
	lockHumanoid(player.Character)
end

disablePlayerModuleControls()
