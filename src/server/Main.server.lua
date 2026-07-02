local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = {
	PlayerDataService = require(script.Services.PlayerDataService),
	CurrencyService = require(script.Services.CurrencyService),
	DrifterService = require(script.Services.DrifterService),
	SkinService = require(script.Services.SkinService),
	StoreService = require(script.Services.StoreService),
	SettingsService = require(script.Services.SettingsService),
	StatsService = require(script.Services.StatsService),
	PartyService = require(script.Services.PartyService),
}

local REMOTE_NAMES = {
	"RequestBuyDrifter",
	"RequestEquipDrifter",
	"RequestBuySkin",
	"RequestEquipSkin",
	"RequestSetSetting",
	"RequestGetLobbyData",
	"RequestGetProfileStats",
	"RequestCreateParty",
	"RequestInviteToParty",
	"RequestAcceptPartyInvite",
	"RequestLeaveParty",
	"RequestGetPartyData",
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
	remotes.RequestBuyDrifter.OnServerInvoke = function(player, drifterName)
		if type(drifterName) ~= "string" then
			return makeResult(false, "Invalid drifter.")
		end

		local success, message = Services.StoreService:BuyDrifter(player, drifterName)
		return makeResult(success, message)
	end

	remotes.RequestEquipDrifter.OnServerInvoke = function(player, drifterName)
		if type(drifterName) ~= "string" then
			return makeResult(false, "Invalid drifter.")
		end

		local success, message = Services.DrifterService:EquipDrifter(player, drifterName)
		return makeResult(success, message)
	end

	remotes.RequestBuySkin.OnServerInvoke = function(player, drifterName, skinName)
		if type(drifterName) ~= "string" or type(skinName) ~= "string" then
			return makeResult(false, "Invalid skin.")
		end

		local success, message = Services.StoreService:BuySkin(player, drifterName, skinName)
		return makeResult(success, message)
	end

	remotes.RequestEquipSkin.OnServerInvoke = function(player, drifterName, skinName)
		if type(drifterName) ~= "string" or type(skinName) ~= "string" then
			return makeResult(false, "Invalid skin.")
		end

		local success, message = Services.SkinService:EquipSkin(player, drifterName, skinName)
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
			EquippedDrifter = Services.DrifterService:GetEquippedDrifter(player),
			Party = Services.PartyService:GetPartyData(player),
		})
	end

	remotes.RequestGetProfileStats.OnServerInvoke = function(player)
		return makeResult(true, "Profile stats loaded.", Services.StatsService:GetFormattedStats(player))
	end

	remotes.RequestCreateParty.OnServerInvoke = function(player)
		local success, message = Services.PartyService:CreateParty(player)
		return makeResult(success, message, Services.PartyService:GetPartyData(player))
	end

	remotes.RequestInviteToParty.OnServerInvoke = function(player, targetUserId)
		if type(targetUserId) ~= "number" then
			return makeResult(false, "Invalid player.")
		end

		local targetPlayer = Players:GetPlayerByUserId(targetUserId)
		local success, message = Services.PartyService:InvitePlayer(player, targetPlayer)
		return makeResult(success, message, Services.PartyService:GetPartyData(player))
	end

	remotes.RequestAcceptPartyInvite.OnServerInvoke = function(player, leaderUserId)
		if type(leaderUserId) ~= "number" then
			return makeResult(false, "Invalid invite.")
		end

		local leaderPlayer = Players:GetPlayerByUserId(leaderUserId)
		local success, message = Services.PartyService:AcceptInvite(player, leaderPlayer)
		return makeResult(success, message, Services.PartyService:GetPartyData(player))
	end

	remotes.RequestLeaveParty.OnServerInvoke = function(player)
		local success, message = Services.PartyService:LeaveParty(player)
		return makeResult(success, message, Services.PartyService:GetPartyData(player))
	end

	remotes.RequestGetPartyData.OnServerInvoke = function(player)
		return makeResult(true, "Party data loaded.", Services.PartyService:GetPartyData(player))
	end
end

Services.PlayerDataService:Init()
Services.CurrencyService:Init(Services)
Services.DrifterService:Init(Services)
Services.SkinService:Init(Services)
Services.StoreService:Init(Services)
Services.SettingsService:Init(Services)
Services.StatsService:Init(Services)
Services.PartyService:Init(Services)

local shared = ReplicatedStorage:WaitForChild("Shared")
local remotesFolder = getOrCreateFolder(shared, "Remotes")
local remotes = {}

for _, remoteName in ipairs(REMOTE_NAMES) do
	remotes[remoteName] = getOrCreateRemoteFunction(remotesFolder, remoteName)
end

connectRemotes(remotes)

-- Future client scripts should call these RemoteFunctions for party, shop, skin, settings, and profile screens.
-- These are request/response handlers for the calling player, not broadcast events.
