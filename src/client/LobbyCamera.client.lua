local Workspace = game:GetService("Workspace")

local camera = Workspace.CurrentCamera

local function findNamedPart(parent, partName)
	if not parent or partName == "" then
		return nil
	end

	local directChild = parent:FindFirstChild(partName)
	if directChild and directChild:IsA("BasePart") then
		return directChild
	end

	local descendant = parent:FindFirstChild(partName, true)
	if descendant and descendant:IsA("BasePart") then
		return descendant
	end

	local workspacePart = Workspace:FindFirstChild(partName, true)
	if workspacePart and workspacePart:IsA("BasePart") then
		return workspacePart
	end

	return nil
end

local function getLobbyCameraPart()
	local lobbyRoom = Workspace:WaitForChild("LobbyRoom", 10)
	if not lobbyRoom then
		warn("LobbyCamera could not find Workspace.LobbyRoom.")
		return nil
	end

	local lobbyCamera = lobbyRoom:WaitForChild("LobbyCamera", 10)
	if not lobbyCamera then
		warn("LobbyCamera could not find Workspace.LobbyRoom.LobbyCamera.")
		return nil
	end

	local cameraPartName = lobbyCamera:FindFirstChild("CamPart")
	if cameraPartName and cameraPartName:IsA("StringValue") then
		local namedPart = findNamedPart(lobbyRoom, cameraPartName.Value)
		if namedPart then
			return namedPart
		end
	end

	if lobbyCamera:IsA("BasePart") then
		return lobbyCamera
	end

	return nil
end

local function setLobbyCamera()
	if not camera then
		return
	end

	local cameraPart = getLobbyCameraPart()
	if not cameraPart then
		return
	end

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = cameraPart.CFrame
end

setLobbyCamera()

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	camera = Workspace.CurrentCamera
	setLobbyCamera()
end)
