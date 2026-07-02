local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LobbySpawnService = {}
LobbySpawnService.SpawnNames = { "Member1", "member1" }

local function findLobbyRoom()
	return Workspace:FindFirstChild("LobbyRoom")
end

local function findSpawnPart()
	local lobbyRoom = findLobbyRoom()
	if not lobbyRoom then
		return nil
	end

	for _, spawnName in ipairs(LobbySpawnService.SpawnNames) do
		local spawnPart = lobbyRoom:FindFirstChild(spawnName, true)
		if spawnPart and spawnPart:IsA("BasePart") then
			return spawnPart
		end
	end

	return nil
end

local function freezeCharacter(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
	if not humanoid then
		warn("LobbySpawnService could not find a Humanoid to freeze.")
		return
	end

	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.AutoRotate = false
end

local function moveCharacterToLobby(character)
	character:WaitForChild("HumanoidRootPart", 10)

	local spawnPart = findSpawnPart()
	if not spawnPart then
		warn("LobbySpawnService could not find Workspace.LobbyRoom.Member1.")
		return
	end

	local spawnCFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
	character:PivotTo(spawnCFrame)
end

function LobbySpawnService:_setupCharacter(character)
	moveCharacterToLobby(character)
	freezeCharacter(character)
end

function LobbySpawnService:_setupPlayer(player)
	player.CharacterAdded:Connect(function(character)
		self:_setupCharacter(character)
	end)

	if player.Character then
		self:_setupCharacter(player.Character)
	end
end

function LobbySpawnService:Init()
	Players.PlayerAdded:Connect(function(player)
		self:_setupPlayer(player)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:_setupPlayer(player)
	end
end

return LobbySpawnService
