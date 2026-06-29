local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LobbyConfig = require(ReplicatedStorage.Shared.LobbyConfig)

local lobbyEvents = ReplicatedStorage:FindFirstChild("LobbyEvents")
if not lobbyEvents then
	lobbyEvents = Instance.new("Folder")
	lobbyEvents.Name = "LobbyEvents"
	lobbyEvents.Parent = ReplicatedStorage
end

local lobbyStateEvent = lobbyEvents:FindFirstChild("LobbyStateChanged")
if not lobbyStateEvent then
	lobbyStateEvent = Instance.new("RemoteEvent")
	lobbyStateEvent.Name = "LobbyStateChanged"
	lobbyStateEvent.Parent = lobbyEvents
end

local countdownRemaining = nil
local countdownTask = nil

local function getLobbyState(status)
	return {
		status = status,
		playerCount = #Players:GetPlayers(),
		minimumPlayers = LobbyConfig.MinimumPlayers,
		maximumPlayers = LobbyConfig.MaximumPlayers,
		countdownRemaining = countdownRemaining,
	}
end

local function broadcastLobbyState(status)
	lobbyStateEvent:FireAllClients(getLobbyState(status))
end

local function stopCountdown()
	countdownRemaining = nil
	countdownTask = nil
	broadcastLobbyState("Waiting for players")
end

local function startCountdown()
	if countdownTask then
		return
	end

	countdownTask = task.spawn(function()
		countdownRemaining = LobbyConfig.CountdownSeconds

		while countdownRemaining > 0 do
			if #Players:GetPlayers() < LobbyConfig.MinimumPlayers then
				stopCountdown()
				return
			end

			broadcastLobbyState("Match starting soon")
			task.wait(1)
			countdownRemaining -= 1
		end

		broadcastLobbyState("Launching match")
		-- TODO: Reserve and teleport players into a battle royale match server.
		task.wait(LobbyConfig.IntermissionSeconds)
		stopCountdown()
	end)
end

local function refreshLobby()
	local playerCount = #Players:GetPlayers()

	if playerCount >= LobbyConfig.MinimumPlayers then
		startCountdown()
	else
		broadcastLobbyState("Waiting for players")
	end
end

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("LobbyReady", true)
	refreshLobby()
	lobbyStateEvent:FireClient(player, getLobbyState("Welcome to the lobby"))
end)

Players.PlayerRemoving:Connect(function()
	task.defer(refreshLobby)
end)

broadcastLobbyState("Waiting for players")
