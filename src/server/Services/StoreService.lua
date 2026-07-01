local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterConfig = require(ReplicatedStorage.Shared.Configs.CharacterConfig)
local SkinConfig = require(ReplicatedStorage.Shared.Configs.SkinConfig)
local StoreConfig = require(ReplicatedStorage.Shared.Configs.StoreConfig)

local StoreService = {}
StoreService.PlayerDataService = nil
StoreService.CharacterService = nil
StoreService.SkinService = nil

function StoreService:Init(services)
	self.PlayerDataService = services.PlayerDataService
	self.CharacterService = services.CharacterService
	self.SkinService = services.SkinService
end

function StoreService:BuyCharacter(player, characterName)
	return self.CharacterService:BuyCharacter(player, characterName)
end

function StoreService:BuySkin(player, characterName, skinName)
	return self.SkinService:BuySkin(player, characterName, skinName)
end

function StoreService:GetStoreData(player)
	local characters = {}
	for characterName, character in pairs(CharacterConfig) do
		characters[characterName] = {
			DisplayName = character.DisplayName,
			Price = character.Price,
			Currency = character.Currency,
			Class = character.Class,
			Rarity = character.Rarity,
			Owned = self.CharacterService:OwnsCharacter(player, characterName),
			Equipped = self.CharacterService:GetEquippedCharacter(player) == characterName,
		}
	end

	local skins = {}
	for characterName, characterSkins in pairs(SkinConfig) do
		skins[characterName] = {}
		for skinName, skin in pairs(characterSkins) do
			skins[characterName][skinName] = {
				DisplayName = skin.DisplayName,
				Price = skin.Price,
				Currency = skin.Currency,
				Rarity = skin.Rarity,
				Owned = self.SkinService:OwnsSkin(player, characterName, skinName),
				Equipped = self.SkinService:GetEquippedSkin(player, characterName) == skinName,
			}
		end
	end

	return {
		Col = self.PlayerDataService:Get(player, "Col") or 0,
		SeedShards = self.PlayerDataService:Get(player, "SeedShards") or 0,
		FeaturedCharacters = StoreConfig.FeaturedCharacters,
		FeaturedSkins = StoreConfig.FeaturedSkins,
		Characters = characters,
		Skins = skins,
	}
end

return StoreService
