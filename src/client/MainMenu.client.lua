local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")


local function destroyScreenGui(instance)
	local current = instance
	while current and current ~= playerGui do
		if current:IsA("ScreenGui") then
			current:Destroy()
			return
		end

		current = current.Parent
	end
end

local function removeOldLobbyStatusGui()
	local oldLobbyHud = playerGui:FindFirstChild("LobbyHud")
	if oldLobbyHud then
		oldLobbyHud:Destroy()
	end

	for _, descendant in ipairs(playerGui:GetDescendants()) do
		if descendant:IsA("TextLabel") then
			if descendant.Text == "Waiting for lobby data..." or string.find(descendant.Text, "Players:") then
				destroyScreenGui(descendant)
			end
		end
	end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainMenu"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local background = Instance.new("Frame")
background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
background.BorderSizePixel = 0
background.Size = UDim2.fromScale(1, 1)
background.Parent = screenGui

local title = Instance.new("TextLabel")
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.Position = UDim2.fromScale(0.5, 0.34)
title.Size = UDim2.fromOffset(520, 72)
title.Text = "ANI ROYALE"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Parent = background

local barBack = Instance.new("Frame")
barBack.AnchorPoint = Vector2.new(0.5, 0.5)
barBack.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
barBack.BorderSizePixel = 0
barBack.Position = UDim2.fromScale(0.5, 0.52)
barBack.Size = UDim2.fromOffset(360, 12)
barBack.Parent = background

local barBackCorner = Instance.new("UICorner")
barBackCorner.CornerRadius = UDim.new(1, 0)
barBackCorner.Parent = barBack

local barFill = Instance.new("Frame")
barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
barFill.BorderSizePixel = 0
barFill.Size = UDim2.fromScale(0, 1)
barFill.Parent = barBack

local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(1, 0)
barFillCorner.Parent = barFill

local loadingText = Instance.new("TextLabel")
loadingText.AnchorPoint = Vector2.new(0.5, 0.5)
loadingText.BackgroundTransparency = 1
loadingText.Font = Enum.Font.GothamMedium
loadingText.Position = UDim2.fromScale(0.5, 0.56)
loadingText.Size = UDim2.fromOffset(360, 28)
loadingText.Text = "Loading assets..."
loadingText.TextColor3 = Color3.fromRGB(180, 180, 180)
loadingText.TextScaled = true
loadingText.Parent = background

local playButton = Instance.new("TextButton")
playButton.AnchorPoint = Vector2.new(0.5, 0.5)
playButton.AutoButtonColor = true
playButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
playButton.BorderSizePixel = 0
playButton.Font = Enum.Font.GothamBold
playButton.Position = UDim2.fromScale(0.5, 0.64)
playButton.Size = UDim2.fromOffset(220, 54)
playButton.Text = "PLAY"
playButton.TextColor3 = Color3.fromRGB(0, 0, 0)
playButton.TextScaled = true
playButton.Visible = false
playButton.Parent = background

local playCorner = Instance.new("UICorner")
playCorner.CornerRadius = UDim.new(0, 10)
playCorner.Parent = playButton

local function finishLoading()
	loadingText.Text = "Ready"
	playButton.Visible = true
end

local loadingTween = TweenService:Create(
	barFill,
	TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	{ Size = UDim2.fromScale(1, 1) }
)

loadingTween.Completed:Connect(finishLoading)
loadingTween:Play()

playButton.Activated:Connect(function()
	removeOldLobbyStatusGui()
	task.defer(removeOldLobbyStatusGui)
	task.delay(0.5, removeOldLobbyStatusGui)
	screenGui.Enabled = false
end)
