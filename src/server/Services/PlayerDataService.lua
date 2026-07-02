local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataTemplate = require(ReplicatedStorage.Shared.Configs.DataTemplate)

local PlayerDataService = {}
PlayerDataService.Profiles = {}
PlayerDataService.DataStore = nil
PlayerDataService.UseStudioFallback = false

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, child in pairs(value) do
		copy[key] = deepCopy(child)
	end

	return copy
end

local function reconcile(target, template)
	for key, templateValue in pairs(template) do
		if target[key] == nil then
			target[key] = deepCopy(templateValue)
		elseif type(target[key]) == "table" and type(templateValue) == "table" then
			reconcile(target[key], templateValue)
		end
	end

	return target
end

function PlayerDataService:Init()
	local packages = ReplicatedStorage:FindFirstChild("Packages")
	local dataServicePackage = packages and packages:FindFirstChild("DataService")

	if dataServicePackage then
		self.DataStore = require(dataServicePackage).server
		self.DataStore:init({
			template = DataTemplate,
			useMock = RunService:IsStudio(),
			resetData = false,
		})
	elseif RunService:IsStudio() then
		self.UseStudioFallback = true
		warn("DataService package missing; using PlayerDataService Studio fallback data.")
	else
		error("DataService package missing. Run `wally install` before publishing or running a live server.")
	end

	Players.PlayerAdded:Connect(function(player)
		self:_loadPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:_releasePlayer(player)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:_loadPlayer(player)
	end
end

function PlayerDataService:_loadPlayer(player)
	if not self.UseStudioFallback or self.Profiles[player] then
		return
	end

	self.Profiles[player] = reconcile(deepCopy(DataTemplate), DataTemplate)
end

function PlayerDataService:_releasePlayer(player)
	self.Profiles[player] = nil
end

function PlayerDataService:GetProfile(player)
	if self.DataStore then
		return self.DataStore:getProfile(player)
	end

	if not self.Profiles[player] then
		self:_loadPlayer(player)
	end

	return self.Profiles[player]
end

function PlayerDataService:Get(player, key)
	if self.DataStore then
		self.DataStore:waitForData(player)
		return self.DataStore:get(player, { key })
	end

	local profile = self:GetProfile(player)
	return profile and profile[key] or nil
end

function PlayerDataService:Set(player, key, value)
	if self.DataStore then
		self.DataStore:waitForData(player)
		self.DataStore:set(player, { key }, value)
		return true
	end

	local profile = self:GetProfile(player)
	if not profile then
		return false
	end

	profile[key] = value
	return true
end

function PlayerDataService:Update(player, key, callback)
	if self.DataStore then
		self.DataStore:waitForData(player)
		local nextValue = self.DataStore:update(player, { key }, callback)
		return true, nextValue
	end

	local currentValue = self:Get(player, key)
	local nextValue = callback(currentValue)

	if nextValue == nil then
		return false, currentValue
	end

	self:Set(player, key, nextValue)
	return true, nextValue
end

return PlayerDataService
