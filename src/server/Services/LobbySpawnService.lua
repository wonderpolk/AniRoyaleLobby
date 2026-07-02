local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LOBBY_SPAWN_LOCATION_NAME = "LobbySpawnLocation"

local LobbySpawnService = {}
LobbySpawnService.SpawnNames = { "Member1", "member1", "SlotOne", "slotone", "Slot1", "slot1" }

local function isSpawnName(name)
	local loweredName = string.lower(name)

	for _, spawnName in ipairs(LobbySpawnService.SpawnNames) do
		if loweredName == string.lower(spawnName) then
			return true
		end
	end

	return false
end

local function findLobbyRoom()
	local directLobbyRoom = Workspace:FindFirstChild("LobbyRoom")
	if directLobbyRoom then
		return directLobbyRoom
	end

	return Workspace:FindFirstChild("LobbyRoom", true)
end

local function getLobbyRoom()
	local startTime = os.clock()
	local lobbyRoom = findLobbyRoom()

	while not lobbyRoom and os.clock() - startTime < 30 do
		task.wait(0.25)
		lobbyRoom = findLobbyRoom()
	end

	return lobbyRoom
end

local function findSpawnPartInLobby(lobbyRoom)
	for _, spawnName in ipairs(LobbySpawnService.SpawnNames) do
		local directSpawn = lobbyRoom:FindFirstChild(spawnName)
		if directSpawn and directSpawn:IsA("BasePart") then
			return directSpawn
		end

		local descendantSpawn = lobbyRoom:FindFirstChild(spawnName, true)
		if descendantSpawn and descendantSpawn:IsA("BasePart") then
			return descendantSpawn
		end
	end

	for _, descendant in ipairs(lobbyRoom:GetDescendants()) do
		if descendant:IsA("BasePart") and isSpawnName(descendant.Name) then
			return descendant
		end
	end

	return nil
end

local function getSpawnPart()
	local lobbyRoom = getLobbyRoom()
	if not lobbyRoom then
		return nil
	end

	local spawnPart = findSpawnPartInLobby(lobbyRoom)
	if spawnPart then
		return spawnPart
	end

	for _, spawnName in ipairs(LobbySpawnService.SpawnNames) do
		local directSpawn = lobbyRoom:WaitForChild(spawnName, 5)
		if directSpawn and directSpawn:IsA("BasePart") then
			return directSpawn
		end
	end

	spawnPart = findSpawnPartInLobby(lobbyRoom)
	if spawnPart then
		return spawnPart
	end

	for _, descendant in ipairs(Workspace:GetDescendants()) do
		if descendant:IsA("BasePart") and isSpawnName(descendant.Name) then
			return descendant
		end
	end

	return nil
end

local function getOrCreateSpawnLocation()
	local spawnPart = getSpawnPart()
	if not spawnPart then
		return nil
	end

	local parent = spawnPart.Parent or Workspace
	local spawnLocation = parent:FindFirstChild(LOBBY_SPAWN_LOCATION_NAME)

	if not spawnLocation then
		spawnLocation = Instance.new("SpawnLocation")
		spawnLocation.Name = LOBBY_SPAWN_LOCATION_NAME
		spawnLocation.Parent = parent
	end

	spawnLocation.Anchored = true
	spawnLocation.CanCollide = false
	spawnLocation.Transparency = 1
	spawnLocation.Enabled = true
	spawnLocation.Neutral = true
	spawnLocation.Duration = 0
	spawnLocation.Size = Vector3.new(4, 1, 4)
	spawnLocation.CFrame = spawnPart.CFrame

	return spawnLocation
end

local function assignRespawnLocation(player)
	local spawnLocation = getOrCreateSpawnLocation()
	if not spawnLocation then
		warn("LobbySpawnService could not create a lobby SpawnLocation.")
		return
	end

	player.RespawnLocation = spawnLocation
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
	local rootPart = character:WaitForChild("HumanoidRootPart", 10)
	if not rootPart then
		warn("LobbySpawnService could not find a HumanoidRootPart to move.")
		return
	end

	local spawnPart = getSpawnPart()
	if not spawnPart then
		warn("LobbySpawnService could not find a Member1 spawn part in Workspace.")
		return
	end

	local spawnCFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
	character:PivotTo(spawnCFrame)
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero
end

function LobbySpawnService:_setupCharacter(character)
	freezeCharacter(character)
	moveCharacterToLobby(character)

	task.delay(0.25, function()
		if character.Parent then
			freezeCharacter(character)
			moveCharacterToLobby(character)
		end
	end)

	task.delay(1, function()
		if character.Parent then
			freezeCharacter(character)
			moveCharacterToLobby(character)
		end
	end)
end

function LobbySpawnService:_setupPlayer(player)
	task.spawn(function()
		assignRespawnLocation(player)
	end)

	player.CharacterAdded:Connect(function(character)
		assignRespawnLocation(player)
		self:_setupCharacter(character)
	end)

	if player.Character then
		assignRespawnLocation(player)
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
