local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = {
	PlayerDataService = require(script.Services.PlayerDataService),
	CurrencyService = require(script.Services.CurrencyService),
	CharacterService = require(script.Services.CharacterService),
	SkinService = require(script.Services.SkinService),
	StoreService = require(script.Services.StoreService),
	SettingsService = require(script.Services.SettingsService),
	StatsService = require(script.Services.StatsService),
}

local REMOTE_NAMES = {
	"RequestBuyCharacter",
	"RequestEquipCharacter",
	"RequestBuySkin",
	"RequestEquipSkin",
	"RequestSetSetting",
	"RequestGetLobbyData",
	"RequestGetProfileStats",
}

local function getOrCreateFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if folder then
		return folder
	end

	folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function getOrCreateRemoteFunction(parent, name)
	local remote = parent:FindFirstChild(name)
	if remote then
		return remote
	end

	remote = Instance.new("RemoteFunction")
	remote.Name = name
	remote.Parent = parent
	return remote
end

local function makeResult(success, message, data)
	return {
		Success = success,
		Message = message,
		Data = data,
	}
end

local function connectRemotes(remotes)
	remotes.RequestBuyCharacter.OnServerInvoke = function(player, characterName)
		if type(characterName) ~= "string" then
			return makeResult(false, "Invalid character.")
		end

		local success, message = Services.StoreService:BuyCharacter(player, characterName)
		return makeResult(success, message)
	end

	remotes.RequestEquipCharacter.OnServerInvoke = function(player, characterName)
		if type(characterName) ~= "string" then
			return makeResult(false, "Invalid character.")
		end

		local success, message = Services.CharacterService:EquipCharacter(player, characterName)
		return makeResult(success, message)
	end

	remotes.RequestBuySkin.OnServerInvoke = function(player, characterName, skinName)
		if type(characterName) ~= "string" or type(skinName) ~= "string" then
			return makeResult(false, "Invalid skin.")
		end

		local success, message = Services.StoreService:BuySkin(player, characterName, skinName)
		return makeResult(success, message)
	end

	remotes.RequestEquipSkin.OnServerInvoke = function(player, characterName, skinName)
		if type(characterName) ~= "string" or type(skinName) ~= "string" then
			return makeResult(false, "Invalid skin.")
		end

		local success, message = Services.SkinService:EquipSkin(player, characterName, skinName)
		return makeResult(success, message)
	end

	remotes.RequestSetSetting.OnServerInvoke = function(player, settingName, value)
		if type(settingName) ~= "string" then
			return makeResult(false, "Invalid setting.")
		end

		local success, message = Services.SettingsService:SetSetting(player, settingName, value)
		return makeResult(success, message)
	end

	remotes.RequestGetLobbyData.OnServerInvoke = function(player)
		return makeResult(true, "Lobby data loaded.", {
			Store = Services.StoreService:GetStoreData(player),
			Settings = Services.SettingsService:GetSettings(player),
			EquippedCharacter = Services.CharacterService:GetEquippedCharacter(player),
		})
	end

	remotes.RequestGetProfileStats.OnServerInvoke = function(player)
		return makeResult(true, "Profile stats loaded.", Services.StatsService:GetFormattedStats(player))
	end
end

Services.PlayerDataService:Init()
Services.CurrencyService:Init(Services)
Services.CharacterService:Init(Services)
Services.SkinService:Init(Services)
Services.StoreService:Init(Services)
Services.SettingsService:Init(Services)
Services.StatsService:Init(Services)

local shared = ReplicatedStorage:WaitForChild("Shared")
local remotesFolder = getOrCreateFolder(shared, "Remotes")
local remotes = {}

for _, remoteName in ipairs(REMOTE_NAMES) do
	remotes[remoteName] = getOrCreateRemoteFunction(remotesFolder, remoteName)
end

connectRemotes(remotes)

-- Future lobby UI should call these RemoteFunctions for shop, skin, settings, and profile screens.
-- These are request/response handlers for the calling player, not broadcast events.
