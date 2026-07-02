local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DrifterConfig = require(ReplicatedStorage.Shared.Configs.DrifterConfig)
local SkinConfig = require(ReplicatedStorage.Shared.Configs.SkinConfig)
local StoreConfig = require(ReplicatedStorage.Shared.Configs.StoreConfig)

local StoreService = {}
StoreService.PlayerDataService = nil
StoreService.DrifterService = nil
StoreService.SkinService = nil

function StoreService:Init(services)
	self.PlayerDataService = services.PlayerDataService
	self.DrifterService = services.DrifterService
	self.SkinService = services.SkinService
end

function StoreService:BuyDrifter(player, drifterName)
	return self.DrifterService:BuyDrifter(player, drifterName)
end

function StoreService:BuySkin(player, drifterName, skinName)
	return self.SkinService:BuySkin(player, drifterName, skinName)
end

function StoreService:GetStoreData(player)
	local drifters = {}
	for drifterName, drifter in pairs(DrifterConfig) do
		drifters[drifterName] = {
			DisplayName = drifter.DisplayName,
			Price = drifter.Price,
			Currency = drifter.Currency,
			Class = drifter.Class,
			Rarity = drifter.Rarity,
			Owned = self.DrifterService:OwnsDrifter(player, drifterName),
			Equipped = self.DrifterService:GetEquippedDrifter(player) == drifterName,
		}
	end

	local skins = {}
	for drifterName, drifterSkins in pairs(SkinConfig) do
		skins[drifterName] = {}
		for skinName, skin in pairs(drifterSkins) do
			skins[drifterName][skinName] = {
				DisplayName = skin.DisplayName,
				Price = skin.Price,
				Currency = skin.Currency,
				Rarity = skin.Rarity,
				Owned = self.SkinService:OwnsSkin(player, drifterName, skinName),
				Equipped = self.SkinService:GetEquippedSkin(player, drifterName) == skinName,
			}
		end
	end

	return {
		Col = self.PlayerDataService:Get(player, "Col") or 0,
		SeedShards = self.PlayerDataService:Get(player, "SeedShards") or 0,
		DrifterTickets = self.PlayerDataService:Get(player, "DrifterTickets") or 0,
		FeaturedDrifters = StoreConfig.FeaturedDrifters,
		FeaturedSkins = StoreConfig.FeaturedSkins,
		Drifters = drifters,
		Skins = skins,
	}
end

return StoreService
