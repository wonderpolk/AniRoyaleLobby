local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LobbyHud"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel = 0
panel.Position = UDim2.fromScale(0.5, 0.04)
panel.Size = UDim2.fromOffset(420, 120)
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.Text = "ANI ROYALE"
title.TextColor3 = Color3.fromRGB(255, 221, 89)
title.TextScaled = true
title.Position = UDim2.fromOffset(20, 12)
title.Size = UDim2.new(1, -40, 0, 34)
title.Parent = panel

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamSemibold
status.Text = "Waiting for lobby data..."
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.TextScaled = true
status.Position = UDim2.fromOffset(20, 52)
status.Size = UDim2.new(1, -40, 0, 26)
status.Parent = panel

local count = Instance.new("TextLabel")
count.BackgroundTransparency = 1
count.Font = Enum.Font.Gotham
count.Text = "Players: 0/30"
count.TextColor3 = Color3.fromRGB(174, 214, 241)
count.TextScaled = true
count.Position = UDim2.fromOffset(20, 82)
count.Size = UDim2.new(1, -40, 0, 22)
count.Parent = panel

local lobbyEvents = ReplicatedStorage:WaitForChild("LobbyEvents")
local lobbyStateEvent = lobbyEvents:WaitForChild("LobbyStateChanged")

local function renderLobbyState(state)
	local countdownText = ""
	if state.countdownRemaining then
		countdownText = string.format(" · %ds", state.countdownRemaining)
	end

	status.Text = string.format("%s%s", state.status, countdownText)
	count.Text = string.format(
		"Players: %d/%d · Need %d to start",
		state.playerCount,
		state.maximumPlayers,
		state.minimumPlayers
	)
end

lobbyStateEvent.OnClientEvent:Connect(renderLobbyState)
